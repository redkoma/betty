import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:intl/intl.dart';

class Scrb048TeamInfo extends StatefulWidget {
  const Scrb048TeamInfo({Key? key}) : super(key: key);

  @override
  _Scrb048TeamInfoState createState() => _Scrb048TeamInfoState();
}

class _Scrb048TeamInfoState extends State<Scrb048TeamInfo> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  TextEditingController nameController = TextEditingController();
  var today = DateFormat("yyyyMMdd").format(DateTime.now());
  dynamic holiday = null;
  dynamic working_time = null;
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
      results = obj['ori_users'];
    } else {
      for (var i = 0; i < obj['ori_users'].length; i++) {
        if (obj['ori_users'][i]['keyword'].contains(input.toLowerCase())) {
          results.add(obj['ori_users'][i]);
        }
      }
    }

    results2 = results;
    results2.sort((a, b) {
      return (a['userinfo']['displayName'] ?? a['userinfo']['email']).toLowerCase().compareTo((b['userinfo']['displayName'] ?? b['userinfo']['email']).toLowerCase());
    });
    // Refresh the UI
    setState(() {
      obj['users'] = results2;
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      initData();
      var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

      var date = DateTime.now();
      for (var i = 0; i < (AppStyle().session['company']['holiday'] ?? []).length; i++) {
        // Flag Holiday
        var hdate = AppStyle().session['company']['holiday'][i]['date'].toDate();
        if ((hdate.month == date.month) && (hdate.day == date.day)) {
          if (AppStyle().session['company']['holiday'][i]['enable']) {
            holiday = AppStyle().session['company']['holiday'][i];
            print('Holiday ${holiday}');
          }
        }
      }
      // get normal working time
      for (var i = 0; i < (AppStyle().session['company']['working_time']['default'] ?? []).length; i++) {
        var key = AppStyle().session['company']['working_time']['default'][i]['wday'].toLowerCase();
        if (AppStyle().session['company']['working_time']['default'][i]['enable']) {
          if (wd[date.weekday] == key) {
            working_time = AppStyle().session['company']['working_time']['default'][i];
            print('Working time ${working_time}');
          }
        }
      }

      // is user in shift

      loaded = true;
      setState(() {});
    }

    var tabPending = Container(
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[400],
            height: 60,
            width: size.width,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
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
                    hintText: AppStyle().tr('Search '),
                    border: InputBorder.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage("${obj['users'][index]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                  ),
                  title: Text(
                    "${obj['users'][index]['userinfo']['displayName'] ?? obj['users'][index]['userinfo']['email']}",
                  ),
                  subtitle: Builder(builder: (context) {
                    List<Widget> list = [];
                    var cal = AppStyle().session['company']['members'][obj['users'][index]['uid']]['calendar'];
                    if (AppStyle().session['calendar'][obj['users'][index]['uid']] != null) {
                      cal = AppStyle().session['calendar'][obj['users'][index]['uid']];
                    }

                    cal ??= {};
                    var shift = cal[today];
                    FirebaseFirestore.instance.collection('timesheet').doc(obj['users'][index]['uid']).get().then((DocumentSnapshot documentSnapshot) async {
                      if (documentSnapshot.exists) {
                        obj['users'][index]['userinfo']['timesheet'] = documentSnapshot.data();
                      }
                      obj['users'][index]['userinfo']['timesheet'] ??= {};
                      if (obj['users'][index]['userinfo']['timesheet'][today] != null) {
                        var info = obj['users'][index]['userinfo']['timesheet'][today];
                        if (info['in'] != null) {
                          var _tmpin = DateFormat("HH:mm").format(info['in'].toDate());
                          bool late = false;
                          if (_tmpin.compareTo(working_time['begin'].toString()) > 0) {
                            late = true;
                          }
                          list.add(Container(
                            width: 70,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(color: (late) ? Colors.red[100] : Colors.blueGrey[100], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Text(
                                  "${(late) ? 'Late in' : 'IN'}",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "${DateFormat("HH:mm").format(info['in'].toDate())}",
                                ),
                              ],
                            ),
                          ));
                        } else {
                          list.add(Container(
                            width: 70,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Text(
                                  "N/A",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "--:--",
                                ),
                              ],
                            ),
                          ));
                        }
                        if (info['out'] != null) {
                          var _tmpout = DateFormat("HH:mm").format(info['out'].toDate());
                          bool early = false;
                          if (_tmpout.compareTo(working_time['end'].toString()) < 0) {
                            early = true;
                          }
                          list.add(Container(
                            width: 70,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(color: (early) ? Colors.red[100] : Colors.blueGrey[100], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Text(
                                  "${(early) ? 'Early out' : 'OUT'}",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "${DateFormat("HH:mm").format(info['out'].toDate())}",
                                ),
                              ],
                            ),
                          ));
                        } else {
                          list.add(Container(
                            width: 70,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Text(
                                  "N/A",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "--:--",
                                ),
                              ],
                            ),
                          ));
                        }
                      } else {
                        list.add(Container(
                          width: 70,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Text(
                                "N/A",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "--:--",
                              ),
                            ],
                          ),
                        ));
                        list.add(Container(
                          width: 70,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Text(
                                "N/A",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "--:--",
                              ),
                            ],
                          ),
                        ));
                      }
                    });

                    return Row(
                      children: list,
                    );
                  }),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    Navigator.pushNamed(context, '/scrb021', arguments: {'timesheet': obj['timesheet'], 'stat': obj['stat'], 'view_as': obj['users'][index]['uid']});
                    _refresh();
                  },
                );
              },
              itemCount: (obj['users'] ?? []).length,
            ),
          )
        ],
      ),
    );

    var tabSummary = Container(
      width: size.width,
      child: Column(
        children: [
          Container(
            color: Colors.grey[400],
            height: 60,
            width: size.width,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['department']} Team'),
            backgroundColor: Colors.brown,
            elevation: 0,
            bottom: TabBar(
                labelColor: Colors.brown,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                // isScrollable: true,
                indicator: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Members"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Summary"),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            tabPending,
            tabSummary,
          ]),
        ));
  }

  void initData() async {
    obj['workflow'] = {
      'displayName': 'Department Manager Approve',
      'code': 'l1',
      'cover': 'assets/images/training_setting_001.png',
    };

    obj['users'] = [];

    _refresh();

    setState(() {});
  }

  void _refresh() async {
    await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['companyId']).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        AppStyle().session['company'] = documentSnapshot.data();
      }
    }).catchError((error) {
      // print("Error: $error");
    });
    obj['users'] = [];
    String dep = AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['department'];
    AppStyle().session['company']['members'].forEach((key, value) {
      value['uid'] = key;
      value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
      if (dep == value['department']) {
        obj['users'].add(value);
      }
    });

    obj['ori_users'] = obj['users'];
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

    getSuggestion(nameController.text);
  }
}
