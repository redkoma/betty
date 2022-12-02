import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scrb031NewsSetting extends StatefulWidget {
  const Scrb031NewsSetting({Key? key}) : super(key: key);

  @override
  _Scrb031NewsSettingState createState() => _Scrb031NewsSettingState();
}

class _Scrb031NewsSettingState extends State<Scrb031NewsSetting> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  TextEditingController nameController = TextEditingController();
  bool switchAnnounce = false;

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      obj = arguments;
      initData();

      loaded = true;
      setState(() {});
    }

    var tabNews = Container(
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  // leading: Image.network("${obj['news'][index]['cover'] ?? AppStyle().no_user_url}"),
                  title: Text(
                    "${obj['news'][index]['subject'] ?? 'No Subject'}",
                  ),
                  subtitle: Text(
                    "${obj['news'][index]['short_description']}",
                  ),
                  trailing: Switch(
                    value: obj['news'][index]['active'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        obj['news'][index]['active'] = value;
                        FirebaseFirestore.instance.collection('news').doc(obj['news'][index]['id']).set({'active': value}, SetOptions(merge: true));
                      });
                    },
                  ),
                  onTap: () async {
                    var res0 = await Navigator.pushNamed(context, '/scrb032', arguments: {'data': obj['news'][index]});
                    _refresh();
                  },
                );
              },
              itemCount: (obj['news'] ?? []).length,
            ),
          )
        ],
      ),
    );
    var tabAnnouncements = Container(
      width: size.width,
      child: Column(
        children: [
          ListTile(
            title: Text('Enable Announcement'),
            trailing: Switch(
              value: switchAnnounce,
              onChanged: (value) {
                setState(() {
                  switchAnnounce = value;
                  FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['uid']).set({'announce_enabled': value}, SetOptions(merge: true));
                });
              },
            ),
            subtitle: Text('เปิดใช้งานประกาศบริษัท'),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget widget, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: widget);
            },
            child: (switchAnnounce)
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: nameController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEEEE),
                            hintText: 'Announcement Message',
                            labelText: 'Announcement Message',
                          ),
                        ),
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
                            await FirebaseFirestore.instance
                                .collection('company')
                                .doc(AppStyle().session['data']['uid'])
                                .set({'announce': nameController.text}, SetOptions(merge: true));
                          },
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('News Settings'),
            actions: [
              TextButton(
                  onPressed: () async {
                    dynamic res0 = await Navigator.pushNamed(context, '/scrb032', arguments: {});
                    if (res0 != null) {
                      _refresh();
                    }
                  },
                  child: Text(
                    'Add News',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
            backgroundColor: Colors.brown,
            elevation: 0,
            bottom: TabBar(
                labelColor: Colors.brown,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                // isScrollable: true,
                indicator: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Announcements"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("News (${(obj['news'] ?? []).length})"),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            tabAnnouncements,
            tabNews,
          ]),
        ));
  }

  void initData() async {
    nameController.text = AppStyle().session['company']['announce'] ?? '';
    switchAnnounce = AppStyle().session['company']['announce_enabled'] ?? false;

    _refresh();
  }

  void _refresh() async {
    obj['news'] = [];
    FirebaseFirestore.instance.collection('news').where('companyId', isEqualTo: AppStyle().session['company']['uid']).get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        print("News Loaded = ");
        print(querySnapshot.size);
        for (var doc in querySnapshot.docs) {
          dynamic tmp = doc.data();
          tmp['id'] = doc.id;
          tmp['keyword'] = tmp['email'].toString();
          obj['news'].add(tmp);
        }
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }
}
