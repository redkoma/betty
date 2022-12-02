import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Util101SelectDate extends StatefulWidget {
  const Util101SelectDate({Key? key}) : super(key: key);

  @override
  _Util101SelectDateState createState() => _Util101SelectDateState();
}

class _Util101SelectDateState extends State<Util101SelectDate> {
  AppStyle appStyle = AppStyle();
  Map arguments = {};

  Map obj = {'profile': {}};

  bool loaded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;

    if (!loaded) {
      obj = arguments;
      initData();
      if (obj['date'] == null) {
        obj['date'] = DateTime.now();
      }
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${obj['title'] ?? ''}'),
        backgroundColor: (obj['barcolor'] != null) ? obj['barcolor'] : null,
      ),
      body: Column(
        children: [
          Container(
            height: 350,
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            child: CupertinoDatePicker(
              mode: (obj['datetime'] == 'Y') ? CupertinoDatePickerMode.dateAndTime : CupertinoDatePickerMode.date,
              initialDateTime: obj['date'],
              use24hFormat: true,
              minimumDate: obj['minDate'],
              onDateTimeChanged: (DateTime newDateTime) {
                // Do something
                obj['date'] = newDateTime;
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
              child: Text(
                AppStyle().tr('Confirm'),
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context, obj['date']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initData() async {
    setState(() {});
  }
}
