import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:betty/util/style.dart';

class Scrb032EditNews extends StatefulWidget {
  const Scrb032EditNews({Key? key}) : super(key: key);

  @override
  _Scrb032EditNewsState createState() => _Scrb032EditNewsState();
}

class _Scrb032EditNewsState extends State<Scrb032EditNews> {
  Map arguments = {};

  Map obj = {'data': {}};
  int selIndex = 0;
  Size size = const Size(1, 1);
  bool loaded = false;
  @override
  void initState() {
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController shortDescController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      initData();
      if (obj['data'] == null) {
        obj['images'] = [];
        obj['data'] = {
          'subject': '',
          'description': '',
          'short_description': '',
          'images': [],
          'url': '',
        };
      } else {
        obj['images'] = List.from(obj['data']['images'] ?? []);
      }
      nameController.text = obj['data']['subject'];
      descController.text = obj['data']['description'];
      shortDescController.text = obj['data']['short_description'];
      urlController.text = obj['data']['url'];
      loaded = true;
      setState(() {});
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News information",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(
            height: 120,
            width: size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 194, 223, 237),
              image: (obj['data']!['cover'] == null)
                  ? null
                  : DecorationImage(
                      image: CachedNetworkImageProvider(obj['data']['cover']),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () async {
                        setState(() {
                          obj['data']['cover'] = null;
                        });
                      },
                      child: Stack(
                        children: [
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 16,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = const Color.fromARGB(198, 255, 255, 255),
                            ),
                          ),
                          const Text('Clear',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              )),
                        ],
                      )),
                  TextButton(
                      onPressed: () async {
                        var image = await AppStyle().browseImageBase64(1024, 1024, 90);
                        if (image['base64'] != '') {
                          AppStyle().showSnackBar(context, "Uploading ... ", Colors.amber);
                          final storageRef = FirebaseStorage.instance.ref();
                          final postImagesRef = storageRef.child("users/" + AppStyle().session['user'].uid + "/images/newsCover_" + image['name'].toString());
                          try {
                            await postImagesRef.putString(image['base64'].toString(), format: PutStringFormat.base64);
                            String url = await postImagesRef.getDownloadURL();
                            setState(() {
                              obj['data']['cover'] = url;
                            });
                          } on FirebaseException catch (e) {
                            // print(e);
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          Text(
                            'Change cover photo',
                            style: TextStyle(
                              fontSize: 16,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = const Color.fromARGB(198, 255, 255, 255),
                            ),
                          ),
                          const Text('Change cover photo',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                        ],
                      )),
                ],
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              //   decoration: const BoxDecoration(
              //     color: Color.fromARGB(157, 0, 0, 0),
              //   ),
              //   child: Row(
              //     children: [
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "${obj['data']['subject']}",
              //             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              //           ),
              //           Text(
              //             "${obj['data']['description']}",
              //             style: const TextStyle(fontSize: 16, color: Colors.white),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ]),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Builder(builder: (context) {
              List<Widget> photoList = [];
              photoList.add(InkWell(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () async {
                                  AppStyle().showLoader(context);

                                  final ImagePicker _picker = ImagePicker();
                                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400, imageQuality: 70);
                                  // print(image);
                                  if (image != null) {
                                    setState(() {
                                      //           setState2(() {
                                      obj['images'].add(image);
                                      //         });
                                    });

                                    final storageRef = FirebaseStorage.instance.ref();
                                    final postImagesRef = storageRef.child("users/" + AppStyle().session['user'].uid + "/images/news_" + image.name);
                                    try {
                                      final bytes = File(image.path).readAsBytesSync();

                                      await postImagesRef.putString(base64Encode(bytes).toString(), format: PutStringFormat.base64);
                                      String url = await postImagesRef.getDownloadURL();
                                      if (url != null) {
                                        setState(() {
                                          //           setState2(() {
                                          obj['data']['images'].add(url);
                                          if ((obj['data']['cover'] == null) || (obj['data']['cover'] == '')) {
                                            obj['data']['cover'] = url;
                                          }
                                          //         });
                                        });
                                      } else {
                                        print("Error");
                                      }
                                      AppStyle().hideLoader(context);
                                    } on FirebaseException catch (e) {
                                      // print(e);
                                      AppStyle().hideLoader(context);
                                    }
                                  } else {
                                    AppStyle().hideLoader(context);
                                  }
                                },
                                leading: Icon(Icons.photo_outlined),
                                title: Text(
                                  "Photo Library",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.video_collection_outlined),
                                title: Text(
                                  "Video Library",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_camera_outlined),
                                title: Text(
                                  "Camera",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.video_camera_back_outlined),
                                title: Text(
                                  "Video",
                                ),
                              ),
                            ],
                          );
                        });
                      });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: Color.fromARGB(255, 150, 177, 191)),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ));

              for (var i = 0; i < (obj['images'] ?? []).length; i++) {
                photoList.add(Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ((obj['images'][i] is String)
                          ? NetworkImage(obj['images'][i])
                          : (obj['images'][i] is XFile)
                              ? FileImage(File(obj['images'][i].path))
                              : NetworkImage(obj['images'][i]['cover'])) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              obj['images'].removeAt(i);
                              obj['data']['images'].removeAt(i);
                              setState(() {});
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ))
                    ],
                  ),
                ));
              }
              return Container(
                height: 100,
                child: Row(
                  children: photoList,
                ),
              );
            }),
          ),

          TextField(
            controller: nameController,
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Subject',
              labelText: 'Subject',
            ),
            onChanged: (val) {
              setState(() {
                obj['data']['subject'] = nameController.text;
              });
            },
          ),
          TextField(
            controller: shortDescController,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Short Description',
              labelText: 'Short Description',
            ),
            onChanged: (val) {
              setState(() {
                obj['data']['short_description'] = shortDescController.text;
              });
            },
          ),
          TextField(
            controller: descController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 5,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Description',
              labelText: 'Description',
            ),
            onChanged: (val) {
              setState(() {
                obj['data']['description'] = descController.text;
              });
            },
          ),
          TextField(
            controller: urlController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Url [link to web site]',
              labelText: 'Url [link to web site]',
            ),
            onChanged: (val) {
              setState(() {
                obj['data']['url'] = urlController.text;
              });
            },
          ),

          // ListTile(
          //   tileColor: Color(0xFFEEEEEE),
          //   title: Text(
          //     '${obj['data']['category']}',
          //     style: TextStyle(color: AppStyle().textColor),
          //   ),
          //   subtitle: Text('Category'),
          //   trailing: Icon(Icons.arrow_forward_ios_outlined),
          //   onTap: () async {
          //     var res = await Navigator.pushNamed(context, '/scr024', arguments: {'list': AppStyle().list_shop_category, 'key': 'name', 'select': obj['data']['category']});
          //     if (res != null) {
          //       setState(() {
          //         var res2 = res as Map<String, dynamic>;
          //         obj['data']['category'] = res2['name'];
          //       });
          //     }
          //   },
          // ),

          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
              child: Text(
                AppStyle().tr('Update'),
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                obj['data']['uid'] = AppStyle().session['data']['uid'];
                obj['data']['companyId'] = AppStyle().session['company']['uid'];
                if (obj['data']['id'] == null) {
                  await FirebaseFirestore.instance.collection('news').add(obj['data']).then((value) {
                    setState(() {
                      obj['data']['id'] = value.id;
                    });
                  });
                  Navigator.pop(context, obj['data']);
                } else {
                  await FirebaseFirestore.instance.collection('news').doc(obj['data']['id']).set(obj['data'], SetOptions(merge: true));
                  Navigator.pop(context, obj['data']);
                }
              },
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ]),
      ),
    );
  }

  void initData() {}
}
