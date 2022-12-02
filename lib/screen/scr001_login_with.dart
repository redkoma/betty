import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:betty/main.dart';
import 'package:betty/util/style.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     //'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

class Scr001LoginWith extends StatefulWidget {
  const Scr001LoginWith({Key? key}) : super(key: key);
  @override
  _Scr001LoginWithState createState() => _Scr001LoginWithState();
}

class _Scr001LoginWithState extends State<Scr001LoginWith> {
  bool _passwordVisible = false;
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map<String, String> secureStorage = {};
  String language = 'EN';
  String loadingMsg = '';
  late LocationData _locationData;
  double lat = 13.8613202, lng = 100.500173;
// Google Sign in
  // GoogleSignInAccount? _currentUser;
  dynamic arguments;
  bool loaded = false;
  Image image = Image.asset("assets/images/loading.gif");
  @override
  void initState() {
    super.initState();
    _passwordVisible = false;

    _readAll();
  }

  Future<void> _readAll() async {
    setState(() {
      loadingMsg = "check session";
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        loadingMsg = "found session";
      });

      _locationData = new LocationData.fromMap({'latitude': lat, 'longitude': lng});

      setState(() {
        loadingMsg = "User data";
      });

      AppStyle().session['user'] = user;
      AppStyle().session['profile'] = {
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'phoneNumber': user.phoneNumber,
        'lat': _locationData.latitude,
        'lng': _locationData.longitude,
        'last_login': FieldValue.serverTimestamp(),
      };
      await loadUser();

      setState(() {
        loadingMsg = "main screen";
      });

      Navigator.pushReplacementNamed(context, '/scr002', arguments: {'authData': AppStyle().session['profile']});
    } else {
      // print('NOT HAVE SESSION');
      setState(() {
        loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          (loaded)
              ? Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 133, 157, 184),
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 0, 0, 0),
                      // color: Color.fromARGB(255, 159, 137, 84),
                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/loading.gif"),
                      //   fit: BoxFit.fitWidth,
                      // ),
                    ),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Loading ... ${loadingMsg}",
                          style: TextStyle(color: Colors.white),
                        ),
                        image,
                      ],
                    )),
                  ),
                ),
          (loaded)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 30,
                    ),
                    Expanded(child: Container()),
                    Text(
                      "Betty",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        "Work Better with Betty",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // Navigator.pushNamed(context, '/scr003', arguments: {'profile': obj['members'][index]});
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(3, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 90),
                        //   child: Image(
                        //     image: AssetImage('assets/images/logo.png'),
                        //     fit: BoxFit.fill,
                        //   ),
                        // ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFEEEEEE),
                            hintText: AppStyle().tr('lb_username'),
                            labelText: AppStyle().tr('lb_username'),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Container(
                          height: 15,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            hintText: AppStyle().tr('lb_password'),
                            labelText: AppStyle().tr('lb_password'),
                            filled: true,
                            fillColor: const Color(0xFFEEEEEE),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TextButton(
                            //   style: ButtonStyle(
                            //     foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                            //   ),
                            //   onPressed: () {
                            //     Navigator.pushNamed(context, "/scr004", arguments: {
                            //       'username': nameController.text,
                            //       'password': passwordController.text,
                            //     });
                            //   },
                            //   child: Text('Sign Up'),
                            // ),
                            TextButton(
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(AppStyle().textColor),
                              ),
                              onPressed: () async {
                                Navigator.pushNamed(context, "/signup", arguments: {
                                  'username': nameController.text,
                                  'password': passwordController.text,
                                });
                              },
                              child: const Text('Sign Up'),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(AppStyle().textColor),
                              ),
                              onPressed: () async {
                                AppStyle().showLoader(context);
                                try {
                                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: nameController.text, password: passwordController.text).then((value) async {
                                    _locationData = new LocationData.fromMap({'latitude': lat, 'longitude': lng});

                                    var user = value.user;
                                    AppStyle().session['user'] = user;

                                    AppStyle().session['profile'] = {
                                      'uid': user?.uid,
                                      'displayName': user?.displayName,
                                      'email': user?.email,
                                      'photoURL': user?.photoURL,
                                      'emailVerified': user?.emailVerified,
                                      'phoneNumber': user?.phoneNumber,
                                      'lat': _locationData.latitude,
                                      'lng': _locationData.longitude,
                                      'last_login': FieldValue.serverTimestamp(),
                                    };
                                    await loadUser();
                                    AppStyle().hideLoader(context);
                                    Navigator.pushReplacementNamed(context, '/scr002', arguments: {'authData': AppStyle().session['profile']});
                                  });
                                } on FirebaseAuthException catch (e) {
                                  AppStyle().hideLoader(context);

                                  if (e.code == 'user-not-found') {
                                    AppStyle().error_pop(context, "Login failed", "No user found for that email.", "OK");
                                  } else if (e.code == 'wrong-password') {
                                    AppStyle().error_pop(context, "Login failed", "Wrong password provided for that user.", "OK");
                                  } else {
                                    AppStyle().error_pop(context, e.code, e.message ?? e.code, "OK");
                                  }
                                }
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        )
                      ]),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, "/forgot_password", arguments: {'username': nameController.text});
                      },
                      child: const Text('Forgot Password'),
                    ),
                    Expanded(child: Container()),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> loadUser() async {
    print("Load User");
    await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          loadingMsg = "Company data";
        });
        AppStyle().session['data'] = documentSnapshot.data();
        if (AppStyle().session['data']['companyId'] != null) {
          await FirebaseFirestore.instance.collection('company').doc(AppStyle().session['data']['companyId']).get().then((DocumentSnapshot documentSnapshot) async {
            if (documentSnapshot.exists) {
              AppStyle().session['company'] = documentSnapshot.data();
              if (AppStyle().session['company'] != null) {
                AppStyle().session['user_department'] = AppStyle().session['company']['members'][AppStyle().session['user'].uid];
              }
              if (AppStyle().session['user_department'] == null) {
                print("Not Member in Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
                AppStyle().session['company'] = null;
                AppStyle().session['profile']['companyId'] = FieldValue.delete();
              } else {
                print("Have Company : ${AppStyle().session['company']['name']} ");
              }

              AppStyle().session['profile']['FCM'] = AppStyle().session['FCM'];
              FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set(AppStyle().session['profile'], SetOptions(merge: true));

              setState(() {});
            }
          }).catchError((error) {
            // print("Error: $error");
          });
          FirebaseFirestore.instance.collection('calendar').where('companyId', isEqualTo: AppStyle().session['data']['companyId']).get().then((QuerySnapshot querySnapshot) {
            if (querySnapshot.size > 0) {
              AppStyle().session['calendar'] = {};
              for (var doc in querySnapshot.docs) {
                dynamic tmp = doc.data();
                tmp['id'] = doc.id;
                setState(() {
                  AppStyle().session['calendar'][doc.id] = tmp['list'];
                });
              }
            }
          });
        } else {}
      } else {
        // print('Document does not exist on the database');
      }
    }).catchError((error) {
      // print("Error: $error");
    });
  }
}
