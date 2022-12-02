import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb035SettingExpenseType extends StatefulWidget {
  const Scrb035SettingExpenseType({Key? key}) : super(key: key);

  @override
  _Scrb035SettingExpenseTypeState createState() => _Scrb035SettingExpenseTypeState();
}

class _Scrb035SettingExpenseTypeState extends State<Scrb035SettingExpenseType> {
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
        title: Text('Expense Type'),
        actions: [
          TextButton(
              onPressed: () async {
                var str = await AppStyle().confirmData(context, "", "Add") ?? "";

                if (str != "") {
                  obj['expense_type'].add({'name': str.toString(), 'enable': true});
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
                    'ประเภทค่าใช้จ่าย',
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
                      "${obj['expense_type'][index]['name']}",
                    ),
                    subtitle: (obj['expense_type'][index]['is_limit'] ?? false)
                        ? Text(
                            "limit ${obj['expense_type'][index]['limit']} days",
                            style: TextStyle(color: Colors.blue),
                          )
                        : null,
                    trailing: Switch(
                      value: obj['expense_type'][index]['enable'],
                      onChanged: (value) {
                        setState(() {
                          obj['expense_type'][index]['enable'] = value;
                        });
                      },
                    ),
                    onTap: () async {
                      dynamic res = await Navigator.pushNamed(context, '/scrb018', arguments: {'data': obj['expense_type'][index]});
                      if (res != null) {
                        obj['expense_type'][index] = res['data'];
                        setState(() {});
                      }
                    },
                  );
                },
                itemCount: (obj['expense_type'] ?? []).length),

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
                  Navigator.pop(context, {'data': obj['expense_type']});
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
