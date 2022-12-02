import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:betty/util/style.dart';

class Util100ListInbox extends StatefulWidget {
  const Util100ListInbox({Key? key}) : super(key: key);

  @override
  _Util100ListInboxState createState() => _Util100ListInboxState();
}

class _Util100ListInboxState extends State<Util100ListInbox> {
  AppStyle appStyle = AppStyle();
  TextEditingController searchController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};

  Map obj = {'profile': {}};

  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;

    if (!loaded) {
      obj = arguments;
      initData();
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 1,
          ),
          shrinkWrap: true,
          itemCount: ((AppStyle().session['notification'] ?? []).length),
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: (AppStyle().session['notification'][index]["status"] == 'OPENED') ? Colors.white : Colors.blueGrey[100],
              trailing: (AppStyle().session['notification'][index]["data"]['action'] == 'message')
                  ? Icon(Icons.message_outlined)
                  : (AppStyle().session['notification'][index]["data"]['action'] == 'post')
                      ? Icon(Icons.photo)
                      : FaIcon(FontAwesomeIcons.user),
              title: Text(
                AppStyle().session['notification'][index]["title"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(AppStyle().session['notification'][index]["body"] ?? ""),
              onTap: () async {
                dynamic message_data = AppStyle().session['notification'][index]['data'];
                print(message_data);

                if (AppStyle().session['notification'][index]["status"] != 'OPENED') {
                  FirebaseFirestore.instance.collection('notification').doc(message_data['id']).set({'status': 'OPENED'}, SetOptions(merge: true));
                  setState(() {
                    AppStyle().session['notification'][index]["status"] = 'OPENED';
                    AppStyle().session['notification_count']--;
                  });
                }

                if (message_data['action'] == 'user') {
                  FirebaseFirestore.instance.collection('users').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb010', arguments: {'data': tmp});
                    }
                  });
                } else if (message_data['action'] == 'invite') {
                  FirebaseFirestore.instance.collection('invite').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb011', arguments: {'data': tmp});
                    }
                  });
                } else if (message_data['action'] == 'join') {
                  FirebaseFirestore.instance.collection('join').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb012', arguments: {'data': tmp});
                    }
                  });
                } else if (message_data['action'] == 'joinStatus') {
                  await FirebaseFirestore.instance.collection('company').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic comp = documentSnapshot.data();
                      if (comp != null) {
                        if (comp['members'][AppStyle().session['user'].uid] != null) {
                          AppStyle().session['company'] = comp;
                          AppStyle().session['user_department'] = AppStyle().session['company']['members'][AppStyle().session['user'].uid];
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(AppStyle().session['user'].uid)
                              .set({'companyId': AppStyle().session['company']['uid']}, SetOptions(merge: true));

                          print("Have Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
                          setState(() {});
                        } else {
                          AppStyle().session['company'] = null;
                        }
                      } else {
                        AppStyle().session['company'] = null;
                      }
                    }
                  }).catchError((error) {
                    // print("Error: $error");
                  });
                  print(AppStyle().session['company']);
                } else if (message_data['action'] == 'memo') {
                  FirebaseFirestore.instance.collection('documents').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb038', arguments: {'doc': tmp});
                    }
                  });
                } else if (message_data['action'] == 'leave') {
                  FirebaseFirestore.instance.collection('documents').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb030', arguments: {'doc': tmp});
                    }
                  });
                } else if (message_data['action'] == 'training') {
                  FirebaseFirestore.instance.collection('documents').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb043', arguments: {'doc': tmp});
                    }
                  });
                } else if (message_data['action'] == 'expense') {
                  FirebaseFirestore.instance.collection('documents').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb036', arguments: {'doc': tmp});
                    }
                  });
                } else if (message_data['action'] == 'message') {
                  FirebaseFirestore.instance.collection('users').doc(message_data['from_uid']).get().then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb023', arguments: {'profile': tmp});
                    }
                  });
                } else if (message_data['action'] == 'task') {
                  FirebaseFirestore.instance.collection('tasks').doc(message_data['did']).get().then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      dynamic tmp = documentSnapshot.data();
                      tmp['id'] = documentSnapshot.id;
                      Navigator.pushNamed(context, '/scrb047', arguments: {'doc': tmp, 'ori_users': []});
                    }
                  });
                } else {}
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> initData() async {
    setState(() {});
  }
}
