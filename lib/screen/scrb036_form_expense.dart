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

class Scrb036FormExpense extends StatefulWidget {
  const Scrb036FormExpense({Key? key}) : super(key: key);

  @override
  _Scrb036FormExpenseState createState() => _Scrb036FormExpenseState();
}

class _Scrb036FormExpenseState extends State<Scrb036FormExpense> {
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
  String key_type = 'expense_type';

  DateTime create_date = DateTime.now();
  DateTime payout_date = DateTime.now();
  double expense_amount = 0;
  String expense_type = '';
  String expense_remark = '';
  List images = [];
  TextEditingController remarkController = TextEditingController();
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
      initData();

      if ((obj['doc']['uid'] == AppStyle().session['data']['uid']) && (obj['doc']['status'] == null)) {
        readonly = false;
      }
      if (obj['doc']['data']['create_date'] == null) {
        expense_amount = 0;
      } else {
        if (obj['doc']['data']['create_date'] is DateTime) {
          create_date = obj['doc']['data']['create_date'];
        } else {
          obj['doc']['data']['create_date'] = obj['doc']['data']['create_date'].toDate();
          create_date = obj['doc']['data']['create_date'];
        }
        if (obj['doc']['data']['payout_date'] == null) {
          payout_date = DateTime(create_date.year, create_date.month, create_date.day + 1);
          expense_amount = 0;
        } else {
          if (obj['doc']['data']['payout_date'] is DateTime) {
            payout_date = obj['doc']['data']['payout_date'];
          } else {
            obj['doc']['data']['payout_date'] = obj['doc']['data']['payout_date'].toDate();
            payout_date = obj['doc']['data']['payout_date'];
          }
        }
      }

      if (obj['doc']['data']['expense_amount'] != null) {
        expense_amount = obj['doc']['data']['expense_amount'];
      }
      if (obj['doc']['data']['expense_type'] != null) {
        expense_type = obj['doc']['data']['expense_type'];
      } else {
        expense_type = AppStyle().session['company']['expense_type'][0]['name'];
      }

      if (obj['doc']['data']['remark'] != null) {
        expense_remark = obj['doc']['data']['remark'];
        remarkController.text = expense_remark;
      }

      if (obj['doc']['data']['images'] != null) {
        obj['files'] = [];
        for (var i = 0; i < (obj['doc']['data']['images'] ?? []).length; i++) {
          obj['files'].add({'url': obj['doc']['data']['images'][i]});
        }
      }

