import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:betty/util/style.dart';

class Scr00DeleteUser extends StatefulWidget {
  const Scr00DeleteUser({Key? key}) : super(key: key);

  @override
  _Scr00DeleteUserState createState() => _Scr00DeleteUserState();
}

class _Scr00DeleteUserState extends State<Scr00DeleteUser> {
  Map arguments = {};

  Map obj = {};
  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Size size = MediaQuery.of(context).size;

    if (!loaded) {
      setState(() {
//        obj = arguments['data'];
      });
      loaded = true;
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Delete Your Account'),
        backgroundColor: Colors.red,
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Icon(
          Icons.delete_forever_rounded,
          size: 250,
          color: Colors.red,
        ),
        Text(
          'Warning',
          style: TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Do you want to delete your account ?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('Your data in account will deleted permanently'),
        Text('and cannot to restore back.'),
        SizedBox(
          height: 60,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(fixedSize: Size((MediaQuery.of(context).size.width - 80), AppStyle().btnHeight), primary: Colors.red),
          child: Text(
            AppStyle().tr('Yes, Delete this account'),
            style: TextStyle(
              fontSize: AppStyle().btnFontSize,
            ),
          ),
          onPressed: () async {
            String email = AppStyle().session['profile']['email'];
            String password = await AppStyle().confirmData(context, "", "Confirm your password to delete");
            AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
            await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
            try {
              await FirebaseAuth.instance.currentUser!.delete();
              AppStyle().showSnackBar(context, 'Account has been deleted', Colors.amber);
              Navigator.pushNamedAndRemoveUntil(context, '/scr001', (r) => false);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'requires-recent-login') {
                print('The user must reauthenticate before this operation can be executed.');
              } else {
                print(e.code);
              }
              AppStyle().showSnackBar(context, e.message ?? 'Error', Colors.red);
            }
          },
        ),
        SizedBox(
          height: 80,
        ),
      ])),
    );
  }
}
