import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb017SelectUser extends StatefulWidget {
  const Scrb017SelectUser({Key? key}) : super(key: key);

  @override
  _Scrb017SelectUserState createState() => _Scrb017SelectUserState();
}

class _Scrb017SelectUserState extends State<Scrb017SelectUser> {
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};
  Size size = const Size(10, 10);
  Map obj = {'profile': {}};
  dynamic res;
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
        title: Text('Please Select'),
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
                    'เลือกผู้อนุมัติ',
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
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage("${obj['data'][index]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                    ),
                    title: Text(
                      "${obj['data'][index]['userinfo']['displayName'] ?? obj['data'][index]['userinfo']['email']}",
                    ),
                    subtitle: Text(
                      "${obj['data'][index]['userinfo']['email']}",
                    ),
                    onTap: () {
                      res = obj['data'][index];
                      Navigator.pop(context, {'data': res});
                    },
                  );
                },
                itemCount: (obj['data'] ?? []).length),

            // Expanded(child: Container()),
            // Container(
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
            //     child: Text(
            //       'Save Setting',
            //       style: TextStyle(
            //         fontSize: AppStyle().btnFontSize,
            //       ),
            //     ),
            //     onPressed: () async {
            //       Navigator.pop(context, {'data': res});
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Future<void> initData() async {
    setState(() {});
  }
}