      if (obj['doc']['status'] != null) {
        readonly = true;
      }

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 179, 94, 2),
        title: Text(
          "${obj['doc']['status'] ?? 'ใบเบิกค่าใช้จ่าย'}",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                dynamic res = null;
                dynamic myinfo = AppStyle().session['company']['members'][AppStyle().session['data']['uid']];
                var mydep = myinfo['department'];
                dynamic manager = {};
                for (var i = 0; i < (AppStyle().session['company']['department'] ?? []).length; i++) {
                  if (AppStyle().session['company']['department'][i]['enable']) {
                    if (AppStyle().session['company']['department'][i]['name'] == mydep) {
                      if (AppStyle().session['company']['department'][i]['managerinfo'] != null) {
                        manager = AppStyle().session['company']['members'][AppStyle().session['company']['department'][i]['managerinfo']['uid']]['userinfo'];
                      } else {
                        manager = null;
                      }
                    }
                  }
                }
                var l2uid = AppStyle().session['company']['expense_payout_user']['userinfo']['uid'];
                AppStyle().session['company']['expense_payout_username'] =
                    AppStyle().session['company']['members'][l2uid]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][l2uid]['userinfo']['email'];
                AppStyle().session['company']['expense_payout_user'] = AppStyle().session['company']['members'][l2uid];
                print(AppStyle().session['company']['expense_payout_username']);
                setState(() {});
                if ((obj['doc']['status'] == null) && (obj['doc']['uid'] == AppStyle().session['data']['uid'])) {
                  if (manager == null) {
                    await AppStyle().alert(context, "ไม่พบรายชื่อ Department Manager (ระบบจะใช้รายชื่อผู้ดูแลแทน) กรุณาตรวจสอบกับผู้ดูแลระบบ");
                    manager = AppStyle().session['company']['members'][AppStyle().session['company']['uid']]['userinfo'];
                  }

                  // Owner view on Status is not set
                  // Save or Send & Preview Flow
                  res = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(
                                  "Status",
                                ),
                                trailing: Text("${obj['doc']['status'] ?? 'Draft'}"),
                              ),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Image.asset(
                                    "assets/images/expense_setting_001.png",
                                    height: size.height * 0.3,
                                  )),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${manager['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Manager (${mydep})",
                                ),
                                subtitle: Text(
                                  "${manager['displayName'] ?? manager['email']}",
                                ),
                                trailing: Text("ผู้อนุมัติ 1"),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${AppStyle().session['company']['expense_payout_user']['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Payout User",
                                ),
                                subtitle: Text(
                                  "${AppStyle().session['company']['expense_payout_username'] ?? ''}",
                                ),
                                trailing: Text("ผู้อนุมัติ 2"),
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('ส่งเอกสารเพื่อขออนุมัติ'),
                                    style: TextStyle(
                                      fontSize: AppStyle().btnFontSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context, {'action': 'Send', 'department': mydep, 'manager': manager});
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: Colors.grey, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('บันทึกร่างเอกสาร'),
                                    style: TextStyle(
                                      fontSize: AppStyle().btnFontSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context, {'action': 'Save', 'department': mydep, 'manager': manager});
                                  },
                                ),
                              ),
                              SizedBox(height: 80),
                            ],
                          );
                        });
                      });
                } else if ((obj['doc']['status'] == 'Wait for manager approve') && (obj['doc']['data']['approver1'] == AppStyle().session['data']['uid'])) {
                  // Owner view on Status is not set
                  // Save or Send & Preview Flow
                  res = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(
                                  "Status",
                                ),
                                trailing: Text("${obj['doc']['status'] ?? 'Draft'}"),
                              ),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Image.asset(
                                    "assets/images/expense_setting_001.png",
                                    height: size.height * 0.3,
                                  )),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver1info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Manager (${obj['doc']['data']['department']})",
                                ),
                                subtitle: Text(
                                  "${obj['doc']['data']['approver1info']['displayName'] ?? obj['doc']['data']['approver1info']['email']}",
                                ),
                                trailing: Text("ผู้อนุมัติ 1"),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver2info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Payout User",
                                ),
                                subtitle: Text(
                                  "${obj['doc']['data']['approver2info']['displayName'] ?? obj['doc']['data']['approver2info']['email']}",
                                ),
                                trailing: Text("ผู้อนุมัติ 2"),
                              ),
                              Container(
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.green, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('อนุมัติ'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'ManagerApprove'});
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.red, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('ไม่อนุมัติ'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'ManagerReject'});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 80),
                            ],
                          );
                        });
                      });
                } else if ((obj['doc']['status'] == 'Wait for Payout') && (AppStyle().session['data']['uid'] == obj['doc']['data']['approver2'])) {
                  // Owner view on Status is not set
                  // Save or Send & Preview Flow
                  res = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(
                                  "Status",
                                ),
                                trailing: Text("${obj['doc']['status'] ?? 'Draft'}"),
                              ),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Image.asset(
                                    "assets/images/expense_setting_001.png",
                                    height: size.height * 0.3,
                                  )),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver1info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Manager (${obj['doc']['data']['department']})",
                                ),
                                subtitle: Text(
                                  "${obj['doc']['data']['approver1info']['displayName'] ?? obj['doc']['data']['approver1info']['email']}",
                                ),
                                trailing: Text("ผู้อนุมัติ 1"),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver2info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Payout User",
                                ),
                                subtitle: Text(
                                  "${obj['doc']['data']['approver2info']['displayName'] ?? obj['doc']['data']['approver2info']['email']}",
                                ),
                                trailing: Text("ผู้อนุมัติ 2"),
                              ),
                              Container(
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.green, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('อนุมัติ'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'PayoutApprove'});
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.red, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('ไม่อนุมัติ'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'PayoutReject'});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 80),
                            ],
                          );
                        });
                      });
                }

                print(AppStyle().session['user_department']['department']);
                if (res != null) {
                  images = [];
                  for (var i = 0; i < (obj['files'] ?? []).length; i++) {
                    if (obj['files'][i]['url'] != '') {
                      images.add(obj['files'][i]['url']);
                    }
                  }
                  obj['doc']['data']['expense_type'] = expense_type;
                  obj['doc']['data']['expense_amount'] = expense_amount;
                  obj['doc']['data']['remark'] = expense_remark;
                  obj['doc']['data']['images'] = images;
                  obj['doc']['companyId'] = AppStyle().session['company']['uid'];
                  if (res['action'] == 'Send') {
                    obj['doc']['data']['create_date'] = FieldValue.serverTimestamp();
                    // Case normal
                    obj['doc']['status'] = "Wait for manager approve";
                    obj['doc']['data']['approver1'] = res['manager']['uid'];
                    obj['doc']['data']['approver1info'] = res['manager'];
                    obj['doc']['data']['department'] = res['department'];

                    obj['doc']['data']['approver2'] = AppStyle().session['company']['expense_payout_user']['uid'];
                    obj['doc']['data']['approver2info'] = AppStyle().session['company']['expense_payout_user']['userinfo'];

                    // Case Requester is Manager and not
                    if (obj['doc']['data']['approver1'] == AppStyle().session['data']['uid']) {
                      obj['doc']['status'] = "Wait for Payout";
                      obj['doc']['data']['status1'] = 'Approved';
                      obj['noti'] = obj['doc']['data']['approver2'];
                    } else {
                      // Wait for Manager Approve
                      // Send Notification to Manager
                      obj['noti'] = obj['doc']['data']['approver1'];
                    }
                  }
                  if (res['action'] == 'ManagerApprove') {
                    obj['doc']['status'] = "Wait for Payout";
                    obj['doc']['data']['status1'] = 'Approved';
                    obj['noti'] = obj['doc']['data']['approver2'];
                  }
                  if (res['action'] == 'ManagerReject') {
                    obj['doc']['status'] = "Manager Rejected";
                    obj['doc']['data']['status1'] = 'Rejected';
                  }
                  if (res['action'] == 'PayoutReject') {
                    obj['doc']['status'] = "Payout Rejected";
                    obj['doc']['data']['status2'] = 'Rejected';
                    obj['doc']['data']['approver2'] = AppStyle().session['data']['uid'];
                    obj['doc']['data']['approver2info'] = AppStyle().session['data'];
                  }
                  if (res['action'] == 'PayoutApprove') {
                    obj['doc']['data']['payout_date'] = FieldValue.serverTimestamp();

                    obj['doc']['status'] = "Payout Approved";
                    obj['doc']['data']['status2'] = 'Approved';
                    obj['doc']['data']['approver2'] = AppStyle().session['data']['uid'];
                    obj['doc']['data']['approver2info'] = AppStyle().session['data'];
                  }
                  if (obj['doc']['id'] == null) {
                    await FirebaseFirestore.instance.collection('documents').add(obj['doc']).then((value) {
                      setState(() {
                        obj['doc']['id'] = value.id;
                      });
                    });
                  } else {
                    await FirebaseFirestore.instance.collection('documents').doc(obj['doc']['id']).set(obj['doc'], SetOptions(merge: true));
                  }

                  if (obj['doc']['status'] != null) {
                    if ((obj['doc']['data']['approver1'] ?? '') != '') {
                      // What ever status (Accepted Draft) update exists approver
                      await FirebaseFirestore.instance.collection('inbox').doc("${obj['doc']['id']}-${obj['doc']['data']['approver1']}").set({
                        'date': FieldValue.serverTimestamp(),
                        'docid': obj['doc']['id'],
                        'uid': obj['doc']['data']['approver1'],
                        'show_uid': obj['doc']['uid'],
                        'doctype': 'expense',
                        'folder_code': 'expense_approval',
                        'title':
                            "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                        'subtitle': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                        'status': obj['doc']['status'],
                        'status_color': '',
                      });
                    }
                    // if status is send to payout then add inbox payout
                    if ((obj['doc']['data']['approver2'] ?? '') != '') {
                      await FirebaseFirestore.instance.collection('inbox').doc("${obj['doc']['id']}-${obj['doc']['data']['approver2']}").set({
                        'date': FieldValue.serverTimestamp(),
                        'docid': obj['doc']['id'],
                        'uid': obj['doc']['data']['approver2'],
                        'show_uid': obj['doc']['uid'],
                        'doctype': 'expense',
                        'folder_code': 'expense_approval',
                        'title':
                            "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                        'subtitle': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                        'status': obj['doc']['status'],
                        'status_color': '',
                      });
                    }
                    if (obj['noti'] != null) {
                      String FCM = AppStyle().session['company']['members'][obj['noti']]['userinfo']['FCM'] ?? '';
                      var payload = {
                        'FCM': FCM,
                        'uid': obj['noti'],
                        'title': 'มีใบเบิกรอพิจารณา',
                        'body': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                        'data': {
                          'body': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                          'action': 'expense',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                      await FirebaseFirestore.instance.collection('notification').add(payload);
                    }

                    // Send Notification to requester ?
                    String FCM = AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['FCM'] ?? '';
                    var payload = {
                      'FCM': FCM,
                      'uid': obj['doc']['uid'],
                      'title': '${obj['doc']['status']}',
                      'body': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                      'data': {
                        'body': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                        'action': 'expense',
                        'did': obj['doc']['id'],
                      },
                      'date': FieldValue.serverTimestamp(),
                      'status': 'WAIT',
                    };
                    await FirebaseFirestore.instance.collection('notification').add(payload);
                  }
                  Navigator.pop(context, {'refresh': 'Y'});
                }
              },
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ))
        ],
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
                  'ใบเบิกค่าใช้จ่าย',
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
          Builder(builder: (context) {
            List<TableRow> row = [];
            int cday = DateTime.now().day;
            String cmon = DateFormat("MMM").format(DateTime.now());
            double rowheight = 60;
            // print(obj['timesheet']);

            var value = obj['doc'];

            var key = '';
            if (value['uid'] == AppStyle().session['data']['uid']) {
              row.insert(
                  0,
                  TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Color.fromARGB(255, 214, 214, 214))),
                      ),
                      children: [
                        Container(
                            color: Color.fromARGB(255, 205, 231, 255),
                            height: rowheight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${expense_type}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // SizedBox(height: 3),
                                Text(
                                  '${AppStyle().formatCurrency.format(expense_amount)}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        Builder(builder: (context) {
                          List<Widget> list = [];
                          if (value['status'] == null) {
                            list.add(Container(
                              // color: Colors.red,
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Text('Draft'),
                            ));
                          } else {
                            list.add(Container(
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${value['data']['status1'] ?? 'Wait'}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (value['data']['status1'] == 'Rejected')
                                            ? Colors.red
                                            : (value['data']['status1'] == 'Approved')
                                                ? Colors.green
                                                : null),
                                  ),
                                  // (value['data']['approver1info'] == null)
                                  //     ? Container()
                                  //     : Text('${value['data']['approver1info']!['displayName'] ?? value['data']['approver1info']!['email']}'),
                                ],
                              ),
                            ));
                            list.add(Container(
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${value['data']['status2'] ?? 'Wait'}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (value['data']['status2'] == 'Rejected')
                                            ? Colors.red
                                            : (value['data']['status2'] == 'Approved')
                                                ? Colors.green
                                                : null),
                                  ),
                                  // (value['data']['approver2info'] == null)
                                  //     ? Container()
                                  //     : Text('${value['data']['approver2info']!['displayName'] ?? value['data']['approver2info']!['email']}'),
                                ],
                              ),
                            ));
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: list,
                          );
                        }),
                      ]));
            }

            return Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(184),
                1: FlexColumnWidth(),
                // 3: FixedColumnWidth(100),
                // 4: FixedColumnWidth(64),
              },
              children: row,
            );
          }),
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage("${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
            ),
            title: Text(
              "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
            ),
            subtitle: Text(
              "${AppStyle().session['company']['members'][obj['doc']['uid']]['department']}",
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
                ListTile(
                  title: Text(
                    "จำนวนเงิน",
                  ),
                  subtitle: Text(
                    "${AppStyle().formatCurrency.format(expense_amount)}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await AppStyle().confirmData(context, expense_amount.toString(), "จำนวนเงิน");
                          if (res != null) {
                            expense_amount = double.tryParse(res) ?? 1.0;
                            obj['doc']['data']['expense_amount'] = expense_amount;
                            setState(() {});
                          }
                        },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "ประเภทค่าใช้จ่าย",
                  ),
                  subtitle: Text(
                    "${expense_type}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await Navigator.pushNamed(context, '/util103',
                              arguments: {'list': AppStyle().session['company']['expense_type'], 'key': 'name', 'select': expense_type});
                          if (res != null) {
                            var res2 = res as Map<String, dynamic>;
                            expense_type = res2['name'];
                            obj['doc']['data']['expense_type'] = expense_type;
                            setState(() {});
                          }
                        },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "Project",
                  ),
                  subtitle: Text(
                    "${obj['doc']['project'] ?? ''}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          AppStyle().session['data']['master_project'] ??= [];
                          var res = await Navigator.pushNamed(context, '/util103',
                              arguments: {'list': AppStyle().session['data']['master_project'] ?? [], 'key': 'name', 'select': obj['doc']['project'], 'Add': 'Y'});
                          if (res != null) {
                            var res2 = res as Map<String, dynamic>;
                            obj['doc']['project'] = res2['keyword'];
                            bool addnew = true;

                            for (var i = 0; i < AppStyle().session['data']['master_project'].length; i++) {
                              if (AppStyle().session['data']['master_project'][i]['name'] == res2['keyword']) {
                                addnew = false;
                              }
                            }
                            if (addnew) {
                              AppStyle().session['data']['master_project'].add({
                                'name': res2['keyword'],
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(AppStyle().session['user'].uid)
                                  .set({'master_project': AppStyle().session['data']['master_project']}, SetOptions(merge: true));
                            }
                            setState(() {});
                          }
                        },
                ),
                TextField(
                  readOnly: readonly,
                  controller: remarkController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'Remark',
                    labelText: 'Remark',
                  ),
                  onChanged: (val) {
                    setState(() {
                      expense_remark = remarkController.text;
                      obj['doc']['data']['remark'] = remarkController.text;
                    });
                  },
                ),
                ListTile(
                  title: Text(
                    "เอกสารแนบ",
                  ),
                  subtitle: Text(
                    "",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.document_scanner_outlined),
                  onTap: (readonly)
                      ? null
                      : () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image =
                              await _picker.pickImage(source: ImageSource.camera, maxHeight: 1600, maxWidth: 1600, imageQuality: 90, preferredCameraDevice: CameraDevice.rear);
                          if (image != null) {
                            if (obj['files'] == null) {
                              obj['files'] = [];
                            }
                            obj['files'].add({'file': image, 'url': ''});
                            setState(() {});
                            AppStyle().showLoader(context);
                            final storageRef = FirebaseStorage.instance.ref();
                            final postImagesRef =
                                storageRef.child("users/" + AppStyle().session['user'].uid + "/images/" + DateFormat("yyyyMM").format(DateTime.now()) + "/expense_" + image.name);
                            try {
                              final bytes = File(image.path).readAsBytesSync();

                              await postImagesRef.putString(base64Encode(bytes).toString(), format: PutStringFormat.base64);
                              String url = await postImagesRef.getDownloadURL();
                              obj['files'][(obj['files'].length - 1)]['url'] = url;
                            } on FirebaseException catch (e) {
                              // print(e);
                            }
                            AppStyle().hideLoader(context);
                            setState(() {});
                          }
                        },
                ),
                Container(
                  width: size.width,
                  height: 150,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Builder(builder: (context) {
                      List<Widget> images = [];

                      for (var i = 0; i < (obj['files'] ?? []).length; i++) {
                        var file = obj['files'][i];

                        images.add(InkWell(
                          onLongPress: (readonly)
                              ? null
                              : () async {
                                  var res = await AppStyle().confirm(context, "ลบรูปภาพ ?");
                                  if (res) {
                                    obj['files'].remove(file);
                                    setState(() {});
                                  }
                                },
                          onTap: () async {
                            var res = await Navigator.pushNamed(context, '/util102', arguments: {'images': obj['files'], 'index': i});
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: ((file['file'] != null) ? FileImage(File(file['file'].path)) : NetworkImage(file['url'])) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: (file['url'] == '')
                                ? Icon(
                                    Icons.upload,
                                    color: Colors.white,
                                    size: 50,
                                  )
                                : null,
                          ),
                        ));
                      }

                      return Row(
                        children: images,
                      );
                    }),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "วันที่เบิก",
                  ),
                  subtitle: Text(
                    "${DateFormat("dd MMMM yyyy HH:mm").format(create_date)}",
                  ),
                ),
                Divider(height: 1),
                (obj['doc']['data']['approver1info'] != null)
                    ? ListTile(
                        title: Text(
                          "วันที่อนุมัติเงิน",
                        ),
                        subtitle: Text(
                          "${DateFormat("dd MMMM yyyy HH:mm").format(payout_date)}",
                        ),
                      )
                    : Container(),
                Divider(height: 1),
                (obj['doc']['data']['approver1info'] != null)
                    ? Container(
                        color: Colors.amber[100],
                        child: ListTile(
                          onLongPress: () {
                            AppStyle().showSnackBar(context, 'Update status to approver 1', Color.fromARGB(255, 211, 91, 0));

                            FirebaseFirestore.instance.collection('inbox').doc("${obj['doc']['id']}-${obj['doc']['data']['approver1']}").set({
                              'date': FieldValue.serverTimestamp(),
                              'docid': obj['doc']['id'],
                              'uid': obj['doc']['data']['approver1'],
                              'show_uid': obj['doc']['uid'],
                              'doctype': 'expense',
                              'folder_code': 'expense_approval',
                              'title':
                                  "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                              'subtitle': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                              'status': obj['doc']['status'],
                              'status_color': '',
                            });
                          },
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                                "${(AppStyle().session['company']['members'][obj['doc']['data']['approver1info']['uid']]['userinfo'] ?? {})['photoURL'] ?? AppStyle().no_user_url}"),
                          ),
                          title: Text(
                            "${(AppStyle().session['company']['members'][obj['doc']['data']['approver1info']['uid']]['userinfo'] ?? {})['displayName'] ?? (AppStyle().session['company']['members'][obj['doc']['data']['approver1info']['uid']]['userinfo'] ?? {})['email'] ?? ''}",
                          ),
                          subtitle: Text(
                            "ผู้อนุมัติ 1",
                          ),
                          trailing: Text(
                            "${obj['doc']['data']['status1'] ?? ''}",
                          ),
                        ),
                      )
                    : Container(),
                (obj['doc']['data']['approver2info'] != null)
                    ? Container(
                        color: Colors.amber[100],
                        child: ListTile(
                          onLongPress: () {
                            AppStyle().showSnackBar(context, 'Update status to approver 2', Color.fromARGB(255, 211, 91, 0));
                            FirebaseFirestore.instance.collection('inbox').doc("${obj['doc']['id']}-${obj['doc']['data']['approver2']}").set({
                              'date': FieldValue.serverTimestamp(),
                              'docid': obj['doc']['id'],
                              'uid': obj['doc']['data']['approver2'],
                              'show_uid': obj['doc']['uid'],
                              'doctype': 'expense',
                              'folder_code': 'expense_approval',
                              'title':
                                  "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                              'subtitle': '${AppStyle().formatCurrency.format(obj['doc']['data']['expense_amount'])} (${obj['doc']['data']['expense_type']})',
                              'status': obj['doc']['status'],
                              'status_color': '',
                            });
                          },
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                                "${(AppStyle().session['company']['members'][obj['doc']['data']['approver2info']['uid']]['userinfo'] ?? {})['photoURL'] ?? AppStyle().no_user_url}"),
                          ),
                          title: Text(
                            "${(AppStyle().session['company']['members'][obj['doc']['data']['approver2info']['uid']]['userinfo'] ?? {})['displayName'] ?? (AppStyle().session['company']['members'][obj['doc']['data']['approver2info']['uid']]['userinfo'] ?? {})['email'] ?? ''}",
                          ),
                          subtitle: Text(
                            "ผู้อนุมัติ 2",
                          ),
                          trailing: Text(
                            "${obj['doc']['data']['status2'] ?? ''}",
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget dataChart(double width) {
    List<BarChartGroupData> barData = [];
    Map records = {};
    for (var i = 0; i < AppStyle().session['company'][key_type].length; i++) {
      records[AppStyle().session['company'][key_type][i]['name']] = {'index': i, 'sum': 0.00};
    }
    for (var i = 0; i < (obj['doclist'] ?? []).length; i++) {
      if (obj['doclist'][i]['data'][key_type] != null) {
        records[obj['doclist'][i]['data'][key_type]]['sum'] += obj['doclist'][i]['data']['expense_amount'];
      }
    }
    for (var i = 0; i < AppStyle().session['company'][key_type].length; i++) {
      barData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: records[AppStyle().session['company'][key_type][i]['name']]['sum'] ?? 0,
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      ));
    }
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 10),
          height: width / 1.7,
          width: width,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(10),
            color: Color(0xff2c4260),
            // color: Color.fromARGB(255, 221, 221, 221),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(3, 3), // changes position of shadow
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              barTouchData: barTouchData,
              titlesData: titlesData,
              borderData: borderData,
              barGroups: barData,
              gridData: FlGridData(show: false),
              alignment: BarChartAlignment.spaceAround,
              // maxY: 20,
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  final _barsGradient = const LinearGradient(
    colors: [
      Colors.lightBlueAccent,
      Colors.greenAccent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchCallback: (event, response) {
          if (response == null || response.spot == null) {
          } else {
            if (!event.isInterestedForInteractions) {
              setState(() {
                print(response.spot!.touchedRodData.toY);
                // chartDataIndex = response.spot!.touchedBarGroupIndex;
              });
            }
          }
        },
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              AppStyle().formatCurrency.format(rod.toY),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Color.fromARGB(255, 149, 171, 199),
        // fontWeight: FontWeight.bold,
        fontSize: 12,
        overflow: TextOverflow.fade);
    String text = "${AppStyle().session['company'][key_type][value.toInt()]['name']}";
    String text2 = "${AppStyle().session['company'][key_type][value.toInt()]['limit'] ?? ''}";
    return Center(
        child: InkWell(
            onTap: () async {
              // await listExpense(text);
            },
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(text, style: style),
                Text(text2, style: style),
              ],
            )));
  }

  void initData() async {
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'leave')
        .where('uid', isEqualTo: AppStyle().session['data']['uid'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      obj['doclist'] = [];
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          if (doc.id != obj['doc']['id']) {
            tmp['id'] = doc.id;
            if (tmp['data']['create_date'] != null) {
              tmp['data']['create_date'] = tmp['data']['create_date'].toDate();
            }
            if (tmp['data']['payout_date'] != null) {
              tmp['data']['payout_date'] = tmp['data']['payout_date'].toDate();
            }
            obj['doclist'].add(tmp);
          }
        }
      }
      print(obj['doclist']);
      setState(() {});
    });
  }
}
