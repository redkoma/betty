import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Scrb039FormMemoSelectUser extends StatefulWidget {
  const Scrb039FormMemoSelectUser({Key? key}) : super(key: key);

  @override
  _Scrb039FormMemoSelectUserState createState() => _Scrb039FormMemoSelectUserState();
}

class _Scrb039FormMemoSelectUserState extends State<Scrb039FormMemoSelectUser> {
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};
  Size size = const Size(10, 10);
  Map obj = {'profile': {}};
  dynamic res;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      _onChanged();
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();

    super.dispose();
  }

  _onChanged() {
    getSuggestion(nameController.text);
  }

  void getSuggestion(String input) async {
    List<dynamic> results = [];
    List<dynamic> results2 = [];
    if (input.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = obj['ori_data'];
    } else {
      for (var i = 0; i < obj['ori_data'].length; i++) {
        if (obj['ori_data'][i]['keyword'].contains(input.toLowerCase())) {
          results.add(obj['ori_data'][i]);
        }
      }
    }
    if (!obj['filter_dep'][0]['select']) {
      var filter = {};
      for (var i = 1; i < obj['filter_dep'].length; i++) {
        if (obj['filter_dep'][i]['select']) {
          filter[obj['filter_dep'][i]['name']] = 'Y';
        }
      }
      for (var i = 0; i < results.length; i++) {
        if (filter[results[i]['department']] == 'Y') {
          results2.add(results[i]);
        }
      }
    } else {
      results2 = results;
    }
    results2.sort((a, b) {
      return (a['userinfo']['displayName'] ?? a['userinfo']['email']).toLowerCase().compareTo((b['userinfo']['displayName'] ?? b['userinfo']['email']).toLowerCase());
    });
    // Refresh the UI
    setState(() {
      obj['data'] = results2;
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    size = MediaQuery.of(context).size;
    if (!loaded) {
      obj = arguments;
      initData();
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                      nameController.clear();
                    },
                  ),
                  hintText: AppStyle().tr('Search ...'),
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: Column(
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
                  'เลือกรายชื่อ',
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
            height: 60,
            width: size.width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (obj['filter_dep'] ?? []).length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () async {
                      if (index == 0) {
                        obj['filter_dep'][index]['select'] = !obj['filter_dep'][index]['select'];
                        for (var i = 1; i < obj['filter_dep'].length; i++) {
                          obj['filter_dep'][i]['select'] = obj['filter_dep'][index]['select'];
                        }
                      } else {
                        obj['filter_dep'][index]['select'] = !obj['filter_dep'][index]['select'];
                        var check = true;
                        for (var i = 1; i < obj['filter_dep'].length; i++) {
                          if (!obj['filter_dep'][i]['select']) {
                            check = false;
                          }
                        }
                        obj['filter_dep'][0]['select'] = check;
                      }
                      getSuggestion(nameController.text);
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                      decoration: BoxDecoration(
                        color: obj['filter_dep'][index]['select'] ? Colors.amber : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      child: Center(child: Text('${obj['filter_dep'][index]['name']}')),
                    ),
                  );
                }),
          ),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => const Divider(
                      height: 1,
                    ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: (obj['select'][obj['data'][index]['userinfo']['uid']] == null) ? null : Colors.blue[50],
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage("${obj['data'][index]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                    ),
                    title: Text(
                      "${obj['data'][index]['userinfo']['displayName'] ?? obj['data'][index]['userinfo']['email']}",
                    ),
                    subtitle: Text(
                      "${obj['data'][index]['userinfo']['email']}",
                    ),
                    trailing: (obj['select'][obj['data'][index]['userinfo']['uid']] == null) ? null : Text('${obj['select'][obj['data'][index]['userinfo']['uid']]}'),
                    onTap: () async {
// show bottomsheet
                      res = await showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
                              dynamic myinfo = AppStyle().session['company']['members'][AppStyle().session['data']['uid']];
                              var mydep = myinfo['department'];
                              dynamic manager = {};
                              for (var i = 0; i < (AppStyle().session['company']['department'] ?? []).length; i++) {
                                if (AppStyle().session['company']['department'][i]['enable']) {
                                  if (AppStyle().session['company']['department'][i]['name'] == mydep) {
                                    manager = AppStyle().session['company']['department'][i]['managerinfo'];
                                  }
                                }
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    tileColor: Colors.grey[300],
                                    title: Text('กรุณาเลือกหมายเหตุสำหรับผู้รับ'),
                                  ),
                                  Divider(height: 1),
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context, {'action': 'แจ้งเพื่อทราบ'});
                                    },
                                    title: Text('แจ้งเพื่อทราบ'),
                                  ),
                                  Divider(height: 1),
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context, {'action': 'แจ้งเพื่อดำเนินการ'});
                                    },
                                    title: Text('แจ้งเพื่อดำเนินการ'),
                                  ),
                                  Divider(height: 1),
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context, {'action': null});
                                    },
                                    title: Text('ยกเลิก'),
                                  ),
                                  Divider(height: 1),
                                  SizedBox(height: 80),
                                ],
                              );
                            });
                          });
                      if (res != null) {
                        obj['select'][obj['data'][index]['userinfo']['uid']] = res['action'];
                        setState(() {});
                      }
                    },
                  );
                },
                itemCount: (obj['data'] ?? []).length),
          ),

          // Expanded(child: Container()),
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context, {'data': obj['select']});
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initData() async {
    obj['users'] = [];
    AppStyle().session['company']['members'].forEach((key, value) {
      value['uid'] = key;
      value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
      obj['users'].add(value);
    });
    obj['data'] = obj['users'];
    obj['ori_data'] = obj['data'];
    obj['filter_dep'] = [];
    obj['department'] = [];
    var value = {'name': 'All', 'select': true, 'enable': true};
    obj['filter_dep'].add(value);
    AppStyle().session['company']['department'].forEach((value) {
      obj['department'].add(value);
      if (value['enable']) {
        value['select'] = true;
        obj['filter_dep'].add(value);
      }
    });
    if (obj['select'] == null) {
      obj['select'] = {};
    }

    getSuggestion(nameController.text);
    setState(() {});
  }
}
