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

class Scrb030FormLeave extends StatefulWidget {
  const Scrb030FormLeave({Key? key}) : super(key: key);

  @override
  _Scrb030FormLeaveState createState() => _Scrb030FormLeaveState();
}

class _Scrb030FormLeaveState extends State<Scrb030FormLeave> {
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
  String key_type = 'leave_type';

  DateTime leave_begin = DateTime.now();
  DateTime leave_end = DateTime.now();
  double leave_day = 1;
  String leave_type = '';
  String leave_remark = '';
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
      if (obj['doc']['data']['leave_from'] == null) {
        leave_begin = DateTime.now();
        obj['doc']['data']['leave_from'] = leave_begin;
        leave_end = DateTime(leave_begin.year, leave_begin.month, leave_begin.day + 1, 23, 59);
        obj['doc']['data']['leave_to'] = leave_end;
        leave_day = 1;
        obj['calc'] = 1;
      } else {
        if (obj['doc']['data']['leave_from'] is DateTime) {
          leave_begin = obj['doc']['data']['leave_from'];
        } else {
          obj['doc']['data']['leave_from'] = obj['doc']['data']['leave_from'].toDate();
          leave_begin = obj['doc']['data']['leave_from'];
        }
        if (obj['doc']['data']['leave_to'] == null) {
          leave_end = DateTime(leave_begin.year, leave_begin.month, leave_begin.day + 1, 23, 59);
          leave_day = 1;
        } else {
          if (obj['doc']['data']['leave_to'] is DateTime) {
            leave_end = obj['doc']['data']['leave_to'];
          } else {
            obj['doc']['data']['leave_to'] = obj['doc']['data']['leave_to'].toDate();
            leave_end = obj['doc']['data']['leave_to'];
          }
        }
      }

      if (obj['doc']['data']['day'] != null) {
        leave_day = obj['doc']['data']['day'];
      }
      if (obj['doc']['data']['leave_type'] != null) {
        leave_type = obj['doc']['data']['leave_type'];
      } else {
        leave_type = AppStyle().session['company']['leave_type'][0]['name'];
      }

