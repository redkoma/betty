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

class Scrb027ApplicationMemo extends StatefulWidget {
  const Scrb027ApplicationMemo({Key? key}) : super(key: key);

  @override
  _Scrb027ApplicationMemoState createState() => _Scrb027ApplicationMemoState();
}

class _Scrb027ApplicationMemoState extends State<Scrb027ApplicationMemo> {
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
        backgroundColor: Color.fromARGB(255, 179, 2, 123),
        title: Text("เอกสารภายใน"),
        actions: ((obj['view_as'] != null) && (obj['view_as']['uid'] != AppStyle().session['data']['uid']))
            ? null
            : [
                TextButton(
                    onPressed: () async {
                      dynamic value = {
                        'data': {},
                        'doctype': 'memo',
                        'date': FieldValue.serverTimestamp(),
                        'show': true,
                        'uid': AppStyle().session['data']['uid'],
                      };
                      await Navigator.pushNamed(context, '/scrb038', arguments: {'doc': value});
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
                  'ข้อมูลเอกสารภายใน',
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
          //dataChart(size.width),
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
                        Builder(builder: (context) {
                          List<Widget> list = [];
                          list.add(Container(
                              width: size.width - 100,
                              color: Color.fromARGB(255, 205, 231, 255),
                              height: rowheight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${value['data']['memo_type']}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  // SizedBox(height: 3),
                                  Text(
                                    '${value['data']['memo_subject'] ?? ''}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )));
                          if (value['status'] == null) {
                            list.add(Container(
                              // color: Colors.red,
                              width: 100,
                              height: rowheight,
                              alignment: Alignment.center,
                              child: Text('Draft'),
                            ));
                          } else {
                            list.add(Container(
                              // color: Colors.red,
                              width: 100,
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
                          }

                          return InkWell(
                            onTap: () async {
                              print('Open memo');
                              await Navigator.pushNamed(context, '/scrb038', arguments: {'doc': value});
                              initData();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: list,
                            ),
                          );
                        }),
                      ]));
            });
            return Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
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
        .where('doctype', isEqualTo: 'memo')
        .where('uid', isEqualTo: obj['uid'])
        .where('show', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((event) async {
      obj['doclist'] = [];
      for (var doc in event.docs) {
        dynamic tmp = doc.data();
        tmp['id'] = doc.id;
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

    obj['key_type'] = 'memo_type';
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'memo')
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
          obj['doclist'].add(tmp);
        }
      }
      print(obj['doclist']);
      AppStyle().hideLoader(context);

      setState(() {});
    });
  }
}
