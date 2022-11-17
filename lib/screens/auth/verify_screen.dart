import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shopping/screens/products_overview_screen.dart';

class VerifyScreen extends StatefulWidget {
  static const routeName = '/verifyEmail';

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  User currentUser = FirebaseAuth.instance.currentUser;
  // User currentUser;

  Timer timer;

  @override
  void initState() {
    currentUser.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // print('hi');
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // print(currentUser);
    await currentUser.reload();
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser.emailVerified) {
      print('verified');
      timer.cancel();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProductOverviewScreen()));
    }
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.pink, Colors.purple],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 1, 1, 1).withOpacity(0.5),
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.7),
                  Color.fromRGBO(255, 255, 51, 1).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                //stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    // transform: Matrix4.rotationZ(-8 * pi / 180)
                    //   ..translate(-10.0),
                    // ..translate(-10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'Verification email has been sent to ${currentUser.email}.\nPlease check your junk mail if you don\'t see the verification email in your mail box.',
                      // style: TextStyle(
                      //   // color: Colors.pink.shade300,
                      //   fontSize: 25,
                      //   fontFamily: 'No_Virus',
                      //   fontWeight: FontWeight.normal,
                      //   foreground: Paint()..shader = linearGradient,
                      // ),
                    ),
                  ),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       print(currentUser);
                  //       print(currentUser.emailVerified);
                  //     },
                  //     child: Text('Check verified')),
                  ElevatedButton(
                      onPressed: () {
                        currentUser
                            .sendEmailVerification()
                            .then((value) => print('verification resent'));
                      },
                      child: Text('Resend the verification email')),
                  ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: Text('Try with other email')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
