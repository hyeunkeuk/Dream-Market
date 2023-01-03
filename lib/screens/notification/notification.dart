import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

Future<void> initializeFBM(userStatus) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // var initializationSettingsAndroid = AndroidInitializationSettings(
  //     'app_icon'); // <- default icon name is @mipmap/ic_launcher
  // var initializationSettingsIOS = IOSInitializationSettings(
  //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  // var initializationSettings = InitializationSettings(
  //     initializationSettingsAndroid, initializationSettingsIOS);
  // flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: onSelectNotification);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final fbm = FirebaseMessaging.instance;
  //This needs to be changed to be toggled
  if (userStatus == "admin") {
    fbm.subscribeToTopic('orders');
    print("subscribed");
  } else {
    fbm.unsubscribeFromTopic('orders');
    print("unsubscribed");
  }

  NotificationSettings settings = await fbm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // // Get the token each time the application loads
  // String token = await fbm.getToken();

  // // Save the initial token to the database
  // await saveTokenToDatabase(token);

  // // Any time the token refreshes, store this in the database too.
  // fbm.onTokenRefresh.listen(saveTokenToDatabase);

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   Map<String, String> data = message.data;

  //   Owner owner = Owner.fromMap(jsonDecode(data['owner']));
  //   User user = User.fromMap(jsonDecode(data['user']));
  //   Picture picture = Picture.fromMap(jsonDecode(data['picture']));

  //   print('The user ${user.name} liked your picture "${picture.title}"!');
  // });

  //Enabling foreground notification on iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("New Message has arrived: ${message}");
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // channel.description,
              icon: android?.smallIcon,
              // other properties...
            ),
          ));
    }
  });
}
