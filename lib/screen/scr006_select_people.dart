import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scr006SelectPeople extends StatefulWidget {
  const Scr006SelectPeople({Key? key}) : super(key: key);

  @override
  _Scr006SelectPeopleState createState() => _Scr006SelectPeopleState();
}

class _Scr006SelectPeopleState extends State<Scr006SelectPeople> {
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
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Size size = MediaQuery.of(context).size;

    if (!loaded) {
      _scrollController.addListener(_scrollListener);
      obj = arguments;
      loaded = true;
      if (obj['userList'] == null) {
        refresh();
      }
      print("User List = ${obj['userList'].length}");
      if (obj['popback'] == null) {
        obj['popback'] = 'N';
      }

      obj['loading'] = false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyle().bgColor,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              onChanged: (e) {
                refresh();
              },
              onEditingComplete: () {
                //
                refresh();
              },
              controller: searchController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                      searchController.text = '';
                    },
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none),
            ),
          ),
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // title: Text(
        //   "${obj['profile']['displayName'] ?? ''}",
        //   style: TextStyle(fontSize: 16),
        // ),
      ),
      backgroundColor: AppStyle().mainBgColor,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
            child: ListView.builder(
                itemCount: (obj['userList'] ?? []).length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: InkWell(
                            onTap: () async {
                              if (obj['popback'] == 'Y') {
                                Navigator.pop(context, obj['userList'][index]);
                              } else {
                                Navigator.pushNamed(context, '/scr003', arguments: {'profile': obj['userList'][index]});
                              }
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: CachedNetworkImageProvider(obj['userList'][index]['photoURL'] ?? AppStyle().no_user_url),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (obj['popback'] == 'Y') {
                              Navigator.pop(context, obj['userList'][index]);
                            } else {
                              Navigator.pushNamed(context, '/scr003', arguments: {'profile': obj['userList'][index]});
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${obj['userList'][index]['displayName'] ?? obj['userList'][index]['email']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text("${obj['userList'][index]['email']}"),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                })),
      ]),
    );
  }

  void refresh() {
    var listUser = [];
    FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: searchController.text)
        .where('displayName', isLessThan: searchController.text + 'z')
        .limit(AppStyle().pageSize)
        .get()
        .then((QuerySnapshot querySnapshot) {
      var foundUid = {};
      if (querySnapshot.size > 0) {
        obj['lastDoc'] = querySnapshot.docs.last;
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          if (tmp['uid'] != AppStyle().session['profile']['uid']) {
            listUser.add(tmp);
            foundUid[tmp['uid']] = 'Y';
          }
        }
      }
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: searchController.text)
          .where('email', isLessThan: searchController.text + 'z')
          .limit(AppStyle().pageSize)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          obj['lastDoc'] = querySnapshot.docs.last;
          for (var doc in querySnapshot.docs) {
            dynamic tmp = doc.data();
            tmp['id'] = doc.id;
            if (tmp['uid'] != AppStyle().session['profile']['uid']) {
              if (foundUid[tmp['uid']] != 'Y') {
                listUser.add(tmp);
              }
            }
          }
        }

        setState(() {
          obj['userList'] = listUser;
        });
      }).catchError((err) {
        print(err);
      });
    }).catchError((err) {
      print(err);
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
