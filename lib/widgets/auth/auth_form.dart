import 'package:flutter/material.dart';
import './pickers/user_image.dart';
import 'dart:io';
import '../../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
    String email,
    String firstName,
    String lastName,
    String password,
    File imageFile,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  AuthMode _authMode = AuthMode.Login;

  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = '';
  String _userFirstName = '';
  String _userLastName = '';
  String _userPassword = '';
  String _confirmUserPassword = '';

  File _userImageFile;

  void _pickedImage(File image) async {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    // if (_userImageFile == null && !_isLogin) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text('Please pick an image'),
    //   ));
    //   return;
    // }
    if (isValid) {
      _formKey.currentState.save();

      // p
      if (_isLogin || _confirmUserPassword == _userPassword) {
        widget.submitFn(
          _userEmail.trim(),
          _userFirstName.trim(),
          _userLastName.trim(),
          _userPassword.trim(),
          _userImageFile,
          _isLogin,
          context,
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Please confirm the password',
            ),
            // content: Text(
            //   'Do you want to remove the item from your products?',
            // ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      if (mounted) {
        setState(() {
          _authMode = AuthMode.Signup;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _authMode = AuthMode.Login;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(10.0),
          ),
      elevation: 8.0,
      margin: EdgeInsets.all(20),
      child: Container(
        // height: _authMode == AuthMode.Signup ? 320 : 260,
        // constraints: BoxConstraints(
        //     minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        // width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // if (!_isLogin) UserImagePicker(_pickedImage),
                    TextFormField(
                      // initialValue: 'gusrb0208@gmail.com',
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
                    if (!_isLogin)
                      TextFormField(
                        autocorrect: false,
                        key: ValueKey('first'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 2) {
                            return 'Please provide your first name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'First Name'),
                        onSaved: (value) {
                          _userFirstName = value;
                        },
                      ),
                    if (!_isLogin)
                      TextFormField(
                        autocorrect: false,
                        key: ValueKey('last'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide your last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'Last Name'),
                        onSaved: (value) {
                          _userLastName = value;
                        },
                      ),
                    // if (!_isLogin)
                    //   TextFormField(
                    //     autocorrect: false,
                    //     // initialValue: 'keuk208',
                    //     key: ValueKey('username'),
                    //     validator: (value) {
                    //       if (value.isEmpty || value.length < 4) {
                    //         return 'Username must be at least 5 charaters long';
                    //       }
                    //       return null;
                    //     },
                    //     decoration: InputDecoration(labelText: 'Username'),
                    //     onSaved: (value) {
                    //       _userFirstName = value;
                    //     },
                    //   ),
                    TextFormField(
                      // initialValue: '890890890'/,
                      key: ValueKey('password'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 charaters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = value;
                      },
                    ),
                    if (!_isLogin)
                      TextFormField(
                        // initialValue: '890890890',
                        key: ValueKey('confirm password'),
                        validator: (value) {
                          // if (value != _userPassword) {
                          //   return 'Please confirm the password';
                          // }
                          return null;
                        },
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        onSaved: (value) {
                          _confirmUserPassword = value;
                        },
                      ),
                    SizedBox(height: 12),
                    if (widget.isLoading) CircularProgressIndicator(),
                    if (!widget.isLoading)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryTextTheme.button.color,
                            textStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text(
                            _isLogin ? 'Login' : 'Signup',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: _trySubmit),
                    if (!widget.isLoading)
                      TextButton(
                        // color: Colors.black,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        // textColor: Theme.of(context).primaryColor,
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'),
                        onPressed: () {
                          _switchAuthMode;
                          if (mounted) {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          }
                        },
                      ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
