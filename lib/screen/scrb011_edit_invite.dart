import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb011EditInvite extends StatefulWidget {
  const Scrb011EditInvite({Key? key}) : super(key: key);

  @override
  _Scrb011EditInviteState createState() => _Scrb011EditInviteState();
}

class _Scrb011EditInviteState extends State<Scrb011EditInvite> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true, 'department': []};
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
  TextEditingController remarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      nameController.text = obj['data']['email'] ?? '';
      remarkController.text = obj['data']['remark'] ?? '';
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
        title: const Text("Invite"),
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
                  'คำเชิญเข้าร่วมบริษัท',
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
          TextField(
            controller: nameController,
            keyboardType: TextInputType.emailAddress,
            maxLines: null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Email',
              labelText: 'Email',
            ),
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
          TextField(
            controller: remarkController,
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'หมายเหตุ',
              labelText: 'หมายเหตุ',
            ),
          ),
          SizedBox(height: 20),
          (obj['data']['status'] == null)
              ? Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
                    child: Text(
                      'Submit Invite',
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      obj['data']['email'] = nameController.text;
                      obj['data']['remark'] = remarkController.text;
                      obj['data']['status'] = 'Wait';
                      obj['data']['inviteBy'] = "${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']} (${AppStyle().session['data']['email']})";

                      Navigator.pop(context, {'invite': obj['data']});
                    },
                  ),
                )
              : Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 40) / 2, AppStyle().btnHeight), primary: Colors.green),
                        child: Text(
                          'Re Invite',
                          style: TextStyle(
                            fontSize: AppStyle().btnFontSize,
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('invite').doc(obj['data']['id']).set({'status': 'Wait'}, SetOptions(merge: true));
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 40) / 2, AppStyle().btnHeight), primary: Colors.red),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: AppStyle().btnFontSize,
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('invite').doc(obj['data']['id']).delete();
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
