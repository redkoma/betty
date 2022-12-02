import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:time_range/time_range.dart';

class Scrb006EditTime extends StatefulWidget {
  const Scrb006EditTime({Key? key}) : super(key: key);

  @override
  _Scrb006EditTimeState createState() => _Scrb006EditTimeState();
}

class _Scrb006EditTimeState extends State<Scrb006EditTime> {
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
    // Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;

      if (obj['time'] != null) {
        var s1 = (obj['time']['begin'] ?? "08:00").toString().split(':');
        var s2 = (obj['time']['end'] ?? "17:00").toString().split(':');
        TimeRangeResult _setTimeRange = TimeRangeResult(
          TimeOfDay(hour: int.parse(s1[0]), minute: int.parse(s1[1])),
          TimeOfDay(hour: int.parse(s2[0]), minute: int.parse(s2[1])),
        );

        _timeRange = _setTimeRange;
      }
      loaded = true;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Setting"),
      ),
      backgroundColor: AppStyle().mainBgColor,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16, left: leftPadding),
            child: Text(
              'Opening Times',
              style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: dark),
            ),
          ),
          SizedBox(height: 20),
          TimeRange(
            fromTitle: Text(
              'FROM',
              style: TextStyle(
                fontSize: 14,
                color: dark,
                fontWeight: FontWeight.w600,
              ),
            ),
            toTitle: Text(
              'TO',
              style: TextStyle(
                fontSize: 14,
                color: dark,
                fontWeight: FontWeight.w600,
              ),
            ),
            titlePadding: leftPadding,
            textStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: dark,
            ),
            activeTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: orange,
            ),
            borderColor: dark,
            activeBorderColor: dark,
            backgroundColor: Colors.transparent,
            activeBackgroundColor: dark,
            firstTime: TimeOfDay(hour: 6, minute: 00),
            lastTime: TimeOfDay(hour: 23, minute: 00),
            initialRange: _timeRange,
            timeStep: 10,
            timeBlock: 30,
            onRangeCompleted: (range) => setState(() => _timeRange = range),
          ),
          const SizedBox(
            height: 30,
          ),
          (_timeRange == null)
              ? Container()
              : Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                    child: Text(
                      AppStyle().tr('Set Time'),
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      obj['time']['begin'] = ((_timeRange!.start.hour < 10) ? '0' : '') +
                          _timeRange!.start.hour.toString() +
                          ':' +
                          ((_timeRange!.start.minute < 10) ? '0' : '') +
                          _timeRange!.start.minute.toString();
                      obj['time']['end'] = ((_timeRange!.end.hour < 10) ? '0' : '') +
                          _timeRange!.end.hour.toString() +
                          ':' +
                          ((_timeRange!.end.minute < 10) ? '0' : '') +
                          _timeRange!.end.minute.toString();
                      Navigator.pop(context, {'time': obj['time']});
                    },
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          (_timeRange == null)
              ? Container()
              : Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight)),
                    child: Text(
                      AppStyle().tr('Set Time to everyday'),
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      obj['time']['begin'] = ((_timeRange!.start.hour < 10) ? '0' : '') +
                          _timeRange!.start.hour.toString() +
                          ':' +
                          ((_timeRange!.start.minute < 10) ? '0' : '') +
                          _timeRange!.start.minute.toString();
                      obj['time']['end'] = ((_timeRange!.end.hour < 10) ? '0' : '') +
                          _timeRange!.end.hour.toString() +
                          ':' +
                          ((_timeRange!.end.minute < 10) ? '0' : '') +
                          _timeRange!.end.minute.toString();
                      Navigator.pop(context, {'time': obj['time'], 'all': 'Y'});
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
