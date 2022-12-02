import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:betty/util/style.dart';

class Util103ListData extends StatefulWidget {
  const Util103ListData({Key? key}) : super(key: key);

  @override
  _Util103ListDataState createState() => _Util103ListDataState();
}

class _Util103ListDataState extends State<Util103ListData> {
  AppStyle appStyle = AppStyle();
  TextEditingController searchController = TextEditingController();
  List<dynamic> _dataList = [];
  List<Map<String, dynamic>> _objList = [];
  Map arguments = {};

  Map obj = {'profile': {}};

  bool loaded = false;
  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChanged();
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    searchController.dispose();
    super.dispose();
  }

  _onChanged() {
    getSuggestion(searchController.text);
  }

  void getSuggestion(String input) async {
    List<Map<String, dynamic>> results = [];
    if (input.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _objList;
    } else {
      if (obj['key'] == null) {
        results = _objList.where((item) => item["keyword"].toLowerCase().contains(input.toLowerCase())).toList();
      } else {
        results = _objList.where((item) => (item["keyword"] ?? '').toLowerCase().contains(input.toLowerCase())).toList();
      }
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _dataList = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;

    if (!loaded) {
      obj = arguments;
      initData();
      loaded = true;
    }

    // _dataList = [
    //   {
    //     'structured_formatting': {'main_text': 'test', 'secondary_text': 'sss'}
    //   }
    // ];
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // flexibleSpace: const Image(
        //   image: AssetImage('assets/images/bg-scaled.jpg'),
        //   fit: BoxFit.cover,
        // ),
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                      searchController.clear();
                    },
                  ),
                  hintText: AppStyle().tr('Search '),
                  border: InputBorder.none),
            ),
          ),
        ),
        actions: (obj['Add'] == 'Y')
            ? [
                IconButton(
                    onPressed: () async {
                      var res = await AppStyle().confirmData(context, '', "Add Data");
                      if (res != null) {
                        _dataList.add({'keyword': res});
                        if (obj['key'] == null) {
                          Navigator.pop(context, {'keyword': res});
                        } else {
                          Navigator.pop(context, {'keyword': res});
                        }
                        setState(() {});
                      }
                    },
                    icon: Icon(Icons.add_box_outlined))
              ]
            : null,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          shrinkWrap: true,
          itemCount: (_dataList == null ? 0 : _dataList.length),
          itemBuilder: (context, index) {
            return ListTile(
              leading: (obj['select'] == _dataList[index]["keyword"]) ? Icon(Icons.check, color: Colors.blue) : Icon(Icons.circle, color: Colors.white),
              title: Text(
                _dataList[index]["keyword"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: (obj['trailing'] == null)
                  ? null
                  : Text(
                      _dataList[index][obj['trailing']] ?? "",
                    ),
              subtitle: (obj['subtitle'] == null)
                  ? null
                  : Text(
                      _dataList[index][obj['subtitle']] ?? "",
                    ),
              onTap: () async {
                if (obj['key'] == null) {
                  Navigator.pop(context, _dataList[index]['keyword']);
                } else {
                  Navigator.pop(context, _dataList[index]);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> initData() async {
    for (var i = 0; i < (obj['list'] ?? []).length; i++) {
      var tmp = {'keyword': ''};
      if (obj['key'] != null) {
        obj['list'][i]['keyword'] = obj['list'][i][obj['key']];
        _objList.add(obj['list'][i]);
      } else {
        tmp['keyword'] = obj['list'][i];
        _objList.add(tmp);
      }
    }
    searchController.text = '';
    getSuggestion(searchController.text);
    setState(() {});
  }
}
