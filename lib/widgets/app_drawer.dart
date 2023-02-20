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
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shopping/widgets/update_alert.dart';

class AppDrawer extends StatefulWidget {
  String username;
  String userStatus;

  AppDrawer(
    this.username,
    this.userStatus,
  );

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String version = '1.1.3';
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // TODO: implement didChangeDependencies
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'Hello, ' + widget.username + '!',
                // softWrap: true,
                overflow: TextOverflow.fade,
              ),
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('QT'),
              onTap: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(QTScreen.routeName);

                var versionNumber = await versionCheck();
                if (version != versionNumber) {
                  update_alert(context);
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Orders'),
              onTap: () async {
                Navigator.of(context).pop();
                var versionNumber = await versionCheck();
                if (version != versionNumber) {
                  update_alert(context);
                } else {
                  Navigator.of(context).pushNamed(OrderScreen.routeName);
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Product'),
              onTap: () async {
                Navigator.of(context).pop();
                var versionNumber = await versionCheck();
                if (version != versionNumber) {
                  update_alert(context);
                } else {
                  Navigator.of(context).pushNamed(UserProductsScreen.routeName);
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(SettingScreen.routeName);

                var versionNumber = await versionCheck();
                if (version != versionNumber) {
                  update_alert(context);
                }
              },
            ),
            widget.userStatus == 'admin' ? Divider() : SizedBox.shrink(),
            widget.userStatus == 'admin'
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
                FirebaseAuth.instance.signOut().then(
                      (_) => Navigator.of(context).pushReplacementNamed('/'),
                    );
              },
            ),
            Text(
              'Version: ${version}',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
