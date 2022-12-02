import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb022SettingShiftCalendar extends StatefulWidget {
  const Scrb022SettingShiftCalendar({Key? key}) : super(key: key);

  @override
  _Scrb022SettingShiftCalendarState createState() => _Scrb022SettingShiftCalendarState();
}

class _Scrb022SettingShiftCalendarState extends State<Scrb022SettingShiftCalendar> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
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
      calcTimesheetStat(myyear, mymonth);
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

                calcTimesheetStat(myyear, mymonth);
                setState(() {});
              },
              child: Text('Next'))
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
                  'ตารางกะงาน',
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
            List<Widget> listShift = [];
            int i = 0;
            AppStyle().session['company']['working_time'].forEach((k, v) {
              if (k != 'default') {
                listShift.add(Container(
                  width: size.width * 0.4,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: color[i],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text('${k}'),
                    ],
                  ),
                ));
                i++;
              }
            });

            return Container(
              width: size.width,
              padding: EdgeInsets.all(15),
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                children: listShift,
              ),
            );
          }),
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
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                  List<Widget> list = [];
                  list.add(ListTile(
                    tileColor: Colors.blue[100],
                    leading: Icon(Icons.calendar_month),
                    title: Text(
                      "Shift Apply (Monthly)",
                    ),
                  ));
                  var listShift = [];
                  AppStyle().session['company']['working_time'].forEach((k, v) {
                    if (k != 'default') {
                      listShift.add(k);
                    }
                  });

                  for (var i = 0; i < listShift.length; i++) {
                    list.add(ListTile(
                      trailing: Container(
                        width: 20,
                        height: 20,
                        color: color[i],
                      ),
                      title: Text(
                        "${listShift[i]}",
                      ),
                      onTap: () async {
                        var listDay = [];
                        (obj['list'] ?? {}).forEach((k, v) {
                          listDay.add(v);
                        });
                        var chkWD = {};
                        for (var j = 0; j < AppStyle().session['company']['working_time'][listShift[i]].length; j++) {
                          if (AppStyle().session['company']['working_time'][listShift[i]][j]['enable']) {
                            chkWD[AppStyle().session['company']['working_time'][listShift[i]][j]['wday']] = 'Y';
                          }
                        }

                        for (var k = 0; k < listDay.length; k++) {
                          if (chkWD[listDay[k]['wday']] == 'Y') {
                            AppStyle().session['calendar'][user['userinfo']['uid']][listDay[k]['key']] = listShift[i];
                          } else {
                            AppStyle().session['calendar'][user['userinfo']['uid']].remove(listDay[k]['key']);
                          }
                        }
                        var data = {
                          'uid': user['userinfo']['uid'],
                          'companyId': AppStyle().session['company']['uid'],
                          'list': AppStyle().session['calendar'][user['userinfo']['uid']],
                        };

                        await FirebaseFirestore.instance.collection('calendar').doc(user['userinfo']['uid']).set(data, SetOptions(merge: true));

                        setState2(() {
                          setState(() {});
                        });
                      },
                    ));
                  }
                  list.add(ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text(
                      "Clear shift",
                    ),
                    onTap: () async {
                      var res = await AppStyle().confirm(context, 'Clear shift calendar ? ');
                      if (res != null) {
                        (obj['list'] ?? {}).forEach((k, v) {
                          AppStyle().session['calendar'][user['userinfo']['uid']].remove(k);
                        });

                        var data = {
                          'uid': user['userinfo']['uid'],
                          'companyId': AppStyle().session['company']['uid'],
                          'list': AppStyle().session['calendar'][user['userinfo']['uid']],
                        };
                        await FirebaseFirestore.instance.collection('calendar').doc(user['userinfo']['uid']).set(data, SetOptions(merge: true));

                        setState2(() {
                          setState(() {});
                        });
                      }
                    },
                  ));

                  list.add(Container(
                    height: 100,
                  ));

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: list,
                  );
                });
              });
        },
        child: Container(
          alignment: Alignment.centerLeft,
          width: 180.0,
          height: 60.0,
          color: (index == 0) ? Colors.grey[200] : Colors.grey[100],
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
        children: (index == 0) ? _buildWDay() : _buildDay(listUser[index - 1]),
      ),
    );
  }

  List<Widget> _buildDay(dynamic user) {
    var listDay = [];
    (obj['list'] ?? {}).forEach((k, v) {
      listDay.add(v);
    });
    var listShiftColor = {};
    int i = 0;
    AppStyle().session['company']['working_time'].forEach((k, v) {
      if (k != 'default') {
        listShiftColor[k] = color[i];
        i++;
      }
    });

    return List.generate(
      listDay.length,
      (index) => InkWell(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                  List<Widget> list = [];
                  list.add(ListTile(
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.calendar_month),
                    title: Text(
                      "Shift Apply (Day)",
                    ),
                  ));
                  var listShift = [];
                  AppStyle().session['company']['working_time'].forEach((k, v) {
                    if (k != 'default') {
                      listShift.add(k);
                    }
                  });

                  for (var i = 0; i < listShift.length; i++) {
                    list.add(ListTile(
                      leading: (AppStyle().session['calendar'][user['userinfo']['uid']][listDay[index]['key']] == listShift[i])
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                      trailing: Container(
                        width: 20,
                        height: 20,
                        color: color[i],
                      ),
                      title: Text(
                        "${listShift[i]}",
                      ),
                      onTap: () async {
                        AppStyle().session['calendar'][user['userinfo']['uid']][listDay[index]['key']] = listShift[i];
                        var data = {
                          'uid': user['userinfo']['uid'],
                          'companyId': AppStyle().session['company']['uid'],
                          'list': AppStyle().session['calendar'][user['userinfo']['uid']],
                        };
                        await FirebaseFirestore.instance.collection('calendar').doc(user['userinfo']['uid']).set(data, SetOptions(merge: true));

                        setState2(() {
                          setState(() {});
                        });
                      },
                    ));
                  }

                  list.add(ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text(
                      "Clear shift",
                    ),
                    onTap: () async {
                      AppStyle().session['calendar'][user['userinfo']['uid']].remove(listDay[index]['key']);

                      var data = {
                        'uid': user['userinfo']['uid'],
                        'companyId': AppStyle().session['company']['uid'],
                        'list': AppStyle().session['calendar'][user['userinfo']['uid']],
                      };
                      await FirebaseFirestore.instance.collection('calendar').doc(user['userinfo']['uid']).set(data, SetOptions(merge: true));

                      setState2(() {
                        setState(() {});
                      });
                    },
                  ));
                  list.add(Container(
                    height: 100,
                  ));

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: list,
                  );
                });
              });
        },
        child: Container(
          alignment: Alignment.center,
          width: 35.0,
          height: 60.0,
          color: (AppStyle().session['calendar'][user['userinfo']['uid']][listDay[index]['key']] == null)
              ? Colors.white
              : listShiftColor[AppStyle().session['calendar'][user['userinfo']['uid']][listDay[index]['key']]],
          padding: EdgeInsets.all(4.0),
          child: Text("${listDay[index]['day']}"),
        ),
      ),
    );
  }

  List<Widget> _buildWDay() {
    var listDay = [];
    (obj['list'] ?? {}).forEach((k, v) {
      listDay.add(v);
    });
    return List.generate(
      listDay.length,
      (index) => Container(
        alignment: Alignment.center,
        width: 35.0,
        height: 60.0,
        color: ((listDay[index]['wday'] == 'sun') || (listDay[index]['wday'] == 'sat')) ? Colors.red[100] : Colors.grey[200],
        padding: EdgeInsets.all(4.0),
        child: Text(
          "${listDay[index]['wday']}",
          style: TextStyle(fontSize: 12),
        ),
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

    for (var i = 1; i <= day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
      month[key] = AppStyle().session['timesheet'][key] ?? {};
      // Flag Shift
      // Flag working day
      var wday = DateTime(date.year, date.month, i).weekday;
      // print(wd[wday]);
      month[key]['day'] = i;
      month[key]['key'] = key;
      month[key]['wday'] = wd[wday];
      month[key]['month'] = DateFormat("MMM").format(date);
    }

    AppStyle().session['company']['members'].forEach((k, v) {
      if (AppStyle().session['calendar'][k] == null) {
        AppStyle().session['calendar'][k] = {};
      }
    });
    obj['list'] = month;
  }

  void initData() {}
}
