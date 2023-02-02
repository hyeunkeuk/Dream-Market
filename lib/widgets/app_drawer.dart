import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/orders_screen.dart';
import 'package:shopping/screens/history_screen.dart';
import 'package:shopping/screens/setting/setting_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';
import '../screens/products_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping/screens/setting/account_deletion_request_screen.dart';
import 'package:shopping/screens/qt/qt_screen.dart';

class AppDrawer extends StatelessWidget {
  String username;
  String userStatus;
  AppDrawer(
    this.username,
    this.userStatus,
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'Hello, ' + username + '!',
                // softWrap: true,
                overflow: TextOverflow.fade,
              ),
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('QT'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(QTScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Orders'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(OrderScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Product'),
              onTap: () {
                Navigator.of(context).pop();

                Navigator.of(context).pushNamed(UserProductsScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {
                Navigator.of(context).pop();

                Navigator.of(context).pushNamed(SettingScreen.routeName);
              },
            ),
            userStatus == 'admin' ? Divider() : SizedBox.shrink(),
            userStatus == 'admin'
                ? ListTile(
                    leading: Icon(Icons.admin_panel_settings_sharp),
                    title: Text('Account Deletion Requests'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamed(AccountDeletionRequestScreen.routeName);
                    },
                  )
                : SizedBox.shrink(),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Navigator.of(context).pushReplacementNamed('/');
                // Navigator.of(context).pop();
                // FirebaseAuth.instance.signOut();
                FirebaseAuth.instance.signOut().then(
                      (_) => Navigator.of(context).pushReplacementNamed('/'),
                    );
                // Navigator.of(context)
                //     .pushReplacementNamed('/')
                //     .then((value) => FirebaseAuth.instance.signOut());

                // Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
