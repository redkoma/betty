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

class Scrb049ApplicationTimeAdjust extends StatefulWidget {
  const Scrb049ApplicationTimeAdjust({Key? key}) : super(key: key);

  @override
  _Scrb049ApplicationTimeAdjustState createState() => _Scrb049ApplicationTimeAdjustState();
}

class _Scrb049ApplicationTimeAdjustState extends State<Scrb049ApplicationTimeAdjust> {
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
//      calcTimesheetStat(myyear, mymonth);
      initData();
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 162, 149),
        title: Text("ข้อมูลการขอปรับเวลา"),
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
                  'ข้อมูลการขอปรับเวลา',
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
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      mymonth++;
                      if (mymonth == 13) {
                        myyear++;
                        mymonth = 1;
                      }
                      mymonthtxt = DateFormat("MMMM").format(DateTime(myyear, mymonth, 1));
                      setState(() {});
                    },
                    child: Icon(Icons.keyboard_arrow_left)),
                Text(
                  '${mymonthtxt} ${myyear}',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(' only pending'),
                    Switch(
                        value: obj['showWait'] ?? false,
                        onChanged: (value) async {
                          setState(() {
                            obj['showWait'] = value;
                          });
                        }),
                  ],
                ),
                InkWell(
                    onTap: () {
                      mymonth--;
                      if (mymonth == 0) {
                        myyear--;
                        mymonth = 12;
                      }
                      mymonthtxt = DateFormat("MMMM").format(DateTime(myyear, mymonth, 1));
                      setState(() {});
                    },
                    child: Icon(Icons.keyboard_arrow_right)),
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
              if ((value['data']['res']['mon'] == mymonth) && (value['data']['res']['year'] == myyear)) {
                if (((obj['showWait'] ?? false) == false) || ((obj['showWait'] == true) && (value['status'] == 'Wait for Approval'))) {
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
                                      '${value['data']['res']['in_adjust_txt'] ?? ''} ${value['data']['res']['out_adjust_txt'] ?? ''}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    // SizedBox(height: 3),
                                    Text(
                                      '${value['data']['res']['day']} ${value['data']['res']['month']}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                            Builder(builder: (context) {
                              List<Widget> list = [];

                              list.add(Container(
                                // color: Colors.red,
                                height: rowheight,
                                alignment: Alignment.center,
                                child: Text(
                                  '${value['status'] ?? 'Wait'}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (value['status'] == 'Rejected')
                                          ? Colors.red
                                          : (value['status'] == 'Approved')
                                              ? Colors.green
                                              : null),
                                ),
                              ));

                              return InkWell(
                                onTap: () async {
                                  await Navigator.pushNamed(context, '/scrb050', arguments: {'doc': value});
                                  initData();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: list,
                                ),
                              );
                            }),
                          ]));
                }
              }
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

  void initData() async {
    AppStyle().showLoader(context);

    if (obj['view_as'] == null) {
      obj['uid'] = AppStyle().session['data']['uid'];
    } else {
      obj['uid'] = obj['view_as']['uid'];
    }

    obj['key_type'] = 'expense_type';
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'time_adjust')
        .where('companyId', isEqualTo: AppStyle().session['company']['uid'])
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

      obj['doclist'].sort((a, b) {
        return (int.parse((a['data']['res']['day'] ?? 0).toString())).compareTo((int.parse((b['data']['res']['day'] ?? 0).toString())));
      });
      AppStyle().hideLoader(context);

      setState(() {});
    });
  }
}
