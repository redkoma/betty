import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb002SetupWorkingTime extends StatefulWidget {
  const Scrb002SetupWorkingTime({Key? key}) : super(key: key);

  @override
  _Scrb002SetupWorkingTimeState createState() => _Scrb002SetupWorkingTimeState();
}

class _Scrb002SetupWorkingTimeState extends State<Scrb002SetupWorkingTime> {
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};
  Size size = const Size(10, 10);
  Map obj = {'profile': {}};

  bool loaded = false;
  bool hasShift = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    size = MediaQuery.of(context).size;
    if (!loaded) {
      obj = arguments;
      setState(() {});
      print(obj);
      initData();
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Working Time'),
        actions: [
          TextButton(
              onPressed: () async {
                var i = 0;
                obj['working_time'].forEach((k, v) {
                  i++;
                });
                var code = await AppStyle().confirmData(context, "Shift_" + i.toString(), "Set shift name");
                if (code != null) {
                  if (code != '') {
                    if (obj['working_time'][code] == null) {
                      obj['working_time'][code] = obj['working_time']['default'];
                      setState(() {});
                    }
                  }
                }
              },
              child: Text(
                'Add Shift',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                    'ตั้งค่าเวลาทำงาน',
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
            SizedBox(height: 20),
            Container(
              width: size.width,
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 242, 238, 228),
                  Color.fromARGB(255, 255, 240, 193),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),

                // image: DecorationImage(
                //   image: AssetImage("assets/images/bg.jpg"),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text(
                  "Default",
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (obj['working_time']['default'] ?? []).map<Widget>((map) {
                    return (map['enable'] ?? false)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${map['wday']} '),
                              Text('${map['begin']} - ${map['end']}'),
                            ],
                          )
                        : Container();
                  }).toList(),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  var res0 = await Navigator.pushNamed(context, '/scrb005', arguments: {'time': obj['working_time']['default'], 'key': 'default'});
                  if (res0 != null) {
                    Map<String, dynamic> res = res0 as Map<String, dynamic>;
                    obj['working_time']['default'] = res['time'];

                    setState(() {});
                  }
                },
              ),
            ),
            Divider(),
            (hasShift)
                ? Builder(builder: (context) {
                    hasShift = false;
                    List<Widget> list = [];
                    print(obj['working_time']);
                    obj['working_time'].forEach((key, value) {
                      if (key != 'default') {
                        hasShift = true;
                        print(key);
                        list.add(Container(
                            width: size.width,
                            padding: EdgeInsets.all(15),
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(colors: [
                                Color.fromARGB(255, 233, 233, 233),
                                Color.fromARGB(255, 217, 217, 217),
                              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),

                              // image: DecorationImage(
                              //   image: AssetImage("assets/images/bg.jpg"),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.calendar_month),
                              title: Text(
                                "${key}",
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (value ?? []).map<Widget>((map) {
                                  return (map['enable'] ?? false)
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${map['wday']} '),
                                            Text('${map['begin']} - ${map['end']}'),
                                          ],
                                        )
                                      : Container();
                                }).toList(),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap: () async {
                                var res0 = await Navigator.pushNamed(context, '/scrb005', arguments: {'time': value, 'key': key});
                                if (res0 != null) {
                                  Map<String, dynamic> res = res0 as Map<String, dynamic>;
                                  obj['working_time'][key] = res['time'];
                                  setState(() {});
                                }
                              },
                            )));
                      }
                    });
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: list,
                    );
                  })
                : Container(),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
                child: Text(
                  'Save Working Time',
                  style: TextStyle(
                    fontSize: AppStyle().btnFontSize,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context, {'working_time': obj['working_time']});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initData() async {
    obj['shift_time'] = {};
    obj['working_time'].forEach((key, value) {
      if (key != 'default') {
        print(key);
        hasShift = true;
        obj['shift_time'][key] = value;
      }
    });
    setState(() {});
  }
}
