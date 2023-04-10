import 'dart:async';
import 'dart:io';
import 'package:auto_inspect/view/faulty.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

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
  loadModel() async {
    String? res = await Tflite.loadModel(
        model: "flutter_assets/assets/model.tflite",
        labels: "flutter_assets/assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  runModel(File pathfile) async {
    String? res = await Tflite.loadModel(
        model: "flutter_assets/assets/model.tflite",
        labels: "flutter_assets/assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );

    var recognitions = await Tflite.runModelOnImage(
        path: pathfile.path,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.35, // defaults to 0.1
        asynch: true // defaults to true
        );

    var result = "";

    recognitions!.forEach((response) {
      result += response["label"] +
          " " +
          (response['confidence'] as double).toStringAsFixed(2) +
          "\n\n";
    });

    print("printing results...........");
    print(result);
  }

  var orange = Colors.orange[900];
  var galleryPicController = picController();

  var loading = ObsController();
  var darkModeController = DarkModeController();
  bool darkmode = true;

  File? myImg;

  var decodeImage;

  @override
  void initState() {
    super.initState();
    loadModel();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.height * 0.02,
                    vertical: context.height * 0.02),
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
                          padding: EdgeInsets.all(10),
                          height: context.height * .7,
                          width: context.width,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
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
                                        // setState(() {});
                                      },
                                      child:
                                          buildButtonTile(context, "Gallery"),
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
                                        File(
                                            galleryPicController.picPath.value),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 40),
                      // Container(
                      //   padding: EdgeInsets.all(10),
                      //   constraints:
                      //       BoxConstraints(maxHeight: context.height * .35),
                      //   width: context.width,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.withOpacity(0.2),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: SingleChildScrollView(
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           "Results",
                      //           style: GoogleFonts.poppins(
                      //             fontSize: 20,
                      //             color: orange,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //         SizedBox(height: 20),
                      //         buildResultTile("Faulty", "Yes"),
                      //         Divider(),
                      //         buildResultTile("Faults Count", "4"),
                      //         Divider(),
                      //         buildResultTile("Confidence", "60"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //         buildResultTile("Accuracy", "98%"),
                      //         Divider(),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: context.height * 0.02,
                vertical: context.height * 0.02),
            child: Align(
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
                            loading.loadingContent("Uploading Picture...");

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
            ),
          )
        ],
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
      var responseData = await response.stream.bytesToString();
      decodeImage = base64.decode(responseData);

      Get.to(
        () => Faulty(
          decodeImage: decodeImage,
        ),
        transition: Transition.rightToLeft,
      );

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

  Future<File> drawRectangle(
      File imageFile, int x, int y, int width, int height) async {
    // Read the image from the file
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      // Draw the rectangle on the image
      img.drawRect(image, x, y, width, height, img.getColor(255, 0, 0));

      // Save the modified image to a new file
      final newFile = File('${imageFile.path}_rect.jpg');
      await newFile.writeAsBytes(img.encodeJpg(image));

      return newFile;
    } else {
      throw Exception('Failed to read image.');
    }
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
