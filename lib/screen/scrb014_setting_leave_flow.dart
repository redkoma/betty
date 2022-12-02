import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb014SettingLeaveFlow extends StatefulWidget {
  const Scrb014SettingLeaveFlow({Key? key}) : super(key: key);

  @override
  _Scrb014SettingLeaveFlowState createState() => _Scrb014SettingLeaveFlowState();
}

class _Scrb014SettingLeaveFlowState extends State<Scrb014SettingLeaveFlow> {
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
        title: Text('Workflow'),
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
                    'เลือกรูปแบบการอนุมัติ',
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
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "${obj['workflow'][index]['displayName']}",
                    ),
                    subtitle: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Image.asset(
                          obj['workflow'][index]['cover'],
                          height: size.height * 0.3,
                        )),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.check_circle,
                        color: (obj['data']['code'] == obj['workflow'][index]['code']) ? Colors.green : Colors.white,
                      ),
                    ),
                    onTap: () {
                      obj['data'] = obj['workflow'][index];
                      setState(() {});
                    },
                  );
                },
                itemCount: (obj['workflow'] ?? []).length),

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
                  Navigator.pop(context, {'data': obj['data']});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> initData() async {
    obj['workflow'] = [
      {
        'displayName': 'Single Approval [HR]',
        'code': 'l1',
        'cover': 'assets/images/leave_setting_001.png',
      },
      {
        'displayName': 'Double Approval [Manager & HR]',
        'code': 'l2',
        'cover': 'assets/images/leave_setting_002.png',
      }
    ];
    if (obj['data'] == null) {
      obj['data'] = obj['workflow'][0];
    }
    setState(() {});
  }
}
