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

class Scrb047FormTask extends StatefulWidget {
  const Scrb047FormTask({Key? key}) : super(key: key);

  @override
  _Scrb047FormTaskState createState() => _Scrb047FormTaskState();
}

class _Scrb047FormTaskState extends State<Scrb047FormTask> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true, 'ori_users': []};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
  bool readonly = true;
  String key_type = 'task_type';

  DateTime task_begin = DateTime.now();
  DateTime task_end = DateTime.now();
  String task_type = '';
  String task_remark = '';
  List images = [];
  TextEditingController remarkController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController resultController = TextEditingController();
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
      print(obj['ori_users']);

      initData();

      if ((obj['doc']['uid'] == AppStyle().session['data']['uid']) || (obj['doc']['from_uid'] == AppStyle().session['data']['uid'])) {
        readonly = false;
      }
      if (obj['doc']['task_begin'] == null) {
        task_begin = DateTime.now();
      } else {
        if (obj['doc']['task_begin'] is DateTime) {
          task_begin = obj['doc']['task_begin'];
        } else {
          obj['doc']['task_begin'] = obj['doc']['task_begin'].toDate();
          task_begin = obj['doc']['task_begin'];
        }
      }
      if (obj['doc']['task_end'] == null) {
        task_end = DateTime.now();
      } else {
        if (obj['doc']['task_end'] is DateTime) {
          task_end = obj['doc']['task_end'];
        } else {
          obj['doc']['task_end'] = obj['doc']['task_end'].toDate();
          task_end = obj['doc']['task_end'];
        }
      }

      if (obj['doc']['project'] == null) {
        obj['doc']['project'] = '';
      }

      if (obj['doc']['task_type'] == null) {
        task_type = '';
      }

      if (obj['doc']['task_remark'] != null) {
        task_remark = obj['doc']['task_remark'];
        remarkController.text = task_remark;
      }
      if (obj['doc']['task_result'] != null) {
        resultController.text = obj['doc']['task_result'];
      }
      if (obj['doc']['task_subject'] != null) {
        subjectController.text = obj['doc']['task_subject'];
      }

      if (obj['doc']['images'] != null) {
        obj['files'] = [];
        for (var i = 0; i < (obj['doc']['images'] ?? []).length; i++) {
          obj['files'].add({'url': obj['doc']['images'][i]});
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
        backgroundColor: Color.fromARGB(255, 69, 69, 69),
        title: Text(
          "${obj['doc']['status'] ?? 'ใบงาน'}",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                dynamic res = null;
                if (obj['doc']['uid'] == null) {
                  AppStyle().confirm(context, "กรุณาระบุผู้รับงาน");
                } else if ((obj['doc']['status'] == null) && (obj['doc']['from_uid'] == AppStyle().session['data']['uid'])) {
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
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('ส่งใบงาน'),
                                    style: TextStyle(
                                      fontSize: AppStyle().btnFontSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context, {'action': 'Send'});
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
                                    Navigator.pop(context, {'action': 'Save'});
                                  },
                                ),
                              ),
                              SizedBox(height: 80),
                            ],
                          );
                        });
                      });
                } else if ((obj['doc']['status'] == 'Todo') && (obj['doc']['uid'] == AppStyle().session['data']['uid'])) {
                  res = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                          dynamic myinfo = AppStyle().session['company']['members'][AppStyle().session['data']['uid']];
                          var mydep = myinfo['department'];

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
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.green, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('รับงาน'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'Confirm'});
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Colors.red, fixedSize: Size((MediaQuery.of(context).size.width - 40) * 0.5, AppStyle().btnHeight)),
                                      child: Text(
                                        AppStyle().tr('ปฏิเสธงาน'),
                                        style: TextStyle(
                                          fontSize: AppStyle().btnFontSize,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context, {'action': 'Reject'});
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
                } else if ((obj['doc']['status'] == 'Doing') && (obj['doc']['uid'] == AppStyle().session['data']['uid'])) {
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
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: Colors.green, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('ดำเนินการเสร็จสิ้น'),
                                    style: TextStyle(
                                      fontSize: AppStyle().btnFontSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context, {'action': 'Done'});
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: Colors.grey, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                  child: Text(
                                    AppStyle().tr('บันทึกเอกสาร'),
                                    style: TextStyle(
                                      fontSize: AppStyle().btnFontSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context, {'action': 'Save'});
                                  },
                                ),
                              ),
                              SizedBox(height: 80),
                            ],
                          );
                        });
                      });
                }

                if (res != null) {
                  dynamic payload = {};
                  String FCM = "";
                  images = [];
                  for (var i = 0; i < (obj['files'] ?? []).length; i++) {
                    if (obj['files'][i]['url'] != '') {
                      images.add(obj['files'][i]['url']);
                    }
                  }
                  obj['doc']['date'] = FieldValue.serverTimestamp();
                  obj['doc']['task_begin'] = task_begin;
                  obj['doc']['task_end'] = task_end;
                  obj['doc']['project'] = obj['doc']['project'];
                  obj['doc']['task_remark'] = remarkController.text;
                  obj['doc']['task_subject'] = subjectController.text;
                  obj['doc']['images'] = images;
                  obj['doc']['companyId'] = AppStyle().session['company']['uid'];
                  if (res['action'] == 'Send') {
                    obj['doc']['status'] = "Todo";
                    FCM = AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['FCM'] ?? '';
                    if (FCM != '') {
                      payload = {
                        'FCM': FCM,
                        'uid': obj['doc']['uid'],
                        'title': 'มีงานใหม่ถึงคุณ',
                        'body': '${obj['doc']['task_subject']}',
                        'data': {
                          'body': '${obj['doc']['task_subject']}',
                          'action': 'task',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                    }
                  }
                  if (res['action'] == 'Confirm') {
                    obj['doc']['status'] = "Doing";
                    FCM = AppStyle().session['company']['members'][obj['doc']['from_uid']]['userinfo']['FCM'] ?? '';
                    if (FCM != '') {
                      payload = {
                        'FCM': FCM,
                        'uid': obj['doc']['uid'],
                        'title': 'งานของคุณได้รับการยืนยันแล้ว',
                        'body': '${obj['doc']['task_subject']}',
                        'data': {
                          'body': '${obj['doc']['task_subject']}',
                          'action': 'task',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                    }
                  }
                  if (res['action'] == 'Done') {
                    obj['doc']['status'] = "Done";
                    FCM = AppStyle().session['company']['members'][obj['doc']['from_uid']]['userinfo']['FCM'] ?? '';
                    if (FCM != '') {
                      payload = {
                        'FCM': FCM,
                        'uid': obj['doc']['uid'],
                        'title': 'งานของคุณดำเนินการเสร็จสิ้นแล้ว',
                        'body': '${obj['doc']['task_subject']}',
                        'data': {
                          'body': '${obj['doc']['task_subject']}',
                          'action': 'task',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                    }
                  }
                  if (res['action'] == 'Reject') {
                    obj['doc']['status'] = "Reject";
                    FCM = AppStyle().session['company']['members'][obj['doc']['from_uid']]['userinfo']['FCM'] ?? '';
                    if (FCM != '') {
                      payload = {
                        'FCM': FCM,
                        'uid': obj['doc']['uid'],
                        'title': 'งานของคุณได้รับการปฏิเสธ',
                        'body': '${obj['doc']['task_subject']}',
                        'data': {
                          'body': '${obj['doc']['task_subject']}',
                          'action': 'task',
                          'did': obj['doc']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                    }
                  }
                  if (obj['doc']['id'] == null) {
                    await FirebaseFirestore.instance.collection('tasks').add(obj['doc']).then((value) {
                      setState(() {
                        obj['doc']['id'] = value.id;
                      });
                    });
                  } else {
                    await FirebaseFirestore.instance.collection('tasks').doc(obj['doc']['id']).set(obj['doc'], SetOptions(merge: true));
                  }

                  if (obj['doc']['status'] != null) {
                    if (FCM != '') {
                      payload['data']['did'] = obj['doc']['id'];
                      await FirebaseFirestore.instance.collection('notification').add(payload);
                    }
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
                  'ใบงาน',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (obj['doc']['status'] == null) ? Colors.amber : Colors.grey[300],
                ),
                child: Center(
                  child: Text('Draft'),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (obj['doc']['status'] == 'Todo') ? Colors.amber : Colors.grey[300],
                ),
                child: Center(
                  child: Text('Todo'),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (obj['doc']['status'] == 'Doing') ? Colors.amber : Colors.grey[300],
                ),
                child: Center(
                  child: Text('Doing'),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (obj['doc']['status'] == 'Done') ? Colors.amber : Colors.grey[300],
                ),
                child: Center(
                  child: Text('Done'),
                ),
              ),
            ],
          ),
          (obj['doc']['from_uid'] == AppStyle().session['data']['uid'])
              ? Container()
              : ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage("${AppStyle().session['company']['members'][obj['doc']['from_uid']]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                  ),
                  subtitle: Text(
                    "${AppStyle().session['company']['members'][obj['doc']['from_uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                  ),
                  title: Text(
                    "ผู้สั่งงาน",
                  ),
                ),
          Divider(height: 1),
          (obj['doc']['uid'] == null)
              ? ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(AppStyle().no_user_url),
                  ),
                  subtitle: Text(
                    "Please select",
                  ),
                  title: Text(
                    "ผู้รับงาน",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          dynamic res = await Navigator.pushNamed(context, '/scrb017', arguments: {'data': obj['ori_users']});
                          if (res != null) {
                            obj['doc']['uid'] = res['data']['userinfo']['uid'];
                            setState(() {});
                          }
                        },
                )
              : ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage("${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                  ),
                  subtitle: Text(
                    "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                  ),
                  title: Text(
                    "ผู้รับงาน",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          dynamic res = await Navigator.pushNamed(context, '/scrb017', arguments: {'data': obj['ori_users']});
                          if (res != null) {
                            obj['doc']['uid'] = res['data']['userinfo']['uid'];
                            setState(() {});
                          }
                        },
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
                Row(
                  children: [
                    Container(
                      width: size.width * 0.5,
                      child: ListTile(
                        title: Text(
                          "วันที่เริ่ม",
                        ),
                        subtitle: Text(
                          "${DateFormat("dd MMMM yyyy").format(task_begin)}",
                        ),
                        trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                        onTap: (readonly)
                            ? null
                            : () async {
                                var res = await Navigator.pushNamed(context, '/util101', arguments: {
                                  'date': task_begin,
                                  'title': 'วันที่เริ่ม',
                                  'datetime': 'N',
                                  'barcolor': Color.fromARGB(255, 69, 69, 69),
                                });
                                if (res != null) {
                                  task_begin = res as DateTime;
                                  obj['doc']['task_begin'] = task_begin;
                                  setState(() {});
                                }
                              },
                      ),
                    ),
                    Container(
                      width: size.width * 0.5,
                      child: ListTile(
                        title: Text(
                          "วันที่สิ้นสุด",
                        ),
                        subtitle: Text(
                          "${DateFormat("dd MMMM yyyy").format(task_end)}",
                        ),
                        trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                        onTap: (readonly)
                            ? null
                            : () async {
                                var res = await Navigator.pushNamed(context, '/util101', arguments: {
                                  'date': task_end,
                                  'title': 'วันที่สิ้นสุด',
                                  'datetime': 'N',
                                  'barcolor': Color.fromARGB(255, 69, 69, 69),
                                });
                                if (res != null) {
                                  task_end = res as DateTime;
                                  obj['doc']['task_end'] = task_end;
                                  setState(() {});
                                }
                              },
                      ),
                    ),
                  ],
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
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "ประเภทงาน",
                  ),
                  subtitle: Text(
                    "${obj['doc']['task_type'] ?? ''}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          AppStyle().session['data']['master_task_type'] ??= [];
                          var res = await Navigator.pushNamed(context, '/util103', arguments: {
                            'list': AppStyle().session['data']['master_task_type'] ?? [],
                            'key': 'name',
                            'select': obj['doc']['task_type'],
                            'Add': 'Y',
                            'Delete': 'Y'
                          });
                          if (res != null) {
                            var res2 = res as Map<String, dynamic>;
                            obj['doc']['task_type'] = res2['keyword'];

                            bool addnew = true;

                            for (var i = 0; i < AppStyle().session['data']['master_task_type'].length; i++) {
                              if (AppStyle().session['data']['master_task_type'][i]['name'] == res2['keyword']) {
                                addnew = false;
                              }
                            }
                            if (addnew) {
                              AppStyle().session['data']['master_task_type'].add({
                                'name': res2['keyword'],
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(AppStyle().session['user'].uid)
                                  .set({'master_task_type': AppStyle().session['data']['master_task_type']}, SetOptions(merge: true));
                            }

                            setState(() {});
                          }
                        },
                ),
                TextField(
                  readOnly: readonly,
                  controller: subjectController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'หัวเรื่อง',
                    labelText: 'หัวเรื่อง',
                  ),
                  onChanged: (val) {
                    setState(() {
                      obj['doc']['task_subject'] = subjectController.text;
                    });
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
                    hintText: 'รายละเอียด',
                    labelText: 'รายละเอียด',
                  ),
                  onChanged: (val) {
                    setState(() {
                      task_remark = remarkController.text;
                      obj['doc']['task_remark'] = remarkController.text;
                    });
                  },
                ),
                ListTile(
                  title: Text(
                    "Check list",
                  ),
                  trailing: (readonly)
                      ? null
                      : InkWell(
                          onTap: () {},
                          child: InkWell(
                            onTap: () async {
                              var res = await AppStyle().confirmData(context, '', "Check list item");
                              if (res != null) {
                                obj['doc']['checklist'] ??= [];
                                obj['doc']['checklist'].add({'title': res, 'checked': false});
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add_box_outlined),
                          ),
                        ),
                ),
                Divider(height: 1),
                Builder(builder: (context) {
                  List<Widget> list = [];
                  obj['doc']['checklist'] ??= [];

                  for (var i = 0; i < obj['doc']['checklist'].length; i++) {
                    list.add(ListTile(
                      onTap: (obj['doc']['uid'] != AppStyle().session['data']['uid'])
                          ? null
                          : () async {
                              obj['doc']['checklist'][i]['checked'] = !obj['doc']['checklist'][i]['checked'];
                              setState(() {});
                            },
                      leading: (obj['doc']['checklist'][i]['checked']) ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                      title: Text('${obj['doc']['checklist'][i]['title']}'),
                    ));
                  }
                  return Column(
                    children: list,
                  );
                }),
                (obj['doc']['uid'] != AppStyle().session['data']['uid'])
                    ? Container()
                    : TextField(
                        controller: resultController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 3,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFEEEEEE),
                          hintText: 'บันทึกการดำเนินงาน',
                          labelText: 'บันทึกการดำเนินงาน',
                        ),
                        onChanged: (val) {
                          setState(() {
                            obj['doc']['task_result'] = resultController.text;
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
                                storageRef.child("users/" + AppStyle().session['user'].uid + "/images/" + DateFormat("yyyyMM").format(DateTime.now()) + "/in_" + image.name);
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
                (obj['doc']['from_uid'] == AppStyle().session['data']['uid'])
                    ? Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                          child: Text(
                            AppStyle().tr('ลบใบงาน'),
                            style: TextStyle(
                              fontSize: AppStyle().btnFontSize,
                            ),
                          ),
                          onPressed: () async {
                            var res = await AppStyle().confirm(context, "ต้องการยืนยันที่จะลบใบงานใช่หรือไม่ ?");
                            if (res != null) {
                              if (obj['doc']['id'] != null) {
                                await FirebaseFirestore.instance.collection('tasks').doc(obj['doc']['id']).delete();
                              }

                              Navigator.pop(context, {'action': 'Delete'});
                            }
                          },
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

  void initData() async {
    AppStyle().session['company']['members'].forEach((key, value) {
      value['uid'] = key;
      value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
      if (key != AppStyle().session['data']['uid']) {
        obj['ori_users'].add(value);
      }
    });

    setState(() {});
  }
}
