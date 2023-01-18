import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopping/screens/account_deleted_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const routeName = '/deleteAccount';
  const DeleteAccountScreen({Key key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;
  var _isInit = true;
  var userData;

  final user = FirebaseAuth.instance.currentUser;

  void didChangeDependencies() {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // getAllProducts();
      getUserData().then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    super.didChangeDependencies();
  }

  Future<void> getUserData() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // print(userData);
  }

  Future<void> updateUserStatus() async {
    CollectionReference orderList =
        FirebaseFirestore.instance.collection('users');

    await orderList.doc(user.uid).update({
      'status': 'deleted',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Delete Account'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(userData['firstName']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber),
                      Text(
                        'Deleting your account is permanent',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'Your profile, posts and \n chat data will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_outlined),
                      Text(
                        '2-3 business days required',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'It may take 2-3 business days to delete \n your account and all of your data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                    child: Text('Delete Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[200],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'This action is irreverible!',
                          ),
                          content: Text('Do you want to delete your account?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                Navigator.of(ctx).pop(false);
                                final timestamp = DateTime.now();
                                final orderTimeStamp =
                                    DateFormat('yyyy-MM-dd HH:mm:ss.SSS')
                                        .add_jm()
                                        .format(timestamp);
                                FirebaseFirestore.instance
                                    .collection('delete')
                                    .add(
                                  {
                                    'requesterId': user.uid,
                                    'requesterName': userData['firstName'],
                                    'requesterEmail': userData['email'],
                                    'dateTime': orderTimeStamp,
                                  },
                                );
                                updateUserStatus();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                      'Account Successfully Deleted',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Okay',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(ctx).pop(false);
                                          FirebaseAuth.instance.signOut().then(
                                                (_) => Navigator.of(context)
                                                    .pushReplacementNamed('/'),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                              child: Text(
                                'No',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
