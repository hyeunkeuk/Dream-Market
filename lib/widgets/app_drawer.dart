import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/orders_screen.dart';
import 'package:shopping/screens/history_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';
import '../screens/products_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  String username;
  AppDrawer(this.username);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Hello, ' + username + '!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          // ListTile(
          //     leading: Icon(Icons.house),
          //     title: Text('Dream'),
          //     onTap: () {
          //       Navigator.of(context).pushReplacementNamed('/');
          //     }),
          // Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(OrderScreen.routeName);
            },
          ),
          // Divider(),
          // ListTile(
          //   leading: Icon(Icons.history),
          //   title: Text('History'),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).pushNamed(HistoryScreen.routeName);
          //   },
          // ),
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
    );
  }
}
