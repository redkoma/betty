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

class Scrb038FormMemo extends StatefulWidget {
  const Scrb038FormMemo({Key? key}) : super(key: key);

  @override
  _Scrb038FormMemoState createState() => _Scrb038FormMemoState();
}

class _Scrb038FormMemoState extends State<Scrb038FormMemo> {
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
  String key_type = 'memo_type';

  DateTime create_date = DateTime.now();
  DateTime payout_date = DateTime.now();
  String memo_subject = "";
  String memo_type = '';
  String memo_remark = '';
  bool memo_forward = false;
  List images = [];
  List user_list = [];
  TextEditingController remarkController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
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
        memo_subject = "";
      } else {
        if (obj['doc']['data']['create_date'] is DateTime) {
          create_date = obj['doc']['data']['create_date'];
        } else {
          obj['doc']['data']['create_date'] = obj['doc']['data']['create_date'].toDate();
          create_date = obj['doc']['data']['create_date'];
        }
      }

      if (obj['doc']['data']['memo_subject'] != null) {
        memo_subject = obj['doc']['data']['memo_subject'];
        subjectController.text = memo_subject;
      }
      if (obj['doc']['data']['memo_type'] != null) {
        memo_type = obj['doc']['data']['memo_type'];
      } else {
        memo_type = AppStyle().session['company']['memo_type'][0]['name'];
      }

      if (obj['doc']['data']['remark'] != null) {
        memo_remark = obj['doc']['data']['remark'];
        remarkController.text = memo_remark;
      }
      memo_forward = obj['doc']['data']['memo_forward'] ?? false;

      if (obj['doc']['data']['images'] != null) {
        obj['files'] = [];
        for (var i = 0; i < (obj['doc']['data']['images'] ?? []).length; i++) {
          obj['files'].add({'url': obj['doc']['data']['images'][i]});
        }
      }
      obj['count_user'] = 0;
      if (obj['doc']['data']['memo_list'] != null) {
        obj['doc']['data']['memo_list'].forEach((key, value) {
          obj['count_user']++;
        });
      }
      if (obj['doc']['status'] != null) {
        readonly = true;
      }

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 179, 2, 123),
        title: Text(
          "${memo_type == '' ? 'เอกสารภายใน' : memo_type}",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
              onPressed: ((obj['count_user'] ?? 0) == 0)
                  ? () async {
                      AppStyle().alert(context, "กรุณาเลือกรายชื่อผู้รับ อย่างน้อย 1 ท่าน");
                    }
                  : () async {
                      dynamic res = null;

                      if ((obj['doc']['status'] == null) && (obj['doc']['uid'] == AppStyle().session['data']['uid'])) {
                        // Owner view on Status is not set
                        // Save or Send & Preview Flow
                        res = await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                                dynamic myinfo = AppStyle().session['company']['members'][AppStyle().session['data']['uid']];
                                var mydep = myinfo['department'];
                                dynamic manager = {};
                                for (var i = 0; i < (AppStyle().session['company']['department'] ?? []).length; i++) {
                                  if (AppStyle().session['company']['department'][i]['enable']) {
                                    if (AppStyle().session['company']['department'][i]['name'] == mydep) {
                                      manager = AppStyle().session['company']['department'][i]['managerinfo'];
                                    }
                                  }
                                }

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
                                          "assets/images/memo_setting_001.png",
                                          height: size.height * 0.3,
                                        )),
                                    Center(
                                      child: ElevatedButton(
                                        style:
                                            ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                        child: Text(
                                          AppStyle().tr('ส่งเอกสาร'),
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
                      } else if ((obj['doc']['status'] != null) && (obj['doc']['data']['memo_list'][AppStyle().session['data']['uid']] != null)) {
                        // Owner view on Status is not set
                        // Save or Send & Preview Flow
                        res = await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
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
                                          "assets/images/memo_setting_001.png",
                                          height: size.height * 0.3,
                                        )),
                                    Container(
                                      width: size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(primary: Colors.green, fixedSize: Size((MediaQuery.of(context).size.width - 40), AppStyle().btnHeight)),
                                            child: Text(
                                              AppStyle().tr('รับทราบ / ดำเนินการเรียบร้อย'),
                                              style: TextStyle(
                                                fontSize: AppStyle().btnFontSize,
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context, {'action': 'MemoResponse'});
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
                        if (res['action'] == 'MemoResponse') {
                          obj['doc']['data']['memo_response'] ??= {};
                          obj['doc']['data']['memo_response'][AppStyle().session['data']['uid']] = 'Confirmed';
                        }
                        AppStyle().showLoader(context);
                        images = [];
                        for (var i = 0; i < (obj['files'] ?? []).length; i++) {
                          if (obj['files'][i]['url'] != '') {
                            images.add(obj['files'][i]['url']);
                          }
                        }

                        obj['doc']['data']['memo_forward'] = memo_forward;
                        obj['doc']['data']['memo_type'] = memo_type;
                        obj['doc']['data']['memo_subject'] = memo_subject;
                        obj['doc']['data']['remark'] = memo_remark;
                        obj['doc']['data']['images'] = images;
                        obj['doc']['companyId'] = AppStyle().session['company']['uid'];
                        if (res['action'] == 'Send') {
                          obj['doc']['data']['create_date'] = FieldValue.serverTimestamp();
                          // Case normal
                          obj['doc']['status'] = "Sent";
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
                          obj['doc']['data']['memo_list'].forEach((key, value) async {
                            await FirebaseFirestore.instance.collection('inbox').doc("${obj['doc']['id']}-$key").set({
                              'date': FieldValue.serverTimestamp(),
                              'docid': obj['doc']['id'],
                              'uid': key,
                              'show_uid': obj['doc']['uid'],
                              'doctype': 'memo',
                              'folder_code': 'memo_approval',
                              'title':
                                  "${AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][obj['doc']['uid']]['userinfo']['email']}",
                              'subtitle': '${obj['doc']['data']['memo_subject']} (${obj['doc']['data']['memo_type']})',
                              'status': value,
                              'status_color': '',
                            });

                            // Send Notification to requester ?
                            String FCM = AppStyle().session['company']['members'][key]['userinfo']['FCM'] ?? '';
                            var payload = {
                              'FCM': FCM,
                              'uid': key,
                              'title': '$value',
                              'body': '${obj['doc']['data']['memo_subject']} (${obj['doc']['data']['memo_type']})',
                              'data': {
                                'body': '${obj['doc']['data']['memo_subject']} (${obj['doc']['data']['memo_type']})',
                                'action': 'memo',
                                'did': obj['doc']['id'],
                              },
                              'date': FieldValue.serverTimestamp(),
                              'status': 'WAIT',
                            };
                            await FirebaseFirestore.instance.collection('notification').add(payload);
                          });
                        }
                        AppStyle().hideLoader(context);
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
                  'เอกสารภายใน',
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
                                  '${memo_type}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // SizedBox(height: 3),
                                Text(
                                  '${memo_subject}',
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
                0: FlexColumnWidth(),
                1: FixedColumnWidth(100),
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
                    "ประเภทเอกสาร",
                  ),
                  subtitle: Text(
                    "${memo_type}",
                  ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res =
                              await Navigator.pushNamed(context, '/util103', arguments: {'list': AppStyle().session['company']['memo_type'], 'key': 'name', 'select': memo_type});
                          if (res != null) {
                            var res2 = res as Map<String, dynamic>;
                            memo_type = res2['name'];
                            obj['doc']['data']['memo_type'] = memo_type;
                            setState(() {});
                          }
                        },
                ),
                Divider(
                  height: 1,
                ),
                ListTile(
                  title: Text(
                    "รายชื่อผู้รับ",
                  ),
                  subtitle: (obj['doc']['status'] != null)
                      ? Builder(builder: (context) {
                          if (obj['doc']['data']['memo_response'] == null) {
                            obj['doc']['data']['memo_response'] = {};
                          }
                          List<Widget> list = [];
                          (obj['doc']['data']['memo_list'] ?? {}).forEach((key, value) {
                            list.add(Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${AppStyle().session['company']['members'][key]['userinfo']['displayName'] ?? AppStyle().session['company']['members'][key]['userinfo']['email']}'),
                                Row(
                                  children: [
                                    (obj['doc']['data']['memo_response'][key] == 'Confirmed')
                                        ? Icon(
                                            Icons.check_box,
                                            color: Colors.green,
                                            size: 16,
                                          )
                                        : Container(),
                                    Text(
                                      '$value',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ));
                          });
                          return Column(
                            children: list,
                          );
                        })
                      : Text(
                          "${obj['count_user'] ?? 0}",
                        ),
                  trailing: (readonly) ? null : Icon(Icons.keyboard_arrow_right),
                  onTap: (readonly)
                      ? null
                      : () async {
                          var res = await Navigator.pushNamed(context, '/scrb039', arguments: {'select': obj['doc']['data']['memo_list'] ?? {}});
                          if (res != null) {
                            obj['count_user'] = 0;
                            var res2 = res as Map<String, dynamic>;
                            obj['doc']['data']['memo_list'] = res2['data'];
                            res2['data'].forEach((key, value) {
                              obj['count_user']++;
                            });
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
                Divider(
                  height: 1,
                ),
                (readonly)
                    ? ListTile(
                        title: Text(
                          "เรื่อง",
                        ),
                        subtitle: Text(
                          "${memo_subject}",
                        ),
                      )
                    : TextField(
                        readOnly: readonly,
                        controller: subjectController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFEEEEEE),
                          hintText: 'เรื่อง',
                          labelText: 'เรื่อง',
                        ),
                        onChanged: (val) {
                          setState(() {
                            memo_subject = subjectController.text;
                            obj['doc']['data']['memo_subject'] = subjectController.text;
                          });
                        },
                      ),
                Divider(height: 1),
                TextField(
                  readOnly: readonly,
                  controller: remarkController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 5,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'ข้อความ',
                    labelText: 'ข้อความ',
                  ),
                  onChanged: (val) {
                    setState(() {
                      memo_remark = remarkController.text;
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
                                storageRef.child("users/" + AppStyle().session['user'].uid + "/images/" + DateFormat("yyyyMM").format(DateTime.now()) + "/memo_" + image.name);
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
                    "วันที่ส่ง",
                  ),
                  subtitle: Text(
                    "${DateFormat("dd MMMM yyyy HH:mm").format(create_date)}",
                  ),
                ),
                Divider(height: 1),
                SizedBox(height: 80),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void initData() async {}
}
