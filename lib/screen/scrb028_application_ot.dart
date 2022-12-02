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

class Scrb028ApplicationOT extends StatefulWidget {
  const Scrb028ApplicationOT({Key? key}) : super(key: key);

  @override
  _Scrb028ApplicationOTState createState() => _Scrb028ApplicationOTState();
}

class _Scrb028ApplicationOTState extends State<Scrb028ApplicationOT> {
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
        title: Text("ใบลา"),
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
              child: Text('New'))
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
                  'ข้อมูลการลา',
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
                                  '${value['data']['day']}',
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
                                    '${value['data']['leave_type']}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  // SizedBox(height: 3),
                                  Text(
                                    '${DateFormat("dd MMM").format(value['data']['leave_from'].toDate())} - ${DateFormat("dd MMM").format(value['data']['leave_to'].toDate())}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: (value['in_txt'] != null)
                                    ? () {
                                        showModalBottomSheet(
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
                                                    Row(
                                                      children: [
                                                        Container(
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
                                                        ),
                                                        Container(
                                                          height: size.width * 0.7,
                                                          width: size.width * 0.5,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(value['in_photo'] ?? AppStyle().no_user_url),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              });
                                            });
                                      }
                                    : null,
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
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (value['out_txt'] != null)
                                    ? () {
                                        showModalBottomSheet(
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
                                                    Row(
                                                      children: [
                                                        Container(
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
                                                        ),
                                                        Container(
                                                          height: size.width * 0.7,
                                                          width: size.width * 0.5,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(value['out_photo'] ?? AppStyle().no_user_url),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              });
                                            });
                                      }
                                    : null,
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

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
                1: FixedColumnWidth(100),
                2: FlexColumnWidth(),
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

  void calcTimesheetStat(int year, int mon) {
    // Process dashboard
    var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var day = DateTime(year, mon + 1, 0).day;
    var date = DateTime(year, mon, day);
    // print(day);
    var month = {};

// check shift if have shift calendar user shift working time
    var cal = AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['calendar'];
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
      month[key] = AppStyle().session['timesheet'][key] ?? {};
      // Flag Shift
      // Flag working day
      var wday = DateTime(date.year, date.month, i).weekday;
      // print(wd[wday]);
      month[key]['day'] = i;
      month[key]['wday'] = wd[wday];
      month[key]['month'] = DateFormat("MMM").format(date);
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
        records[obj['doclist'][i]['data'][obj['key_type']]]['sum'] += obj['doclist'][i]['data']['day'];
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

  void initData() async {
    obj['key_type'] = 'leave_type';
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
          tmp['id'] = doc.id;
          obj['doclist'].add(tmp);
        }
      }
      print(obj['doclist']);
      setState(() {});
    });
  }
}
