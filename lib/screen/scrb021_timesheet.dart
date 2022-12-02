import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb021TimeSheet extends StatefulWidget {
  const Scrb021TimeSheet({Key? key}) : super(key: key);

  @override
  _Scrb021TimeSheetState createState() => _Scrb021TimeSheetState();
}

class _Scrb021TimeSheetState extends State<Scrb021TimeSheet> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
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
      if (obj["view_as"] == null) {
        obj["view_as"] = AppStyle().session['data']['uid'];
      }
      print("View as ${obj["view_as"]}");
      calcTimesheetStat(myyear, mymonth);
      initData();
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${mymonthtxt} ${myyear}"),
        actions: [
          TextButton(
              onPressed: () {
                mymonth--;
                if (mymonth == 0) {
                  myyear--;
                  mymonth = 12;
                }
                mymonthtxt = DateFormat("MMMM").format(DateTime(myyear, mymonth, 1));

                calcTimesheetStat(myyear, mymonth);
              },
              child: Text('Previous'))
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
                  'ประวัติการเข้าออกงาน',
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
            (obj['timesheet'] ?? {}).forEach((key, value) {
              if ((value['day'] <= cday) || (cmon != value['month'])) {
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
                                  '${value['wday']}',
                                  style: TextStyle(fontSize: 14, color: Colors.red),
                                ),
                                Text(
                                  '${value['day']}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: (value['in_txt'] != null)
                                    ? () async {
                                        var res = await showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: Icon(Icons.login),
                                                      title: Text(
                                                        "Check In",
                                                      ),
                                                      subtitle: (value['late'] != null)
                                                          ? Text(
                                                              "LATE",
                                                              style: TextStyle(color: Colors.redAccent),
                                                            )
                                                          : null,
                                                      trailing: Text("${value['in_txt']}"),
                                                    ),
                                                    (obj['view_as'] != AppStyle().session['data']['uid'])
                                                        ? Container()
                                                        : Padding(
                                                            padding: const EdgeInsets.all(15),
                                                            child: Center(
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    primary: Colors.amber, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                                                child: Text(
                                                                  AppStyle().tr('ขอปรับเวลาเข้างาน'),
                                                                  style: TextStyle(fontSize: AppStyle().btnFontSize, color: Colors.black),
                                                                ),
                                                                onPressed: () async {
                                                                  var at = value['in_txt'].toString().split(':');
                                                                  TimeOfDay initialTime = TimeOfDay(hour: int.parse(at[0]), minute: int.parse(at[1]));
                                                                  var time = await showTimePicker(context: context, initialTime: initialTime);
                                                                  if (time != null) {
                                                                    String adjust_txt = "${(time.hour < 10) ? '0' : ''}${time.hour}:${(time.minute < 10) ? '0' : ''}${time.minute}";
                                                                    var res = await AppStyle().confirmDataTextArea(context, "", "ขอปรับเป็นเวลา $adjust_txt เนื่องจาก");
                                                                    if (res != null) {
                                                                      obj['timesheet'][key]['in_adjust_hour'] = time.hour;
                                                                      obj['timesheet'][key]['in_adjust_min'] = time.minute;
                                                                      obj['timesheet'][key]['in_adjust_txt'] = adjust_txt;
                                                                      obj['timesheet'][key]['in_adjust_remark'] = res;
                                                                    }
                                                                  }
                                                                  Navigator.pop(context, {'action': 'AdjustTimeIn', 'res': obj['timesheet'][key], 'key': key});
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                    Row(
                                                      children: [
                                                        (value['in_location'] != null)
                                                            ? Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: GoogleMap(
                                                                  markers: <Marker>{
                                                                    Marker(
                                                                      markerId: MarkerId('marker_1'),
                                                                      position: LatLng(value['in_location']['lat'], value['in_location']['lng']),
                                                                    )
                                                                  },
                                                                  myLocationButtonEnabled: false,
                                                                  initialCameraPosition: CameraPosition(
                                                                    target: LatLng(value['in_location']['lat'], value['in_location']['lng']),
                                                                    zoom: 15, //กำหนดระยะการซูม สามารถกำหนดค่าได้ 0-20
                                                                  ),
                                                                  onMapCreated: (GoogleMapController controller) {
                                                                    // mapController = controller;
                                                                    // _controller.complete(controller);
                                                                  },
                                                                ),
                                                              )
                                                            : Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: Center(child: Text('No data')),
                                                              ),
                                                        (value['in_photo'] != null)
                                                            ? Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(value['in_photo'] ?? AppStyle().no_user_url),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: Center(child: Text('No data')),
                                                              ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              });
                                            });
                                        if (res != null) {
                                          String type = "ขอปรับเวลาเข้างาน ${res['res']['day']} ${res['res']['month']} ${res['res']['year']} ${res['res']['in_adjust_txt']}";
                                          await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['data']['uid']).set({
                                            "${res['key']}": res['res'],
                                          }, SetOptions(merge: true));
                                          obj['doc'] = {
                                            'doctype': 'time_adjust',
                                            'date': FieldValue.serverTimestamp(),
                                            'show': true,
                                            'status': 'Wait for Approval',
                                            'uid': AppStyle().session['data']['uid'],
                                            'companyId': AppStyle().session['company']['uid'],
                                            'data': res,
                                          };
                                          await FirebaseFirestore.instance.collection('documents').add(obj['doc']).then((value) {
                                            setState(() {
                                              obj['doc']['id'] = value.id;
                                            });
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('inbox')
                                              .doc("${obj['doc']['id']}-${AppStyle().session['company']['leave_final_user']['userinfo']['uid'] ?? 0}")
                                              .set({
                                            'date': FieldValue.serverTimestamp(),
                                            'docid': obj['doc']['id'],
                                            'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                            'show_uid': obj['doc']['uid'],
                                            'doctype': obj['doc']['doctype'],
                                            'folder_code': 'timesheet_approval',
                                            'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                            'subtitle': "$type",
                                            'status': obj['doc']['status'],
                                            'status_color': '',
                                          }, SetOptions(merge: true));
                                          String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]['userinfo']
                                                  ['FCM'] ??
                                              '';
                                          var payload = {
                                            'FCM': FCM,
                                            'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                            'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                            'body': '$type',
                                            'data': {
                                              'body': '$type',
                                              'action': obj['doc']['doctype'],
                                              'did': obj['doc']['id'],
                                            },
                                            'date': FieldValue.serverTimestamp(),
                                            'status': 'WAIT',
                                          };
                                          await FirebaseFirestore.instance.collection('notification').add(payload);
                                        }
                                      }
                                    : (value['working_time'] == null)
                                        ? null
                                        : () async {
                                            var res = await showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(Icons.login),
                                                          title: Text(
                                                            "Check In",
                                                          ),
                                                          subtitle: Text(
                                                            "ไม่มีข้อมูล",
                                                            style: TextStyle(color: Colors.redAccent),
                                                          ),
                                                          trailing: Text("N/A"),
                                                        ),
                                                        (obj['view_as'] != AppStyle().session['data']['uid'])
                                                            ? Container()
                                                            : Padding(
                                                                padding: const EdgeInsets.all(15),
                                                                child: Center(
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary: Colors.amber, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                                                    child: Text(
                                                                      AppStyle().tr('ขอปรับเวลาเข้างาน'),
                                                                      style: TextStyle(fontSize: AppStyle().btnFontSize, color: Colors.black),
                                                                    ),
                                                                    onPressed: () async {
                                                                      TimeOfDay initialTime = TimeOfDay(hour: 0, minute: 0);
                                                                      var time = await showTimePicker(context: context, initialTime: initialTime);
                                                                      if (time != null) {
                                                                        String adjust_txt =
                                                                            "${(time.hour < 10) ? '0' : ''}${time.hour}:${(time.minute < 10) ? '0' : ''}${time.minute}";
                                                                        var res = await AppStyle().confirmDataTextArea(context, "", "ขอปรับเป็นเวลา $adjust_txt เนื่องจาก");
                                                                        if (res != null) {
                                                                          obj['timesheet'][key]['in_adjust_hour'] = time.hour;
                                                                          obj['timesheet'][key]['in_adjust_min'] = time.minute;
                                                                          obj['timesheet'][key]['in_adjust_txt'] = adjust_txt;
                                                                          obj['timesheet'][key]['in_adjust_remark'] = res;
                                                                          print(time);
                                                                        }
                                                                      }
                                                                      Navigator.pop(context, {'action': 'AdjustTimeIn', 'res': obj['timesheet'][key], 'key': key});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    );
                                                  });
                                                });

                                            if (res != null) {
                                              String type = "ขอปรับเวลาเข้างาน ${res['res']['day']} ${res['res']['month']} ${res['res']['year']} ${res['res']['in_adjust_txt']}";
                                              await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['data']['uid']).set({
                                                "${res['key']}": res['res'],
                                              }, SetOptions(merge: true));
                                              obj['doc'] = {
                                                'doctype': 'time_adjust',
                                                'date': FieldValue.serverTimestamp(),
                                                'show': true,
                                                'status': 'Wait for Approval',
                                                'uid': AppStyle().session['data']['uid'],
                                                'companyId': AppStyle().session['company']['uid'],
                                                'data': res,
                                              };
                                              await FirebaseFirestore.instance.collection('documents').add(obj['doc']).then((value) {
                                                setState(() {
                                                  obj['doc']['id'] = value.id;
                                                });
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('inbox')
                                                  .doc("${obj['doc']['id']}-${AppStyle().session['company']['leave_final_user']['userinfo']['uid'] ?? 0}")
                                                  .set({
                                                'date': FieldValue.serverTimestamp(),
                                                'docid': obj['doc']['id'],
                                                'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                                'show_uid': obj['doc']['uid'],
                                                'doctype': obj['doc']['doctype'],
                                                'folder_code': 'timesheet_approval',
                                                'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                                'subtitle': "$type",
                                                'status': obj['doc']['status'],
                                                'status_color': '',
                                              }, SetOptions(merge: true));
                                              String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]
                                                      ['userinfo']['FCM'] ??
                                                  '';
                                              var payload = {
                                                'FCM': FCM,
                                                'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                                'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                                'body': '$type',
                                                'data': {
                                                  'body': '$type',
                                                  'action': obj['doc']['doctype'],
                                                  'did': obj['doc']['id'],
                                                },
                                                'date': FieldValue.serverTimestamp(),
                                                'status': 'WAIT',
                                              };
                                              await FirebaseFirestore.instance.collection('notification').add(payload);
                                            }
                                          },
                                child: Container(
                                  height: rowheight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${value['in_txt'] ?? '00:00'}',
                                        style: TextStyle(fontSize: 20, color: (value['in_txt'] == null) ? Colors.grey[200] : Colors.black),
                                      ),
                                      (value['late'] != null)
                                          ? Text(
                                              'LATE',
                                              style: TextStyle(fontSize: 10, color: Colors.redAccent),
                                            )
                                          : Container(),
                                      (value['in_adjust_txt'] != null)
                                          ? Text(
                                              'ขอปรับเวลา ${value['in_adjust_txt']}',
                                              style: TextStyle(fontSize: 10, color: Colors.redAccent),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (value['out_txt'] != null)
                                    ? () async {
                                        var res = await showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: Icon(Icons.login),
                                                      title: Text(
                                                        "Check Out",
                                                      ),
                                                      subtitle: (value['early_out'] != null)
                                                          ? Text(
                                                              "EARLY OUT",
                                                              style: TextStyle(color: Colors.redAccent),
                                                            )
                                                          : null,
                                                      trailing: Text("${value['out_txt']}"),
                                                    ),
                                                    (obj['view_as'] != AppStyle().session['data']['uid'])
                                                        ? Container()
                                                        : Padding(
                                                            padding: const EdgeInsets.all(15),
                                                            child: Center(
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    primary: Colors.amber, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                                                child: Text(
                                                                  AppStyle().tr('ขอปรับเวลาออกงาน'),
                                                                  style: TextStyle(fontSize: AppStyle().btnFontSize, color: Colors.black),
                                                                ),
                                                                onPressed: () async {
                                                                  var at = value['out_txt'].toString().split(':');
                                                                  TimeOfDay initialTime = TimeOfDay(hour: int.parse(at[0]), minute: int.parse(at[1]));
                                                                  var time = await showTimePicker(context: context, initialTime: initialTime);
                                                                  if (time != null) {
                                                                    String adjust_txt = "${(time.hour < 10) ? '0' : ''}${time.hour}:${(time.minute < 10) ? '0' : ''}${time.minute}";
                                                                    var res = await AppStyle().confirmDataTextArea(context, "", "ขอปรับเป็นเวลา $adjust_txt เนื่องจาก");
                                                                    if (res != null) {
                                                                      obj['timesheet'][key]['out_adjust_hour'] = time.hour;
                                                                      obj['timesheet'][key]['out_adjust_min'] = time.minute;
                                                                      obj['timesheet'][key]['out_adjust_txt'] = adjust_txt;
                                                                      obj['timesheet'][key]['out_adjust_remark'] = res;
                                                                    }
                                                                  }
                                                                  Navigator.pop(context, {'action': 'AdjustTimeOut', 'res': obj['timesheet'][key], 'key': key});
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                    Row(
                                                      children: [
                                                        (value['out_location'] != null)
                                                            ? Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: GoogleMap(
                                                                  markers: <Marker>{
                                                                    Marker(
                                                                      markerId: MarkerId('marker_1'),
                                                                      position: LatLng(value['out_location']['lat'], value['out_location']['lng']),
                                                                    )
                                                                  },
                                                                  myLocationButtonEnabled: false,
                                                                  initialCameraPosition: CameraPosition(
                                                                    target: LatLng(value['out_location']['lat'], value['out_location']['lng']),
                                                                    zoom: 15, //กำหนดระยะการซูม สามารถกำหนดค่าได้ 0-20
                                                                  ),
                                                                  onMapCreated: (GoogleMapController controller) {
                                                                    // mapController = controller;
                                                                    // _controller.complete(controller);
                                                                  },
                                                                ),
                                                              )
                                                            : Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: Center(child: Text('No data')),
                                                              ),
                                                        (value['out_photo'] != null)
                                                            ? Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(value['out_photo'] ?? AppStyle().no_user_url),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: size.width * 0.7,
                                                                width: size.width * 0.5,
                                                                child: Center(child: Text('No data')),
                                                              ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              });
                                            });

                                        if (res != null) {
                                          String type = "ขอปรับเวลาออกงาน ${res['res']['day']} ${res['res']['month']} ${res['res']['year']} ${res['res']['out_adjust_txt']}";
                                          await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['data']['uid']).set({
                                            "${res['key']}": res['res'],
                                          }, SetOptions(merge: true));
                                          obj['doc'] = {
                                            'doctype': 'time_adjust',
                                            'date': FieldValue.serverTimestamp(),
                                            'show': true,
                                            'status': 'Wait for Approval',
                                            'uid': AppStyle().session['data']['uid'],
                                            'companyId': AppStyle().session['company']['uid'],
                                            'data': res,
                                          };
                                          await FirebaseFirestore.instance.collection('documents').add(obj['doc']).then((value) {
                                            setState(() {
                                              obj['doc']['id'] = value.id;
                                            });
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('inbox')
                                              .doc("${obj['doc']['id']}-${AppStyle().session['company']['leave_final_user']['userinfo']['uid'] ?? 0}")
                                              .set({
                                            'date': FieldValue.serverTimestamp(),
                                            'docid': obj['doc']['id'],
                                            'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                            'show_uid': obj['doc']['uid'],
                                            'doctype': obj['doc']['doctype'],
                                            'folder_code': 'timesheet_approval',
                                            'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                            'subtitle': "$type",
                                            'status': obj['doc']['status'],
                                            'status_color': '',
                                          }, SetOptions(merge: true));
                                          String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]['userinfo']
                                                  ['FCM'] ??
                                              '';
                                          var payload = {
                                            'FCM': FCM,
                                            'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                            'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                            'body': '$type',
                                            'data': {
                                              'body': '$type',
                                              'action': obj['doc']['doctype'],
                                              'did': obj['doc']['id'],
                                            },
                                            'date': FieldValue.serverTimestamp(),
                                            'status': 'WAIT',
                                          };
                                          await FirebaseFirestore.instance.collection('notification').add(payload);
                                        }
                                      }
                                    : (value['working_time'] == null)
                                        ? null
                                        : () async {
                                            var res = await showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(Icons.login),
                                                          title: Text(
                                                            "Check Out",
                                                          ),
                                                          subtitle: Text(
                                                            "ไม่มีข้อมูล",
                                                            style: TextStyle(color: Colors.redAccent),
                                                          ),
                                                          trailing: Text("N/A"),
                                                        ),
                                                        (obj['view_as'] != AppStyle().session['data']['uid'])
                                                            ? Container()
                                                            : Padding(
                                                                padding: const EdgeInsets.all(15),
                                                                child: Center(
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary: Colors.amber, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                                                                    child: Text(
                                                                      AppStyle().tr('ขอปรับเวลาออกงาน'),
                                                                      style: TextStyle(fontSize: AppStyle().btnFontSize, color: Colors.black),
                                                                    ),
                                                                    onPressed: () async {
                                                                      TimeOfDay initialTime = TimeOfDay(hour: 0, minute: 0);
                                                                      var time = await showTimePicker(context: context, initialTime: initialTime);
                                                                      if (time != null) {
                                                                        String adjust_txt =
                                                                            "${(time.hour < 10) ? '0' : ''}${time.hour}:${(time.minute < 10) ? '0' : ''}${time.minute}";

                                                                        var res = await AppStyle().confirmDataTextArea(context, "", "ขอปรับเป็นเวลา $adjust_txt เนื่องจาก");
                                                                        if (res != null) {
                                                                          obj['timesheet'][key]['out_adjust_hour'] = time.hour;
                                                                          obj['timesheet'][key]['out_adjust_min'] = time.minute;
                                                                          obj['timesheet'][key]['out_adjust_txt'] = adjust_txt;
                                                                          obj['timesheet'][key]['out_adjust_remark'] = res;
                                                                        }
                                                                      }
                                                                      Navigator.pop(context, {'action': 'AdjustTimeOut', 'res': obj['timesheet'][key], 'key': key});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    );
                                                  });
                                                });
                                            if (res != null) {
                                              String type = "ขอปรับเวลาออกงาน ${res['res']['day']} ${res['res']['month']} ${res['res']['year']} ${res['res']['out_adjust_txt']}";
                                              await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['data']['uid']).set({
                                                "${res['key']}": res['res'],
                                              }, SetOptions(merge: true));
                                              obj['doc'] = {
                                                'doctype': 'time_adjust',
                                                'date': FieldValue.serverTimestamp(),
                                                'show': true,
                                                'status': 'Wait for Approval',
                                                'uid': AppStyle().session['data']['uid'],
                                                'companyId': AppStyle().session['company']['uid'],
                                                'data': res,
                                              };
                                              await FirebaseFirestore.instance.collection('documents').add(obj['doc']).then((value) {
                                                setState(() {
                                                  obj['doc']['id'] = value.id;
                                                });
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('inbox')
                                                  .doc("${obj['doc']['id']}-${AppStyle().session['company']['leave_final_user']['userinfo']['uid'] ?? 0}")
                                                  .set({
                                                'date': FieldValue.serverTimestamp(),
                                                'docid': obj['doc']['id'],
                                                'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                                'show_uid': obj['doc']['uid'],
                                                'doctype': obj['doc']['doctype'],
                                                'folder_code': 'timesheet_approval',
                                                'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                                'subtitle': "$type",
                                                'status': obj['doc']['status'],
                                                'status_color': '',
                                              }, SetOptions(merge: true));
                                              String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]
                                                      ['userinfo']['FCM'] ??
                                                  '';
                                              var payload = {
                                                'FCM': FCM,
                                                'uid': AppStyle().session['company']['leave_final_user']['userinfo']['uid'],
                                                'title': '${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                                'body': '$type',
                                                'data': {
                                                  'body': '$type',
                                                  'action': obj['doc']['doctype'],
                                                  'did': obj['doc']['id'],
                                                },
                                                'date': FieldValue.serverTimestamp(),
                                                'status': 'WAIT',
                                              };
                                              await FirebaseFirestore.instance.collection('notification').add(payload);
                                            }
                                          },
                                child: Container(
                                  height: rowheight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${value['out_txt'] ?? '00:00'}',
                                        style: TextStyle(fontSize: 20, color: (value['out_txt'] == null) ? Colors.grey[200] : Colors.black),
                                      ),
                                      (value['early_out'] != null)
                                          ? Text(
                                              'EARLY OUT',
                                              style: TextStyle(fontSize: 10, color: Colors.redAccent),
                                            )
                                          : Container(),
                                      (value['out_adjust_txt'] != null)
                                          ? Text(
                                              'ขอปรับเวลา ${value['out_adjust_txt']}',
                                              style: TextStyle(fontSize: 10, color: Colors.redAccent),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isLeave(key, obj['leave'], value)
                              ? Container(
                                  color: Color.fromARGB(255, 246, 228, 112),
                                  height: rowheight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Leave',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${obj['leave'][key]['data']['leave_type']}',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ))
                              : (value['holiday'] != null)
                                  ? Container(
                                      color: Color.fromARGB(255, 255, 209, 205),
                                      height: rowheight,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Holiday',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            '${value['holiday']['name']}',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ))
                                  : (value['working_time'] != null)
                                      ? Container(
                                          color: Color.fromARGB(255, 205, 231, 255),
                                          height: rowheight,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Working day',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                '${value['working_time']['begin']}-${value['working_time']['end']}',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ))
                                      : Container(),

                          // Container(
                          //   height: rowheight,
                          //   child: GoogleMap(
                          //     markers: <Marker>{
                          //       Marker(
                          //         markerId: MarkerId('marker_1'),
                          //         position: AppStyle().session['location'] ?? LatLng(0.0, 0.0),
                          //       )
                          //     },
                          //     myLocationButtonEnabled: false,
                          //     initialCameraPosition: CameraPosition(
                          //       target: AppStyle().session['location'] ?? LatLng(0.0, 0.0),
                          //       zoom: 15, //กำหนดระยะการซูม สามารถกำหนดค่าได้ 0-20
                          //     ),
                          //     onMapCreated: (GoogleMapController controller) {
                          //       // mapController = controller;
                          //       // _controller.complete(controller);
                          //     },
                          //   ),
                          // ),
                          // Container(
                          //   height: rowheight,
                          //   decoration: BoxDecoration(
                          //     image: DecorationImage(
                          //       image: NetworkImage(AppStyle().no_user_url),
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // )
                        ]));
              }
            });
            return Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(64),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(100),
                // 3: FixedColumnWidth(100),
                // 4: FixedColumnWidth(64),
              },
              children: row,
            );
          }),
        ]),
      ),
    );
  }

  void calcTimesheetStat(int year, int mon) async {
    // Process dashboard
    var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var day = DateTime(year, mon + 1, 0).day;
    var date = DateTime(year, mon, day);
    // print(day);
    var month = {};

// check shift if have shift calendar user shift working time
    var cal = AppStyle().session['company']['members'][obj["view_as"]]['calendar'];
    if (AppStyle().session['calendar'][obj["view_as"]] != null) {
      cal = AppStyle().session['calendar'][obj["view_as"]];
    }
    var shift = {};
    int shift_count = 0;
    print("-------------------------");
    print(cal);
    if (cal != null) {
      for (var i = 1; i <= day; i++) {
        var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
        if (cal[key] != null) {
          shift_count++;
          if (shift[cal[key]] == null) {
            shift[cal[key]] = {};
            for (var x = 0; x < (AppStyle().session['company']['working_time'][cal[key]] ?? []).length; x++) {
              var _w = AppStyle().session['company']['working_time'][cal[key]][x]['wday'].toLowerCase();
              shift[cal[key]][_w] = AppStyle().session['company']['working_time'][cal[key]][x];
            }
          }
        }
      }
    }
    print(shift);
    dynamic time_sheet;
    await FirebaseFirestore.instance.collection('timesheet').doc(obj["view_as"]).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        time_sheet = documentSnapshot.data();
      }
    });
    time_sheet ??= {};
    // Working Time
    var working_time = {};
    for (var i = 0; i < (AppStyle().session['company']['working_time']['default'] ?? []).length; i++) {
      var key = AppStyle().session['company']['working_time']['default'][i]['wday'].toLowerCase();
      if (AppStyle().session['company']['working_time']['default'][i]['enable']) {
        working_time[key] = AppStyle().session['company']['working_time']['default'][i];
      }
    }
    // print(working_time);
    for (var i = 1; i <= day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
      month[key] = time_sheet[key] ?? {};
      // Flag Shift
      // Flag working day
      var wday = DateTime(date.year, date.month, i).weekday;
      // print(wd[wday]);
      month[key]['day'] = i;
      month[key]['wday'] = wd[wday];
      month[key]['month'] = DateFormat("MMM").format(date);
      month[key]['mon'] = date.month;
      month[key]['year'] = date.year;
      if (shift_count == 0) {
        if (working_time[wd[wday]] != null) {
          month[key]['working_time'] = working_time[wd[wday]];
        }
      } else {
        if (cal[key] != null) {
          month[key]['working_time'] = shift[cal[key]][wd[wday]];
        }
      }
    }
    for (var i = 0; i < (AppStyle().session['company']['holiday'] ?? []).length; i++) {
      // Flag Holiday
      var hdate = AppStyle().session['company']['holiday'][i]['date'].toDate();
      var key = DateFormat("yyyyMMdd").format(DateTime(date.year, hdate.month, hdate.day));
      if (hdate.month == date.month) {
        if (AppStyle().session['company']['holiday'][i]['enable']) {
          month[key]['holiday'] = AppStyle().session['company']['holiday'][i];
        }
      }
    }
    // Calc until current day
    var stat = {
      'in': 0,
      'out': 0,
      'absence': 0,
      'late': 0,
      'early_out': 0,
      'leave': 0,
    };
    for (var i = 1; i <= date.day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
      // print(key);
      var m = month[key];

      if (m['working_time'] != null) {
//        print("Working");
        if (m['holiday'] == null) {
          if (m['in'] != null) {
            stat['in'] = (stat['in'] ?? 0) + 1;
            month[key]['in_txt'] = DateFormat("HH:mm").format(m['in'].toDate());
            if ((DateFormat("HH:mm").format(m['in'].toDate())).compareTo(m['working_time']['begin'].toString()) > 0) {
              stat['late'] = (stat['late'] ?? 0) + 1;
              month[key]['late'] = 'Y';
            }
          }
          if (m['out'] != null) {
            stat['out'] = (stat['out'] ?? 0) + 1;
            month[key]['out_txt'] = DateFormat("HH:mm").format(m['out'].toDate());
            if ((DateFormat("HH:mm").format(m['out'].toDate())).compareTo(m['working_time']['end'].toString()) < 0) {
              stat['early_out'] = (stat['early_out'] ?? 0) + 1;
              month[key]['early_out'] = 'Y';
            }
          }

          if ((m['in'] == null) && (m['out'] == null)) {
            stat['absence'] = (stat['absence'] ?? 0) + 1;
            month[key]['absence'] = 'Y';
          }
        }
      } else {
        if (m['in'] != null) {
          month[key]['in_txt'] = DateFormat("HH:mm").format(m['in'].toDate());
        }
        if (m['out'] != null) {
          month[key]['out_txt'] = DateFormat("HH:mm").format(m['out'].toDate());
        }
      }
    }
    obj['stat'] = stat;
    obj['timesheet'] = month;
    setState(() {});
  }

  void initData() {
    FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'leave')
        .where('uid', isEqualTo: obj['view_as'])
        .where('status', isEqualTo: 'Final Approved')
        .get()
        .then((QuerySnapshot querySnapshot) {
      obj['doclist'] = [];
      obj['leave'] = {};
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          tmp['data']['leave_from'] = tmp['data']['leave_from'].toDate();
          tmp['data']['leave_to'] = tmp['data']['leave_to'].toDate();

          obj['doclist'].add(tmp);
          DateTime s1 = tmp['data']['leave_from'];
          DateTime start = DateTime(s1.year, s1.month, s1.day);
          DateTime s2 = tmp['data']['leave_to'];
          DateTime stop = DateTime(s2.year, s2.month, s2.day);

          int rday = stop.difference(start).inDays;
          for (var i = 0; i <= rday; i++) {
            var key = DateFormat("yyyyMMdd").format(DateTime(start.year, start.month, start.day + i));
            obj['leave'][key] = tmp;
          }
        }
      }
      print(obj['leave']);
      setState(() {});
    });
  }

  bool isLeave(key, objleave, value) {
    bool isLeave = false;
    objleave ??= {};
    print('Call isLeave $key ');
    if (objleave[key] != null) {
      isLeave = true;
      // date match
      String toKey = DateFormat("yyyyMMdd").format(objleave[key]['data']['leave_to']);
      String fromKey = DateFormat("yyyyMMdd").format(objleave[key]['data']['leave_from']);
      print('toKey $toKey ');
      if (toKey == key) {
        print('toKey $toKey Yes');
        // end leave case
        String toTime = DateFormat("HH:mm").format(objleave[key]['data']['leave_to']);
        print('IS LEAVE  $toTime ${value['working_time']['begin']} ${toTime.compareTo(value['working_time']['begin'].toString())}');
        if (toTime.compareTo(value['working_time']['begin'].toString()) < 0) {
          isLeave = false;
        } else {
          isLeave = true;
        }
      }
      if (fromKey == key) {
        print('fromKey $fromKey Yes');
        // end leave case
        String fromTime = DateFormat("HH:mm").format(objleave[key]['data']['leave_from']);
        print('IS LEAVE  $fromTime ${value['working_time']['end']} ${fromTime.compareTo(value['working_time']['end'].toString())}');
        if (fromTime.compareTo(value['working_time']['end'].toString()) > 0) {
          isLeave = false;
        } else {
          isLeave = true;
        }
      }
      // check end leave time with start working time
      //

    }
    return isLeave;
  }
}
