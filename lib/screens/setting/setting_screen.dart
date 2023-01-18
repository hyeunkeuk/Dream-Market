import 'package:flutter/material.dart';
import 'package:shopping/screens/setting/delete_account_screen.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/setting';
  // const SettingScreen({Key key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            tileColor: Colors.red[200],
            onTap: () {
              Navigator.of(context).pushNamed(DeleteAccountScreen.routeName);
            },
            title: Text('Delete Account'),
            trailing: Icon(Icons.arrow_circle_right_outlined),
          ),
        ],
      ),
    );
  }
}
