import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scr000Signup extends StatefulWidget {
  const Scr000Signup({Key? key}) : super(key: key);

  @override
  _Scr000SignupState createState() => _Scr000SignupState();
}

class _Scr000SignupState extends State<Scr000Signup> {
  Map arguments = {};

  Map obj = {};

  bool loaded = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  bool _passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      loaded = true;
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(
          'Sign up',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Please fill your email and password for create new account.',
                style: TextStyle(fontSize: 18, color: AppStyle().mainBtnTxtColor),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, right: 50, top: 0, bottom: 20),
              child: Image(
                image: AssetImage('assets/images/signup.webp'),
                fit: BoxFit.fill,
                height: size.height * 0.25,
              ),
            ),
            TextField(
              controller: fullnameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                hintText: AppStyle().tr('ชื่อ-นามสกุล'),
                labelText: AppStyle().tr('ชื่อ-นามสกุล'),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                hintText: AppStyle().tr('lb_email'),
                labelText: AppStyle().tr('lb_email'),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
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
              textInputAction: TextInputAction.next,
            ),
            Container(
              height: 15,
            ),
            TextField(
              controller: cpasswordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                hintText: AppStyle().tr('Confirm Password'),
                labelText: AppStyle().tr('Confirm Password'),
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
              textInputAction: TextInputAction.next,
            ),
            Container(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppStyle().bgColor, fixedSize: Size((MediaQuery.of(context).size.width - 60), AppStyle().btnHeight)),
              child: Text(
                AppStyle().tr('lb_next'),
                style: TextStyle(
                  fontSize: AppStyle().btnFontSize,
                ),
              ),
              onPressed: () async {
                if (AppStyle()
                    .validate(context, '/scr004', arguments: {'username': nameController.text, 'password': passwordController.text, 'cpassword': cpasswordController.text})) {
                  AppStyle().showLoader(context);
                  try {
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: nameController.text,
                      password: passwordController.text,
                    )
                        .then((value) async {
                      var user = value.user;
                      AppStyle().session['user'] = user;
                      AppStyle().session['profile'] = {
                        'uid': user?.uid,
                        'displayName': fullnameController.text,
                        'email': user?.email,
                        'photoURL': user?.photoURL,
                        'emailVerified': user?.emailVerified,
                        'phoneNumber': user?.phoneNumber,
                      };
                      await loadUser();
                      AppStyle().hideLoader(context);

                      Navigator.pushReplacementNamed(context, '/scr002', arguments: {'authData': AppStyle().session['profile']});
                    });
                  } on FirebaseAuthException catch (e) {
                    AppStyle().hideLoader(context);
                    if (e.code == 'weak-password') {
                      AppStyle().error_pop(context, 'Error', 'The password provided is too weak.', 'ok');
                    } else if (e.code == 'email-already-in-use') {
                      AppStyle().error_pop(context, 'Error', 'The account already exists for that email.', 'ok');
                    }
                  } catch (e) {
                    AppStyle().hideLoader(context);
                    AppStyle().error_pop(context, 'Error', e.toString(), 'ok');
                  }
                }
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> loadUser() async {
    await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set(AppStyle().session['profile'], SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        AppStyle().session['data'] = documentSnapshot.data();
        await FirebaseFirestore.instance.collection('users').doc(AppStyle().session['user'].uid).set({'FCM': AppStyle().session['FCM']}, SetOptions(merge: true));
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
              } else {
                print("Have Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
              }

              print("Have Company : ${AppStyle().session['company']['name']}  ${AppStyle().session['company']}");
              setState(() {});
            }
          }).catchError((error) {
            // print("Error: $error");
          });
        }
      } else {
        // print('Document does not exist on the database');
      }
    }).catchError((error) {
      // print("Error: $error");
    });
  }
}
