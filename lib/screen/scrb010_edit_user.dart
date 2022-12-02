import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';

class Scrb010EditUser extends StatefulWidget {
  const Scrb010EditUser({Key? key}) : super(key: key);

  @override
  _Scrb010EditUserState createState() => _Scrb010EditUserState();
}

class _Scrb010EditUserState extends State<Scrb010EditUser> {
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
      if (obj['data']['joindate'] != null) {
        if (obj['data']['joindate'] is DateTime) {
        } else {
          obj['data']['joindate'] = obj['data']['joindate'].toDate();
        }
      }
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
        title: const Text("User Profile"),
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
                  'ข้อมูลผู้ใช้',
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
          Divider(height: 1),
          ListTile(
            title: Text(
              "วันที่เริ่มนับวันขาดงาน",
            ),
            subtitle: (obj['data']['joindate'] == null)
                ? Text('N/A')
                : Text(
                    "${DateFormat("dd MMMM yyyy").format(obj['data']['joindate'])}",
                  ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              var res = await Navigator.pushNamed(context, '/util101', arguments: {'date': obj['data']['joindate'], 'title': 'วันที่เริ่มใช้งาน'});
              if (res != null) {
                DateTime tmp = res as DateTime;

                obj['data']['joindate'] = tmp;
                setState(() {});
              }
            },
          ),
          SizedBox(height: 20),
          Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
              child: Text(
                'Update',
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                var members = {};
                members[obj['data']['uid']] = {
                  'department': obj['data']['department'],
                };
                if (obj['data']['joindate'] != null) {
                  members[obj['data']['uid']]['joindate'] = obj['data']['joindate'];
                }
                await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'members': members}, SetOptions(merge: true));

                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: 20),
          (obj['data']['uid'] != AppStyle().session['company']['uid'])
              ? Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: Colors.red),
                    child: Text(
                      'Remove from company',
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      var res = await AppStyle().confirm(context, "ต้องการนำผู้ใช้ออกจากบริษัท ?");
                      if (res != null) {
                        var members = {};
                        members[obj['data']['uid']] = FieldValue.delete();
                        await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'members': members}, SetOptions(merge: true));
                        await FirebaseFirestore.instance.collection('users').doc(obj['data']['uid']).set({'companyId': FieldValue.delete()}, SetOptions(merge: true));

                        Navigator.pop(context);
                      }
                    },
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }

  void initData() {}
}
