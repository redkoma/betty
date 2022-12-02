import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb052ReportTimeSheet extends StatefulWidget {
  const Scrb052ReportTimeSheet({Key? key}) : super(key: key);

  @override
  _Scrb052ReportTimeSheetState createState() => _Scrb052ReportTimeSheetState();
}

class _Scrb052ReportTimeSheetState extends State<Scrb052ReportTimeSheet> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  double cellWidth = 150;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
  dynamic timesheet = {};
  dynamic header = [
    {
      'name': "เข้า",
      'code': "in",
    },
    {
      'name': "ออก",
      'code': "out",
    },
    {
      'name': "สาย",
      'code': "late",
    },
    {
      'name': "ออกก่อน",
      'code': "early_out",
    },
    {
      'name': "ขาดงาน",
      'code': "absence",
    },
  ];
  var color = [
    Color(0xFFEEB859),
    Color(0xFF81CEFD),
    Color(0xFF9AE58D),
    Color(0xFFF47B7B),
    Color.fromARGB(255, 105, 207, 197),
    Color(0xFFFBACD7),
    Color.fromARGB(255, 149, 98, 10),
    Color.fromARGB(255, 9, 77, 119),
    Color.fromARGB(255, 31, 117, 16),
    Color.fromARGB(255, 101, 8, 8),
    Color.fromARGB(255, 8, 105, 95),
    Color.fromARGB(255, 105, 3, 59),
  ];
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
      initData();
      // calcReportData(myyear, mymonth);
      // dynamic calcTimesheetStat(user,myyear, mymonth);

      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${mymonthtxt} ${myyear}"),
        actions: [
          TextButton(
              onPressed: () {
                mymonth++;
                if (mymonth == 13) {
                  myyear++;
                  mymonth = 1;
                }
                mymonthtxt = DateFormat("MMMM").format(DateTime(myyear, mymonth, 1));

                setState(() {});
              },
              child: Text('Next')),
          TextButton(
              onPressed: () {
                mymonth--;
                if (mymonth == 0) {
                  myyear--;
                  mymonth = 12;
                }
                mymonthtxt = DateFormat("MMMM").format(DateTime(myyear, mymonth, 1));

                setState(() {});
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
                  '${obj['title']}',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildUserList(),
              ),
              Flexible(
                  child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildRows(),
                ),
              )),
            ],
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildUserList() {
    var listUser = [];
    (AppStyle().session['company']['members'] ?? {}).forEach((k, v) {
      listUser.add(v);
    });
    listUser.sort((a, b) {
      return a['department'].toLowerCase().compareTo((b['department']).toLowerCase());
    });

    return List.generate(
      listUser.length + 1,
      (index) => InkWell(
        onTap: () async {
          var user = listUser[index - 1];
        },
        child: Container(
          alignment: Alignment.centerLeft,
          width: 180.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: (index == 0) ? Colors.grey[200] : Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Color.fromARGB(255, 208, 207, 207), width: 1, style: BorderStyle.solid),
            ),
          ),
          padding: EdgeInsets.all(4.0),
          child: (index == 0)
              ? Container()
              : Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5, left: 5),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage("${listUser[index - 1]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${listUser[index - 1]['userinfo']['displayName'] ?? listUser[index - 1]['userinfo']['email']}",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "${listUser[index - 1]['department']}",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _buildRows() {
    var listUser = [];
    (AppStyle().session['company']['members'] ?? {}).forEach((k, v) {
      listUser.add(v);
    });
    listUser.sort((a, b) {
      return a['department'].toLowerCase().compareTo((b['department']).toLowerCase());
    });

    return List.generate(
      listUser.length + 1,
      (index) => Row(
        children: (index == 0) ? _buildHeaderColumn(header) : _buildColumn(listUser[index - 1], header),
      ),
    );
  }

  List<Widget> _buildColumn(dynamic user, List<dynamic> list) {
    var listCell = [];
    for (var i = 0; i < list.length; i++) {
      listCell.add(list[i]);
    }
    var stat = calcTimesheetStat(user, timesheet[user['uid']], myyear, mymonth);
    setState(() {});

    return List.generate(
      listCell.length,
      (index) => InkWell(
        onTap: () {},
        child: Container(
          alignment: Alignment.center,
          width: cellWidth,
          height: 60.0,
          decoration: BoxDecoration(
            color: (index % 2) == 1 ? Colors.white : Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Color.fromARGB(255, 208, 207, 207), width: 1, style: BorderStyle.solid),
            ),
          ),
          padding: EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${stat[listCell[index]['code']]}"),
              (stat[listCell[index]['code'] + '_min'] != null)
                  ? Text(
                      "(${stat[listCell[index]['code'] + '_min']} min)",
                      style: TextStyle(fontSize: 12),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderColumn(List<dynamic> list) {
    var listColumn = [];
    // print(list);
    for (var i = 0; i < list.length; i++) {
      listColumn.add(list[i]);
    }
    return List.generate(
      listColumn.length,
      (index) => Container(
        alignment: Alignment.center,
        width: cellWidth,
        height: 60.0,
        color: Colors.blue[100],
        padding: EdgeInsets.all(4.0),
        child: Text(
          "${listColumn[index]['name']}",
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void initData() async {
    var listUser = [];
    (AppStyle().session['company']['members'] ?? {}).forEach((k, v) async {
      await FirebaseFirestore.instance.collection('timesheet').doc(k).get().then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          var tmp = documentSnapshot.data();
          timesheet[k] = tmp;
          // print(tmp);
          print(timesheet);
          setState(() {});
        }
      });
    });
  }

  dynamic calcTimesheetStat(dynamic user, dynamic timesheet, int year, int mon) {
    obj['profile'] = user;
    // Process dashboard
    var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var day = DateTime(year, mon + 1, 0).day;
    var date = DateTime(year, mon, day);

    // print(day);
    var month = {};

// check shift if have shift calendar user shift working time
    var cal = (AppStyle().session['company']['members'][user['uid']] ?? {})['calendar'];
    if (AppStyle().session['calendar'][user['uid']] != null) {
      cal = AppStyle().session['calendar'][user['uid']];
    }

    cal ??= {};
    var shift = {};
    int shift_count = 0;
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

    // Working Time
    var working_time = {};
    for (var i = 0; i < (AppStyle().session['company']['working_time']['default'] ?? []).length; i++) {
      var key = AppStyle().session['company']['working_time']['default'][i]['wday'].toLowerCase();
      if (AppStyle().session['company']['working_time']['default'][i]['enable']) {
        working_time[key] = AppStyle().session['company']['working_time']['default'][i];
      }
    }

    timesheet ??= {};
    // print(working_time);
    for (var i = 1; i <= day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
      month[key] = timesheet[key] ?? {};
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

      var hdate = (AppStyle().session['company']['holiday'][i]['date'] is DateTime)
          ? AppStyle().session['company']['holiday'][i]['date']
          : AppStyle().session['company']['holiday'][i]['date'].toDate();
      var key = DateFormat("yyyyMMdd").format(hdate);
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
    String joinkey = '';
    if (AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['joindate'] != null) {
      joinkey = DateFormat("yyyyMMdd").format(AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['joindate'].toDate());
    }
    for (var i = 1; i <= date.day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();

      // print(key);
      var m = month[key];

      if (m['working_time'] != null) {
        // print("Working");
        if (m['holiday'] == null) {
          if (m['in'] != null) {
            stat['in'] = (stat['in'] ?? 0) + 1;
            month[key]['in_txt'] = DateFormat("HH:mm").format(m['in'].toDate());
            if ((DateFormat("HH:mm").format(m['in'].toDate())).compareTo(m['working_time']['begin'].toString()) > 0) {
              stat['late'] = (stat['late'] ?? 0) + 1;
              month[key]['late'] = 'Y';
              var h1 = DateFormat("HH").format(m['in'].toDate());
              var m1 = DateFormat("mm").format(m['in'].toDate());
              int min1 = (int.parse(h1) * 60) + int.parse(m1);
              var t2 = m['working_time']['begin'].toString().split(':');
              int min2 = (int.parse(t2[0]) * 60) + int.parse(t2[1]);
              stat['late_min'] = min1 - min2;
            }
          }
          if (m['out'] != null) {
            stat['out'] = (stat['out'] ?? 0) + 1;
            month[key]['out_txt'] = DateFormat("HH:mm").format(m['out'].toDate());
            if ((DateFormat("HH:mm").format(m['out'].toDate())).compareTo(m['working_time']['end'].toString()) < 0) {
              stat['early_out'] = (stat['early_out'] ?? 0) + 1;
              month[key]['early_out'] = 'Y';
              var h1 = DateFormat("HH").format(m['out'].toDate());
              var m1 = DateFormat("mm").format(m['out'].toDate());
              int min1 = (int.parse(h1) * 60) + int.parse(m1);
              var t2 = m['working_time']['end'].toString().split(':');
              int min2 = (int.parse(t2[0]) * 60) + int.parse(t2[1]);
              stat['early_out_min'] = min2 - min1;
            }
          }

          if ((m['in'] == null) && (m['out'] == null)) {
            if (joinkey != '') {
              if (joinkey.compareTo(key) < 0) {
                print('Abeense $joinkey $key ${joinkey.compareTo(key)}');
                stat['absence'] = (stat['absence'] ?? 0) + 1;
                month[key]['absence'] = 'Y';
              }
            } else {
              stat['absence'] = (stat['absence'] ?? 0) + 1;
              month[key]['absence'] = 'Y';
            }
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
    // print(month);

    return stat;
  }
}
