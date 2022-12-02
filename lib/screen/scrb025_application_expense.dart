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

class Scrb025ApplicationExpense extends StatefulWidget {
  const Scrb025ApplicationExpense({Key? key}) : super(key: key);

  @override
  _Scrb025ApplicationExpenseState createState() => _Scrb025ApplicationExpenseState();
}

class _Scrb025ApplicationExpenseState extends State<Scrb025ApplicationExpense> {
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
        backgroundColor: Color.fromARGB(255, 179, 94, 2),
        title: Text("ใบเบิกค่าใช้จ่าย"),
        actions: ((obj['view_as'] != null) && (obj['view_as']['uid'] != AppStyle().session['data']['uid']))
            ? null
            : [
                TextButton(
                    onPressed: () async {
                      dynamic value = {
                        'data': {},
                        'doctype': 'expense',
                        'date': FieldValue.serverTimestamp(),
                        'show': true,
                        'uid': AppStyle().session['data']['uid'],
                      };
                      await Navigator.pushNamed(context, '/scrb036', arguments: {'doc': value});
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
                  'ข้อมูลการเบิก',
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
          dataChart(size.width),
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
                                  '${value['data']['expense_type']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // SizedBox(height: 3),
                                Text(
                                  '${AppStyle().formatCurrency.format(value['data']['expense_amount'] ?? 0)}',
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
                              await Navigator.pushNamed(context, '/scrb036', arguments: {'doc': value});
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

  Widget dataChart(double width) {
    List<BarChartGroupData> barData = [
      // BarChartGroupData(
      //   x: 0,
      //   barRods: [
      //     BarChartRodData(
      //       toY: 800,
      //       gradient: _barsGradient,
      //     )
      //   ],
      //   showingTooltipIndicators: [0],
      // ),
      // BarChartGroupData(
      //   x: 1,
      //   barRods: [
      //     BarChartRodData(
      //       toY: 10,
      //       gradient: _barsGradient,
      //     )
      //   ],
      //   showingTooltipIndicators: [0],
      // ),
    ];
    Map records = {};
    for (var i = 0; i < AppStyle().session['company'][obj['key_type']].length; i++) {
      records[AppStyle().session['company'][obj['key_type']][i]['name']] = {'index': i, 'sum': 0.00};
    }
    for (var i = 0; i < (obj['doclist'] ?? []).length; i++) {
      if (obj['doclist'][i]['data'][obj['key_type']] != null) {
        records[obj['doclist'][i]['data'][obj['key_type']]]['sum'] += obj['doclist'][i]['data']['expense_amount'];
      }
    }
    for (var i = 0; i < AppStyle().session['company'][obj['key_type']].length; i++) {
      barData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: records[AppStyle().session['company'][obj['key_type']][i]['name']]['sum'] ?? 0,
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      ));
    }
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 10),
          height: width / ((size.width > size.height) ? 4 : 1.7),
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
    String text = "${AppStyle().session['company'][obj['key_type']][value.toInt()]['name']}";
    String text2 = "${AppStyle().session['company'][obj['key_type']][value.toInt()]['limit'] ?? ''}";
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

  void listenData() async {
    listenerData = FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'expense')
        .where('uid', isEqualTo: obj['uid'])
        .where('show', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((event) async {
      obj['doclist'] = [];
      for (var doc in event.docs) {
        dynamic tmp = doc.data();
        tmp['id'] = doc.id;
        if (tmp['data']['create_date'] != null) {
          tmp['data']['create_date'] = tmp['data']['create_date'].toDate();
        }
        if (tmp['data']['payout_date'] != null) {
          tmp['data']['payout_date'] = tmp['data']['payout_date'].toDate();
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

    obj['key_type'] = 'expense_type';
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'expense')
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
          if (tmp['data']['create_date'] != null) {
            tmp['data']['create_date'] = tmp['data']['create_date'].toDate();
          }
          if (tmp['data']['payout_date'] != null) {
            tmp['data']['payout_date'] = tmp['data']['payout_date'].toDate();
          }
          obj['doclist'].add(tmp);
        }
      }
      print(obj['doclist']);
      AppStyle().hideLoader(context);

      setState(() {});
    });
  }
}
