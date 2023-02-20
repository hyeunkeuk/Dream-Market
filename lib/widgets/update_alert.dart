import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:store_redirect/store_redirect.dart';
import 'package:shopping/screens/products_overview_screen.dart';

Future<String> versionCheck() async {
  var versionID = await FirebaseFirestore.instance
      .collection('version')
      .doc('versionID')
      .get();
  if (Platform.isAndroid) {
    return versionID['AndroidVersionNumber'];
  } else if (Platform.isIOS) {
    return versionID['iOSVersionNumber'];
  } else {
    return versionID['versionNumber'];
  }
}

Future<void> update_alert(context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        'Update Available!',
      ),
      content: const Text(
        'There is a new version available. Please update to avoid any technical issues.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(false);

            StoreRedirect.redirect(
              androidAppId: "com.vandream.dreammarket",
              iOSAppId: "1664339439",
            );
          },
          child: const Text(
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

Future<void> update_alert_to_main(context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        'Update Available!',
      ),
      content: const Text(
        'There is a new version available. Please update to avoid any technical issues.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(false);

            StoreRedirect.redirect(
              androidAppId: "com.vandream.dreammarket",
              iOSAppId: "1664339439",
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProductOverviewScreen(),
              ),
            );
          },
          child: const Text(
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
