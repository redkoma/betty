// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:betty/main.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:betty/util/style.dart';
import "dart:math";
import 'package:badges/badges.dart';

class Scr002Main extends StatefulWidget {
  const Scr002Main({Key? key}) : super(key: key);

  @override
  _Scr002MainState createState() => _Scr002MainState();
}

class _Scr002MainState extends State<Scr002Main> {
  int _selectedIndex = 2;
  var statColor = {
    'Draft': Color.fromARGB(255, 152, 148, 141),
    'Todo': Color.fromARGB(255, 191, 160, 6),
    'Doing': Color.fromARGB(255, 191, 98, 6),
    'Done': Color.fromARGB(255, 12, 191, 6),
  };

  TextStyle text = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  TextStyle text2 = const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey);
  ScrollController _scrollController = ScrollController(initialScrollOffset: 5.0);
  bool selected = true;
  bool switchMission = true;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
// notification
    AppStyle().debugmsg('initState');
    print("Firebase Config : " + Firebase.app().name);
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
//    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (payload) async {
      print('onSelectNotification');
      print(jsonDecode(payload!));
      var message_data = jsonDecode(payload);
      if (message_data['id'] != null) {
        FirebaseFirestore.instance.collection('notification').doc(message_data['id']).set({'status': 'OPENED'}, SetOptions(merge: true));
      }

      if (message_data['action'] == 'message') {
        FirebaseFirestore.instance.collection('users').doc(message_data['from_uid']).get().then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            dynamic tmp = documentSnapshot.data();
            tmp['id'] = documentSnapshot.id;
            Navigator.pushNamed(context, '/scrb023', arguments: {'profile': tmp});
          }
        });
      } else if (message_data['action'] == 'profile') {
        FirebaseFirestore.instance.collection('users').doc(message_data['uid']).get().then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            dynamic tmp = documentSnapshot.data();
            tmp['id'] = documentSnapshot.id;
            Navigator.pushNamed(context, '/scr003', arguments: {'profile': tmp});
          }
        });
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      AppStyle().debugmsg('getInitialMessage');
      AppStyle().debugmsg(message);
      if (message != null) {
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppStyle().debugmsg('onMessageOpenedApp');
      if (message.data.isNotEmpty) {
        if (message.data['action'] == 'message') {
          FirebaseFirestore.instance.collection('users').doc(message.data['from_uid']).get().then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              dynamic tmp = documentSnapshot.data();
              tmp['id'] = documentSnapshot.id;
              Navigator.pushNamed(context, '/scrb023', arguments: {'profile': tmp});
            }
          });
        } else if (message.data['action'] == 'profile') {
          FirebaseFirestore.instance.collection('users').doc(message.data['uid']).get().then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              dynamic tmp = documentSnapshot.data();
              tmp['id'] = documentSnapshot.id;
              Navigator.pushNamed(context, '/scr003', arguments: {'profile': tmp});
            }
          });
        }
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppStyle().debugmsg('Got a message whilst in the foreground!');
      AppStyle().debugmsg('Message data: ${message.data}');
      AppStyle().debugmsg(message);

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      setState(() {
        AppStyle().session['need_refresh'] = 'Y';
        print("need_refresh = ${AppStyle().session['need_refresh']}");
      });

      if (notification != null && android != null && !kIsWeb) {
        AppStyle().debugmsg('Message also contained a notification: ${notification}');

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
              ),
            ),
            payload: jsonEncode(message.data));
      }
      if (message.data.isNotEmpty) {
        AppStyle().debugmsg('Android Message has data ##############');
      }
    });
  }

  @override
  void dispose() {
    //timer.cancel();

    super.dispose();
  }

  final textfieldController = TextEditingController();
  dynamic folders = {};
  Map arguments = {};
  String filter = "All";
  String view = "Pet";
  Map obj = {};
  List<String> swipeImage = [
    "assets/images/card5.jpg",
    "assets/images/card2.png",
    "assets/images/card3.jpeg",
  ];
  List<String> swipeTitle = [
    "Set up your pet",
    "Add your buddy",
    "Near places around you.",
  ];
  List<String> swipeDesc = [
    "ตั้งค่าสัตว์เลี้ยงของคุณ เพื่อเริ่มใช้งาน Pet Book สำหรับบันทึกน้ำหนักและประวัติวัคซีน",
    "เพิ่มเพื่อนสนิทของสัตว์เลี้ยงของคุณ",
    "ค้นหาสถานที่ใกล้ตัวคุณ ที่คุณและสัตว์เลี้ยงของคุณ สามารถไปด้วยกันได้",
  ];
  int scanIndex = 0;
  bool loaded = false;
  List<Widget> itemsWidget = [];
  List<dynamic> items = [];
  List<Widget> filters = [];
  Size size = const Size(10, 10);
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    size = MediaQuery.of(context).size;
    if (!loaded) {
      print("LOADING MAIN ############");
      initData();

      FirebaseFirestore.instance.collection('okrs').doc(AppStyle().session['user'].uid).snapshots().listen((documentSnapshot) async {
        print("### ACTIVE OKRS ONCHANGE #####");
        if (documentSnapshot.exists) {
          dynamic tmp = documentSnapshot.data();
          obj['okrs'] = tmp['okrs'] ?? {};
          obj['okrcount'] = 0;
          (obj['okrs'] ?? {}).forEach((key, okr) {
            obj['okrcount']++;
          });
        } else {
          obj['okrs'] = {};
          obj['okrcount'] = 0;
        }
        setState(() {});
      });
      FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).snapshots().listen(
        (event) async {
          print("### ACTIVE USER ONCHANGE #####");
          if (AppStyle().session != null) {
            AppStyle().session['data'] = event.data();

            // await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) async {
            //   if (documentSnapshot.exists) {
            //     AppStyle().session['timesheet'] = documentSnapshot.data();
            //     setState(() {});
            //   }
            // });

            if ((AppStyle().session['data']['companyId'] != null) && (AppStyle().session['company'] == null)) {
              print("## CASE :  Just Join Company ### ${AppStyle().session['data']['companyId']}");
              await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['companyId']).get().then((DocumentSnapshot documentSnapshot) async {
                if (documentSnapshot.exists) {
                  AppStyle().session['company'] = documentSnapshot.data();
                  if (AppStyle().session['company'] != null) {
                    AppStyle().session['user_department'] = AppStyle().session['company']['members'][AppStyle().session['user'].uid];

                    // calcTimesheetStat();
                  }
                  if (AppStyle().session['user_department'] == null) {
                    print("Not Member in Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
                    AppStyle().session['company'] = null;
                    await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set({'companyId': FieldValue.delete()}, SetOptions(merge: true));
                  } else {
                    print("Have Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
                  }
                  setState(() {});
                }
              }).catchError((error) {
                // print("Error: $error");
              });
            }
            if ((AppStyle().session['data']['companyId'] == null) && (AppStyle().session['company'] != null)) {
              print("## CASE : JUST REMOVED FROM COMPANY");
              AppStyle().session['company'] = null;
              AppStyle().session['inviteStatus'] = null;
            }
            // if (AppStyle().session['company'] != null) {
            //   if (AppStyle().session['company']['members'][AppStyle().session['data']['uid']] != null) {
            //     calcTimesheetStat();
            //   }
            // }
            setState(() {});
          }
        },
        onError: (error) => print("Listen failed: $error"),
      );

      FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['user'].uid).snapshots().listen((event) async {
        print("### ACTIVE TIMESHEET ONCHANGE #####");

        AppStyle().session['timesheet'] = event.data();
        AppStyle().session['timesheet'] ??= {};
        if (AppStyle().session['company'] != null) {
          calcTimesheetStat();
        }
        setState(() {});
      });

      FirebaseFirestore.instance
          .collection('notification')
          .where('uid', isEqualTo: AppStyle().session['user'].uid)
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots()
          .listen((event) async {
        print("### ACTIVE NOTIFICATION ONCHANGE #####");

        AppStyle().session['notification'] = [];
        AppStyle().session['notification_count'] = 0;
        for (var doc in event.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          setState(() {
            AppStyle().session['notification'].add(tmp);
            if (tmp['status'] == 'SENT') {
              AppStyle().session['notification_count']++;
            }
          });
        }
        setState(() {});
      });

      FirebaseFirestore.instance
          .collection('invite')
          .where('email', isEqualTo: AppStyle().session['data']['email'])
          .where('status', isEqualTo: 'Wait')
          .snapshots()
          .listen((event) async {
        print("### ACTIVE INVITE ONCHANGE #####");
        AppStyle().session['_inviteFeedback'] = null;
        AppStyle().session['inviteStatus'] = null;
        for (var doc in event.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          setState(() {
            AppStyle().session['inviteStatus'] = tmp;
          });
        }
        setState(() {});
      });

      FirebaseFirestore.instance.collection('join').where('uid', isEqualTo: AppStyle().session['data']['email']).snapshots().listen((event) async {
        print("### ACTIVE JOIN ONCHANGE #####");
        AppStyle().session['joinStatus'] = null;
        for (var doc in event.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          print('Join Status $tmp');
          setState(() {
            AppStyle().session['joinStatus'] = tmp;
          });
        }
        setState(() {});
      });

      loaded = true;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          selected = !selected;
        });
      });
    }

    List<Widget> tabItems = [
      tabInbox(context),
      tabTask(context),
      // tabService(context),
      tabHome(context),
      tabContact(context),
      tabProfile(context),
    ];

    return Scaffold(
      appBar: (_selectedIndex == 3)
          ? AppBar(
              backgroundColor: AppStyle().bgColor,
              title: const Text('Contacts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              centerTitle: false,
              // actions: [
              //   IconButton(
              //       onPressed: () async {
              //         await Navigator.pushNamed(context, '/scr005', arguments: {'profile': AppStyle().session['profile']});
              //       },
              //       icon: const FaIcon(FontAwesomeIcons.cartShopping))
              // ],
            )
          : (_selectedIndex == 2)
              ? AppBar(
                  backgroundColor: AppStyle().bgColor,
                  toolbarHeight: 70,
                  title: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: InkWell(
                            onTap: () async {
                              if (AppStyle().session['user'].uid == obj['profile']['uid']) {
                                var image = await AppStyle().browseImageBase64(1024, 1024, 90);
                                if (image['base64'] != '') {
                                  AppStyle().showSnackBar(context, "Uploading ... ", Colors.amber);

                                  final storageRef = FirebaseStorage.instance.ref();
                                  final postImagesRef =
                                      storageRef.child("users/" + AppStyle().session['user'].uid + "/images/post" + DateTime.now().microsecondsSinceEpoch.toString() + ".jpg");
                                  try {
                                    await postImagesRef.putString(image['base64'].toString(), format: PutStringFormat.base64);
                                    String url = await postImagesRef.getDownloadURL();
                                    AppStyle().session['user'].updatePhotoURL(url);

                                    FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set({
                                      'photoURL': url,
                                    }, SetOptions(merge: true)).then((value) {
                                      setState(() {
                                        obj['profile']['photoURL'] = url;
                                        AppStyle().session['data']['photoURL'] = url;
                                        print(obj['profile']['photoURL']);
                                      });
                                    }).catchError((error) {
                                      // print("Failed to merge data: $error");
                                      AppStyle().error_pop(context, 'Error', error.toString(), 'OK');
                                    });
                                  } on FirebaseException catch (e) {
                                    AppStyle().error_pop(context, 'Error', e.toString(), 'OK');
                                    // print(e);
                                  }
                                }
                              }
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage("${AppStyle().session['data']['photoURL'] ?? AppStyle().no_user_url}"),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppStyle().session['data']['displayName'] ?? AppStyle().session['data']['email']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  overflow: TextOverflow.fade,
                                  // fontWeight: FontWeight.bold,
                                )),
                            Text('${(AppStyle().session['user_department'] ?? {})['department'] ?? 'Not have department'}',
                                style: TextStyle(
                                  color: AppStyle().mainTabActiveColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.fade,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  actions: [
                    InkWell(
                        onTap: () async {
                          await Navigator.pushNamed(context, '/util100', arguments: {'profile': AppStyle().session['profile']});
                          setState(() {});
                        },
                        child: Badge(
                          position: BadgePosition.topEnd(top: 5, end: 5),
                          badgeContent: ((AppStyle().session['notification_count'] ?? 0) > 0)
                              ? Text('${AppStyle().session['notification_count']}', style: TextStyle(color: Colors.white, fontSize: 12))
                              : null,
                          showBadge: ((AppStyle().session['notification_count'] ?? 0) > 0),
                          child: FaIcon(FontAwesomeIcons.envelope),
                        )),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                )
              : (_selectedIndex == 1)
                  ? AppBar(
                      backgroundColor: AppStyle().bgColor,
                      title: const Text('Task Management',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                      centerTitle: false,
                      actions: [
                        IconButton(
                          onPressed: () async {
                            dynamic req = {
                              'doc': {'from_uid': AppStyle().session['data']['uid']},
                              'ori_users': []
                            };
                            dynamic res0 = await Navigator.pushNamed(context, '/scrb047', arguments: req);
                            if (res0 != null) {
                              // print(res0);
                              // FirebaseFirestore.instance.collection('places').doc(res0['id']).get().then((DocumentSnapshot documentSnapshot) {
                              //   if (documentSnapshot.exists) {
                              //     print(documentSnapshot.data());
                              //     Navigator.pushNamed(context, '/scr011', arguments: {'profile': documentSnapshot.data()});
                              //   } else {
                              //     Navigator.pushNamed(context, '/scr011', arguments: {'profile': res0});
                              //   }
                              // }).catchError((error) {
                              //   // print("Error: $error");
                              // });
                            }
                          },
                          icon: const Icon(Icons.add_box),
                        )
                      ],
                    )
                  : (_selectedIndex == 0)
                      ? AppBar(
                          backgroundColor: AppStyle().bgColor,
                          title: Text('Inbox',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              )),
                          centerTitle: false,
                        )
                      : null,
      backgroundColor: AppStyle().mainBgColor,
      body: tabItems[_selectedIndex],
      bottomNavigationBar: FlashyTabBar(
        backgroundColor: AppStyle().mainTabBgColor,
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
          if (index == 0) {
            obj['loading'] = false;
            _pullInboxRefresh();
          }
          if (index == 1) {
            obj['loading'] = false;
            _pullTaskRefresh();
          }
        }),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.move_to_inbox_outlined),
            title: const Text('Inbox'),
            activeColor: AppStyle().mainTabActiveColor,
            inactiveColor: AppStyle().mainTabTxtColor,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.task_outlined),
            title: const Text('Task'),
            activeColor: AppStyle().mainTabActiveColor,
            inactiveColor: AppStyle().mainTabTxtColor,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            activeColor: AppStyle().mainTabActiveColor,
            inactiveColor: AppStyle().mainTabTxtColor,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.group),
            title: const Text('Contacts'),
            activeColor: AppStyle().mainTabActiveColor,
            inactiveColor: AppStyle().mainTabTxtColor,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: AppStyle().mainTabActiveColor,
            inactiveColor: AppStyle().mainTabTxtColor,
          ),
        ],
      ),
    );
  }

  void calcTimesheetStat() {
    obj['profile'] = AppStyle().session['data'];
    // Process dashboard
    var wd = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var date = DateTime.now();
    var day = DateTime(date.year, date.month + 1, 0).day;
    // print(day);
    var month = {};

// check shift if have shift calendar user shift working time
    var cal = (AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {})['calendar'];
    if (AppStyle().session['calendar'][AppStyle().session['data']['uid']] != null) {
      cal = AppStyle().session['calendar'][AppStyle().session['data']['uid']];
    }
    cal ??= {};
    var shift = {};
    int shift_count = 0;
    print("-------------------------");
    if (cal != null) {
      for (var i = 1; i <= day; i++) {
        var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
        if (cal[key] != null) {
          shift_count++;
          if (shift[cal[key]] == null) {
            shift[cal[key]] = {};
            for (var x = 0; x < (AppStyle().session['company']['working_time'][cal[key]] ?? []).length; x++) {
              var _w = AppStyle().session['company']['working_time'][cal[key]][x]['wday'].toLowerCase();
              shift[cal[key]][_w] = AppStyle().session['company']['working_time'][cal[key]][x];
            }
          }
        }
      }
    }
    print(shift);

    // Working Time
    var working_time = {};
    for (var i = 0; i < (AppStyle().session['company']['working_time']['default'] ?? []).length; i++) {
      var key = AppStyle().session['company']['working_time']['default'][i]['wday'].toLowerCase();
      if (AppStyle().session['company']['working_time']['default'][i]['enable']) {
        working_time[key] = AppStyle().session['company']['working_time']['default'][i];
      }
    }
    if (AppStyle().session['timesheet'] == null) {
      AppStyle().session['timesheet'] = {};
    }
    // print(working_time);
    for (var i = 1; i <= day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();
      month[key] = AppStyle().session['timesheet'][key] ?? {};
      // Flag Shift
      // Flag working day
      var wday = DateTime(date.year, date.month, i).weekday;
      // print(wd[wday]);
      month[key]['day'] = i;
      month[key]['wday'] = wd[wday];
      month[key]['month'] = DateFormat("MMM").format(date);
      if (shift_count == 0) {
        if (working_time[wd[wday]] != null) {
          month[key]['working_time'] = working_time[wd[wday]];
        }
      } else {
        if (cal[key] != null) {
          month[key]['working_time'] = shift[cal[key]][wd[wday]];
        }
      }
    }
    for (var i = 0; i < (AppStyle().session['company']['holiday'] ?? []).length; i++) {
      // Flag Holiday

      var hdate = (AppStyle().session['company']['holiday'][i]['date'] is DateTime)
          ? AppStyle().session['company']['holiday'][i]['date']
          : AppStyle().session['company']['holiday'][i]['date'].toDate();
      var key = DateFormat("yyyyMMdd").format(hdate);
      if (hdate.month == date.month) {
        if (AppStyle().session['company']['holiday'][i]['enable']) {
          month[key]['holiday'] = AppStyle().session['company']['holiday'][i];
        }
      }
    }
    // Calc until current day
    var stat = {
      'in': 0,
      'out': 0,
      'absence': 0,
      'late': 0,
      'early_out': 0,
      'leave': 0,
    };
    String joinkey = '';
    if (AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['joindate'] != null) {
      joinkey = DateFormat("yyyyMMdd").format(AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['joindate'].toDate());
    }
    for (var i = 1; i <= date.day; i++) {
      var key = DateFormat("yyyyMM").format(date) + ((i < 10) ? '0' : '') + i.toString();

      print(key);
      var m = month[key];

      if (m['working_time'] != null) {
        print("Working");
        if (m['holiday'] == null) {
          if (m['in'] != null) {
            stat['in'] = (stat['in'] ?? 0) + 1;
            month[key]['in_txt'] = DateFormat("HH:mm").format(m['in'].toDate());
            if ((DateFormat("HH:mm").format(m['in'].toDate())).compareTo(m['working_time']['begin'].toString()) > 0) {
              stat['late'] = (stat['late'] ?? 0) + 1;
              month[key]['late'] = 'Y';
            }
          }
          if (m['out'] != null) {
            stat['out'] = (stat['out'] ?? 0) + 1;
            month[key]['out_txt'] = DateFormat("HH:mm").format(m['out'].toDate());
            if ((DateFormat("HH:mm").format(m['out'].toDate())).compareTo(m['working_time']['end'].toString()) < 0) {
              stat['early_out'] = (stat['early_out'] ?? 0) + 1;
              month[key]['early_out'] = 'Y';
            }
          }

          if ((m['in'] == null) && (m['out'] == null)) {
            if (joinkey != '') {
              if (joinkey.compareTo(key) < 0) {
                print('Abeense $joinkey $key ${joinkey.compareTo(key)}');
                stat['absence'] = (stat['absence'] ?? 0) + 1;
                month[key]['absence'] = 'Y';
              }
            } else {
              stat['absence'] = (stat['absence'] ?? 0) + 1;
              month[key]['absence'] = 'Y';
            }
          }
        }
      } else {
        if (m['in'] != null) {
          month[key]['in_txt'] = DateFormat("HH:mm").format(m['in'].toDate());
        }
        if (m['out'] != null) {
          month[key]['out_txt'] = DateFormat("HH:mm").format(m['out'].toDate());
        }
      }
    }
    // print(month);
    print(stat);
    obj['stat'] = stat;
    obj['timesheet'] = month;
  }

  void _refreshNotification() {
    FirebaseFirestore.instance
        .collection('notification')
        .where('uid', isEqualTo: AppStyle().session['user'].uid)
        .orderBy('date', descending: true)
        .limit(100)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // print(hotPerson);
      // print(querySnapshot.size);
      if (querySnapshot.size > 0) {
        AppStyle().session['notification'] = [];
        AppStyle().session['notification_count'] = 0;
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          setState(() {
            AppStyle().session['notification'].add(tmp);
            if (tmp['status'] == 'SENT') {
              AppStyle().session['notification_count']++;
            }
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('invite')
        .where('email', isEqualTo: AppStyle().session['data']['email'])
        .where('status', isEqualTo: 'Wait')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          setState(() {
            AppStyle().session['inviteStatus'] = tmp;
          });
        }
      }
    });
    FirebaseFirestore.instance.collection('join').where('uid', isEqualTo: AppStyle().session['data']['email']).get().then((QuerySnapshot querySnapshot) {
      // print('Join');
      // print(querySnapshot.size);
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          setState(() {
            AppStyle().session['joinStatus'] = tmp;
          });
        }
      }
    });
  }

  void validateData() async {
    if (AppStyle().session['data']['show_welcome'] != 'Y') {
      print("show_welcome = ${AppStyle().session['data']['show_welcome']}");
      // await Navigator.pushNamed(context, '/welcome');
//      Navigator.of(context).push(PageRouteBuilder(opaque: false, pageBuilder: (BuildContext context, _, __) => Scr00Hint()));
    }
  }

  Future<void> _pullPlaceRefresh() async {
    obj['placeLoading'] = null;

    if (!(obj['loading'] ?? true)) {
      late LocationData _locationData;
      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          print('SERVICE NOT AVAL');
          // return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          // return;
        }
      }
      if (((_serviceEnabled) && ((_permissionGranted == PermissionStatus.granted) || (_permissionGranted == PermissionStatus.grantedLimited))) != true) {
        _locationData = new LocationData.fromMap({'latitude': AppStyle().session['profile']['lat'], 'longitude': AppStyle().session['profile']['lng']});
        AppStyle().debugmsg('location disable mode');
        AppStyle().session['location_service'] = false;
      } else {
        AppStyle().session['location_service'] = true;
        //_locationData = await location.getLocation();
        if (kReleaseMode) {
          // is Release Mode ??
          _locationData = await location.getLocation();
          AppStyle().session['profile']['lat'] = _locationData.latitude;
          AppStyle().session['profile']['lng'] = _locationData.longitude;
          AppStyle().debugmsg('release mode');
        } else {
          _locationData = new LocationData.fromMap({'latitude': AppStyle().session['profile']['lat'], 'longitude': AppStyle().session['profile']['lng']});
          AppStyle().debugmsg('debug mode');
        }
      }

      var ptype = "";
      obj['lastPlace'] = {};
      obj['places'] = {};
      int distance = AppStyle().nearby;
      double lat = 1 / 110.574;
      double lng = 1 / 111.320;
      double gapLat = distance * lat;
      double gapLng = distance * lng;
      LatLng point = LatLng(AppStyle().session['profile']['lat'], AppStyle().session['profile']['lng']);
      double lowerLat = point.latitude - (lat * distance);
      double lowerLon = point.longitude - (lng * distance);

      double greaterLat = point.latitude + (lat * distance);
      double greaterLon = point.longitude + (lng * distance);
      GeoPoint lesserGeoPoint = GeoPoint(lowerLat, lowerLon);
      GeoPoint greaterGeoPoint = GeoPoint(greaterLat, greaterLon);
      // print(lowerLat);
      // print(lowerLon);
      // print(greaterLat);
      // print(greaterLon);
      AppStyle().session['nearby'] = [];
      var foundPlace = [];
      var foundPlaceLot = [];
      // ignore: prefer_function_declarations_over_variables
      var func = (QuerySnapshot querySnapshot) {
        // print("refresh $ptype");
        print(querySnapshot.size);
        if (querySnapshot.size > 0) {
          obj['lastPlace'][ptype] = querySnapshot.docs.last;
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            foundPlace.add(doc.id);
            if (foundPlace.length >= 10) {
              foundPlaceLot.add(foundPlace);
              foundPlace = [];
            }
            // obj['places'][ptype].add(tmp);
            tmp['structured_formatting'] = {'main_text': tmp['displayName'] ?? '', 'secondary_text': tmp['description'] ?? ''};
            if (tmp['date'] != null) {
              tmp['time'] = DateTime.parse(tmp['date'].toDate().toString()).millisecondsSinceEpoch;
            } else {
              tmp['time'] = 0;
            }
            AppStyle().session['nearby'].add(tmp);
          }
          if (foundPlace.length >= 0) {
            foundPlaceLot.add(foundPlace);
            foundPlace = [];
          }

          AppStyle().session['nearby'].sort((a, b) {
            var adate = int.parse(a['time'].toString()); //before -> var adate = a.expiry;
            var bdate = int.parse(b['time'].toString()); //var bdate = b.expiry;
            return -adate.compareTo(bdate);
          });
          for (var idx = 0; idx < foundPlaceLot.length; idx++) {
            if (foundPlaceLot[idx].length > 0) {
              FirebaseFirestore.instance
                  .collection('products')
                  .where('publiced', isEqualTo: 'Y')
                  .where('placeid', whereIn: foundPlaceLot[idx])
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                if (querySnapshot.size > 0) {
                  for (var doc in querySnapshot.docs) {
                    dynamic tmp = doc.data();
                    tmp['id'] = doc.id;
                    setState(() {
                      for (var i = 0; i < AppStyle().session['nearby'].length; i++) {
                        if (AppStyle().session['nearby'][i]['id'] == tmp['placeid']) {
                          print('Found review ' + tmp['id'] + ' on place id ' + tmp['placeid']);
                          AppStyle().session['nearby'][i]['review'] = tmp;
                        }
                      }
                    });
                  }
                }
              });
            }
          }
        } else {
          obj['places'][ptype] = [];
        }
      };
      var ref = await FirebaseFirestore.instance;
      if (searchController.text == '') {
        await FirebaseFirestore.instance
            .collection('places')
            .where("geopoint", isGreaterThan: lesserGeoPoint)
            .where("geopoint", isLessThan: greaterGeoPoint)
            .limit(AppStyle().pageSize)
            .get()
            .then(func);
      } else {
        await FirebaseFirestore.instance
            .collection('places')
            .where('displayName', isGreaterThanOrEqualTo: searchController.text)
            .where('displayName', isLessThan: searchController.text + 'z')
            .limit(AppStyle().pageSize)
            .get()
            .then(func);
      }

      // for (var i = 0; i < AppStyle().list_place_type.length; i++) {
      //   ptype = AppStyle().list_place_type[i];
      //   obj['places'][ptype] = [];
      //   var func = (QuerySnapshot querySnapshot) {
      //     // print("refresh $ptype");
      //     // print(querySnapshot.size);
      //     if (querySnapshot.size > 0) {
      //       obj['lastPlace'][ptype] = querySnapshot.docs.last;
      //       for (var doc in querySnapshot.docs) {
      //         dynamic tmp = doc.data();
      //         tmp['id'] = doc.id;
      //         obj['places'][ptype].add(tmp);
      //         tmp['structured_formatting'] = {'main_text': tmp['displayName'] ?? '', 'secondary_text': tmp['description'] ?? ''};

      //         AppStyle().session['nearby'].add(tmp);
      //       }
      //     } else {
      //       obj['places'][ptype] = [];
      //     }
      //   };
      //   var ref = await FirebaseFirestore.instance;
      //   if (searchController.text == '') {
      //     await FirebaseFirestore.instance
      //         .collection('places')
      //         .where('placetype', isEqualTo: ptype)
      //         .where("geopoint", isGreaterThan: lesserGeoPoint)
      //         .where("geopoint", isLessThan: greaterGeoPoint)
      //         .limit(AppStyle().pageSize)
      //         .get()
      //         .then(func);
      //   } else {
      //     await FirebaseFirestore.instance
      //         .collection('places')
      //         .where('placetype', isEqualTo: ptype)
      //         .where('displayName', isGreaterThanOrEqualTo: searchController.text)
      //         .where('displayName', isLessThan: searchController.text + 'z')
      //         .limit(AppStyle().pageSize)
      //         .get()
      //         .then(func);
      //   }
      // }
      obj['placeLoading'] = true;
      setState(() {});
    }
  }

  Widget tabTask(BuildContext context) {
    // _pullInboxRefresh();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size.width - 20,
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            obj['selectedTask'] = index;
                            if (index == 0) {
                              obj['show_todo'] = obj['todo'];
                            } else {
                              obj['show_todo'] = obj['follow_todo'];
                            }
                            setState(() {});
                          },
                          child: Container(
                            decoration: ((obj['selectedTask'] ?? 0) != index)
                                ? null
                                : BoxDecoration(
                                    color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                            padding: const EdgeInsets.only(right: 10, top: 10, left: 10, bottom: 10),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/task${index}.png"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Center(
                                      child: Container(
                                          margin: EdgeInsets.only(top: 0),
                                          child: Text(
                                            "${(index == 0) ? (obj['todo'] ?? []).length : (obj['follow_todo'] ?? []).length}",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ))),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "${(index == 0) ? 'งานที่รับมา' : 'ติดตามงาน'}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        height: 15,
      ),
      Divider(height: 1),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            _pullTaskRefresh();
          },
          child: Container(
            padding: EdgeInsets.only(top: 15),
            color: Colors.grey[100],
            child: ((obj['show_todo'] ?? []).length == 0)
                ? Center(
                    child: Text('No task found'),
                  )
                : ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemCount: (obj['show_todo'] ?? []).length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          AppStyle().showLoader(context);

                          // Get Doc
                          FirebaseFirestore.instance.collection('tasks').doc(obj['show_todo'][index]['id']).get().then((DocumentSnapshot documentSnapshot) async {
                            AppStyle().hideLoader(context);

                            if (documentSnapshot.exists) {
                              dynamic tmp = documentSnapshot.data();
                              tmp['id'] = documentSnapshot.id;

                              dynamic res = await Navigator.pushNamed(context, '/scrb047', arguments: {'doc': tmp, 'ori_users': []});
                              if (res != null) {
                                _pullTaskRefresh();
                              }
                            }
                          });
                          // open form
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                              "${AppStyle().session['company']['members'][obj['show_todo'][index][((obj['selectedTask'] == 0) ? 'from_uid' : 'uid')]]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${obj['show_todo'][index]['task_subject']}'),
                            Text(
                              '${obj['show_todo'][index]['status'] ?? 'Draft'}',
                              style: TextStyle(color: statColor[obj['show_todo'][index]['status'] ?? 'Draft']),
                            ),
                          ],
                        ),
                        subtitle: Text('${obj['show_todo'][index]['task_type'] ?? ''}'),
                      );
                    }),
          ),
        ),
      ),
    ]);
  }

  Future<void> _pullInboxRefresh() async {
// Config DocType list
    folders = {
      'task_update': {'title': 'งานที่รับทั้งหมด', 'form': '/scrb030', 'count': 0},
      'task_view': {'title': 'ติดตามงาน', 'form': '/scrb030', 'count': 0},
      'leave_approval': {'title': 'ใบลา', 'form': '/scrb030', 'count': 0},
      'expense_approval': {'title': 'ใบเบิก', 'form': '/scrb036', 'count': 0},
      'memo_approval': {'title': 'เอกสารภายใน', 'form': '/scrb038', 'count': 0},
      'training_approval': {'title': 'คำขออบรม', 'form': '/scrb043', 'count': 0},
      'timesheet_approval': {'title': 'คำขอปรับเวลา', 'form': '/scrb050', 'count': 0},
    };

    if (!(obj['loading'] ?? true)) {
      List<dynamic> news = [];
      await FirebaseFirestore.instance
          .collection('news')
          .where('companyId', isEqualTo: (AppStyle().session['company'] ?? {})['uid'])
          .where('active', isEqualTo: true)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            news.add(tmp);
          }

          setState(() {
            obj['news'] = news;
          });
        } else {
          setState(() {
            news = [];
            obj['news'] = news;
          });
        }
      });
      List<dynamic> inbox = [];
      await FirebaseFirestore.instance
          .collection('inbox')
          .where('uid', isEqualTo: AppStyle().session['data']['uid'])
          .orderBy('date', descending: true)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            inbox.add(tmp);
            if (tmp['folder_code'] != null) {
              if (folders[tmp['folder_code']] != null) {
                folders[tmp['folder_code']]['count']++;
              }
            }
          }
          obj['inbox'] = inbox;
        } else {
          inbox = [];
          obj['inbox'] = inbox;
        }
        AppStyle().session['folders'] = [];
        folders.forEach((key, value) {
          if (value['count'] > 0) {
            value['folder_code'] = key;
            AppStyle().session['folders'].add(value);
          }
        });
        print(AppStyle().session['folders']);
        obj['selectedFolder'] = obj['selectedFolder'] ?? 0;
        obj['docs'] = [];
        if (AppStyle().session['folders'].length > 0) {
          for (var i = 0; i < (obj['inbox'] ?? []).length; i++) {
            if (obj['inbox'][i]['folder_code'] == AppStyle().session['folders'][obj['selectedFolder']]['folder_code']) {
              obj['docs'].add(obj['inbox'][i]);
            }
          }
        }

        setState(() {});
      });
    }
  }

  Future<void> _pullTaskRefresh() async {
    List<dynamic> todo = [];
    await FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: AppStyle().session['data']['uid'])
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          todo.add(tmp);
        }
        obj['todo'] = todo;
      } else {
        todo = [];
        obj['todo'] = todo;
      }
      setState(() {});
    });

    List<dynamic> follow_todo = [];
    await FirebaseFirestore.instance
        .collection('tasks')
        .where('from_uid', isEqualTo: AppStyle().session['data']['uid'])
        .orderBy('date', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          follow_todo.add(tmp);
        }
        obj['follow_todo'] = follow_todo;
      } else {
        todo = [];
        obj['follow_todo'] = follow_todo;
      }
      setState(() {});
    });
    obj['selectedTask'] ??= 0;
    if (obj['selectedTask'] == 0) {
      obj['show_todo'] = obj['todo'];
    } else {
      obj['show_todo'] = obj['follow_todo'];
    }
    setState(() {});
  }

  Widget tabInbox(BuildContext context) {
    // _pullInboxRefresh();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      (((AppStyle().session['company'] ?? {})['announce_enabled'] ?? false) == false)
          ? Container()
          : Container(
              width: size.width,
              // margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 255, 142, 56),
                  Colors.amber,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Text(
                '${AppStyle().session['company']['announce'] ?? ''}',
                style: TextStyle(fontSize: 16, color: Colors.black, overflow: TextOverflow.fade),
              ),
            ),
      ((obj['news'] ?? []).length == 0)
          ? Container()
          : const Padding(
              padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 0),
              child: Text(
                'NEWS',
                style: TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
            ),
      ((obj['news'] ?? []).length == 0)
          ? Container()
          : Container(
              width: size.width,
              height: 120,
              child: Swiper(
                onTap: (index) {
                  Navigator.pushNamed(context, '/scrb056', arguments: {'data': obj['news'][index]});
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: size.width,
                    height: 100,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      image: (obj['news'][index]['cover'] == null)
                          ? null
                          : DecorationImage(
                              image: CachedNetworkImageProvider(obj['news'][index]['cover']),
                              fit: BoxFit.cover,
                            ),
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(255, 217, 244, 255),
                        Color.fromARGB(255, 151, 255, 248),
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(1.5, 1.5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            child: Stack(
                          children: [
                            Text(
                              '${obj['news'][index]['subject']}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = const Color.fromARGB(198, 255, 255, 255),
                              ),
                            ),
                            Text('${obj['news'][index]['subject']}',
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        )),
                        Container(
                          child: Stack(
                            children: [
                              Text(
                                '${obj['news'][index]['short_description']}',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 16,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6
                                    ..color = const Color.fromARGB(198, 255, 255, 255),
                                ),
                              ),
                              Text('${obj['news'][index]['short_description']}',
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: (obj['news'] ?? []).length,
                viewportFraction: 1,
                scale: 1,
                // autoplay: true,
                autoplayDelay: 8000,
                pagination: SwiperPagination(),
              ),
            ),
      SizedBox(
        height: 20,
      ),
      ((AppStyle().session['folders'] ?? []).length == 0)
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width - 20,
                        height: 120,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (AppStyle().session['folders'] ?? []).length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  obj['selectedFolder'] = index;
                                  obj['docs'] = [];
                                  for (var i = 0; i < (obj['inbox'] ?? []).length; i++) {
                                    if (obj['inbox'][i]['folder_code'] == AppStyle().session['folders'][obj['selectedFolder']]['folder_code']) {
                                      obj['docs'].add(obj['inbox'][i]);
                                    }
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: ((obj['selectedFolder'] ?? 0) != index)
                                      ? null
                                      : BoxDecoration(
                                          color: Colors.blueGrey[100],
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                  padding: const EdgeInsets.only(right: 10, top: 10, left: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/folder_doc.png"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Center(
                                            child: Container(
                                                margin: EdgeInsets.only(top: 24),
                                                child: Text(
                                                  "${AppStyle().session['folders'][index]['count']}",
                                                  style: TextStyle(fontSize: 18),
                                                ))),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          "${AppStyle().session['folders'][index]['title']}",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      SizedBox(
        height: 15,
      ),
      Divider(height: 1),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            obj['loading'] = false;
            _pullInboxRefresh();
          },
          child: Container(
            padding: EdgeInsets.only(top: 15),
            color: Colors.grey[100],
            child: ((obj['docs'] ?? []).length == 0)
                ? Center(
                    child: Text('No document found'),
                  )
                : ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemCount: (obj['docs'] ?? []).length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          AppStyle().showLoader(context);
                          // Get Doc
                          FirebaseFirestore.instance.collection('documents').doc(obj['docs'][index]['docid']).get().then((DocumentSnapshot documentSnapshot) async {
                            AppStyle().hideLoader(context);
                            if (documentSnapshot.exists) {
                              dynamic tmp = documentSnapshot.data();
                              tmp['id'] = documentSnapshot.id;

                              dynamic res = await Navigator.pushNamed(context, AppStyle().session['folders'][obj['selectedFolder']]['form'], arguments: {'doc': tmp});
                              print(res);
                              if (res != null) {
                                _pullInboxRefresh();
                              }
                            }
                          });
                          // open form
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              NetworkImage("${AppStyle().session['company']['members'][obj['docs'][index]['show_uid']]['userinfo']['photoURL'] ?? AppStyle().no_user_url}"),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${obj['docs'][index]['title']}'),
                            Text(
                              '${obj['docs'][index]['status']}',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        subtitle: Text('${obj['docs'][index]['subtitle']}'),
                      );
                    }),
          ),
        ),
      ),
    ]);
  }

  Future<void> refresh() async {
    // var req = {'dataset': 'transaction'};
    // var data = await AppStyle().getAPI("wms.dashboard", {'token': arguments['token']}, req);
    setState(() {
      // arguments['list'] = data['list'];
      // print(arguments['list']);
      obj = {
        'reorder': [],
        'list': [],
        'count': {
          'all': {
            'Total': 0,
            'label': 'All',
          },
          'receive': {
            'Total': 0,
            'label': 'Putaway',
          },
          'delivery': {
            'Total': 0,
            'label': 'Pick',
          },
          'transfer': {
            'Total': 0,
            'label': 'Other',
          },
        }
      };
      filters = [];
      initData();
    });
  }

  Widget tabHome(BuildContext context) {
    return SingleChildScrollView(
      child: (AppStyle().session['company'] != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (AppStyle().session['setting'] != null)
                    ? (AppStyle().session['setting']['announce'] != '')
                        ? Container(
                            padding: EdgeInsets.all(20),
                            width: size.width,
                            color: Colors.amberAccent,
                            child: Text(
                              "${AppStyle().session['setting']['announce']}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          )
                        : Container()
                    : Container(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (Widget widget, Animation<double> animation) {
                    final flipAnimation = Tween(begin: pi, end: 0.0).animate(animation);
                    // return ScaleTransition(scale: animation, child: widget);
                    return AnimatedBuilder(
                        animation: flipAnimation,
                        child: widget,
                        builder: (context, widget) {
                          final isUnder = (ValueKey(((AppStyle().session['lastActivity'] ?? []).length == 0)) != widget!.key);
                          final value = isUnder ? min(flipAnimation.value, pi / 2) : flipAnimation.value;
                          return Transform(
                            transform: Matrix4.rotationX(value),
                            child: widget,
                            alignment: Alignment.center,
                          );
                        });
                  },
                  child: (switchMission)
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.teal,
                              Colors.tealAccent,
                            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                switchMission = !switchMission;
                              });
                            },
                            title: Text(
                              '${obj['okrcount'] ?? 0} OKRs',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'view your objective & key results',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            trailing: Badge(
                              badgeContent: Text('${((AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {})['okr'] ?? []).length}',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                              showBadge: ((((AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {})['okr'] ?? []).length) > 0),
                              child: FaIcon(FontAwesomeIcons.coins),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.tealAccent,
                              Colors.teal,
                            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  //if (((AppStyle().session['company']['members'][AppStyle().session['data']['uid']]['okrs'] ?? []).length > 0)) {
                                  setState(() {
                                    switchMission = !switchMission;
                                  });
                                  //}
                                },
                                title: Text(
                                  '${obj['okrcount'] ?? 0} OKRs',
                                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'view your objective & key results',
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                trailing: Badge(
                                  badgeContent: Text('${((AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {})['okr'] ?? []).length}',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                  showBadge: ((((AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {})['okr'] ?? []).length) > 0),
                                  child: FaIcon(FontAwesomeIcons.coins),
                                ),
                              ),
                              (obj['okrs'] == null)
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: Column(
                                        children: [
                                          Card(
                                            color: Colors.white60,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              width: size.width - 40,
                                              child: Builder(builder: (context) {
                                                List<Widget> listtmp = [];
                                                listtmp.add(Text('Objective & Key Results (OKRs)'));
                                                listtmp.add(SizedBox(
                                                  height: 5,
                                                ));
                                                (obj['okrs'] ?? {}).forEach((key, okr) {
                                                  listtmp.add(Card(
                                                    elevation: 2,
                                                    child: Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          ListTile(
                                                            title: Text('${okr['title'] ?? ''}'),
                                                            subtitle: Text('${AppStyle().formatCurrency.format(okr['target'] ?? 0)} (Target)'),
                                                            trailing: Text('${AppStyle().formatCurrency.format(okr['current'] ?? 0)}'),
                                                          ),

                                                          Slider(
                                                            min: okr['start'] * 1.0 ?? 0.0,
                                                            max: okr['target'] * 1.0 ?? 100.0,
                                                            activeColor: Colors.blue,
                                                            inactiveColor: Colors.blue[100],
                                                            thumbColor: Colors.blueAccent,
                                                            value: okr['current'] * 1.0 ?? 0.0,
                                                            onChanged: (value) async {
                                                              setState(() {
                                                                okr['current'] = value;
                                                              });
                                                            },
                                                            onChangeEnd: (value) async {
                                                              await FirebaseFirestore.instance.collection('okrs').doc(AppStyle().session['data']['uid']).set({
                                                                'okrs': {'${key}': okr},
                                                              }, SetOptions(merge: true));

                                                              // await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['company']['uid']).set({
                                                              //   'members': {
                                                              //     AppStyle().session['data']['uid']: {
                                                              //       'okrs': {key: okr},
                                                              //     }
                                                              //   }
                                                              // }, SetOptions(merge: true));

                                                              print(value);
                                                            },
                                                          ),
                                                          // LinearProgressIndicator(
                                                          //   minHeight: 10,
                                                          //   value: 0.5,
                                                          //   backgroundColor: Colors.blue[100],
                                                          //   color: Colors.blue,
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                                });
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: listtmp,
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                ),
                (((AppStyle().session['company'] ?? {})['hide_menu'] ?? {})['timesheet'] != true)
                    ? const Padding(
                        padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 1),
                        child: Text(
                          '  Check in / out ',
                          style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                        ),
                      )
                    : Container(),
                (((AppStyle().session['company'] ?? {})['hide_menu'] ?? {})['timesheet'] != true)
                    ? Container(
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: Builder(builder: (context) {
                            List<Widget> list = [];
                            var i = 1;
                            list.add(
                              InkWell(
                                onTap: () async {
                                  var key = DateFormat("yyyyMMdd").format(DateTime.now());
                                  var data = (AppStyle().session['timesheet'] ?? {})[key] ?? {};
                                  await Navigator.pushNamed(context, '/scrb019', arguments: {'data': data});
                                  // await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) async {
                                  //   if (documentSnapshot.exists) {
                                  //     AppStyle().session['data'] = documentSnapshot.data();
                                  //   }
                                  // });
                                  // setState(() {});
                                },
                                child: Builder(builder: (context) {
                                  var key = DateFormat("yyyyMMdd").format(DateTime.now());
                                  var data = (AppStyle().session['timesheet'] ?? {})[key] ?? {};
                                  Column checkin;
                                  if (data['in'] != null) {
                                    var time = data['in'].toDate();
                                    checkin = Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${DateFormat("HH:mm").format(time)}',
                                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  } else {
                                    checkin = Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Check in',
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                      ],
                                    );
                                  }

                                  return Container(
                                      height: 65,
                                      width: (MediaQuery.of(context).size.width / 2) - 20,
                                      decoration: BoxDecoration(
                                        color: (data['in'] != null) ? Color.fromARGB(255, 202, 202, 202) : Color(0xFF81CEFD),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: checkin);
                                }),
                              ),
                            );
                            list.add(
                              InkWell(
                                onTap: () async {
                                  var key = DateFormat("yyyyMMdd").format(DateTime.now());
                                  var data = (AppStyle().session['timesheet'] ?? {})[key] ?? {};
                                  await Navigator.pushNamed(context, '/scrb020', arguments: {'data': data});

                                  // await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) async {
                                  //   if (documentSnapshot.exists) {
                                  //     AppStyle().session['data'] = documentSnapshot.data();
                                  //   }
                                  // });
                                  // setState(() {});
                                },
                                child: Builder(builder: (context) {
                                  var key = DateFormat("yyyyMMdd").format(DateTime.now());
                                  var data = (AppStyle().session['timesheet'] ?? {})[key] ?? {};
                                  Column checkout;
                                  if (data['out'] != null) {
                                    var time = data['out'].toDate();
                                    checkout = Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${DateFormat("HH:mm").format(time)}',
                                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  } else {
                                    checkout = Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Check Out',
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                      ],
                                    );
                                  }

                                  return Container(
                                      height: 65,
                                      width: (MediaQuery.of(context).size.width / 2) - 20,
                                      decoration: BoxDecoration(
                                        color: (data['out'] != null) ? Color.fromARGB(255, 202, 202, 202) : Color(0xFF81CEFD),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: checkout);
                                }),
                              ),
                            );

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: list,
                            );
                          }),
                        ),
                      )
                    : Container(),
                (((AppStyle().session['company'] ?? {})['hide_menu'] ?? {})['timesheet'] != true)
                    ? const Padding(
                        padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 1),
                        child: Text(
                          '  Monthly Statistics',
                          style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                        ),
                      )
                    : Container(),
                (((AppStyle().session['company'] ?? {})['hide_menu'] ?? {})['timesheet'] != true)
                    ? Container(
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: Builder(builder: (context) {
                            List<Widget> list = [];
                            var iconSize = (MediaQuery.of(context).size.width / 6) - 20;

                            if (iconSize < 120) {
                              iconSize = (MediaQuery.of(context).size.width / 4) - 20;
                            }
                            print("ICON SIZE = $iconSize , SizeWidth = ${MediaQuery.of(context).size.width}");
                            for (var i = 0; i < AppStyle().list_activity_type.length; i++) {
                              list.add(
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/scrb021', arguments: {'timesheet': obj['timesheet'], 'stat': obj['stat']});
                                  },
                                  child: Container(
                                    height: iconSize,
                                    width: iconSize,
                                    decoration: BoxDecoration(
                                      color: AppStyle().list_activity_type_color[i],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${(obj['stat'] ?? {})[AppStyle().list_statcode[i]] ?? 0}',
                                          style: TextStyle(fontSize: 24, color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          AppStyle().list_activity_type[i],
                                          style: TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: list,
                            );
                          }),
                        ),
                      )
                    : Container(),
                // Container(
                //     margin: EdgeInsets.symmetric(vertical: 10),
                //     height: 200,
                //     width: size.width,
                //     decoration: BoxDecoration(
                //       color: Colors.grey[200],
                //     ),
                //     child: Row(
                //       children: [
                //         Column(
                //           children: [],
                //         ),
                //         Column(
                //           children: [],
                //         ),
                //       ],
                //     )),
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 1),
                  child: Text(
                    '  Applications',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ),
                Container(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Builder(builder: (context) {
                      List<Widget> list = [];
                      var iconSize = (MediaQuery.of(context).size.width / 6) - 20;
                      if (iconSize < 120) {
                        iconSize = (MediaQuery.of(context).size.width / 5) - 20;
                      }
                      if (iconSize < 120) {
                        iconSize = (MediaQuery.of(context).size.width / 4) - 20;
                      }
                      if (iconSize < 120) {
                        iconSize = (MediaQuery.of(context).size.width / 3) - 20;
                      }
                      print("APP ICON SIZE = $iconSize , SizeWidth = ${MediaQuery.of(context).size.width}");
                      AppStyle().session['company']['hide_menu'] ??= {};
                      if ((AppStyle().session['company']['leave_type'] != null) && (AppStyle().session['company']['hide_menu']['leave'] != true)) {
                        // Leave
                        list.add(
                          InkWell(
                            onTap: () {
                              //Main ของใบลา
                              Navigator.pushNamed(context, '/scrb024', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 26, 162, 149),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.calendarCheck,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'ใบลา',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Leave request',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      if ((AppStyle().session['company']['expense_type'] != null) && (AppStyle().session['company']['hide_menu']['expense'] != true)) {
                        list.add(
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/scrb025', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 179, 94, 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.coins,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'ใบเบิก',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Expense request',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      if ((AppStyle().session['company']['training_type'] != null) && (AppStyle().session['company']['hide_menu']['training'] != true)) {
                        list.add(
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/scrb026', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 27, 35, 140),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'การอบรม',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Training request',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      if ((AppStyle().session['company']['memo_type'] != null) && (AppStyle().session['company']['hide_menu']['memo'] != true)) {
                        list.add(
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/scrb027', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 179, 2, 123),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.noteSticky,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'เอกสารภายใน',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Memo',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      dynamic myinfo = AppStyle().session['company']['members'][AppStyle().session['data']['uid']] ?? {};
                      var mydep = myinfo['department'];
                      dynamic manager = {};
                      for (var i = 0; i < (AppStyle().session['company']['department'] ?? []).length; i++) {
                        if (AppStyle().session['company']['department'][i]['enable']) {
                          if (AppStyle().session['company']['department'][i]['name'] == mydep) {
                            manager = AppStyle().session['company']['department'][i]['managerinfo'] ?? {};
                          }
                        }
                      }
                      manager ??= {};

                      if ((manager['uid'] == AppStyle().session['data']['uid']) && (AppStyle().session['company']['hide_menu']['team'] != true)) {
                        list.add(
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/scrb048', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 40, 40, 40),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.peopleGroup,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'ข้อมูลทีม',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Team Info.',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if ((mydep == 'Human Resource') && (AppStyle().session['company']['hide_menu']['timesheet'] != true)) {
                        list.add(
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/scrb049', arguments: {'data': obj['timesheet']});
                            },
                            child: Container(
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 0, 98, 159),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.clock,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'ขอปรับเวลา',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    'Time Adjust',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: list,
                      );
                    }),
                  ),
                ),
              ],
            )
          : (AppStyle().session['inviteStatus'] != null)
              ? inviteJoin()
              : joinCompany(),
    );
  }

  Column inviteJoin() {
    return Column(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(color: Colors.amber[900]),
          padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'คุณได้รับคำเชิญให้เข้าร่วม',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text(
                'Betty',
                style: TextStyle(
                  fontFamily: "Sriracha",
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'บริษัท : ${AppStyle().session['inviteStatus']['compinfo']['name'] ?? ''}',
                style: TextStyle(fontSize: 20, color: Colors.brown),
              ),
              Text(
                'แผนก : ${AppStyle().session['inviteStatus']['department'] ?? ''}',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
              Text(
                'หมายเหตุ : ${AppStyle().session['inviteStatus']['remark'] ?? ''}',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
              Text(
                'เชิญโดย : ${AppStyle().session['inviteStatus']['inviteBy'] ?? ''}',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        (AppStyle().session['_inviteFeedback'] != null)
            ? Container(
                child: Center(child: Text('Please wait ...')),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.lightGreen),
                    child: Text(
                      'เข้าร่วม',
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      AppStyle().session['_inviteFeedback'] = true;
                      setState(() {});
                      // Join
                      // update Status
                      // let cloud function create user
                      await FirebaseFirestore.instance
                          .collection('invite')
                          .doc(AppStyle().session['inviteStatus']['id'])
                          .set({'status': 'Accepted', 'userinfo': AppStyle().session['data']}, SetOptions(merge: true));

                      AppStyle().session['company'] = AppStyle().session['inviteStatus']['compinfo'];
                      AppStyle().session['user_department'] = {
                        'department': AppStyle().session['inviteStatus']['department'],
                        'enable': true,
                      };
                      setState(() {});
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                    child: Text(
                      'ปฎิเสธการเข้าร่วม',
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      AppStyle().session['_inviteFeedback'] = true;
                      setState(() {});
                      await FirebaseFirestore.instance
                          .collection('invite')
                          .doc(AppStyle().session['inviteStatus']['id'])
                          .set({'status': 'Rejected', 'userinfo': AppStyle().session['data']}, SetOptions(merge: true));
                      AppStyle().session['inviteStatus'] = null;
                      setState(() {});
                    },
                  ),
                ],
              )
      ],
    );
  }

  Widget joinCompany() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ขอต้อนรับสู่การใช้งาน',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              Text(
                'Betty',
                style: TextStyle(
                  fontFamily: "Sriracha",
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: Builder(builder: (context) {
              var btnHeight = (MediaQuery.of(context).size.width / 3) - 20;
              if (btnHeight > 120) {
                btnHeight = 120;
              }
              List<Widget> list = [];
              var i = 1;
              list.add(
                InkWell(
                  onTap: () async {
                    String code = await AppStyle().confirmData(context, "", "Company Join Code");
                    await FirebaseFirestore.instance.collection('company').where('companyCode', isEqualTo: code).limit(1).get().then((QuerySnapshot querySnapshot) {
                      if (querySnapshot.size > 0) {
                        for (var doc in querySnapshot.docs) {
                          dynamic tmp = doc.data();
                          tmp['id'] = doc.id;
                          FirebaseFirestore.instance.collection('join').doc(AppStyle().session['user'].uid).set({
                            'companyId': tmp['id'],
                            'uid': AppStyle().session['user'].uid,
                            'userinfo': AppStyle().session['data'],
                            'compinfo': tmp,
                            'enable': false,
                          }, SetOptions(merge: true));
                          AppStyle().session['joinStatus'] = {
                            'companyId': tmp['id'],
                            'uid': AppStyle().session['user'].uid,
                            'userinfo': AppStyle().session['data'],
                            'compinfo': tmp,
                            'enable': false,
                          };
                          setState(() {});
                        }
                      } else {
                        AppStyle().error_pop(context, "Incorrect Code", "Company code not found", "OK");
                      }
                    });
                  },
                  child: Container(
                    height: btnHeight,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    decoration: BoxDecoration(
                      color: Color(0xFF81CEFD),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join',
                          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Company',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              list.add(
                InkWell(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/scrb001', arguments: {});
                    setState(() {});
                  },
                  child: Container(
                    height: btnHeight,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    decoration: BoxDecoration(
                      color: Color(0xFF9AE58D),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Setup',
                          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Company',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: list,
              );
            }),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget widget, Animation<double> animation) {
            final flipAnimation = Tween(begin: pi, end: 0.0).animate(animation);
            // return ScaleTransition(scale: animation, child: widget);
            return AnimatedBuilder(
                animation: flipAnimation,
                child: widget,
                builder: (context, widget) {
                  final isUnder = (ValueKey(((AppStyle().session['lastActivity'] ?? []).length == 0)) != widget!.key);
                  final value = isUnder ? min(flipAnimation.value, pi / 2) : flipAnimation.value;
                  return Transform(
                    transform: Matrix4.rotationX(value),
                    child: widget,
                    alignment: Alignment.center,
                  );
                });
          },
          child: (AppStyle().session['joinStatus'] == null)
              ? Column(
                  children: [
                    Container(
                      width: size.width,
                      padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 20),
                      child: Text(
                        'คุณยังไม่ตั้งค่าบริษัท ต้องการเข้าร่วมบริษัท หรือ ต้องการสร้างบริษัทใหม่',
                        style: TextStyle(fontSize: 18, color: Colors.brown),
                      ),
                    ),
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Text(
                        '- วิธีการเข้าร่วมบริษัท (Join Company) ให้กดที่ปุ่มสีฟ้า และกรอกรหัสที่คุณได้รับจาก HR (Invite Code)',
                        style: TextStyle(fontSize: 16, color: Colors.brown),
                      ),
                    ),
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Text(
                        '- วิธีสร้างบริษัทใหม่ (Setup Company) ให้กดที่ปุ่มสีเขียว และกรอกรายละเอียดเกี่ยวกับบริษัท',
                        style: TextStyle(fontSize: 16, color: Colors.brown),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: size.width,
                      padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 50),
                      child: Text(
                        'คุณได้ยื่นการเข้าร่วมบริษัทไปเรียบร้อย อยู่ระหว่างรออนุมัติ',
                        style: TextStyle(fontSize: 18, color: Colors.brown),
                      ),
                    ),
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'ชื่อ : ${AppStyle().session['joinStatus']['compinfo']['name']}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            overflow: TextOverflow.fade,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'สถานะ : ${(AppStyle().session['joinStatus']['enable'] ?? false) ? 'อนุมัติ' : 'รออนุมัติ'}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _pullShopRefresh() async {
    obj['shopLoading'] = null;

    if (!(obj['loading'] ?? true)) {
      var ptype = "";
      obj['products'] = {};
      for (var i = 0; i < AppStyle().list_shop_category.length; i++) {
        ptype = AppStyle().list_shop_category[i]['name'].toString();
        obj['products'][ptype] = [];
        var func = (QuerySnapshot querySnapshot) {
          // print("refresh $ptype");
          // print(querySnapshot.size);
          if (querySnapshot.size > 0) {
            for (var doc in querySnapshot.docs) {
              dynamic tmp = doc.data();
              tmp['id'] = doc.id;
              obj['products'][ptype].add(tmp);
            }
          } else {
            obj['products'][ptype] = [];
          }
        };
        var ref = await FirebaseFirestore.instance;
        if (searchController.text == '') {
          await FirebaseFirestore.instance.collection('products').where('publiced', isEqualTo: 'Y').where('category', isEqualTo: ptype).limit(AppStyle().pageSize).get().then(func);
        } else {
          await FirebaseFirestore.instance
              .collection('products')
              .where('publiced', isEqualTo: 'Y')
              .where('category', isEqualTo: ptype)
              .where('displayName', isGreaterThanOrEqualTo: searchController.text)
              .where('displayName', isLessThan: searchController.text + 'z')
              .limit(AppStyle().pageSize)
              .get()
              .then(func);
        }
      }
      await FirebaseFirestore.instance
          .collection('products')
          .where('is_hot', isEqualTo: 'Y')
          .where('publiced', isEqualTo: 'Y')
          .limit(AppStyle().pageSize)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          obj['hot_products'] = [];
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            obj['hot_products'].add(tmp);
          }
        } else {
          obj['hot_products'] = [];
        }
      });

      obj['shopLoading'] = true;
      setState(() {});
    }
  }

  Widget tabContact(BuildContext context) {
    if (AppStyle().session['company'] != null) {
      obj['users'] = [];
      AppStyle().session['company']['members'].forEach((key, value) {
        value['uid'] = key;
        value['keyword'] = (value['userinfo']['displayName'] ?? '').toLowerCase() + '.' + value['userinfo']['email'].toString();
        if (value['uid'] != AppStyle().session['data']['uid']) {
          obj['users'].add(value);
        }
      });
      // results2.sort((a, b) {
      //   return (a['userinfo']['displayName'] ?? a['userinfo']['email']).toLowerCase().compareTo((b['userinfo']['displayName'] ?? b['userinfo']['email']).toLowerCase());
      // });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Navigator.pushNamed(context, '/scrb023', arguments: {'profile': obj['users'][index]['userinfo'], 'department': obj['users'][index]['department']});
                  },
                );
              },
              itemCount: (obj['users'] ?? []).length,
            ),
          )
        ],
      );
    } else {
      return Center(
        child: Text('Please join company first'),
      );
    }
  }

  Widget tabProfile(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        children: [
          Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomRight, colors: [
                  Color.fromARGB(255, 235, 208, 180),
                  Color.fromARGB(255, 200, 183, 145),
                  Color.fromARGB(255, 179, 137, 105),
                ]),
                // color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            Positioned(
                top: 100.0,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: InkWell(
                    onTap: () async {
                      if (AppStyle().session['user'].uid == obj['profile']['uid']) {
                        var image = await AppStyle().browseImageBase64(1024, 1024, 90);
                        if (image['base64'] != '') {
                          AppStyle().showSnackBar(context, "Uploading ... ", Colors.amber);

                          final storageRef = FirebaseStorage.instance.ref();
                          final postImagesRef =
                              storageRef.child("users/" + AppStyle().session['user'].uid + "/images/post" + DateTime.now().microsecondsSinceEpoch.toString() + ".jpg");
                          try {
                            await postImagesRef.putString(image['base64'].toString(), format: PutStringFormat.base64);
                            String url = await postImagesRef.getDownloadURL();
                            AppStyle().session['user'].updatePhotoURL(url);

                            FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set({
                              'photoURL': url,
                            }, SetOptions(merge: true)).then((value) {
                              setState(() {
                                obj['profile']['photoURL'] = url;
                                AppStyle().session['data']['photoURL'] = url;
                                print(obj['profile']['photoURL']);
                              });
                            }).catchError((error) {
                              // print("Failed to merge data: $error");
                              AppStyle().error_pop(context, 'Error', error.toString(), 'OK');
                            });
                          } on FirebaseException catch (e) {
                            AppStyle().error_pop(context, 'Error', e.toString(), 'OK');
                            // print(e);
                          }
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage("${AppStyle().session['data']['photoURL'] ?? AppStyle().no_user_url}"),
                    ),
                  ),
                )),
          ]),
          const SizedBox(
            height: 45,
          ),
          ListTile(
            title: InkWell(
              onTap: () async {
                var res = await AppStyle().confirmData(context, AppStyle().session['data']['displayName'] ?? '', "Display Name");
                if (res != null) {
                  //AppStyle().session['user'].phoneNumber = res;
                  await AppStyle().session['user']?.updateDisplayName(res);
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(AppStyle().session['user'].uid)
                      .set({
                        'displayName': res,
                      }, SetOptions(merge: true))
                      .then((value) {})
                      .catchError((error) {
                        // print("Failed to merge data: $error");
                      });

                  setState(() {
                    AppStyle().session['data']['displayName'] = res;
                    // print(AppStyle().session['profile']);
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppStyle().session['data']['displayName'] ?? 'N/a'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            subtitle: Column(
              children: [
                Center(child: Text('${(AppStyle().session['user_department'] ?? {})['department']}', style: TextStyle(fontSize: 18))),
                InkWell(
                  onTap: () async {
                    var res = await AppStyle().confirmData(context, AppStyle().session['data']['email'] ?? '', "Email");
                    if (res != null) {
                      //AppStyle().session['user'].phoneNumber = res;
                      await AppStyle().session['user']?.updateEmail(res);
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(AppStyle().session['user'].uid)
                          .set({
                            'email': res,
                          }, SetOptions(merge: true))
                          .then((value) {})
                          .catchError((error) {
                            // print("Failed to merge data: $error");
                          });

                      setState(() {
                        AppStyle().session['data']['email'] = res;
                        // print(AppStyle().session['profile']);
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${AppStyle().session['data']['email']}'),
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () async {
              var res = await AppStyle().confirmData(context, AppStyle().session['data']['displayName'] ?? '', "Display Name");
              if (res != null) {
                //AppStyle().session['user'].phoneNumber = res;
                await AppStyle().session['user']?.updateDisplayName(res);
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(AppStyle().session['user'].uid)
                    .set({
                      'displayName': res,
                    }, SetOptions(merge: true))
                    .then((value) {})
                    .catchError((error) {
                      // print("Failed to merge data: $error");
                    });

                setState(() {
                  AppStyle().session['data']['displayName'] = res;
                  // print(AppStyle().session['profile']);
                });
              }
            },
          ),
          ((AppStyle().session['company'] ?? {})['uid'] == AppStyle().session['data']['uid'])
              ? Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                          title: Text('Company Setting'),
                          subtitle: Text('${AppStyle().session['company']['name']}'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb001', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('User management'),
                          subtitle: Text('list of users, invites, join requests'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb009', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Shift Calendar'),
                          subtitle: Text('Configure shift calendar'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb022', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Leave Setting'),
                          subtitle: Text('Configure workflow for leave request'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb013', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Expense Setting'),
                          subtitle: Text('Configure workflow for expense request'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb033', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Memo Setting'),
                          subtitle: Text('Configure workflow for memo'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb037', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Training Record Setting'),
                          subtitle: Text('Configure workflow for training request'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb041', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('News and Announcements Setting'),
                          subtitle: Text('Configure news and announcements'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb031', arguments: {});
                            setState(() {});
                          }),
                      Divider(height: 1),
                      ListTile(
                          title: Text('Objective & Key Results (OKRs)'),
                          subtitle: Text('Configure employee OKRs'),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/scrb044', arguments: {});
                            setState(() {});
                          }),
                    ],
                  ),
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
            child: Text(
              AppStyle().tr('Logout'),
              style: TextStyle(
                fontSize: AppStyle().btnFontSize,
              ),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set({'FCM': ''}, SetOptions(merge: true));
              AppStyle().session = {};

              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/scr001', (r) => false);
            },
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/delete', arguments: {});
              },
              child: Text(
                'Delete this account',
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }

  void viewTopFriend(BuildContext context, int no) {
    FirebaseFirestore.instance.collection('users').doc(AppStyle().session['data']['topfriend' + no.toString()]['id']).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Navigator.pushNamed(context, '/scr003', arguments: {'profile': documentSnapshot.data()});
      } else {
        setTopfriend(context, no);
      }
    }).catchError((error) {
      // print("Error: $error");
    });
  }

  Future<void> setTopfriend(BuildContext context, int no) async {
    Map<dynamic, dynamic> req = {'popback': 'Y'};
    dynamic res = await Navigator.pushNamed(context, '/scr006', arguments: req);
    if (res != null) {
      FirebaseFirestore.instance.collection('users').doc(AppStyle().session['data']['uid']).set({
        'topfriend' + no.toString(): {'id': res['uid'], 'photoURL': res['photoURL']}
      }, SetOptions(merge: true));
      setState(() {
        AppStyle().session['data']['topfriend' + no.toString()] = {'id': res['uid'], 'photoURL': res['photoURL']};
      });
    }
  }

  void getNextPage() async {}

  _scrollListener() async {
    //inspect(_scrollController.offset);
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      if (!(obj['loading'] ?? true)) {
        obj['loading'] = true;

        // print("LAST ==============");
        // print(_scrollController.offset);
        // print(_scrollController.position.maxScrollExtent);
        // print(_scrollController.position.outOfRange);
        getNextPage();
      }
    }
  }

  Future<void> initData() async {
    obj['profile'] = AppStyle().session['data'];
    // Realtime Monitor For

    obj['loading'] = false;
    _refreshNotification();
    validateData();
    FirebaseFirestore.instance.collection('setting').doc('default').get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        AppStyle().session['setting'] = documentSnapshot.data();

        if (AppStyle().session['setting']['update_version'] > AppStyle().appVersion) {
          var res = await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Container(
                  margin: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 50),
                  padding: EdgeInsets.all(20),
                  width: size.width,
                  decoration: BoxDecoration(
                    color: AppStyle().bgColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(3, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "${AppStyle().session['setting']['update_announce']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                );
              });
        }
      } else {
        // print('Document does not exist on the database');
      }
      setState(() {});
    }).catchError((error) {
      // print("Error: $error");
    });
  }
}
