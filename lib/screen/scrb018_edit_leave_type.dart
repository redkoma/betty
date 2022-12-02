import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb018EditLeaveType extends StatefulWidget {
  const Scrb018EditLeaveType({Key? key}) : super(key: key);

  @override
  _Scrb018EditLeaveTypeState createState() => _Scrb018EditLeaveTypeState();
}

class _Scrb018EditLeaveTypeState extends State<Scrb018EditLeaveType> {
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
      nameController.text = obj['data']['name'] ?? '';
      remarkController.text = obj['data']['limit'] ?? '0';
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Type Detail"),
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
                  'ตั้งค่าประเภทการลา',
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
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFEEEEEE),
              hintText: 'Leave Type',
              labelText: 'Leave Type',
            ),
          ),
          ListTile(
            title: Text(
              "จำกัดจำนวนการลา",
            ),
            trailing: Switch(
              value: obj['data']['is_limit'] ?? false,
              onChanged: (value) {
                setState(() {
                  obj['data']['is_limit'] = value;
                });
              },
            ),
          ),
          (obj['data']['is_limit'] ?? false)
              ? TextField(
                  controller: remarkController,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    hintText: 'จำกัดการลา',
                    labelText: 'จำกัดการลา',
                  ),
                )
              : Container(),
          SizedBox(height: 20),
          Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
              child: Text(
                'Submit Invite',
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                obj['data']['name'] = nameController.text;
                obj['data']['limit'] = int.parse(remarkController.text);

                Navigator.pop(context, {'data': obj['data']});
              },
            ),
          ),
        ]),
      ),
    );
  }

  void initData() {}
}
