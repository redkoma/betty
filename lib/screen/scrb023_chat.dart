import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scrb023Chat extends StatefulWidget {
  const Scrb023Chat({Key? key}) : super(key: key);

  @override
  _Scrb023ChatState createState() => _Scrb023ChatState();
}

class _Scrb023ChatState extends State<Scrb023Chat> {
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
  ScrollController _scrollController = ScrollController(initialScrollOffset: 5.0);
  TextEditingController nameController = TextEditingController();
  TextEditingController breedsController = TextEditingController();
  late Timer timer;
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  ScrollController _controllerT = ScrollController();

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;
    if (!loaded) {
      _scrollController.addListener(_scrollListener);
      obj = arguments;
      loaded = true;
      if (obj['messages'] == null) {
        obj['messages'] = [];
      }
      obj['loading'] = false;
      refresh();
      setState(() {});
      timer = Timer.periodic(new Duration(seconds: 15), (timer) {
        refresh();
        if (_controllerT.hasClients) {
          final position = _controllerT.position.maxScrollExtent;
          _controllerT.jumpTo(position);
          print('trigger ${position}');
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage("${obj['profile']['photoURL'] ?? AppStyle().no_user_url}"),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${obj['profile']['displayName'] ?? obj['profile']['email']}",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  "${obj['department'] ?? ''}",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                refresh();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      backgroundColor: AppStyle().mainBgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _controllerT,
            child: Container(
              width: size.width,
              padding: EdgeInsets.only(top: 15, bottom: MediaQuery.of(context).viewInsets.bottom + 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: obj['messages'].map<Widget>((map) {
                  return BubbleSpecialThree(
                    text: '${map['message']}',
                    color: (map['from_uid'] == AppStyle().session['data']['uid']) ? Color(0xFF1B97F3) : Color(0xFFE8E8EE),
                    tail: false,
                    isSender: (map['from_uid'] == AppStyle().session['data']['uid']),
                    textStyle: (map['from_uid'] == AppStyle().session['data']['uid']) ? TextStyle(color: Colors.white, fontSize: 16) : TextStyle(color: Colors.black, fontSize: 16),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                    suffixIcon: TextButton(
                      child: const Text(
                        "send",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () async {
                        if (nameController.text != '') {
                          AppStyle().showLoader(context);
                          obj['message'] = {
                            'from_uid': AppStyle().session['data']['uid'],
                            'to_uid': obj['profile']['uid'],
                            'date': FieldValue.serverTimestamp(),
                            'message': nameController.text,
                          };
                          await FirebaseFirestore.instance.collection('messages').add(obj['message']);
                          obj['message']['date'] = null;
                          obj['messages'].add(obj['message']);
                          setState(() {
                            nameController.text = '';
                          });
                          AppStyle().hideLoader(context);
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_controllerT.hasClients) {
                            final position = _controllerT.position.maxScrollExtent;
                            _controllerT.jumpTo(position);
                          }
                        }
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE),
                    hintText: 'Message ... ',
                    border: InputBorder.none),
                // decoration: InputDecoration(
                //   filled: true,
                //   fillColor: Color(0xFFEEEEEE),
                //   hintText: 'Message',
                //   labelText: 'Message',
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void refresh() {
    // print('refresh');
    var listData = [];
    FirebaseFirestore.instance
        .collection('messages')
        .where('from_uid', isEqualTo: obj['profile']['uid'])
        .where('to_uid', isEqualTo: AppStyle().session['data']['uid'])
        // .orderBy('date', descending: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.size);

      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          tmp['time'] = doc['date'].toDate();
          listData.add(tmp);
        }
      }
      FirebaseFirestore.instance
          .collection('messages')
          .where('to_uid', isEqualTo: obj['profile']['uid'])
          .where('from_uid', isEqualTo: AppStyle().session['data']['uid'])
          // .orderBy('date', descending: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        print(querySnapshot.size);

        if (querySnapshot.size > 0) {
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            tmp['time'] = doc['date'].toDate();
            listData.add(tmp);
          }
        }
        listData.sort((a, b) {
          var adate = a['time']; //before -> var adate = a.expiry;
          var bdate = b['time']; //var bdate = b.expiry;
          return adate.compareTo(bdate);
        });
        print(listData);
        setState(() {
          obj['messages'] = listData;
          Timer(new Duration(seconds: 1), () {
            if (_controllerT.hasClients) {
              final position = _controllerT.position.maxScrollExtent;
              _controllerT.jumpTo(position);
            }
          });
        });
      });
    });
  }

  void initData() {
    FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // print('Document data: ${documentSnapshot.data()}');
        setState(() {
          obj['profile'] = documentSnapshot.data();
        });
      } else {
        // print('Document does not exist on the database');
      }
    }).catchError((error) {
      // print("Error: $error");
    });
  }

  void getNextPage() async {
    if (obj['lastDoc'] != null) {
      if (obj['lastDocLoaded'] != true) {
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: obj['profile']['uid'])
            .orderBy('date', descending: true)
            .startAfterDocument(obj['lastDoc'])
            .limit(AppStyle().pageSize)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.size > 0) {
            // print("Loaded = ");
            // print(querySnapshot.size);
            obj['lastDoc'] = querySnapshot.docs.last;
            for (var doc in querySnapshot.docs) {
              dynamic tmp = doc.data();
              tmp['id'] = doc.id;
              obj['posts'].add(tmp);
            }
            setState(() {
              obj['loading'] = false;
            });
          } else {
            // print("Finished Load");
            obj['lastDocLoaded'] = true;
          }
        });
      }
    }
  }

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
}