      if (obj['doc']['data']['remark'] != null) {
        leave_remark = obj['doc']['data']['remark'];
        remarkController.text = leave_remark;
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
        backgroundColor: Color.fromARGB(255, 26, 162, 149),
        title: Text(
          "${obj['doc']['status'] ?? 'ใบลา'}",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                leave_day = countLeaveDay();

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
                var l2uid = AppStyle().session['company']['leave_final_user']['userinfo']['uid'];
                AppStyle().session['company']['leave_final_username'] =
                    AppStyle().session['company']['members'][l2uid]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][l2uid]['userinfo']['email'];
                AppStyle().session['company']['leave_final_user'] = AppStyle().session['company']['members'][l2uid];
                print(AppStyle().session['company']['leave_final_username']);
                setState(() {});
                if (AppStyle().session['company']['workflow']['leave']['code'] == 'l2') {
                  if (manager == null) {
                    await AppStyle().alert(context, "ไม่พบรายชื่อ Department Manager (ระบบจะใช้รายชื่อผู้ดูแลแทน) กรุณาตรวจสอบกับผู้ดูแลระบบ");
                    manager = AppStyle().session['company']['members'][AppStyle().session['company']['uid']]['userinfo'];
                  }
                }
                if (leave_day <= 0) {
                  await AppStyle().alert(context, "วันที่ลาไม่ถูกต้องกรุณาตรวจสอบช่วงเวลาที่ลาอีกครั้ง");
                } else if ((obj['doc']['status'] == null) && (obj['doc']['uid'] == AppStyle().session['data']['uid'])) {
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
                                    AppStyle().session['company']['workflow']['leave']['cover'],
                                    height: size.height * 0.3,
                                  )),
                              (AppStyle().session['company']['workflow']['leave']['code'] == 'l2')
                                  ? ListTile(
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
                                    )
                                  : Container(),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${AppStyle().session['company']['leave_final_user']['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Final Approve User",
                                ),
                                subtitle: Text(
                                  "${AppStyle().session['company']['leave_final_username'] ?? ''}",
                                ),
                                trailing: Text("ผู้อนุมัติ 2"),
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('ส่งใบลาเพื่อขออนุมัติ'),
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
                                    AppStyle().session['company']['workflow']['leave']['cover'],
                                    height: size.height * 0.3,
                                  )),
                              (AppStyle().session['company']['workflow']['leave']['code'] == 'l2')
                                  ? ListTile(
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
                                    )
                                  : Container(),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver2info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Final Approve User",
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
                } else if ((obj['doc']['status'] == 'Wait for Final approve') && (AppStyle().session['data']['uid'] == obj['doc']['data']['approver2'])) {
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
                                    AppStyle().session['company']['workflow']['leave']['cover'],
                                    height: size.height * 0.3,
                                  )),
                              (AppStyle().session['company']['workflow']['leave']['code'] == 'l2')
                                  ? ListTile(
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
                                    )
                                  : Container(),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("${obj['doc']['data']['approver2info']['photoURL'] ?? AppStyle().no_user_url}"),
                                ),
                                title: Text(
                                  "Final Approve User",
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
                                        Navigator.pop(context, {'action': 'FinalApprove'});
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
                                        Navigator.pop(context, {'action': 'FinalReject'});
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
                String FCM = "";
                dynamic payload = {};
                if (res != null) {
                  images = [];
                  for (var i = 0; i < (obj['files'] ?? []).length; i++) {
                    if (obj['files'][i]['url'] != '') {
                      images.add(obj['files'][i]['url']);
                    }
                  }
                  obj['doc']['data']['leave_from'] = leave_begin;
                  obj['doc']['data']['leave_to'] = leave_end;
                  obj['doc']['data']['leave_type'] = leave_type;
                  obj['doc']['data']['day'] = leave_day;
                  obj['doc']['data']['remark'] = leave_remark;
                  obj['doc']['data']['images'] = images;
                  obj['doc']['companyId'] = AppStyle().session['company']['uid'];
                  if (res['action'] == 'Send') {
                    print("Leave Flow = ${AppStyle().session['company']['workflow']['leave']}");
                    if (AppStyle().session['company']['workflow']['leave']['code'] == 'l1') {
                      obj['doc']['status'] = "Wait for Final approve";
                      obj['doc']['data']['department'] = res['department'];
                      obj['doc']['data']['approver2'] = AppStyle().session['company']['leave_final_user']['uid'];
                      obj['doc']['data']['approver2info'] = AppStyle().session['company']['leave_final_user']['userinfo'];
                      obj['noti'] = obj['doc']['data']['approver2'];
                    } else {
                      // Case normal
                      obj['doc']['status'] = "Wait for manager approve";
                      obj['doc']['data']['approver1'] = res['manager']['uid'];
                      obj['doc']['data']['approver1info'] = res['manager'];
                      obj['doc']['data']['department'] = res['department'];
                      obj['doc']['data']['approver2'] = AppStyle().session['company']['leave_final_user']['uid'];
                      obj['doc']['data']['approver2info'] = AppStyle().session['company']['leave_final_user']['userinfo'];

                      // Case Requester is Manager and not
                      if (obj['doc']['data']['approver1'] == AppStyle().session['data']['uid']) {
                        obj['doc']['status'] = "Wait for Final approve";
                        obj['doc']['data']['status1'] = 'Approved';
                        obj['noti'] = obj['doc']['data']['approver2'];
                      } else {
                        // Wait for Manager Approve
                        // Send Notification to Manager
                        obj['noti'] = obj['doc']['data']['approver1'];
                      }
                    }
                  }
                  if (res['action'] == 'ManagerApprove') {
                    obj['doc']['status'] = "Wait for Final approve";
                    obj['doc']['data']['status1'] = 'Approved';
                    obj['noti'] = obj['doc']['data']['approver2'];
                  }
                  if (res['action'] == 'ManagerReject') {
                    obj['doc']['status'] = "Manager Rejected";
                    obj['doc']['data']['status1'] = 'Rejected';
                  }
                  if (res['action'] == 'FinalReject') {
                    obj['doc']['status'] = "Final Rejected";
                    if (AppStyle().session['company']['workflow']['leave']['code'] == 'l1') {
                      obj['doc']['data']['status1'] = 'Rejected';
                    } else {
                      obj['doc']['data']['status2'] = 'Rejected';
                    }
                  }
                  if (res['action'] == 'FinalApprove') {
                    obj['doc']['status'] = "Final Approved";
                    if (AppStyle().session['company']['workflow']['leave']['code'] == 'l1') {
                      obj['doc']['data']['status1'] = 'Approved';
                    } else {
                      obj['doc']['data']['status2'] = 'Approved';
                    }
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
                        'doctype': 'leave',
                        'folder_code': 'leave_approval',
                        'title':
                            "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                        'subtitle':
                            '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
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
                        'doctype': 'leave',
                        'folder_code': 'leave_approval',
                        'title':
                            "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                        'subtitle':
                            '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
                        'status': obj['doc']['status'],
                        'status_color': '',
                      });
                    }
                    // Send Notification to requester ?
                    if (obj['noti'] != null) {
                      FCM = AppStyle().session['company']['members'][obj['noti']]['userinfo']['FCM'] ?? '';
                      var payload = {
                        'FCM': FCM,
                        'uid': obj['noti'],
                        'title': 'มีใบลารอพิจารณา',
                        'body':
                            '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
                        'data': {
                          'body':
                              '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
                          'action': 'leave',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };

                      await FirebaseFirestore.instance.collection('notification').add(payload);
                    }
                    FCM = AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['FCM'] ?? '';
                    payload = {
                      'FCM': FCM,
                      'uid': obj['doc']['uid'],
                      'title': '${obj['doc']['status']}',
                      'body':
                          '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
                      'data': {
                        'body':
                            '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
                        'action': 'leave',
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
                  'ใบลา',
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          height: rowheight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'days',
                                style: TextStyle(fontSize: 14, color: Colors.red),
                              ),
                              Text(
                                '${leave_day}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            color: Color.fromARGB(255, 205, 231, 255),
                            height: rowheight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${leave_type}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // SizedBox(height: 3),
                                Text(
                                  '${DateFormat("dd MMM").format(leave_begin)} - ${DateFormat("dd MMM").format(leave_end)}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                          } else if (AppStyle().session['company']['workflow']['leave']['code'] == 'l1') {
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
                          } else if (AppStyle().session['company']['workflow']['leave']['code'] == 'l2') {
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
                0: FixedColumnWidth(64),
                1: FixedColumnWidth(120),
                2: FlexColumnWidth(),
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
                    "วันที่ลา",
                  ),
                  subtitle: Text(
                    "${DateFormat("dd MMMM yyyy HH:mm").format(leave_begin)}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await Navigator.pushNamed(context, '/util101',
                              arguments: {'date': leave_begin, 'title': 'วันที่ลา', 'datetime': 'Y', 'barcolor': Color.fromARGB(255, 26, 162, 149)});
                          if (res != null) {
                            var tmp = res as DateTime;
                            bool passed = true;
                            for (var i = 0; i < obj['doclist'].length; i++) {
                              DateTime start = obj['doclist'][i]['data']['leave_from'];
                              DateTime stop = obj['doclist'][i]['data']['leave_to'];
                              if ((tmp.millisecondsSinceEpoch >= start.millisecondsSinceEpoch) && (tmp.millisecondsSinceEpoch <= stop.millisecondsSinceEpoch)) {
                                AppStyle().alert(context, "วันที่ลาซ้ำกับใบลาทีมีอยู่");
                                passed = false;
                              }
                            }
                            if (passed) {
                              leave_begin = res as DateTime;
                              obj['doc']['data']['leave_from'] = leave_begin;
                              leave_end = DateTime(leave_begin.year, leave_begin.month, leave_begin.day + 1, 23, 59);

                              obj['doc']['data']['leave_to'] = leave_end;

                              setState(() {
                                leave_day = countLeaveDay();
                              });
                            }
                          }
                        },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "ถึงวันที่",
                  ),
                  subtitle: Text(
                    "${DateFormat("dd MMMM yyyy HH:mm").format(leave_end)}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await Navigator.pushNamed(context, '/util101',
                              arguments: {'date': leave_end, 'title': 'ถึงวันที่', 'datetime': 'Y', 'barcolor': Color.fromARGB(255, 26, 162, 149)});
                          if (res != null) {
                            DateTime tmp = res as DateTime;

                            if (tmp.isBefore(leave_begin)) {
                              AppStyle().confirm(context, "คุณเลือกวันที่ไม่ถูกต้อง");
                            } else {
                              leave_end = res as DateTime;
                              obj['doc']['data']['leave_to'] = leave_end;
                            }
                            setState(() {
                              leave_day = countLeaveDay();
                            });
                          }
                        },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "จำนวนวันที่ลา (${obj['calc']} วัน)",
                  ),
                  subtitle: Text(
                    "${leave_day}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await AppStyle().confirmData(context, leave_day.toString(), "จำนวนวันที่ลา");
                          if (res != null) {
                            leave_day = double.tryParse(res) ?? 1.0;
                            obj['doc']['data']['day'] = leave_day;
                            setState(() {});
                          }
                        },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "ประเภทการลา",
                  ),
                  subtitle: Text(
                    "${leave_type}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res =
                              await Navigator.pushNamed(context, '/util103', arguments: {'list': AppStyle().session['company']['leave_type'], 'key': 'name', 'select': leave_type});
                          if (res != null) {
                            var res2 = res as Map<String, dynamic>;
                            leave_type = res2['name'];
                            obj['doc']['data']['leave_type'] = leave_type;
                            setState(() {});
                          }
                        },
                ),
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
                              'doctype': 'leave',
                              'folder_code': 'leave_approval',
                              'title':
                                  "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                              'subtitle':
                                  '${obj['doc']['data']['leave_type']} ${DateFormat("dd MMM yyyy HH:mm").format(leave_begin)} - ${DateFormat("dd MMM yyyy HH:mm").format(leave_end)} (${obj['doc']['data']['day']} วัน)',
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
                      leave_remark = remarkController.text;
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
                                storageRef.child("users/" + AppStyle().session['user'].uid + "/images/" + DateFormat("yyyyMM").format(DateTime.now()) + "/leave_" + image.name);
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
                SizedBox(height: 80),
              ],
            ),
          ),
        ]),
      ),
    );
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
            tmp['data']['leave_from'] = tmp['data']['leave_from'].toDate();
            tmp['data']['leave_to'] = tmp['data']['leave_to'].toDate();
            obj['doclist'].add(tmp);
          }
        }
      }
      print(obj['doclist']);
      setState(() {});
    });
  }

  double countLeaveDay() {
    var tmp = {};
    double count = 0.0;
    DateTime s1 = obj['doc']['data']['leave_from'];
    DateTime start = DateTime(s1.year, s1.month, s1.day);
    DateTime s2 = obj['doc']['data']['leave_to'];
    DateTime stop = DateTime(s2.year, s2.month, s2.day);

    String fromKey = DateFormat("yyyyMMdd").format(s1);
    String toKey = DateFormat("yyyyMMdd").format(s2);
    var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var cal = AppStyle().session['company']['members'][obj['doc']['uid']]['calendar'] ?? {};
    if (AppStyle().session['calendar'][obj['doc']['uid']] != null) {
      cal = AppStyle().session['calendar'][obj['doc']['uid']];
    }
    var shift = {};

    var working_time = {};
    for (var i = 0; i < (AppStyle().session['company']['working_time']['default'] ?? []).length; i++) {
      var key = AppStyle().session['company']['working_time']['default'][i]['wday'].toLowerCase();
      if (AppStyle().session['company']['working_time']['default'][i]['enable']) {
        working_time[key] = AppStyle().session['company']['working_time']['default'][i];
      }
    }

    AppStyle().session['company']['working_time'].forEach((key, value) {
      for (var x = 0; x < (value ?? []).length; x++) {
        var _w = value[x]['wday'].toLowerCase();
        shift[key] ??= {};
        shift[key][_w] = value[x];
      }
    });

    int rday = stop.difference(start).inDays;
    for (var i = 0; i <= rday; i++) {
      var key = DateFormat("yyyyMMdd").format(DateTime(start.year, start.month, start.day + i));
      var wday = DateTime(start.year, start.month, start.day + i).weekday;

      tmp[key] = obj['doc']['data'];
      if (cal[key] == null) {
        if (working_time[wd[wday]] != null) {
          tmp[key]['working_time'] = working_time[wd[wday]];
          count += 1;
        }
      } else {
        if (cal[key] != null) {
          tmp[key]['working_time'] = shift[cal[key]][wd[wday]];
          count += 1;
        }
      }

      if (toKey == key) {
        if (tmp[key]['working_time'] != null) {
          print('toKey $toKey Yes');
          // end leave case
          String toTime = DateFormat("HH:mm").format(tmp[key]['leave_to']);
          print('IS LEAVE  $toTime ${tmp[key]['working_time']['begin']} ${toTime.compareTo(tmp[key]['working_time']['begin'].toString())}');
          if (toTime.compareTo(tmp[key]['working_time']['begin'].toString()) < 0) {
            count -= 1;
          } else {}
        }
      }
      if (fromKey == key) {
        if (tmp[key]['working_time'] != null) {
          print('fromKey $fromKey Yes');
          // end leave case
          String fromTime = DateFormat("HH:mm").format(tmp[key]['leave_from']);
          print('IS LEAVE  $fromTime ${tmp[key]['working_time']['end']} ${fromTime.compareTo(tmp[key]['working_time']['end'].toString())}');
          if (fromTime.compareTo(tmp[key]['working_time']['end'].toString()) > 0) {
            count -= 1;
          } else {}
        }
      }
    }

    // bool isLeave = false;
    // objleave ??= {};
    // print('Call isLeave $key ');
    // if (objleave[key] != null) {
    //   isLeave = true;
    //   // date match
    //   String toKey = DateFormat("yyyyMMdd").format(objleave[key]['data']['leave_to']);
    //   String fromKey = DateFormat("yyyyMMdd").format(objleave[key]['data']['leave_from']);
    //   print('toKey $toKey ');
    //   if (toKey == key) {
    //     print('toKey $toKey Yes');
    //     // end leave case
    //     String toTime = DateFormat("HH:mm").format(objleave[key]['data']['leave_to']);
    //     print('IS LEAVE  $toTime ${value['working_time']['begin']} ${toTime.compareTo(value['working_time']['begin'].toString())}');
    //     if (toTime.compareTo(value['working_time']['begin'].toString()) < 0) {
    //       isLeave = false;
    //     } else {
    //       isLeave = true;
    //     }
    //   }
    //   if (fromKey == key) {
    //     print('fromKey $fromKey Yes');
    //     // end leave case
    //     String fromTime = DateFormat("HH:mm").format(objleave[key]['data']['leave_from']);
    //     print('IS LEAVE  $fromTime ${value['working_time']['end']} ${fromTime.compareTo(value['working_time']['end'].toString())}');
    //     if (fromTime.compareTo(value['working_time']['end'].toString()) > 0) {
    //       isLeave = false;
    //     } else {
    //       isLeave = true;
    //     }
    //   }
    //   // check end leave time with start working time
    //   //

    // }
    print(count);
    obj['calc'] = count;
    return count;
  }
}
