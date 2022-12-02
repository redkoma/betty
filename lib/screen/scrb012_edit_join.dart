import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb012EditJoin extends StatefulWidget {
  const Scrb012EditJoin({Key? key}) : super(key: key);

  @override
  _Scrb012EditJoinState createState() => _Scrb012EditJoinState();
}

class _Scrb012EditJoinState extends State<Scrb012EditJoin> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  List<String> department = [];
  @override
  void initState() {
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      department = [];
      for (var i = 0; i < AppStyle().session['company']['department'].length; i++) {
        if (AppStyle().session['company']['department'][i]['enable']) {
          department.add(AppStyle().session['company']['department'][i]['name']);
        }
      }
      if (obj['data']['department'] == null) {
        obj['data']['department'] = department[0];
      }
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Request"),
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
                  'คำขอเข้าบริษัท',
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
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage("${obj['data']['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
            ),
            title: Text('${obj['data']['userinfo']['displayName'] ?? obj['data']['userinfo']['email']}'),
            subtitle: Text('${obj['data']['userinfo']['email']}'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: obj['data']['department'] ?? department[0],
                  isExpanded: true,
                  items: department.map((map) {
                    return DropdownMenuItem(
                      child: Text(map),
                      value: map,
                    );
                  }).toList(),
                  hint: const Text("Department"),
                  onChanged: (String? val) {
                    setState(() {
                      obj['data']['department'] = val ?? department[0];
                    });
                  }),
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 40) / 2, AppStyle().btnHeight), primary: Colors.green),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: AppStyle().btnFontSize,
                    ),
                  ),
                  onPressed: () async {
                    var members = {};
                    members[obj['data']['uid']] = {
                      'department': obj['data']['department'],
                      'enable': true,
                      'userinfo': obj['data']['userinfo'],
                      'joindate': FieldValue.serverTimestamp()
                    };
                    await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'members': members}, SetOptions(merge: true));
                    await FirebaseFirestore.instance.collection('users').doc(obj['data']['id']).set({'companyId': AppStyle().session['data']['uid']}, SetOptions(merge: true));
                    await FirebaseFirestore.instance.collection('join').doc(obj['data']['id']).delete();

                    if (obj['data']['userinfo']['FCM'] != null) {
                      var payload = {
                        'FCM': obj['data']['userinfo']['FCM'],
                        'uid': obj['data']['uid'],
                        'title': 'Join Accepted',
                        'body': AppStyle().session['company']['name'] + ' has approved your request.',
                        'data': {
                          'body': AppStyle().session['company']['name'] + ' has approved your request.',
                          'action': 'joinStatus',
                          'did': AppStyle().session['company']['uid'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                      await FirebaseFirestore.instance.collection('notification').add(payload);
                    }

                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 40) / 2, AppStyle().btnHeight), primary: Colors.red),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: AppStyle().btnFontSize,
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('join').doc(obj['data']['id']).delete();
                    if (obj['data']['userinfo']['FCM'] != null) {
                      var payload = {
                        'FCM': obj['data']['userinfo']['FCM'],
                        'uid': obj['data']['uid'],
                        'title': 'Join Rejected',
                        'body': AppStyle().session['company']['name'] + ' has rejected your request.',
                        'data': {
                          'body': AppStyle().session['company']['name'] + ' has rejected your request.',
                          'action': 'joinStatus',
                          'did': obj['data']['id'],
                        },
                        'date': FieldValue.serverTimestamp(),
                        'status': 'WAIT',
                      };
                      await FirebaseFirestore.instance.collection('notification').add(payload);
                    }

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void initData() {}
}
