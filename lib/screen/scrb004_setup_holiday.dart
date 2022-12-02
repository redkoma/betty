import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';
import 'package:intl/intl.dart';

class Scrb004SetupHoliday extends StatefulWidget {
  const Scrb004SetupHoliday({Key? key}) : super(key: key);

  @override
  _Scrb004SetupHolidayState createState() => _Scrb004SetupHolidayState();
}

class _Scrb004SetupHolidayState extends State<Scrb004SetupHoliday> {
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};
  Size size = const Size(10, 10);
  Map obj = {'profile': {}};

  bool loaded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    size = MediaQuery.of(context).size;
    if (!loaded) {
      obj = arguments;
      initData();
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Setting'),
        actions: [
          TextButton(
              onPressed: () async {
                var res0 = await Navigator.pushNamed(context, '/scrb008', arguments: {
                  'data': {'date': DateTime.now(), 'enable': true, 'name': ''}
                });
                if (res0 != null) {
                  Map<String, dynamic> res = res0 as Map<String, dynamic>;
                  obj['holiday'].add(res['data']);
                  setState(() {});
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                    'ตั้งค่าวันหยุดประจำปี',
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

            ListView.separated(
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "${obj['holiday'][index]['name']}",
                    ),
                    subtitle: Text(
                      "${DateFormat("dd MMM").format(obj['holiday'][index]['date'])}",
                    ),
                    trailing: Switch(
                      value: obj['holiday'][index]['enable'],
                      onChanged: (value) {
                        setState(() {
                          obj['holiday'][index]['enable'] = value;
                        });
                      },
                    ),
                    onTap: () async {
                      var res0 = await Navigator.pushNamed(context, '/scrb008', arguments: {'data': obj['holiday'][index]});
                      if (res0 != null) {
                        Map<String, dynamic> res = res0 as Map<String, dynamic>;
                        obj['holiday'][index] = res['data'];
                        setState(() {});
                      }
                    },
                  );
                },
                itemCount: (obj['holiday'] ?? []).length),
            // Expanded(child: Container()),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
                child: Text(
                  'Save Setting',
                  style: TextStyle(
                    fontSize: AppStyle().btnFontSize,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context, {'department': obj['holiday']});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> initData() async {
    setState(() {});
  }
}
