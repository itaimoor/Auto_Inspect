import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Faulty extends StatefulWidget {
  final decodeImage;
  final List<List> results;

  final double calib;
  const Faulty(
      {Key? key,
      required this.decodeImage,
      required this.results,
      required this.calib})
      : super(key: key);

  @override
  State<Faulty> createState() => _FaultyState();
}

class _FaultyState extends State<Faulty> {
  var orange = Colors.orange[900];

  bool showResults = false;
  String showresultlabel = 'Show Results';

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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Image.memory(widget.decodeImage),
                ),
              ),
            ),
            SizedBox(height: 40),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: context.height * 0.7,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              // constraints: BoxConstraints(maxHeight: context.height * .35),
                              width: context.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Total Faults : ${widget.results.length - 1}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  for (int i = 1;
                                      i < widget.results.length;
                                      i++)
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  // Container(
                                                  //   width: context.width * 0.1,
                                                  //   child: Text('No.${i} '),
                                                  // ),
                                                  Column(
                                                    children: [
                                                      buildResultTile(
                                                          'Fault type',
                                                          widget.results[i][0]
                                                              .toString()),
                                                      buildResultTile(
                                                          "Confidence",
                                                          '${(double.parse(widget.results[i][1].toString()) * 100).toStringAsFixed(2)} %'),
                                                      buildResultTile(
                                                          "Fault Length",
                                                          '${(double.parse(widget.results[i][2]) * widget.calib).toStringAsFixed(2)} mm'),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5)
                                      ],
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    });
                // showResults = !showResults;
                // if (showResults) {
                //   showresultlabel = 'Hide Results';
                // } else {
                //   showresultlabel = 'Show Results';
                // }
                // setState(() {});
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 55,
                width: context.width,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                    child: Text(
                  showresultlabel,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 0.9),
                )),
              ),
            )
          ],
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
