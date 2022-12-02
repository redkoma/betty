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

class Scrb050FormTimeAdjust extends StatefulWidget {
  const Scrb050FormTimeAdjust({Key? key}) : super(key: key);

  @override
  _Scrb050FormTimeAdjustState createState() => _Scrb050FormTimeAdjustState();
}

class _Scrb050FormTimeAdjustState extends State<Scrb050FormTimeAdjust> {
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
  String key_type = 'training_type';

  DateTime create_date = DateTime.now();
  DateTime training_date = DateTime.now();
  double expense_amount = 0;
  String training_type = '';
  String training_remark = '';
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
      readonly = false;

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 162, 149),
        title: Text(
          "${obj['doc']['status'] ?? 'คำขอปรับเวลา'}",
          style: TextStyle(fontSize: 15),
        ),
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
                  'คำขอปรับเวลา',
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
                            height: rowheight,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${value['status'] ?? 'Wait'}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (value['status'] == 'Rejected')
                                          ? Colors.red
                                          : (value['status'] == 'Approved')
                                              ? Colors.green
                                              : null),
                                ),
                              ],
                            ),
                          ));

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
                  leading: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${obj['doc']['data']['res']['wday']}',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        Text(
                          '${obj['doc']['data']['res']['day']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${obj['doc']['data']['res']['month']}',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    "เวลาเข้างานปกติ",
                  ),
                  trailing: Text(
                    "${obj['doc']['data']['res']['working_time']['begin']} - ${obj['doc']['data']['res']['working_time']['end']}",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Divider(height: 1),
                (obj['doc']['data']['res']['in_adjust_txt'] == null)
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            width: (size.width - 40) * 0.5,
                            decoration: BoxDecoration(color: Colors.blue[100]),
                            child: Column(
                              children: [
                                Text(
                                  '${obj['doc']['data']['res']['in_txt'] ?? '--:--'}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('IN (old)'),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_outlined),
                          Container(
                            padding: EdgeInsets.all(15),
                            width: (size.width - 40) * 0.5,
                            decoration: BoxDecoration(color: Colors.blue[100]),
                            child: Column(
                              children: [
                                Text(
                                  '${obj['doc']['data']['res']['in_adjust_txt'] ?? '--:--'}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('IN (new)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                (obj['doc']['data']['res']['out_adjust_txt'] == null)
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            width: (size.width - 40) * 0.5,
                            decoration: BoxDecoration(color: Colors.blue[100]),
                            child: Column(
                              children: [
                                Text(
                                  '${obj['doc']['data']['res']['out_txt'] ?? '--:--'}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('OUT (old)'),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_outlined),
                          Container(
                            padding: EdgeInsets.all(15),
                            width: (size.width - 40) * 0.5,
                            decoration: BoxDecoration(color: Colors.blue[100]),
                            child: Column(
                              children: [
                                Text(
                                  '${obj['doc']['data']['res']['out_adjust_txt']}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('OUT (new)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                ListTile(
                  title: Text('เหตุผล'),
                  subtitle: Text('${obj['doc']['data']['res']['in_adjust_remark'] ?? ''}\n${obj['doc']['data']['res']['out_adjust_remark'] ?? ''}'),
                ),
                Divider(height: 1),
                (obj['doc']['data']['approver1info'] != null)
                    ? Container(
                        color: Colors.amber[100],
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage("${(obj['doc']['data']['approver1info'] ?? {})['photoURL'] ?? AppStyle().no_user_url}"),
                          ),
                          title: Text(
                            "${(obj['doc']['data']['approver1info'] ?? {})['displayName'] ?? (obj['doc']['data']['approver1info'] ?? {})['email'] ?? ''}",
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
              ],
            ),
          ),
          SizedBox(height: 20),
          (obj['doc']['status'] == 'Wait for Approval')
              ? Container(
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
                          AppStyle().showLoader(context);
                          obj['doc']['status'] = "Approved";
                          if (obj['doc']['data']['res']['in_adjust_txt'] != null) {
                            obj['doc']['data']['res']['in_txt'] = obj['doc']['data']['res']['in_adjust_txt'];
                            obj['doc']['data']['res']['in'] = DateTime(obj['doc']['data']['res']['year'], obj['doc']['data']['res']['mon'], obj['doc']['data']['res']['day'],
                                obj['doc']['data']['res']['in_adjust_hour'], obj['doc']['data']['res']['in_adjust_min']);
                          }
                          if (obj['doc']['data']['res']['out_adjust_txt'] != null) {
                            obj['doc']['data']['res']['out_txt'] = obj['doc']['data']['res']['out_adjust_txt'];
                            obj['doc']['data']['res']['out'] = DateTime(obj['doc']['data']['res']['year'], obj['doc']['data']['res']['mon'], obj['doc']['data']['res']['day'],
                                obj['doc']['data']['res']['out_adjust_hour'], obj['doc']['data']['res']['out_adjust_min']);
                          }
                          await FirebaseFirestore.instance.collection('documents').doc(obj['doc']['id']).set(obj['doc'], SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('inbox')
                              .doc("${obj['doc']['id']}-${AppStyle().session['data']['uid']}")
                              .set({'status': obj['doc']['status']}, SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('inbox')
                              .doc("${obj['doc']['id']}-${obj['doc']['uid']}")
                              .set({'status': obj['doc']['status']}, SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('timesheet')
                              .doc("${obj['doc']['uid']}")
                              .set({'${obj['doc']['data']['key']}': obj['doc']['data']['res']}, SetOptions(merge: true));
                          String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]['userinfo']['FCM'] ?? '';
                          String type =
                              "อนุมัติขอปรับเวลา ${obj['doc']['data']['res']['day']} ${obj['doc']['data']['res']['month']} ${obj['doc']['data']['res']['in_adjust_txt'] ?? ''}${obj['doc']['data']['res']['out_adjust_txt'] ?? ''}";

                          var payload = {
                            'FCM': FCM,
                            'uid': obj['doc']['uid'],
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

                          AppStyle().hideLoader(context);

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
                          AppStyle().showLoader(context);
                          obj['doc']['status'] = "Rejected";

                          await FirebaseFirestore.instance.collection('documents').doc(obj['doc']['id']).set(obj['doc'], SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('inbox')
                              .doc("${obj['doc']['id']}-${AppStyle().session['data']['uid']}")
                              .set({'status': obj['doc']['status']}, SetOptions(merge: true));
                          await FirebaseFirestore.instance
                              .collection('inbox')
                              .doc("${obj['doc']['id']}-${obj['doc']['uid']}")
                              .set({'status': obj['doc']['status']}, SetOptions(merge: true));

                          String FCM = AppStyle().session['company']['members'][AppStyle().session['company']['leave_final_user']['userinfo']['uid']]['userinfo']['FCM'] ?? '';
                          if (FCM != '') {
                            String type =
                                "ไม่อนุมัติขอปรับเวลา ${obj['doc']['data']['res']['day']} ${obj['doc']['data']['res']['month']} ${obj['doc']['data']['res']['in_adjust_txt']}${obj['doc']['data']['res']['out_adjust_txt']}";

                            var payload = {
                              'FCM': FCM,
                              'uid': obj['doc']['uid'],
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
                          AppStyle().hideLoader(context);
                          Navigator.pop(context, {'action': 'FinalReject'});
                        },
                      ),
                    ],
                  ),
                )
              : Container(),
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
    // await FirebaseFirestore.instance
    //     .collection('documents')
    //     .where('doctype', isEqualTo: 'training')
    //     .where('uid', isEqualTo: AppStyle().session['data']['uid'])
    //     .get()
    //     .then((QuerySnapshot querySnapshot) {
    //   obj['doclist'] = [];
    //   if (querySnapshot.size > 0) {
    //     for (var doc in querySnapshot.docs) {
    //       dynamic tmp = doc.data();
    //       if (doc.id != obj['doc']['id']) {
    //         tmp['id'] = doc.id;
    //         tmp['data']['create_date'] = tmp['data']['create_date'].toDate();
    //         tmp['data']['training_date'] = tmp['data']['training_date'].toDate();
    //         obj['doclist'].add(tmp);
    //       }
    //     }
    //   }
    //   print(obj['doclist']);
    //   setState(() {});
    // });
  }
}
