import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';
import 'package:intl/intl.dart';

class Scrb001SetupCompany extends StatefulWidget {
  const Scrb001SetupCompany({Key? key}) : super(key: key);

  @override
  _Scrb001SetupCompanyState createState() => _Scrb001SetupCompanyState();
}

class _Scrb001SetupCompanyState extends State<Scrb001SetupCompany> {
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
      appBar: AppBar(title: Text('Company Setting')),
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
                    'ตั้งค่าเกี่ยวกับบริษัท',
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
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              maxLines: null,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFEEEEEE),
                hintText: 'Company Name',
                labelText: 'Company Name',
              ),
              onChanged: (e) {
                setState(() {});
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text(
                "Woking Time",
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (obj['working_time']['default'] ?? []).map<Widget>((map) {
                  return (map['enable'] ?? false)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${map['wday']} '),
                            Text('${map['begin']} - ${map['end']}'),
                          ],
                        )
                      : Container();
                }).toList(),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                var res0 = await Navigator.pushNamed(context, '/scrb002', arguments: obj);
                if (res0 != null) {
                  Map<String, dynamic> res = res0 as Map<String, dynamic>;
                  if (res['working_time'] != null) {
                    obj['working_time'] = res['working_time'];
                  }
                  setState(() {});
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.group),
              title: Text(
                "Department",
              ),
              subtitle: Builder(builder: (context) {
                List<Widget> list = [];
                list = (obj['department'] ?? []).map<Widget>((map) {
                  return (map['enable'] ?? false) ? Text(map['name']) : Container();
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: list,
                );
              }),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                var res0 = await Navigator.pushNamed(context, '/scrb003', arguments: obj);
                if (res0 != null) {
                  Map<String, dynamic> res = res0 as Map<String, dynamic>;
                  if (res['department'] != null) {
                    obj['department'] = res['department'];
                  }
                  setState(() {});
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.outgoing_mail),
              title: Text(
                "วันหยุดประจำปี",
              ),
              subtitle: Builder(builder: (context) {
                List<Widget> list = [];
                list = (obj['holiday'] ?? []).map<Widget>((map) {
                  if (map['date'] is DateTime) {
                  } else {
                    map['date'] = map['date'].toDate();
                  }
                  return (map['enable'] ?? false) ? Text("${DateFormat("dd MMM").format(map['date'])} ${map['name']}") : Container();
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: list,
                );
              }),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                var res0 = await Navigator.pushNamed(context, '/scrb004', arguments: obj);
                if (res0 != null) {
                  Map<String, dynamic> res = res0 as Map<String, dynamic>;
                  if (res['holiday'] != null) {
                    obj['holiday'] = res['holiday'];
                  }
                  setState(() {});
                }
              },
            ),
            Divider(),
            // Expanded(child: Container()),
            (nameController.text != '')
                ? Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
                      child: Text(
                        'Save Setting',
                        style: TextStyle(
                          fontSize: AppStyle().btnFontSize,
                        ),
                      ),
                      onPressed: () async {
                        bool confirm = await AppStyle().confirm(context, "Confirm Setting ?");
                        if (confirm) {
                          AppStyle().showLoader(context);
                          var compObj = {
                            'uid': AppStyle().session['user'].uid,
                            'name': nameController.text,
                            'working_time': obj['working_time'],
                            'department': obj['department'],
                            'holiday': obj['holiday'],
                            'workflow': obj['workflow'],
                            'leave_type': obj['leave_type'],
                            'expense_type': obj['expense_type'],
                            'memo_type': obj['memo_type'],
                            'training_type': obj['training_type'],
                            'members': {
                              "${AppStyle().session['user'].uid}": {
                                'admin': 'Y',
                                'enable': true,
                                'department': 'Human Resource',
                                'userinfo': AppStyle().session['data'],
                              }
                            },
                            'companyCode': getRandomString(8),
                          };
                          if ((AppStyle().session['company'] ?? {})['leave_final_user'] == null) {
                            compObj['leave_final_user'] = {'userinfo': AppStyle().session['data']};
                            compObj['leave_final_username'] = AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email'];
                          }
                          if ((AppStyle().session['company'] ?? {})['training_confirm_user'] == null) {
                            compObj['training_confirm_user'] = {'userinfo': AppStyle().session['data']};
                            compObj['training_confirm_username'] = AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email'];
                          }
                          if ((AppStyle().session['company'] ?? {})['expense_payout_user'] == null) {
                            compObj['expense_payout_user'] = {'userinfo': AppStyle().session['data']};
                            compObj['expense_payout_username'] = AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email'];
                          }
                          await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['user'].uid).set(compObj, SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(AppStyle().session['user'].uid)
                              .set({'companyId': AppStyle().session['user'].uid}, SetOptions(merge: true));

                          AppStyle().hideLoader(context);
                          AppStyle().session['company'] = compObj;
                          Navigator.pop(context);
                        }
                      },
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'กรุณากรอกชื่อบริษัท',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  Future<void> initData() async {
    if (AppStyle().session['company'] == null) {
      obj['working_time'] = AppStyle().session['setting']['default_working_time'] ?? {};
      obj['department'] = AppStyle().session['setting']['default_department'] ?? [];
      obj['holiday'] = AppStyle().session['setting']['default_holiday'] ?? [];
      obj['leave_type'] = AppStyle().session['setting']['default_leave_type'] ?? [];
      obj['expense_type'] = AppStyle().session['setting']['default_expense_type'] ?? [];
      obj['memo_type'] = AppStyle().session['setting']['default_memo_type'] ?? [];
      obj['training_type'] = AppStyle().session['setting']['default_training_type'] ?? [];
      obj['workflow'] = AppStyle().session['setting']['default_workflow'] ?? [];
    } else {
      obj = AppStyle().session['company'];
      nameController.text = obj['name'];
    }
    for (var i = 0; i < (obj['holiday'] ?? []).length; i++) {
      if (obj['holiday'][i]['date'] is DateTime) {
      } else {
        obj['holiday'][i]['date'] = obj['holiday'][i]['date'].toDate();
      }
    }

    setState(() {});
  }
}
