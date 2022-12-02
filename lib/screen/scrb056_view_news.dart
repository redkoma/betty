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

class Scrb056ViewNews extends StatefulWidget {
  const Scrb056ViewNews({Key? key}) : super(key: key);

  @override
  _Scrb056ViewNewsState createState() => _Scrb056ViewNewsState();
}

class _Scrb056ViewNewsState extends State<Scrb056ViewNews> {
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
          ListTile(
            title: Text('${obj['data']['subject']}'),
            subtitle: Text('${obj['data']['short_description']}'),
          ),
          ListTile(
            title: Text('${obj['data']['url'] ?? ''}'),
            subtitle: Text('${obj['data']['description']}'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Builder(builder: (context) {
              List<Widget> photoList = [];

              for (var i = 0; i < (obj['images'] ?? []).length; i++) {
                photoList.add(InkWell(
                  onTap: () async {
                    var res = await Navigator.pushNamed(context, '/util102', arguments: {'images': obj['images'], 'index': i});
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
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
        ]),
      ),
    );
  }

  void initData() {}
}
