import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scrb009UserManagement extends StatefulWidget {
  const Scrb009UserManagement({Key? key}) : super(key: key);

  @override
  _Scrb009UserManagementState createState() => _Scrb009UserManagementState();
}

class _Scrb009UserManagementState extends State<Scrb009UserManagement> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController nameInviteController = TextEditingController();
  TextEditingController nameJoinController = TextEditingController();
  var listenerInvite;
  var listenerJoin;
  var listenerUser;
  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      _onChanged();
    });
    nameInviteController.addListener(() {
      _onChangedInvite();
    });
    nameJoinController.addListener(() {
      _onChangedJoin();
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    nameInviteController.dispose();
    nameJoinController.dispose();
    listenerInvite.cancel();
    listenerJoin.cancel();
    listenerUser.cancel();
    super.dispose();
  }

  _onChanged() {
    getSuggestion(nameController.text);
  }

  _onChangedInvite() {
    getSuggestionInvite(nameInviteController.text);
  }

  _onChangedJoin() {
    getSuggestionJoin(nameJoinController.text);
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
    if (obj['filter_dep'] != null) {
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

  void getSuggestionInvite(String input) async {
    List<dynamic> results = [];
    List<dynamic> results2 = [];
    if (input.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = obj['ori_invite'];
    } else {
      for (var i = 0; i < obj['ori_invite'].length; i++) {
        if (obj['ori_invite'][i]['keyword'].contains(input.toLowerCase())) {
          results.add(obj['ori_invite'][i]);
        }
      }
    }

    // Refresh the UI
    setState(() {
      obj['invite'] = results;
    });
  }

  void getSuggestionJoin(String input) async {
    List<dynamic> results = [];
    List<dynamic> results2 = [];
    if (input.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = obj['ori_join'];
    } else {
      for (var i = 0; i < obj['ori_join'].length; i++) {
        if (obj['ori_join'][i]['keyword'].contains(input.toLowerCase())) {
          results.add(obj['ori_join'][i]);
        }
      }
    }

    // Refresh the UI
    setState(() {
      obj['join'] = results;
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

    var tabUser = Container(
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
                    var res0 = await Navigator.pushNamed(context, '/scrb010', arguments: {'data': obj['users'][index]});
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
    var tabInvite = Container(
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
              child: TextField(
                controller: nameInviteController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                        nameInviteController.clear();
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
                  leading: Icon(
                    Icons.outgoing_mail,
                    color: (obj['invite'][index]['status'] == 'Wait')
                        ? Colors.brown
                        : (obj['invite'][index]['status'] == 'Rejected')
                            ? Colors.deepOrange
                            : Colors.blueGrey,
                  ),
                  title: Text(
                    "${obj['invite'][index]['email']}",
                  ),
                  subtitle: Text(
                    "${obj['invite'][index]['department']} (${obj['invite'][index]['status']})",
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    dynamic res0 = await Navigator.pushNamed(context, '/scrb011', arguments: {'data': obj['invite'][index]});
                    _refresh();
                  },
                );
              },
              itemCount: (obj['invite'] ?? []).length,
            ),
          )
        ],
      ),
    );
    var tabJoin = Container(
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
              child: TextField(
                controller: nameJoinController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                        nameJoinController.clear();
                      },
                    ),
                    hintText: AppStyle().tr('Search '),
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            color: Colors.brown[100],
            height: 60,
            width: size.width,
            child: Center(
              child: Text(
                "JOIN CODE : ${AppStyle().session['company']['companyCode']}",
                style: TextStyle(fontSize: 24),
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
                    backgroundImage: NetworkImage("${obj['join'][index]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                  ),
                  title: Text(
                    "${obj['join'][index]['userinfo']['displayName'] ?? obj['join'][index]['userinfo']['email']}",
                  ),
                  subtitle: Text(
                    "${obj['join'][index]['userinfo']['email']}",
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    var res0 = await Navigator.pushNamed(context, '/scrb012', arguments: {'data': obj['join'][index]});
                    _refresh();
                  },
                );
              },
              itemCount: (obj['join'] ?? []).length,
            ),
          )
        ],
      ),
    );
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('User management'),
            actions: [
              TextButton(
                  onPressed: () async {
                    dynamic res0 = await Navigator.pushNamed(context, '/scrb011', arguments: {'data': {}});
                    if (res0 != null) {
                      var invite = {
                        'email': res0['invite']['email'],
                        'department': res0['invite']['department'],
                        'remark': res0['invite']['remark'],
                        'status': res0['invite']['status'],
                        'inviteBy': res0['invite']['inviteBy'],
                        'companyId': AppStyle().session['company']['uid'],
                        'compinfo': AppStyle().session['company'],
                      };
                      print(invite);
                      FirebaseFirestore.instance.collection('invite').add(invite).then((value) {
                        invite['id'] = value.id;
                        if (obj['ori_invite'] == null) {
                          obj['ori_invite'] = [];
                        }
                        if (obj['invite'] == null) {
                          obj['invite'] = [];
                        }
                        obj['ori_invite'].add(invite);
//                        obj['invite'].add(invite);
                        setState(() {});
                      });
                    }
                  },
                  child: Text(
                    'Invite',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
            backgroundColor: Colors.brown,
            elevation: 0,
            bottom: TabBar(
                labelColor: Colors.brown,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Users (${(obj['users'] ?? []).length})"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Invites (${(obj['invite'] ?? []).length})"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Join (${(obj['join'] ?? []).length})"),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            tabUser,
            tabInvite,
            tabJoin,
          ]),
        ));
  }

  void initData() async {
    obj['users'] = [];
    _refresh();
    _initListen();
  }

  void _initListen() async {
    listenerInvite = FirebaseFirestore.instance.collection('invite').where('companyId', isEqualTo: AppStyle().session['company']['uid']).snapshots().listen((event) async {
      obj['invite'] = [];
      for (var doc in event.docs) {
        dynamic tmp = doc.data();
        tmp['id'] = doc.id;
        tmp['keyword'] = tmp['email'].toString();
        obj['invite'].add(tmp);
      }
      obj['ori_invite'] = obj['invite'];
      setState(() {});
    });
    listenerJoin = FirebaseFirestore.instance.collection('join').where('companyId', isEqualTo: AppStyle().session['company']['uid']).snapshots().listen((event) async {
      obj['join'] = [];
      for (var doc in event.docs) {
        dynamic tmp = doc.data();
        tmp['id'] = doc.id;
        tmp['keyword'] = tmp['userinfo']['email'];
        obj['join'].add(tmp);
      }
      obj['ori_join'] = obj['join'];
      setState(() {});
    });
    listenerUser = FirebaseFirestore.instance.collection('company').doc(AppStyle().session['company']['uid']).snapshots().listen((event) async {
      if (event.exists) {
        AppStyle().session['company'] = event.data();
      }
      obj['users'] = [];
      AppStyle().session['company']['members'].forEach((key, value) {
        value['uid'] = key;
        value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
        obj['users'].add(value);
      });

      obj['ori_users'] = obj['users'];
      getSuggestion(nameController.text);

      setState(() {});
    });
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
    var value = {'name': 'All', 'select': true, 'enable': true};
    obj['filter_dep'].add(value);
    AppStyle().session['company']['department'].forEach((value) {
      if (value['enable']) {
        value['select'] = true;
        obj['filter_dep'].add(value);
      }
    });
    getSuggestion(nameController.text);

    obj['invite'] = [];
    FirebaseFirestore.instance.collection('invite').where('companyId', isEqualTo: AppStyle().session['company']['uid']).get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        print("Loaded = ");
        print(querySnapshot.size);
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          tmp['keyword'] = tmp['email'].toString();
          obj['invite'].add(tmp);
        }
        obj['ori_invite'] = obj['invite'];
        setState(() {});
      } else {
        obj['ori_invite'] = obj['invite'];
        setState(() {});
      }
    });
    obj['join'] = [];
    FirebaseFirestore.instance.collection('join').where('companyId', isEqualTo: AppStyle().session['company']['uid']).get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        // print("Loaded = ");
        // print(querySnapshot.size);
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          tmp['keyword'] = tmp['userinfo']['email'];
          obj['join'].add(tmp);
        }
        obj['ori_join'] = obj['join'];
        setState(() {});
      } else {
        obj['ori_join'] = obj['join'];
        setState(() {});
      }
    });
  }
}
