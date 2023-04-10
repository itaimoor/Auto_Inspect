import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Faulty extends StatefulWidget {
  final decodeImage;
  const Faulty({Key? key, required this.decodeImage}) : super(key: key);

  @override
  State<Faulty> createState() => _FaultyState();
}

class _FaultyState extends State<Faulty> {
  var orange = Colors.orange[900];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, // change color here
        ),
        title: Text(
          'Faulty Instrument',
          style: TextStyle(color: Colors.red),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    MultiImageProvider multiImageProvider = MultiImageProvider([
                      Image.memory(widget.decodeImage).image,
                    ]);

                    showImageViewerPager(context, multiImageProvider,
                        onPageChanged: (page) {
                      print("page changed to $page");
                    }, onViewerDismissed: (page) {
                      print("dismissed while on page $page");
                    });
                  },
                  child: Container(
                    height: context.height * 0.5,
                    child: Image.memory(widget.decodeImage),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(10),
                // constraints: BoxConstraints(maxHeight: context.height * .35),
                width: context.width,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Results",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20),
                      buildResultTile("Faulty", "Yes"),
                      Divider(),
                      buildResultTile("Fault Type", "-"),
                      Divider(),
                      buildResultTile("Faults Count", "-"),
                      Divider(),
                      buildResultTile("Confidence", "86.5%"),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
