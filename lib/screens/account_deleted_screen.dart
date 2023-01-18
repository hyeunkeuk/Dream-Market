import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletedScreen extends StatelessWidget {
  static const routeName = '/accountDeleted';
  // const AccountDeletedScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(child: Text('Account Deleted')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your account is deleted',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
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
              child: Text('Logout'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then(
                      (_) => Navigator.of(context).pushReplacementNamed('/'),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[200],
              ),
            )
          ],
        ),
      ),
    );
  }
}
