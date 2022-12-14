import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scrb033ExpenseSetting extends StatefulWidget {
  const Scrb033ExpenseSetting({Key? key}) : super(key: key);

  @override
  _Scrb033ExpenseSettingState createState() => _Scrb033ExpenseSettingState();
}

class _Scrb033ExpenseSettingState extends State<Scrb033ExpenseSetting> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  TextEditingController nameController = TextEditingController();

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

      loaded = true;
      setState(() {});
    }

    var tabPending = Container(
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  subtitle: Text(
                    "${obj['users'][index]['department']}",
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    var res0 = await Navigator.pushNamed(context, '/scrb025', arguments: {'view_as': obj['users'][index]});
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
    var tabSetting = Container(
      width: size.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Workflow'),
              // trailing: Icon(Icons.keyboard_arrow_right),
              subtitle: Text('Department Manager Approval'),
              // onTap: () async {
              //   dynamic res = await Navigator.pushNamed(context, '/scrb034', arguments: {'data': obj['workflow']});
              //   if (res != null) {
              //     obj['workflow'] = res['data'];
              //     var flow = {'expense': obj['workflow']};
              //     await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'workflow': flow}, SetOptions(merge: true));
              //     if (AppStyle().session['company']['workflow'] == null) {
              //       AppStyle().session['company']['workflow'] = {};
              //     }
              //     AppStyle().session['company']['workflow']['expense'] = obj['workflow'];
              //     setState(() {});
              //   }
              // },
            ),
            Container(
              child: Image.asset(
                obj['workflow']['cover'],
                height: size.height * 0.3,
              ),
            ),
            SizedBox(height: 15),
            ListTile(
              title: Text('Department Manager'),
              trailing: Icon(Icons.keyboard_arrow_right),
              subtitle: Builder(builder: (context) {
                List<Widget> list = [];
                list = (obj['department'] ?? []).map<Widget>((map) {
                  return (map['enable'] ?? false)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(map['name']),
                            Text(map['manager'] ?? 'Please Select'),
                          ],
                        )
                      : Container();
                }).toList();

                return Container(
                  margin: EdgeInsets.only(top: 10, left: 15, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list,
                  ),
                );
              }),
              onTap: () async {
                dynamic res = await Navigator.pushNamed(context, '/scrb015', arguments: {'data': obj['department']});
                if (res != null) {
                  obj['department'] = res['data'];
                  await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'department': obj['department']}, SetOptions(merge: true));
                  AppStyle().session['company']['department'] = obj['department'];
                  setState(() {});
                }
              },
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Payout User'),
              trailing: Icon(Icons.keyboard_arrow_right),
              subtitle: Text('${AppStyle().session['company']['expense_payout_username'] ?? 'Please select'}'),
              onTap: () async {
                dynamic res = await Navigator.pushNamed(context, '/scrb017', arguments: {'data': obj['ori_users']});
                if (res != null) {
                  AppStyle().session['company']['expense_payout_username'] = res['data']['userinfo']['displayName'] ?? res['data']['userinfo']['email'];
                  AppStyle().session['company']['expense_payout_user'] = res['data'];
                  await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({
                    'expense_payout_username': AppStyle().session['company']['expense_payout_username'],
                    'expense_payout_user': AppStyle().session['company']['expense_payout_user'],
                  }, SetOptions(merge: true));

                  setState(() {});
                }
              },
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Expense type'),
              trailing: Icon(Icons.keyboard_arrow_right),
              subtitle: Builder(
                builder: (context) {
                  List<Widget> list = [];
                  list = (obj['expense_type'] ?? []).map<Widget>((map) {
                    return (map['enable'] ?? false)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(map['name']),
                              (map['is_limit'] ?? false)
                                  ? Text(
                                      "limit ${map['limit']} days",
                                    )
                                  : Container(),
                            ],
                          )
                        : Container();
                  }).toList();
                  return Container(
                    margin: EdgeInsets.only(top: 10, left: 15, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: list,
                    ),
                  );
                },
              ),
              onTap: () async {
                dynamic res = await Navigator.pushNamed(context, '/scrb035', arguments: {'expense_type': obj['expense_type']});
                if (res != null) {
                  obj['expense_type'] = res['data'];
                  await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'expense_type': obj['expense_type']}, SetOptions(merge: true));
                  AppStyle().session['company']['expense_type'] = obj['expense_type'];
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
    var tabSummary = Container(
      width: size.width,
      child: Column(
        children: [
          ListTile(
            title: Text("?????????????????????????????????????????????????????????"),
            onTap: () {
              Navigator.pushNamed(context, '/scrb053', arguments: {'title': "?????????????????????????????????????????????????????????", 'params': {}});
            },
          ),
          ListTile(
            title: Text("???????????????????????????????????????????????????????????????"),
            onTap: () async {
              AppStyle().session['data']['master_project'] ??= [];
              var res = await Navigator.pushNamed(context, '/util103',
                  arguments: {'list': AppStyle().session['data']['master_project'] ?? [], 'key': 'name', 'select': obj['project'] ?? '', 'Add': 'N'});
              if (res != null) {
                var res2 = res as Map<String, dynamic>;
                obj['project'] = res2['keyword'];
                Navigator.pushNamed(context, '/scrb057', arguments: {
                  'title': "???????????????????????????????????????????????????????????????",
                  'params': {'project': obj['project']}
                });
              }
            },
          ),
        ],
      ),
    );
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Expense Settings'),
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
                      child: Text("Settings"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Transaction"),
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
            tabSetting,
            tabPending,
            tabSummary,
          ]),
        ));
  }

  void initData() async {
    obj['workflow'] = {
      'displayName': 'Department Manager Approve',
      'code': 'l1',
      'cover': 'assets/images/expense_setting_001.png',
    };

    obj['users'] = [];

    _refresh();
    if (AppStyle().session['company']['expense_type'] == null) {
      AppStyle().session['company']['expense_type'] = AppStyle().session['setting']['default_expense_type'];
      await FirebaseFirestore.instance
          .collection('company')
          .doc(AppStyle().session['data']['uid'])
          .set({'expense_type': AppStyle().session['setting']['default_expense_type']}, SetOptions(merge: true));
    }
    obj['expense_type'] = AppStyle().session['company']['expense_type'];

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
    AppStyle().session['company']['members'].forEach((key, value) {
      value['uid'] = key;
      value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
      obj['users'].add(value);
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
