import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetScreen extends StatefulWidget {
  // const PasswordResetScreen({Key key}) : super(key: key);
  static const routename = '/passwordReset';
  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final firebaseAuth = FirebaseAuth.instance;
  var _userEmail;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
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
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(20.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 40.0),
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
                        child: Column(
                          children: [
                            Text(
                              'Enter your email to reset your password.',
                              style: TextStyle(
                                // fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _emailController,
                                key: ValueKey('email'),
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                ),
                                onSaved: (value) {
                                  _userEmail = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final isValid = _formKey.currentState.validate();
                      // FocusScope.of(context).unfocus();
                      if (isValid) {
                        _formKey.currentState.save();
                        firebaseAuth
                            .sendPasswordResetEmail(email: _userEmail)
                            .then(
                          (value) {
                            print('successful');
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  'Password reset has been requested',
                                ),
                                content: Text(
                                  'Follow the link which has been sent to your email (${_userEmail}) to reset your password and try logging in again. \n\nPlease check your junk mail if you don\'t see the password reset email in your mail box.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                    child: Text(
                                      'Okay',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).catchError(
                          (err) {
                            print('error');

                            if (err.toString().contains('invalid-email')) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    'Invalid Email',
                                  ),
                                  content: Text(
                                    'The email address is badly formatted. Please check if you submitted the correct email address.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: Text(
                                        'Okay',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (err
                                .toString()
                                .contains('user-not-found')) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    'No Users Found',
                                  ),
                                  content: Text(
                                    'The email address you entered is not registered. Please check if you submitted the correct email address.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: Text(
                                        'Okay',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    'Error!',
                                  ),
                                  content: Text(
                                    '${err}',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: Text(
                                        'Okay',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        print('not valid');
                      }
                    },
                    child: Text('Request Password Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[200],
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: Text('Back to Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 248, 209, 104),
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
