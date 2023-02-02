import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping/screens/auth/verify_screen.dart';
import 'package:shopping/screens/products_overview_screen.dart';
import '../../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewAuthScreen extends StatefulWidget {
  static const routeName = '/newAuth';
  @override
  _NewAuthScreenState createState() => _NewAuthScreenState();
}

class _NewAuthScreenState extends State<NewAuthScreen> {
  final _auth = FirebaseAuth.instance;

  var _isLoading = false;

  @override
  void initState() {
    ////////////////////////////////////////////////////////////////////////////////////
    /*
    This is the main problem
    */
    // if (_auth.currentUser != null && _auth.currentUser.emailVerified) {
    //   Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (context) => ProductOverviewScreen()));
    // }
    super.initState();
  }

  void _submitAuthForm(
    String email,
    String firstName,
    String lastName,
    String password,
    File imageFile,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      if (isLogin) {
        try {
          authResult = await _auth
              .signInWithEmailAndPassword(email: email, password: password)
              .then((value) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProductOverviewScreen(),
              ),
            );
          });
        } catch (error) {
          String errorMessage = error.message.toString();
          if (errorMessage.contains('password is invalid')) {
            errorMessage = 'The password is incorrect. Please try again.';
          }
          print(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        var url = '';
        if (imageFile != null) {
          await ref.putFile(imageFile);

          final url = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'chattingWith': '',
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'imageUrl': url,
          'status': 'dreamer',
        }).then((value) => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => VerifyScreen())));
      }
    } on PlatformException catch (error) {
      var errorMessage = 'An error occurred, please check your credentials!';

      if (error != null) {
        errorMessage = error.message;
      } else {
        print('error is null');
      }
      // print('hi');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      String errorMessage = error.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.pink, Colors.purple],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

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
                  Color.fromRGBO(101, 0, 201, 1),
                  Color.fromRGBO(101, 0, 201, 1).withOpacity(0.9),
                  Color.fromRGBO(235, 52, 79, 1),
                  Color.fromRGBO(235, 52, 79, 1),
                  Color.fromRGBO(255, 127, 8, 1).withOpacity(1),
                  Color.fromRGBO(255, 218, 105, 1).withOpacity(1),
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
                  Flexible(
                    flex: 1,
                    child: Container(
                      // margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
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
                        'Dream Square',
                        style: TextStyle(
                          // color: Colors.pink.shade300,
                          fontSize: 25,
                          fontFamily: 'No_Virus',
                          fontWeight: FontWeight.normal,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: AuthForm(
                      _submitAuthForm,
                      _isLoading,
                    ),
                  ),
                  Text(
                    'Version: 1.1.2',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
