import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:time_range/time_range.dart';

class Scrb020CheckOut extends StatefulWidget {
  const Scrb020CheckOut({Key? key}) : super(key: key);

  @override
  _Scrb020CheckOutState createState() => _Scrb020CheckOutState();
}

class _Scrb020CheckOutState extends State<Scrb020CheckOut> {
  Map arguments = {};

  Map obj = {'profile': {}, 'loading': true, 'department': []};
  int selIndex = 0;
  final dataKey = GlobalKey();
  Size size = const Size(1, 1);
  bool loaded = false;
  List<String> department = [];
  Completer<GoogleMapController> _controller = Completer();
  late LocationData _locationData;
  late GoogleMapController mapController;
  var time = DateTime.now();

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
      loaded = true;
      if (obj['data']['out'] == null) {
        getLocation();
      } else {
        AppStyle().session['location'] = LatLng(obj['data']['out_location']['lat'], obj['data']['out_location']['lng']);

        time = obj['data']['out'].toDate();
      }
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Out"),
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
                  'ลงเวลาออกจากงาน',
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
            height: 140,
            child: GoogleMap(
              markers: <Marker>{
                Marker(
                  markerId: MarkerId('marker_1'),
                  position: AppStyle().session['location'] ?? LatLng(0.0, 0.0),
                )
              },
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: AppStyle().session['location'] ?? LatLng(0.0, 0.0),
                zoom: 15, //กำหนดระยะการซูม สามารถกำหนดค่าได้ 0-20
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _controller.complete(controller);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.camera_front),
            title: Text('Selfie Photo'),
            subtitle: Text('กดที่นี่เพื่อถ่ายรูป'),
            trailing: (obj['data']['out'] == null) ? ((obj['images'] != null) ? Image.file(File(obj['images'].path)) : null) : Image.network(obj['data']['out_photo']),
            onTap: (obj['data']['out'] == null)
                ? () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera, maxHeight: 800, maxWidth: 800, imageQuality: 80, preferredCameraDevice: CameraDevice.front);
                    if (image != null) {
                      setState(() {
                        print(image.name);
                        obj['images'] = image;
                      });
                    }
                  }
                : null,
          ),
          Divider(),
          (obj['data']!['out'] != null)
              ? Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(15),
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: [
                      Colors.teal,
                      Colors.tealAccent,
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '${DateFormat("HH:mm").format(time)}',
                          style: TextStyle(fontSize: 80, color: Colors.white),
                        ),
                        Text(
                          '${DateFormat("dd MMM yyyy").format(time)}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          SizedBox(height: 20),
          (obj['images'] != null)
              ? Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 20), AppStyle().btnHeight), primary: AppStyle().bgColor),
                    child: Text(
                      'Confirm Check Out',
                      style: TextStyle(
                        fontSize: AppStyle().btnFontSize,
                      ),
                    ),
                    onPressed: () async {
                      AppStyle().showLoader(context);
                      final storageRef = FirebaseStorage.instance.ref();
                      final postImagesRef = storageRef.child("users/" +
                          AppStyle().session['user'].uid +
                          "/images/" +
                          DateFormat("yyyyMM").format(DateTime.now()) +
                          '/' +
                          DateFormat("yyyyMMdd").format(DateTime.now()) +
                          "in_" +
                          obj['images'].name);
                      try {
                        final bytes = File(obj['images'].path).readAsBytesSync();
                        await postImagesRef.putString(base64Encode(bytes).toString(),
                            format: PutStringFormat.base64,
                            metadata: SettableMetadata(
                              contentType: "image/jpeg",
                            ));
                        String url = await postImagesRef.getDownloadURL();
                        Map<String, dynamic> data = {};
                        data[DateFormat("yyyyMMdd").format(DateTime.now())] = {
                          'out': FieldValue.serverTimestamp(),
                          'out_location': {
                            'lat': _locationData.latitude,
                            'lng': _locationData.longitude,
                          },
                          'out_photo': url,
                        };
                        await FirebaseFirestore.instance.collection('timesheet').doc(AppStyle().session['data']['uid']).set(data, SetOptions(merge: true));

                        AppStyle().hideLoader(context);
                      } on FirebaseException catch (e) {
                        // print(e);
                        AppStyle().hideLoader(context);
                      }

                      Navigator.pop(context, {'data': obj['data']});
                    },
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }

  getLocation() async {
    Location location = new Location();
    var lat = 0.0;
    var lng = 0.0;
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
      _locationData = new LocationData.fromMap({'latitude': lat, 'longitude': lng});
      AppStyle().debugmsg('location disable mode');
      AppStyle().session['location_service'] = false;
    } else {
      AppStyle().session['location_service'] = true;
      _locationData = await location.getLocation();
      // if (kReleaseMode) {
      //   // is Release Mode ??
      //   _locationData = await location.getLocation();
      //   AppStyle().debugmsg('release mode');
      // } else {
      //   _locationData = new LocationData.fromMap({'latitude': lat, 'longitude': lng});
      //   AppStyle().debugmsg('debug mode');
      // }
      AppStyle().session['location'] = LatLng(_locationData.latitude ?? 0, _locationData.longitude ?? 0);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_locationData.latitude ?? 0, _locationData.longitude ?? 0), 14));
      setState(() {});
    }
  }

  void initData() {}
}
