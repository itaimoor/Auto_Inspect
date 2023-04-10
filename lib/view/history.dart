import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  var orange = Colors.orange[900];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("History"),
      ),
      body: StreamBuilder<dynamic>(
        stream: FirebaseFirestore.instance.collection("Images").snapshots(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(orange),
              ),
            );
          } else if (snapshot.data!.docs.length < 1) {
            return Center(
              child: Text("No Images Found"),
            );
          } else {
            var data = snapshot.data!.docs;

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10),
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      MultiImageProvider multiImageProvider =
                          MultiImageProvider([
                        Image.network(data[index]['imgLink']).image,
                      ]);

                      showImageViewerPager(context, multiImageProvider,
                          onPageChanged: (page) {
                        print("page changed to $page");
                      }, onViewerDismissed: (page) {
                        print("dismissed while on page $page");
                      });
                      // Get.to(
                      //         () => Product(
                      //       productModel: productModel,
                      //     ),
                      //     transition: Transition.rightToLeft,
                      //     duration: Duration(milliseconds: 500));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Ink(
                        height: context.height * .2,
                        width: context.width * 0.45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // image:
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            data[index]['imgLink'],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.4),
                                  color: orange,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ));
              },
            );
          }
        },
      ),
    );
  }
}
