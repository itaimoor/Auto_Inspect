import 'dart:async';
import 'dart:io';
import 'package:auto_inspect/view/calibration.dart';
import 'package:auto_inspect/view/faulty.dart';

import 'package:auto_inspect/controller/obsController.dart';
import 'package:auto_inspect/controller/selectImageController.dart';
import 'package:auto_inspect/view/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var orange = Colors.orange[900];
  var galleryPicController = picController();

  var loading = ObsController();
  var darkModeController = DarkModeController();
  bool darkmode = true;

  File? myImg;

  var decodeImage;

  var color = Colors.grey.withOpacity(0.2);

  var calibration = false.obs;

  TextEditingController calib = TextEditingController();

  @override
  void initState() {
    calib.text = '0.10366111849170036';
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Auto Inspect"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.dark_mode,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(
                () {
                  if (darkmode) {
                    darkmode = false;
                    Get.changeThemeMode(ThemeMode.dark);
                  } else {
                    darkmode = true;

                    Get.changeThemeMode(ThemeMode.light);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Get.to(
                () => History(),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Get Started",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 0.9),
                    ),
                    SizedBox(height: 25),
                    Obx(
                      () => Container(
                        height: context.height * .5,
                        width: context.width,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () async {
                            Get.defaultDialog(
                                title: "Source",
                                middleText: "Select Image Source",
                                actions: [
                                  InkWell(
                                    onTap: () async {
                                      await galleryPicController
                                          .selectFromCamera(context);
                                      Get.back();
                                      // setState(() {});
                                    },
                                    child: buildButtonTile(context, "Camera"),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await galleryPicController
                                          .selectFromGallery(context);
                                      Get.back();
                                      if (galleryPicController
                                          .picPath.isNotEmpty) {
                                        color = Colors.transparent;
                                      }
                                      // setState(() {});
                                    },
                                    child: buildButtonTile(context, "Gallery"),
                                  ),
                                ]);
                          },
                          child: (galleryPicController.picPath.isEmpty)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 70),
                                    SizedBox(height: 5),
                                    Text(
                                      "Upload Image for",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Magic",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: InteractiveViewer(
                                    child: Image.file(
                                      File(galleryPicController.picPath.value),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              value: calibration.value,
              activeColor: orange,
              title: Text(
                "Configure Calibration Scale",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              secondary: Icon(
                Icons.edit,
                color: orange,
                size: 25,
              ),
              onChanged: (bool value) {
                calibration(value);
                setState(() {});
              },
            ),
          ),
          if (calibration.value) SizedBox(height: 10),
          if (calibration.value)
            inputField('Calibration', '0.1234', calib, Icons.camera, false,
                TextInputType.number),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => loading.isLoading.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(orange),
                        ),
                        SizedBox(width: 20),
                        Text(loading.loadingContent.value)
                      ],
                    )
                  : InkWell(
                      onTap: () async {
                        if (galleryPicController.picPath.isEmpty) {
                          Get.snackbar("No Picture Selected",
                              "Please Select a picture to start the process");
                        } else {
                          loading.isLoading(true);
                          loading.loadingContent("Fetching Results...");

                          await uploadImage(
                              File(galleryPicController.picPath.value));

                          // myImg = await drawRectangle(
                          //     File(galleryPicController.picPath.value),
                          //     10,
                          //     10,
                          //     100,
                          //     100);
                          //
                          // loaded = true;

                          setState(() {});
                          //abc

                          // var fileName =
                          //     basename(galleryPicController.picPath.value);
                          // var des = 'images/$fileName';
                          // Reference ref =
                          //     FirebaseStorage.instance.ref().child(des);
                          // await ref.putFile(
                          //     File(galleryPicController.picPath.value));
                          // String picLink = await ref.getDownloadURL();
                          //
                          // loading.loadingContent("Logging Picture...");
                          //
                          // CollectionReference Cref = await FirebaseFirestore
                          //     .instance
                          //     .collection("Images");
                          // Map<String, String?> data = {
                          //   "imgLink": picLink,
                          // };
                          // await Cref.add(data);
                          loading.isLoading(false);
                          // Get.snackbar(
                          //     "Picture Saved", "Picture store in database");
                        }
                      },
                      child: buildButtonTile(context, "Process")),
            ),
          )
        ],
      ),
    );
  }

  TextFormField inputField(
    var label,
    var hint,
    var controller,
    var icon,
    var obscure,
    var keyboardType,
  ) {
    return TextFormField(
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      obscureText: obscure,
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        labelStyle: GoogleFonts.poppins(fontSize: 16),
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
          gapPadding: 10,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.transparent),
          gapPadding: 10,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IconButton(
            icon: Icon(
              icon,
            ),
            onPressed: () async {
              double x = await Get.to(
                () => Calibration(),
                transition: Transition.rightToLeft,
              );
              print('val=$x');
              if (x != 0) {
                Get.snackbar(
                    'Camera calibration Successful', 'Calibration Factor:$x');
                calib.text = x.toString();
              } else {
                Get.snackbar('Failed', 'Calibration Factor cannot be 0');
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> uploadImage(File imageFile) async {
    // Create a multipart request

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://saqib0494.pythonanywhere.com/'));

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    // Send the request
    var response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 202) {
      var responseData = await response.stream.bytesToString();
      print(responseData);
      Get.snackbar(
          "No Defects", "No Defect Detected in the Surgical Instrument");
    } else if (response.statusCode == 203) {
      print('Defect Found');
      var responseData = await http.Response.fromStream(response);

      final result = jsonDecode(responseData.body) as Map<String, dynamic>;
      decodeImage = base64.decode(result['image']);

      String text = result['text'];
      text = text.replaceAll('[', '');
      text = text.replaceAll(']', '');
      text = text.replaceAll('\'', '');
      text = text.replaceAll(' ', '');

      List results = text.split(',');

      int count = 0;

      List<List> finalresults = [[]];
      List row = [];
      for (int i = 0; i < results.length; i++) {
        row.add(results[i]);
        count += 1;

        if (count == 3) {
          count = 0;
          print(row);
          finalresults.add(row);
          row = [];
        }
      }

      print(finalresults);

      // print(result['text']);

      double val = double.parse(calib.text.trim());
      if (finalresults.length > 1) {
        Get.to(
          () => Faulty(
            decodeImage: decodeImage,
            results: finalresults,
            calib: val,
          ),
          transition: Transition.rightToLeft,
        );
      } else {
        Get.snackbar(
            "No Defects", "No Defect Detected in the Surgical Instrument");
      }

      // Do something with the decoded image, like displaying it in a widget
      // For example, you could use the image in a `Container` widget like this:
    }
    // // Check if the request was successful
    // if (response.statusCode == 200) {
    //   // Handle the response data here
    //
    //   var responseData = await response.stream.bytesToString();
    //
    //   print(responseData);
    // } else {
    //   // Handle errors here
    //   print(response.statusCode);
    //
    //
    //   // print(response.stream.)
    //   // var responseData = await response.stream.bytesToString();
    //   // // var image = Image.memory(responseData);
    //   // // print('width');
    //   // // print(image.width);
    //   //
    //   // print('data');
    //   // print(responseData);
    //
    //   // print('Error: ${response.statusCode}');
    // }
  }

  Row buildResultTile(String feature, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          feature,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 10),
        Text("|"),
        SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: orange,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Container buildButtonTile(BuildContext context, var title) {
    return Container(
      height: 55,
      width: context.width,
      decoration: BoxDecoration(
        color: orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
          child: Text(
        title,
        style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 0.9),
      )),
    );
  }
}
