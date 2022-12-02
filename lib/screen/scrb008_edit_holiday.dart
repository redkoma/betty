import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb008EditHoliday extends StatefulWidget {
  const Scrb008EditHoliday({Key? key}) : super(key: key);

  @override
  _Scrb008EditHolidayState createState() => _Scrb008EditHolidayState();
}

class _Scrb008EditHolidayState extends State<Scrb008EditHoliday> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;

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
      nameController.text = obj['data']['name'];
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Holiday"),
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
                  'ตั้งค่าวันหยุด',
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
              hintText: 'Holiday Name',
              labelText: 'Holiday Name',
            ),
          ),
          Container(
            height: 350,
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: obj['data']['date'],
              onDateTimeChanged: (DateTime newDateTime) {
                // Do something
                obj['data']['date'] = newDateTime;
              },
            ),
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
                obj['data']['name'] = nameController.text;
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
