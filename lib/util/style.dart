import 'dart:convert';
import 'dart:math';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io' as dart_io;
import 'dart:io' show Platform;

import 'package:betty/util/lang.dart';
import 'package:video_player/video_player.dart';

class AppStyle {
  ThemeData appTheme = ThemeData(
    primarySwatch: Colors.brown,
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 200, 190, 145),
    ),
    primaryColor: Color.fromARGB(255, 133, 72, 7),
    backgroundColor: Colors.white,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  Color btnBgColor = Color.fromARGB(255, 238, 242, 244);

  Color bgColor = Color.fromARGB(255, 200, 179, 145);
  Color mainBgColor = Colors.white;
  Color mainBtnTxtColor = Color.fromARGB(255, 133, 72, 7);
  Color mainTabBgColor = Color.fromARGB(255, 245, 245, 245);
  Color mainTabActiveColor = Color.fromARGB(255, 133, 72, 7);
  Color mainTabTxtColor = Color.fromARGB(132, 180, 176, 124);
  List color = [
    Color(0xFFEEB859),
    Color(0xFF81CEFD),
    Color(0xFF9AE58D),
    Color(0xFFF47B7B),
    Color.fromARGB(255, 105, 207, 197),
    Color(0xFFFBACD7),
    Color.fromARGB(255, 149, 98, 10),
    Color.fromARGB(255, 9, 77, 119),
    Color.fromARGB(255, 31, 117, 16),
    Color.fromARGB(255, 101, 8, 8),
    Color.fromARGB(255, 8, 105, 95),
    Color.fromARGB(255, 105, 3, 59),
  ];
  var mainBtnDecoration = BoxDecoration(
//    color: Color.fromARGB(255, 238, 242, 244),
    color: Color.fromARGB(255, 242, 249, 249),
    borderRadius: BorderRadius.circular(15),
    // boxShadow: [
    //   BoxShadow(
    //     blurRadius: 7.0,
    //     color: Colors.grey[50]!,
    //     offset: const Offset(-3.0, -3.0),
    //   ),
    //   BoxShadow(
    //     blurRadius: 7.0,
    //     color: Colors.grey[400]!,
    //     offset: const Offset(3.0, 3.0),
    //   ),
    // ],
  );

  Color textColor = const Color.fromARGB(255, 7, 133, 116);

  String googlePlaceKey = "AIzaSyC0-Us8F3xIbJMyGz1YcMxy_VS7ySSz2zI"; // ABPO "AIzaSyDeG_kB4ltpn9jTfyO9aSHK7wEByv9TcRc"; //"AIzaSyCndvIz0LLx0Gi4fxLro8uANJvaO2UVKnk";
  String googleVisionAiKey = "AIzaSyDeG_kB4ltpn9jTfyO9aSHK7wEByv9TcRc"; //"AIzaSyBQxNosIm8uEBXZCTNJyYpqzUtNvrN35tY";
  String pointerUrl = "https://performax-k2c-default-rtdb.firebaseio.com/server_list/";
  String apiUrl = "http://127.0.0.1/performax/app/core/service.php?do=";
  int pageSize = 24;
  var list_expense_type = ['Food', 'Travel', 'Cloth', 'Clinic', 'Other'];
  var list_book_style = ['Modern', 'Diary', 'Notebook'];
  var list_shipping_package = ['Box', 'Can', 'Bag', 'Other', ''];
  var list_pet_type = ['Dog', 'Cat', 'Rabbit', 'Other', ''];
  var list_pet_subtype = {
    'Dog': [
      'บาเซนจิ (Basenji)',
      'อิงลิช บูลล์ด็อก (English Bulldog)',
      'เวสต์ ไฮแลนด์ ไวท์ เทอร์เรีย (West Highland White Terrier)',
      'มินิเอเจอร์ ชเนาเซอร์ (Miniature Schnauzer)',
      'เยอรมันเชพเพิร์ด (German Shepherd)',
      'มอลทีส (Maltese)',
      'ชิสุ (Shih Tzu)',
      'ปาปิยอง (Papillon)',
      'อเมริกันพิทบูลเทอเรีย (American Pit bull terrier)',
      'ปักกิ่ง (Pekingese)',
      'ยอร์กเชียร์ เทอร์เรียร์ (Yorkshire terrier)',
      'บอสตัน เทอร์เรีย (Boston Terrier)',
      'บิชอง ฟริเซ่ (Bichon Frise)',
      'ปั๊ก (Pug)',
      'ปอมเมอเรเนียน (Pomeranian)',
      'ชิวาวา (Chihuahua)',
      'บูล เทอร์เรีย (Bull Terrier)',
      'บอร์เดอร์ คอลลี่ (Border Collie)',
      'เกรทเดน (Great Dane)',
      'ค็อกเกอร์ สแปเนียล (Cocker Spaniel)',
      'ร็อตไวเลอร์ (Rottweiler)',
      'ชิบะ อินุ (Shiba Inu)',
      'เฟรนช์ บูลด็อก (French bulldog)',
      'ดัชชุน (Dachshund)',
      'ไซบีเรียนฮัสกี้ (siberian husky)',
      'เวลช์ คอร์กี้ (Welsh corgi)',
      'โกลเด้น รีทรีฟเวอร์ (Golden Retriever)',
      'อลาสกัน มาลามิวท์ (Alaskan Malamute)',
      'อากิตะ อินุ (Akita Inu)',
      'เบลเยี่ยม มาลินอยส์  (Belgian Malinois)',
      'ลาบราดอ รีทรีฟเวอร์ (Labrador Retriever)',
      'ปูลิ (Puli)',
      'โคมอนดอร์ (Komondor)',
      'วิปเพ็ท (Whippet)',
      'อิตาเลียน เกรย์ฮาวด์ (Italian Greyhound)',
      'คอลลี่ (Rough Collie)',
      'สก็อตทิช เชพเพิร์ด เชลตี้ (Scottish Shepherd Sheltie)',
      'เบอร์นีส เมาท์เทนด็อก (Bernese Mountain Dog)',
      'เกรทเทอร์ สวิสส์ เมาน์เทนด็อก (Greater Swiss Mountain Dog)',
      'บีเกิ้ล (Beagle)',
      'อเมริกัน ฟ็อกฮาวด์ (American Foxhound)',
      'รัสซียน ทอย เทอร์เรีย (Russian Toy Terrier)',
      'ลาซา แอปโซ (Lhasa Apso)',
      'วิซสลา (Vizsla)',
      'โรดีเชียน ริดจ์แบ็ค (Rhodesian Ridgeback)',
      'เซนต์เบอร์นาร์ด (Saint Bernard)',
      'มอสโกว วอทด็อก (Moscow Watchdog)',
      'เคน คอร์โซ่ (Cane Corso)',
      'บ็อกเซอร์ (Boxer)',
      'บางแก้ว (Thai Bangkaew)',
      'ดัลเมเชี่ยน (Dalmatian)',
      'ไทยหลังอาน (Thai Ridgeback)',
      'ทิเบตันมาสทิฟฟ์ (Tibetan Mastiff)',
      'ชามอย (Samoyed)',
      'เชาเชา (Chow Chow)',
      'อเมริกัน เอสกิโม ด็อก (American Eskimo Dog) ',
      'เจแปนนิส สปิตซ์ (Japanese Spitz)',
      'คูวาสซ์ (Kuvasz)',
      'เจแปนนิส ชิน (Japanese Chin)',
      'พุดเดิ้ล (Poodle)',
      'อัฟกัน ฮาวนด์ (Afghan Hound)',
      'เปอตี บราบ็องซง',
      'โบโลเนส',
      'ไชนีส เครสเต็ด',
      'คอนทิเนนทัล ทอย สแปเนียล',
      'ออสเตรเลียน ซิลกี เทอร์เรีย ',
      'อิงลิช ทอย เทอร์เรีย แบล็ค แอนด์ แทน',
      'เครน เทอร์เรีย',
      'เจแปนนีส เทอร์เรีย',
      'เชทแลนด์ ชีพด็อก',
      'เชสกี เทอร์เรีย',
      'เบดลิงตัน เทอร์เรีย',
      'เยอรมัน ฮันทิง เทอร์เรีย',
      'เลคแลนด์ เทอร์เรีย ',
      'เลิฟเชิน หรือ ลิตเติ้ล ไลอ้อน ด็อก',
      'คาวาเลีย คิงชาร์ล สแปเนียล',
    ],
    'Cat': [
      'เปอร์เซีย (Persian)',
      'อเมริกัน ชอร์ตแฮร์ (American Shorthair)',
      'สก็อตติช โฟลด์ (Scottish Fold) ',
      'วิเชียรมาศ (Siamese)',
      'สฟริงซ์ (Sphynx) ',
      'บริติช ชอร์ตแฮร์ (British Shorthair) ',
      'เมนคูน (Main Coon) ',
      'เบงกอล (Bengal) ',
      'เอ็กโซติก (Exotic) ',
      'อเมริกัน เคิร์ล (American Curl) ',
      'สีสวาด หรือ โคราช (Silver Blue)',
      'แมวป่านอร์เวย์ (Norwegian Forest Cat)',
      'หิมาลายัน (Himalayan cat)',
      'ปีเตอร์บัลด์ (Peterbald)',
      'อียิปเตียน โม (Egytian Mau)',
      'ลาเปิร์ม ( La Perm)',
      'รัสเซียน บลู (Russian Blue)',
      'เซเรนเกติ ( Seregeti Cat)',
      'เอลฟ์ (Elf Cat)',
      'ทอยเกอร์  (Toyger)',
      'ซาฟารี  (Safari)',
      'ขาวมณี ( Khao Manee)',
      'ชอซี (Chausie)',
      'คาราคัล ( Caracal)',
      'ซาวันนนาห์ ( Savannah )',
      'อาชีร่า ( Ashera)',
      'มันช์กิ้น (Munchkin)',
      'แร็กดอลล์ (Ragdoll)',
      'เทอร์คิชแองโกรา (Turkish Angora)',
      'ไซบีเรียน (Siberian cat)',
      'ศุภลักษณื ( Copper Cat)',
      'อะบิสซิเนียน ',
      'บาหลี',
      'เบอร์แมน',
      'เบอร์มีส',
      'เบอร์มิลลา',
      'ชินชิลล่า',
      'คอร์นิชเรกซ์',
      'เดวอนเรกซ์',
      'มีอกกี้',
      'แมงซ์',
      'นอร์วีเจียนฟอเรสต์',
      'อ็อกซิแคต',
      'โอเรียนทัลขนสั้น',
    ],
    'Rabbit': [
      'มินิลอป (Mini Lop)',
      'ไลออนเฮด (Lion Head)',
      'ฟลอริดาไวท์ (Florida White)',
      'เนเธอร์แลนด์ดวอร์ฟ (Netherland Dwarf)',
      'ฮอลแลนด์ลอป (Holland Lop)',
      'มินิเร็กซ์ (Mini Rex)',
      'เจอร์ซี วูลลี (Jersey Wooly)',
      'ดัตช์ (Dutch)',
      'ดวอร์ฟ โฮโท (Dwarf Hotot)',
      'เฟลมมิชไจแอนท์ (Flemish Giant)',
    ],
    'Other': ['Other'],
    '': ['Other'],
  };
  var list_vaccine_type = [
    {'name': 'Vaccine 1', 'cover_month': 3, 'pet_type': 'Dog'},
    {'name': 'Vaccine 2', 'cover_month': 3, 'pet_type': 'Dog'},
    {'name': 'Vaccine 3', 'cover_month': 3, 'pet_type': 'Dog'},
  ];
  var list_shop_category = [
    {'name': 'Pet Places', 'color': Colors.orangeAccent, 'pet_type': 'Dog'},
    {'name': 'Tips', 'color': Color.fromARGB(255, 45, 193, 121), 'pet_type': 'Dog'},
    {'name': 'Foods & Snacks', 'color': Colors.amber, 'pet_type': 'Dog'},
    {'name': 'Accessories', 'color': Colors.blue, 'pet_type': 'Dog'},
  ];
  var list_place_type = ['Cafe', 'Hospital', 'Dog Park', 'Camping', 'Hotel', 'Grooming', 'Pet Shop', ''];
  var list_activity_type = ['Late', 'In', 'Out', 'Early Out', 'Leave', 'Absence'];
  var list_statcode = ['late', 'in', 'out', 'early_out', 'leave', 'absence'];
  var list_activity_type_icon = [
    Icon(Icons.coffee, color: Colors.white, size: 40),
    FaIcon(FontAwesomeIcons.userDoctor, color: Colors.white, size: 40),
    FaIcon(FontAwesomeIcons.cartShopping, color: Colors.white, size: 40),
    FaIcon(FontAwesomeIcons.personRunning, color: Colors.white, size: 40),
    FaIcon(FontAwesomeIcons.campground, color: Colors.white, size: 40),
    FaIcon(FontAwesomeIcons.scissors, color: Colors.white, size: 40),
  ];
  var list_activity_type_color = [
    Color(0xFFEEB859),
    Color(0xFF81CEFD),
    Color(0xFF9AE58D),
    Color(0xFFF47B7B),
    Color.fromARGB(255, 105, 207, 197),
    Color(0xFFFBACD7),
  ];
  double btnFontSize = 18;
  double btnHeight = 52;
  double appVersion = 1.0;
  String platform = (Platform.isIOS) ? "ios" : "android";
  String language = "TH";
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  final formatNumber = NumberFormat("#,###", "en_US");
  bool _isSnackbarShow = false;
  String no_user_url = "https://firebasestorage.googleapis.com/v0/b/tailtrips-k2c.appspot.com/o/images%2Fno-user-200x200.jpeg?alt=media&token=21e15695-c782-41a4-b66d-72f2f36be7cd";
  final _storage = const FlutterSecureStorage();
  Map session = {
    'data': {
      'topfriend1': {},
      'topfriend2': {},
      'topfriend3': {},
      'topfriend4': {},
    }
  };

  String serverName = 'demo';

  int nearby = 30; //30
  double distance(double lat, double lng) {
    double x2 = lat;
    double y2 = lng;
    double x1 = this.session['profile']['lat'];
    double y1 = this.session['profile']['lng'];
    return (sqrt(pow((x1 - x2), 2) + pow(y1 - y2, 2)) * 130);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  error_api(BuildContext context, String title, String message, String button, String route) {
    dialog(context, {
      "title": title,
      "message": message,
      "ok_btn": button,
      "ok_function": () async {
        Navigator.pushReplacementNamed(context, route);
      },
      "cancel_btn": AppStyle().tr('lb_cancel'),
      "cancel_function": () {},
      "show_cancel": false,
      "type": CoolAlertType.error
    });
  }

  error_pop(BuildContext context, String title, String message, String button) {
    dialog(context, {
      "title": title,
      "message": message,
      "ok_btn": button,
      "ok_function": () async {
        Navigator.of(context).pop();
      },
      "cancel_btn": AppStyle().tr('lb_cancel'),
      "cancel_function": () {},
      "show_cancel": false,
      "type": CoolAlertType.error
    });
  }

  Future<bool> alert(BuildContext context, String title) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: btnFontSize,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> confirm(BuildContext context, String title) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.white),
              child: Text(
                "No",
                style: TextStyle(fontSize: btnFontSize, color: Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            ElevatedButton(
              child: Text(
                "Yes",
                style: TextStyle(
                  fontSize: btnFontSize,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  confirmData(BuildContext context, String value, String title) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        _textController.text = value;
        return AlertDialog(
//          title: Text(title),
          content: TextField(
            autofocus: true,
            onChanged: ((value) {
//              obj['sn_lot'] = value;
            }),
            controller: _textController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEEEEEE),
              hintText: '',
              labelText: title,
            ),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: btnFontSize,
                ),
              ),
              onPressed: () {
                String res = _textController.text;
                Navigator.pop(context, res);
              },
            ),
          ],
        );
      },
    );
  }

  confirmDataTextArea(BuildContext context, String value, String title) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        _textController.text = value;
        return AlertDialog(
//          title: Text(title),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: ((value) {
//              obj['sn_lot'] = value;
            }),
            controller: _textController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEEEEEE),
              hintText: '',
              labelText: title,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: btnFontSize,
                ),
              ),
              onPressed: () {
                String res = _textController.text;
                Navigator.pop(context, res);
              },
            ),
          ],
        );
      },
    );
  }

  confirmDataDropdown(BuildContext context, String value, String title, List<dynamic> list, String propName) async {
    if (value == null) {
      value = "";
    }

    List<DropdownMenuItem<String>> itemList = [
      DropdownMenuItem(
        child: Text("Please select $title"),
        value: "",
      ),
    ];
    var matchItem = false;
    for (var i = 0; i < list.length; i++) {
      itemList.add(DropdownMenuItem(
        child: Text(list[i][propName].toString()),
        value: list[i][propName].toString(),
      ));
      if (value == list[i][propName].toString()) {
        matchItem = true;
      }
    }
    if (!matchItem) {
      if (value != '') {
        itemList.add(DropdownMenuItem(
          child: Text(value),
          value: value,
        ));
      }
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setStateAlert /*You can rename this!*/) {
          return AlertDialog(
//          title: Text(title),
            content: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: itemList,
                  hint: const Text("Please select "),
                  onChanged: (String? val) {
                    setStateAlert(() {
                      value = val ?? '';
                    });
                  }),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: btnFontSize,
                  ),
                ),
                onPressed: () {
                  String res = value;
                  Navigator.pop(context, res);
                },
              ),
            ],
          );
        });
      },
    );
  }

  dialog(BuildContext context, arguments) {
    _dialog(context, arguments);
  }

  _dialog2(BuildContext context, arguments) {
    CoolAlert.show(
      context: context,
      type: arguments['type'] ?? CoolAlertType.info,
      title: arguments['title'],
      text: arguments['message'],
      showCancelBtn: arguments['show_cancel'],
      cancelBtnText: arguments['cancel_btn'],
      onCancelBtnTap: arguments['cancel_function'],
      confirmBtnText: arguments['ok_btn'],
      onConfirmBtnTap: arguments['ok_function'],
    );
  }

  _dialog(BuildContext context, arguments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          title: Text(arguments['title']),
          content: Text(arguments['message']),
          actions: <Widget>[
            (arguments['show_cancel'])
                ? TextButton(
                    child: Text(
                      arguments['cancel_btn'],
                      style: TextStyle(
                        fontSize: btnFontSize,
                      ),
                    ),
                    onPressed: arguments['cancel_function'],
                  )
                : Container(),
            ElevatedButton(
              child: Text(
                arguments['ok_btn'],
                style: TextStyle(
                  fontSize: btnFontSize,
                ),
              ),
              onPressed: arguments['ok_function'],
            ),
          ],
        );
      },
    );
  }

  dynamic validate(BuildContext context, String s, {dynamic? arguments}) {
    String error = "";
    switch (s) {
      case '/scr002':
        if ((arguments['username'] == "") || (arguments['username'] == null)) {
          error += "- Username is required\n";
        }
        if ((arguments['password'] == "") || (arguments['password'] == null)) {
          error += "- Password is required\n";
        }
        break;
      case '/scr004':
        if ((arguments['username'] == "") || (arguments['username'] == null)) {
          error += "- Username is required\n";
        }
        if ((arguments['password'] == "") || (arguments['password'] == null)) {
          error += "- Password is required\n";
        } else if ((arguments['password'].toString().length < 8) || (arguments['password'].toString().length > 16)) {
          error += "- Password is required 8-16 characters\n";
        }

        // var password = arguments['password'];
        // bool passwordValid = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(password);
        // if (!passwordValid) {
        //   error += "- Password must be character or number (a-z,A-Z,0-9)\n";
        // }

        if ((arguments['password'] != arguments['cpassword'])) {
          error += "- Confirm Password must equal Password \n";
        }

        // validate email
        var email = arguments['username'];
        bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
        if (!emailValid) {
          error += "- Username must be email address\n";
        }

        break;

      default:
    }
    if (error != "") {
      AppStyle().dialog(context, {
        "title": "Warning",
        "message": error,
        "ok_btn": AppStyle().tr('lb_close'),
        "ok_function": () async {
          Navigator.of(context).pop();
        },
        "cancel_btn": AppStyle().tr('lb_cancel'),
        "cancel_function": () {},
        "show_cancel": false,
        "type": CoolAlertType.error
      });

      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text("Warning"),
      //       content: Text(error),
      //       actions: <Widget>[
      //         ElevatedButton(
      //           child: Text(
      //             'Close',
      //             style: TextStyle(
      //               fontSize: AppStyle().btnFontSize,
      //             ),
      //           ),
      //           onPressed: () async {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
      return false;
    } else {
      return true;
    }
  }

  void showSnackBar(BuildContext context, String s, Color color) {
    if (!_isSnackbarShow) {
      _isSnackbarShow = true;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            backgroundColor: color,
            content: Text(s),
          ))
          .closed
          .then((SnackBarClosedReason reason) {
        _isSnackbarShow = false;
      });
    }
  }

  Future<Map<String, Object>> takeImageBase64(double height, double width, int quality) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxHeight: height, maxWidth: width, imageQuality: quality);
    if (image != null) {
      final bytes = dart_io.File(image.path).readAsBytesSync();
      var img64 = {'base64': base64Encode(bytes), 'path': image.path};
      return img64;
    } else {
      return {'base64': ''};
    }
  }

  Future<Map<String, Object>> browseImageBase64(double height, double width, int quality) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxHeight: height, maxWidth: width, imageQuality: quality);
    if (image != null) {
      final bytes = dart_io.File(image.path).readAsBytesSync();
      var img64 = {'base64': base64Encode(bytes), 'path': image.path, 'name': image.name};
      return img64;
    } else {
      return {'base64': ''};
    }
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  bool isNumericUsing_tryParse(String string) {
    // Null or empty string is not a number
    if (string.isEmpty) {
      return false;
    }

    // Try to parse input string to number.
    // Both integer and double work.
    // Use int.tryParse if you want to check integer only.
    // Use double.tryParse if you want to check double only.
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }

  void debugmsg(Object? data) {
    print(data);
  }

  getAPI(String apiName, Map arguments, Map req) async {
    req['do'] = apiName;
    Response response = await post(
      Uri.parse(AppStyle().apiUrl + apiName),
      headers: {'Authorization': arguments['token'], 'content-type': 'application/json'},
      body: jsonEncode(req),
    );
    dynamic data = json.decode(response.body);
    AppStyle().debugmsg('Token : ' + arguments['token']);
    AppStyle().debugmsg('Call API : ' + apiName);
    AppStyle().debugmsg('Request');
    AppStyle().debugmsg(req);
    AppStyle().debugmsg('Response');
    AppStyle().debugmsg(data);
    return data;
  }

  doLogin(Map req) async {
    Response response = await post(
      Uri.parse(AppStyle().apiUrl + "LOGIN"),
      headers: {
        //'Authorization': AppStyle().authHeader + arguments['token'],
        'content-type': 'application/json'
      },
      body: jsonEncode(req),
    );
    dynamic data = json.decode(response.body);
    AppStyle().debugmsg('Call API : Login');
    AppStyle().debugmsg('Request');
    AppStyle().debugmsg(req);
    AppStyle().debugmsg('Response');
    AppStyle().debugmsg(data);
    return data;
  }

  getGAPI(Map req) async {
    Response response = await post(
      Uri.parse("https://vision.googleapis.com/v1/images:annotate?key=" + this.googleVisionAiKey),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(req),
    );
    dynamic data = json.decode(response.body);
    return data;
  }

  getUrl(String url, Map req) async {
    Response response = await get(
      Uri.parse(url),
      headers: {'content-type': 'application/json'},
//      body: jsonEncode(req),
    );
    dynamic data = json.decode(response.body);
    return data;
  }

  showLoader(BuildContext context) {
    Loader.show(context, progressIndicator: const CircularProgressIndicator(), overlayColor: const Color(0x99000000));
  }

  hideLoader(BuildContext context) {
    Loader.hide();
  }

  String tr(code) {
    return langPack[AppStyle().language][code] ?? code;
  }

  static AppStyle u = AppStyle.init();

  factory AppStyle() {
    return u;
  }

  AppStyle.init() {}
}

class VideoWidget extends StatefulWidget {
  String url;
  VideoWidget(this.url);
//  const VideoWidget({Key? key}) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  double volumn = 0;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.setVolume(volumn);
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          children: <Widget>[
            (_controller.value.aspectRatio > 1)
                ? SizedBox(
                    height: ((size.width - (size.width / _controller.value.aspectRatio)) / 2),
                  )
                : Container(),
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  ClosedCaption(text: _controller.value.caption.text),
                  // VideoProgressIndicator(_controller, allowScrubbing: true),
                  Positioned(
                      top: 20,
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          if (volumn == 0) {
                            volumn = 1;
                          } else {
                            volumn = 0;
                          }
                          _controller.setVolume(volumn);
                          setState(() {});
                          print(_controller.value.size.height);
                          print(size.width / _controller.value.aspectRatio);
                          print(_controller.value.aspectRatio);
                          print((size.width - (size.width / _controller.value.aspectRatio)) / 2);
                        },
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                          child: Icon((volumn == 1) ? Icons.volume_mute : Icons.volume_off),
                        ),
                      ))
                ],
              ),
            ),
            (_controller.value.aspectRatio > 1)
                ? SizedBox(
                    height: ((size.width - (size.width / _controller.value.aspectRatio)) / 2),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
