import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb015SettingLeaveDepartmentManager extends StatefulWidget {
  const Scrb015SettingLeaveDepartmentManager({Key? key}) : super(key: key);

  @override
  _Scrb015SettingLeaveDepartmentManagerState createState() => _Scrb015SettingLeaveDepartmentManagerState();
}

class _Scrb015SettingLeaveDepartmentManagerState extends State<Scrb015SettingLeaveDepartmentManager> {
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
        title: Text('Department Manager'),
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
                    'ตั้งผู้อนุมัติในแผนก',
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
                separatorBuilder: (BuildContext context, int index) => Container(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return (obj['data'][index]['enable'] ?? false)
                      ? ListTile(
                          title: Text(
                            "${obj['data'][index]['name']}",
                          ),
                          subtitle: (obj['data'][index]['manager'] == null)
                              ? Text(
                                  "Please select",
                                  style: TextStyle(color: Colors.red),
                                )
                              : Text(
                                  "${obj['data'][index]['manager'] ?? ''}",
                                  style: TextStyle(color: Colors.blue),
                                ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            var userdep = [];
                            for (var i = 0; i < (obj['users'] ?? []).length; i++) {
                              if (obj['users'][i]['department'] == obj['data'][index]['name']) {
                                userdep.add(obj['users'][i]);
                              }
                            }
                            dynamic res = await Navigator.pushNamed(context, '/scrb017', arguments: {'data': userdep});
                            if (res != null) {
                              obj['data'][index]['manager'] = res['data']['userinfo']['displayName'] ?? res['data']['userinfo']['email'];
                              obj['data'][index]['managerinfo'] = res['data']['userinfo'];
                              setState(() {});
                            }
                          },
                        )
                      : Container();
                },
                itemCount: (obj['data'] ?? []).length),

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
    obj['users'] = [];
    AppStyle().session['company']['members'].forEach((key, value) {
      value['uid'] = key;
      value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
      obj['users'].add(value);
    });

    setState(() {});
  }
}
