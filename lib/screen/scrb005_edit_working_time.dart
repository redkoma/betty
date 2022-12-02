import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb005EditWorkingTime extends StatefulWidget {
  const Scrb005EditWorkingTime({Key? key}) : super(key: key);

  @override
  _Scrb005EditWorkingTimeState createState() => _Scrb005EditWorkingTimeState();
}

class _Scrb005EditWorkingTimeState extends State<Scrb005EditWorkingTime> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  TextStyle text = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  TextStyle text2 = const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey);
  static const orange = Colors.white;
  static const dark = Colors.blueGrey;
  static const double leftPadding = 15;

  final _defaultTimeRange = TimeRangeResult(
    TimeOfDay(hour: 14, minute: 50),
    TimeOfDay(hour: 15, minute: 20),
  );
  TimeRangeResult? _timeRange;
  @override
  void initState() {
    super.initState();
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      obj['openday'] = {
        'mon': false,
        'tue': false,
        'wed': false,
        'thu': false,
        'fri': false,
        'sat': false,
        'sun': false,
      };
      obj['rangetime'] = {
        'mon': {},
        'tue': {},
        'wed': {},
        'thu': {},
        'fri': {},
        'sat': {},
        'sun': {},
      };
      for (var i = 0; i < (obj['time'] ?? []).length; i++) {
        var tmp = obj['time'][i];
        obj['openday'][tmp['wday'].toLowerCase()] = tmp['enable'];
        obj['rangetime'][tmp['wday'].toLowerCase()] = tmp;
      }
      print(obj['time']);
      print(obj['openday']);
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Working Time"),
      ),
      backgroundColor: AppStyle().mainBgColor,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
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
                  'เวลาเข้า-เลิกงาน',
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
            width: size.width,
            color: Colors.blueGrey[100],
            padding: const EdgeInsets.all(15),
            child: Text(
              '${obj['key']}',
              style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.brown),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Monday'),
            subtitle: Text('${obj['rangetime']['mon']['begin'] ?? '00:00'} - ${obj['rangetime']['mon']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['mon'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['mon'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['mon']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['mon'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Tueday'),
            subtitle: Text('${obj['rangetime']['tue']['begin'] ?? '00:00'} - ${obj['rangetime']['tue']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['tue'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['tue'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['tue']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['tue'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Wednesday'),
            subtitle: Text('${obj['rangetime']['wed']['begin'] ?? '00:00'} - ${obj['rangetime']['wed']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['wed'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['wed'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['wed']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['wed'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Thuresday'),
            subtitle: Text('${obj['rangetime']['thu']['begin'] ?? '00:00'} - ${obj['rangetime']['thu']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['thu'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['thu'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['thu']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['thu'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Friday'),
            subtitle: Text('${obj['rangetime']['fri']['begin'] ?? '00:00'} - ${obj['rangetime']['fri']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['fri'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['fri'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['fri']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['fri'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Saturday'),
            subtitle: Text('${obj['rangetime']['sat']['begin'] ?? '00:00'} - ${obj['rangetime']['sat']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['sat'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['sat'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['sat']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['sat'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          ListTile(
            title: Text('Sunday'),
            subtitle: Text('${obj['rangetime']['sun']['begin'] ?? '00:00'} - ${obj['rangetime']['sun']['end'] ?? '00:00'}'),
            trailing: Switch(
              value: obj['openday']['sun'],
              onChanged: (value) {
                setState(() {
                  obj['openday']['sun'] = value;
                });
              },
            ),
            onTap: () async {
              var res0 = await Navigator.pushNamed(context, '/scrb006', arguments: {'time': obj['rangetime']['sun']});
              if (res0 != null) {
                Map<String, dynamic> res = res0 as Map<String, dynamic>;
                obj['rangetime']['sun'] = res['time'];
                if (res['all'] == 'Y') {
                  obj['rangetime']['mon'] = res['time'];
                  obj['rangetime']['tue'] = res['time'];
                  obj['rangetime']['wed'] = res['time'];
                  obj['rangetime']['thu'] = res['time'];
                  obj['rangetime']['fri'] = res['time'];
                  obj['rangetime']['sat'] = res['time'];
                  obj['rangetime']['sun'] = res['time'];
                }
                setState(() {});
              }
            },
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
              child: Text(
                AppStyle().tr('Update'),
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                List tmp = [];
                obj['rangetime'].forEach((key, value) {
                  obj['rangetime'][key]['wday'] = key;
                });
                obj['openday'].forEach((key, value) {
                  var tmp_ = obj['rangetime'][key];
                  tmp_['wday'] = key;
                  tmp_['enable'] = value;
                  tmp.add(tmp_);
                });
                print(tmp);
                Navigator.pop(context, {'time': tmp});
              },
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ]),
      ),
    );
  }

  void initData() {}
}
