import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb054ReportTraining extends StatefulWidget {
  const Scrb054ReportTraining({Key? key}) : super(key: key);

  @override
  _Scrb054ReportTrainingState createState() => _Scrb054ReportTrainingState();
}

class _Scrb054ReportTrainingState extends State<Scrb054ReportTraining> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  int mymonth = DateTime.now().month;
  int myyear = DateTime.now().year;
  double cellWidth = 150;
  String type_key = "training_type";
  String mymonthtxt = DateFormat("MMMM").format(DateTime.now());
  var rowcolor = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 222, 236, 244),
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
      calcReportData(myyear, mymonth);
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

                calcReportData(myyear, mymonth);
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

                calcReportData(myyear, mymonth);
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
        children: (index == 0) ? _buildHeaderColumn(AppStyle().session['company'][type_key]) : _buildColumn(listUser[index - 1], AppStyle().session['company'][type_key]),
      ),
    );
  }

  List<Widget> _buildColumn(dynamic user, List<dynamic> list) {
    var listCell = [];
    for (var i = 0; i < list.length; i++) {
      listCell.add(list[i]);
    }
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
          child: Text("${(((obj['docinfo'] ?? {})[user['uid']] ?? {})[listCell[index]['name']] ?? {})['count'] ?? ''}"),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderColumn(List<dynamic> list) {
    var listColumn = [];
    print(list);
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

  void calcReportData(int year, int mon) async {
    // load leave data of company in selected month
    await FirebaseFirestore.instance
        .collection('documents')
        .where('doctype', isEqualTo: 'training')
        .where('companyId', isEqualTo: AppStyle().session['company']['uid'])
        .where('status', isEqualTo: 'Payout Approved')
        .where('mon', isEqualTo: mon)
        .where('year', isEqualTo: year)
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      obj['docinfo'] = {};
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          obj['docinfo'][tmp['uid']] ??= {};
          obj['docinfo'][tmp['uid']][tmp['data'][type_key]] ??= {'sum': 0.0, 'count': 0.0};
          obj['docinfo'][tmp['uid']][tmp['data'][type_key]]['count'] += 1;
        }
      }
      setState(() {});
    });
    print(obj['docinfo']);
  }

  void initData() {}
}
