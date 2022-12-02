import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:betty/util/style.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     //'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

class Scr00ForgotPassword extends StatefulWidget {
  const Scr00ForgotPassword({Key? key}) : super(key: key);
  @override
  _Scr00ForgotPasswordState createState() => _Scr00ForgotPasswordState();
}

class _Scr00ForgotPasswordState extends State<Scr00ForgotPassword> {
  bool _passwordVisible = false;
  AppStyle appStyle = AppStyle();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map<String, String> secureStorage = {};
  String language = 'EN';

  dynamic arguments;
  bool loaded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF91c8c1),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Color(0XFF91c8c1),
            ),
          ),
          (loaded)
              ? SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            padding: EdgeInsets.all(30),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                    ),
                    Text("Forgot Password", style: TextStyle(color: Colors.white, fontSize: 30)),
                    Container(
                      height: 20,
                    ),
                    Icon(
                      Icons.lock_reset_outlined,
                      color: Colors.white,
                      size: 100,
                    ),
                    // Text("Forgot Password", style: TextStyle(color: Colors.white, fontSize: 30)),
                    Container(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        TextField(
                          autofocus: true,
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFEEEEEE),
                            hintText: AppStyle().tr('lb_email'),
                            labelText: AppStyle().tr('lb_email'),
                          ),
                          textInputAction: TextInputAction.go,
                          keyboardType: TextInputType.emailAddress,
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
                                try {
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: nameController.text);
                                } catch (e) {
                                  print(e);
                                }
                                AppStyle().showSnackBar(context, "Email has been send", AppStyle().mainBtnTxtColor);
                              },
                              child: const Text('Send Verification Email'),
                            ),
                          ],
                        )
                      ]),
                    ),

//  APPLE SIGNIN

                    // (Platform.isIOS)
                    //     ? SignInButton(Buttons.Apple, onPressed: () async {
                    //         AppStyle().showLoader(context);

                    //         final credential = await SignInWithApple.getAppleIDCredential(
                    //           scopes: [
                    //             AppleIDAuthorizationScopes.email,
                    //             AppleIDAuthorizationScopes.fullName,
                    //           ],
                    //         );

                    //         post(
                    //           Uri.parse(AppStyle().apiUrl + '/api/Account/LoginV2'),
                    //           headers: {'content-type': 'application/json'},
                    //           body: jsonEncode({
                    //             "ExternalIdentifier": credential.userIdentifier,
                    //             "ExternalProviderName": "Apple",
                    //             'Version': AppStyle().appVersion,
                    //             'Platform': AppStyle().platform,
                    //           }),
                    //         ).then((response) async {});
                    //       })
                    //     : Container(),
                    // // Hide Social Login
                    // SignInButton(Buttons.Google, onPressed: () async {
                    //   await signInGoogle();
                    // }),
                    // SignInButton(Buttons.Facebook, onPressed: () async {
                    //   await signInFacebook();
                    // }),

                    Container(
                      height: 5,
                    ),
                  ],
                ))
              : Container(),
        ],
      ),
      //   bottomNavigationBar: FlashyTabBar(
      //     selectedIndex: _selectedIndex,
      //     showElevation: true,
      //     onItemSelected: (index) => setState(() {
      //       _selectedIndex = index;
      //     }),
      //     items: [
      //       FlashyTabBarItem(
      //         icon: Icon(Icons.event),
      //         title: Text('Events'),
      //       ),
      //       FlashyTabBarItem(
      //         icon: Icon(Icons.search),
      //         title: Text('Search'),
      //       ),
      //       FlashyTabBarItem(
      //         icon: Icon(Icons.highlight),
      //         title: Text('Highlight'),
      //       ),
      //       FlashyTabBarItem(
      //         icon: Icon(Icons.settings),
      //         title: Text('Settings'),
      //       ),
      //       FlashyTabBarItem(
      //         icon: Icon(Icons.settings),
      //         title: Text('한국어'),
      //       ),
      //     ],
      //   ),
    );
  }

  // Future<void> signInFacebook() async {
  //   AppStyle().showLoader(context);
  //   final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile
  //   // or FacebookAuth.i.login()
  //   if (result.status == LoginStatus.success) {
  //     // you are logged

  //     final AccessToken accessToken = result.accessToken!;
  //     // accessToken.userId
  //     final userDataFb = await FacebookAuth.instance.getUserData();
  //     if (userDataFb != null) {
  //       post(
  //         Uri.parse(AppStyle().apiUrl + '/api/Account/LoginV2'),
  //         headers: {'content-type': 'application/json'},
  //         body: jsonEncode({
  //           "ExternalIdentifier": accessToken.userId,
  //           "ExternalProviderName": "Facebook",
  //           'Version': AppStyle().appVersion,
  //           'Platform': AppStyle().platform,
  //         }),
  //       ).then((response) async {});
  //     }
  //   } else {
  //     AppStyle().hideLoader(context);
  //     // print(result.status);
  //     // print(result.message);
  //   }
  // }

  // Future<void> signInGoogle() async {
  //   AppStyle().showLoader(context);
  //   try {
  //     _currentUser = await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleAuth = await _currentUser!.authentication;
  //     print(_currentUser);
  //     print(await _currentUser!.authHeaders);
  //     print(await googleAuth.accessToken);
  //     print(await googleAuth.idToken);
  //     if (_currentUser != null) {
  //       post(
  //         Uri.parse(AppStyle().apiUrl + '/api/Account/LoginV2'),
  //         headers: {'content-type': 'application/json'},
  //         body: jsonEncode({
  //           "ExternalIdentifier": _currentUser!.id,
  //           "ExternalProviderName": "Google",
  //           'Version': AppStyle().appVersion,
  //           'Platform': AppStyle().platform,
  //         }),
  //       ).then((response) async {});
  //     }
  //   } catch (error) {
  //     AppStyle().hideLoader(context);
  //     print(error);
  //   }
  // }
}
