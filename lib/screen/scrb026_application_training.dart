import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb026ApplicationTraining extends StatefulWidget {
  const Scrb026ApplicationTraining({Key? key}) : super(key: key);

  @override
  _Scrb026ApplicationTrainingState createState() => _Scrb026ApplicationTrainingState();
}

class _Scrb026ApplicationTrainingState extends State<Scrb026ApplicationTraining> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
  var listenerData;
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    listenerData.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
//      calcTimesheetStat(myyear, mymonth);
      initData();
      listenData();

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 27, 35, 140),
        title: Text("การอบรม"),
        actions: ((obj['view_as'] != null) && (obj['view_as']['uid'] != AppStyle().session['data']['uid']))
            ? null
            : [
                TextButton(
                    onPressed: () async {
                      dynamic value = {
                        'data': {},
                        'doctype': 'training',
                        'date': FieldValue.serverTimestamp(),
                        'show': true,
                        'uid': AppStyle().session['data']['uid'],
                      };
                      await Navigator.pushNamed(context, '/scrb043', arguments: {'doc': value});
                      initData();
                    },
                    child: Text(
                      'New',
                      style: TextStyle(color: Colors.white),
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
                  'ข้อมูลการอบรม',
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

            (obj['doclist'] ?? []).forEach((value) {
              var key = '';

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
                                  '${value['data']['training_type']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // SizedBox(height: 3),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(value['data']['training_date'])}',
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
                              // color: Colors.red,
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Text(
                                '${value['data']['status1'] ?? 'Wait'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (value['data']['status1'] == 'Rejected')
                                        ? Colors.red
                                        : (value['data']['status1'] == 'Approved')
                                            ? Colors.green
                                            : null),
                              ),
                            ));
                            list.add(Container(
                              // color: Colors.red,
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Text(
                                '${value['data']['status2'] ?? 'Wait'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (value['data']['status2'] == 'Rejected')
                                        ? Colors.red
                                        : (value['data']['status2'] == 'Approved')
                                            ? Colors.green
                                            : null),
                              ),
                            ));
                          }

                          return InkWell(
                            onTap: () async {
                              print('Open Expense');
                              await Navigator.pushNamed(context, '/scrb043', arguments: {'doc': value});
                              initData();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: list,
                            ),
                          );
                        }),
                      ]));
            });
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
        ]),
      ),
    );
  }

  void listenData() async {
    listenerData = FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'training')
        .where('uid', isEqualTo: obj['uid'])
        .where('show', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((event) async {
      obj['doclist'] = [];
      for (var doc in event.docs) {
        dynamic tmp = doc.data();
        tmp['id'] = doc.id;
        if (tmp['data']['training_date'] != null) {
          tmp['data']['training_date'] = tmp['data']['training_date'].toDate();
        }
        obj['doclist'].add(tmp);
      }
      setState(() {});
    });
  }

  void initData() async {
    AppStyle().showLoader(context);

    if (obj['view_as'] == null) {
      obj['uid'] = AppStyle().session['data']['uid'];
    } else {
      obj['uid'] = obj['view_as']['uid'];
    }

    obj['key_type'] = 'training_type';
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'training')
        .where('uid', isEqualTo: obj['uid'])
        .where('show', isEqualTo: true)
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      obj['doclist'] = [];
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          if (tmp['data']['training_date'] != null) {
            tmp['data']['training_date'] = tmp['data']['training_date'].toDate();
          }
          // tmp['data']['confirm_date'] = tmp['data']['confirm_date'].toDate();
          obj['doclist'].add(tmp);
        }
      }
      print(obj['doclist']);
      AppStyle().hideLoader(context);

      setState(() {});
    });
  }
}
