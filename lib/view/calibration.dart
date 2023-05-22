import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/selectImageController.dart';

import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;

class Calibration extends StatefulWidget {
  const Calibration({Key? key}) : super(key: key);

  @override
  State<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  var galleryPicController = picController();
  var orange = Colors.orange[900];

  TextEditingController calib = TextEditingController();
  var calibration = false.obs;

  var loading = false.obs;

  var imgloaded = false.obs;
  var color = Colors.grey.withOpacity(0.2);

  @override
  void initState() {
    calib.text = '20';
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, // change color here
        ),
        title: Text('Calibration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Obx(
              () => Container(
                // padding: EdgeInsets.all(10),
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
                              if (galleryPicController.picPath.isNotEmpty) {
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
                            Icon(Icons.camera, size: 70),
                            SizedBox(height: 5),
                            Text(
                              "Upload Image for",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Calibration",
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
                  "Set Diameter of the Coin",
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
              inputField('Enter Diameter of the Coin', 'Eg. 20', calib,
                  Icons.edit, false, TextInputType.number),
            SizedBox(height: 10),
            Obx(() => loading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(orange),
                      ),
                      SizedBox(width: 20),
                      Text('Loading')
                    ],
                  )
                : InkWell(
                    onTap: () async {
                      if (galleryPicController.picPath.isEmpty) {
                        Get.snackbar("No Picture Selected",
                            "Please Select a picture to start the process");
                      } else {
                        loading(true);
                        await uploadImage(
                            File(galleryPicController.picPath.value));
                        loading(false);
                      }
                    },
                    child: buildButtonTile(context, "Process"))),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.priority_high,
                  size: 15,
                ),
                Text('Ensure that the image contains a coin of known diameter')
              ],
            )
          ],
        ),
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
            onPressed: () {},
          ),
        ),
      ),
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

  Future<void> uploadImage(File imageFile) async {
    // Create a multipart request

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://saqib0494.pythonanywhere.com/calibration/'));

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    // Send the request
    var response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 203) {
      var responseData = await http.Response.fromStream(response);

      String val = responseData.body.toString();
      double result = double.parse(val);
      print('received $val');
      // final result = jsonDecode(responseData.body) as double;
      //

      if (calib.text.trim().isEmpty) {
        calib.text = '0';
      }
      double newR = double.parse(calib.text.trim()) / result;

      print(newR);
      Get.back(result: newR);

      // decodeImage = base64.decode(result['image']);
      //
      // String text = result['text'];
      // text = text.replaceAll('[', '');
      // text = text.replaceAll(']', '');
      // text = text.replaceAll('\'', '');
      // text = text.replaceAll(' ', '');
      //
      // List results = text.split(',');
      //
      // int count = 0;
      //
      // List<List> finalresults = [[]];
      // List row = [];
      // for (int i = 0; i < results.length; i++) {
      //   row.add(results[i]);
      //   count += 1;
      //
      //   if (count == 3) {
      //     count = 0;
      //     print(row);
      //     finalresults.add(row);
      //     row = [];
      //   }
      // }
      //
      // print(finalresults);
      //
      // // print(result['text']);
      //
      // double val = double.parse(calib.text.trim());
      // if (finalresults.length > 1) {
      //   Get.to(
      //         () => Faulty(
      //       decodeImage: decodeImage,
      //       results: finalresults,
      //       calib: val,
      //     ),
      //     transition: Transition.rightToLeft,
      //   );
      // } else {
      //   Get.snackbar(
      //       "No Defects", "No Defect Detected in the Surgical Instrument");
      // }

      // Do something with the decoded image, like displaying it in a widget
      // For example, you could use the image in a `Container` widget like this:
    }
  }
}
