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

class Scrb045ApplicationOKR extends StatefulWidget {
  const Scrb045ApplicationOKR({Key? key}) : super(key: key);

  @override
  _Scrb045ApplicationOKRState createState() => _Scrb045ApplicationOKRState();
}

class _Scrb045ApplicationOKRState extends State<Scrb045ApplicationOKR> {
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
        backgroundColor: Color.fromARGB(255, 190, 0, 0),
        title: Text("OKRs"),
        actions: [
          TextButton(
              onPressed: () async {
                dynamic value = {
                  'current': 0.0,
                  'start': 0.0,
                  'target': 100.0,
                  'title': '',
                };
                dynamic res = await Navigator.pushNamed(context, '/scrb046', arguments: {'doc': value});
                if (res != null) {
                  AppStyle().showLoader(context);
                  var key = DateTime.now().millisecondsSinceEpoch;

                  if (obj['okrs'] == null) {
                    obj['okrs'] = {};
                  }
                  obj['okrs']['${key}'] = res;
                  await FirebaseFirestore.instance.collection('okrs').doc(obj['uid']).set({
                    'okrs': {'${key}': res},
                  }, SetOptions(merge: true));
                  setState(() {});
                  AppStyle().hideLoader(context);
                }
//                initData();
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
                  'OKRs',
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
          (obj['okrs'] == null)
              ? Container(
                  padding: EdgeInsets.all(50),
                  child: Text('No OKR'),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white60,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          width: size.width - 40,
                          child: Builder(builder: (context) {
                            List<Widget> listtmp = [];
                            listtmp.add(Text('Objective & Key Results (OKRs)'));
                            listtmp.add(SizedBox(
                              height: 5,
                            ));

                            (obj['okrs'] ?? {}).forEach((key, okr) {
                              listtmp.add(Card(
                                elevation: 2,
                                child: (okr == null)
                                    ? Container()
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text('${okr['title'] ?? ''}'),
                                              subtitle: Text('${AppStyle().formatCurrency.format(okr['target'] ?? 0)} (Target)'),
                                              trailing: Text('${AppStyle().formatCurrency.format(okr['current'] ?? 0)}'),
                                            ),

                                            Slider(
                                              min: (okr['start'] ?? 0) * 1.0 ?? 0.0,
                                              max: (okr['target'] ?? 0) * 1.0 ?? 100.0,
                                              activeColor: Colors.blue,
                                              inactiveColor: Colors.blue[100],
                                              thumbColor: Colors.blueAccent,
                                              value: (okr['current'] ?? 0) * 1.0 ?? 0.0,
                                              onChanged: (value) async {
                                                setState(() {
                                                  okr['current'] = value;
                                                });
                                              },
                                              onChangeEnd: (value) async {
                                                await FirebaseFirestore.instance.collection('okrs').doc(obj['uid']).set({
                                                  'okrs': {'${key}': okr},
                                                }, SetOptions(merge: true));
                                                // await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['company']['uid']).set({
                                                //   'members': {
                                                //     obj['uid']: {
                                                //       'okrs': {key: okr},
                                                //     }
                                                //   }
                                                // }, SetOptions(merge: true));

                                                print(value);
                                              },
                                            ),
                                            // LinearProgressIndicator(
                                            //   minHeight: 10,
                                            //   value: 0.5,
                                            //   backgroundColor: Colors.blue[100],
                                            //   color: Colors.blue,
                                            // ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      dynamic res = await AppStyle().confirm(context, 'Delete this OKR ?');
                                                      if (res == true) {
                                                        await FirebaseFirestore.instance.collection('okrs').doc(obj['uid']).set({
                                                          'okrs': {'${key}': FieldValue.delete()},
                                                        }, SetOptions(merge: true));
                                                        obj['okrs'][key] = null;
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                    )),
                                                IconButton(
                                                    onPressed: () async {
                                                      dynamic res = await Navigator.pushNamed(context, '/scrb046', arguments: {'doc': okr});
                                                      if (res != null) {
                                                        AppStyle().showLoader(context);

                                                        if (obj['okrs'] == null) {
                                                          obj['okrs'] = {};
                                                        }
                                                        obj['okrs']['${key}'] = res;
                                                        await FirebaseFirestore.instance.collection('okrs').doc(obj['uid']).set({
                                                          'okrs': {'${key}': res},
                                                        }, SetOptions(merge: true));
                                                        setState(() {});
                                                        AppStyle().hideLoader(context);
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      color: Colors.blue,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                              ));
                            });
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: listtmp,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
        ]),
      ),
    );
  }

  void initData() async {
    if (obj['view_as'] == null) {
      obj['uid'] = AppStyle().session['data']['uid'];
    } else {
      obj['uid'] = obj['view_as']['uid'];
    }
    FirebaseFirestore.instance.collection('okrs').doc(obj['uid']).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        dynamic tmp = documentSnapshot.data();
        obj['okrs'] = tmp['okrs'];
        setState(() {});
      } else {
        // print('Document does not exist on the database');
      }
    }).catchError((error) {
      // print("Error: $error");
    });
  }
}
