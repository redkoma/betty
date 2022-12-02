import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb046FormOKR extends StatefulWidget {
  const Scrb046FormOKR({Key? key}) : super(key: key);

  @override
  _Scrb046FormOKRState createState() => _Scrb046FormOKRState();
}

class _Scrb046FormOKRState extends State<Scrb046FormOKR> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
  bool readonly = true;
  String key_type = 'memo_type';

  DateTime create_date = DateTime.now();
  DateTime payout_date = DateTime.now();
  String memo_subject = "";
  String memo_type = '';
  String memo_remark = '';
  bool memo_forward = false;
  List images = [];
  List user_list = [];
  TextEditingController startController = TextEditingController();
  TextEditingController targetController = TextEditingController();
  TextEditingController currentController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
//      calcTimesheetStat(myyear, mymonth);
      currentController.text = obj['doc']['current'].toString();
      startController.text = obj['doc']['start'].toString();
      targetController.text = obj['doc']['target'].toString();
      subjectController.text = obj['doc']['title'];
      initData();

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 190, 0, 0),
        title: Text(
          "OKR",
          style: TextStyle(fontSize: 15),
        ),
      ),
      backgroundColor: AppStyle().mainBgColor,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
            width: size.width,
            height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OKR',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  'Betty',
                  style: TextStyle(
                    fontFamily: "Sriracha",
                    fontSize: 30,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: subjectController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'เรื่อง',
                    labelText: 'เรื่อง',
                  ),
                  onChanged: (val) {
                    setState(() {
                      obj['doc']['title'] = subjectController.text;
                    });
                  },
                ),
                Divider(height: 1),
                TextField(
                  controller: startController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'Start',
                    labelText: 'Start',
                  ),
                  onChanged: (val) {
                    setState(() {
                      obj['doc']['start'] = double.parse(startController.text);
                    });
                  },
                ),
                Divider(height: 1),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'Target',
                    labelText: 'Target',
                  ),
                  onChanged: (val) {
                    setState(() {
                      obj['doc']['target'] = double.parse(targetController.text);
                    });
                  },
                ),
                Divider(height: 1),
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'Current',
                    labelText: 'Current',
                  ),
                  onChanged: (val) {
                    setState(() {
                      obj['doc']['current'] = double.parse(currentController.text);
                    });
                  },
                ),
                Divider(height: 1),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: Colors.brown),
              child: Text(
                'Update',
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context, obj['doc']);
              },
            ),
          ),
        ]),
      ),
    );
  }

  void initData() async {}
}
