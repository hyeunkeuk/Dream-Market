// import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/screens/account_deleted_screen.dart';
import 'package:shopping/screens/auth/new_auth_screen.dart';
import 'package:shopping/screens/auth/verify_screen.dart';
import 'package:shopping/screens/chat/chat_screen.dart';
import 'package:shopping/screens/chat/search_user_screen.dart';
import 'package:shopping/screens/history_screen.dart';
// import 'package:shopping/screens/chat/chat_screen.dart';
import 'package:shopping/screens/product_detail_screen.dart';
import 'package:shopping/screens/setting/setting_screen.dart';
import 'package:shopping/screens/setting/delete_account_screen.dart';
import 'package:shopping/screens/setting/account_deletion_request_screen.dart';
import '../screens/products_overview_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
// import './screens/auth_screen.dart';
// import './providers/auth.dart';
// import './screens/splash-screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/product.dart';
import './screens/chat/message_inbox_screen.dart';
import './providers/user_favorite.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //For Android only. Handling messages whilst the application is in the background\
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserFavorite(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Product(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Orders(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Dream Square',
        theme: ThemeData(
          buttonColor: Colors.black,
          primarySwatch: Colors.grey,
          primaryTextTheme: TextTheme(
              headline6: TextStyle(
            color: Colors.white,
          )),
          // buttonColor: Colors.pink[400],
          // textTheme: Typography().black,
          primaryColor: Colors.white,
          primaryColorDark: Colors.black,
          // canvasColor: Colors.black,

          // primarySwatch: Colors.blue,
          accentColor: Colors.deepPurple[200],
          fontFamily: 'Lato',
          // primaryTextTheme: Typography().black,
        ),

        // home: NewAuthScreen(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            return NewAuthScreen();

            // if (userSnapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            ////////////////////////////////////////////////////////////////////////////////////
            /*
            This is the main problem
            */
            // if (userSnapshot.hasData) {
            //   print('hasdata');
            //   return ProductOverviewScreen();
            // } else {
            //   return NewAuthScreen();
            // }
            ////////////////////////////////////////////////////////////////////////////////////

            // if (userSnapshot.hasData && userSnapshot.data.emailVerified) {
            //   return ProductOverviewScreen();
            // } else if (userSnapshot.hasData &&
            //     !userSnapshot.data.emailVerified) {
            //   return VerifyScreen();
            // }

            // if (!userSnapshot.hasData) {
            //   print('has no data');
            //   return NewAuthScreen();
            // }

            // return const Center(child: CircularProgressIndicator());
          },
        ),
        routes: {
          ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
          NewAuthScreen.routeName: (ctx) => NewAuthScreen(),
          VerifyScreen.routeName: (ctx) => VerifyScreen(),
          MessageInboxScreen.routeName: (ctx) => MessageInboxScreen(),
          ChatScreen.routeName: (ctx) => ChatScreen(),
          SearchUserScreen.routeName: (ctx) => SearchUserScreen(),
          HistoryScreen.routeName: (ctx) => HistoryScreen(),
          SettingScreen.routeName: (ctx) => SettingScreen(),
          DeleteAccountScreen.routeName: (ctx) => DeleteAccountScreen(),
          AccountDeletedScreen.routeName: (ctx) => AccountDeletedScreen(),
          AccountDeletionRequestScreen.routeName: (ctx) =>
              AccountDeletionRequestScreen(),
        },
      ),
    );
  }
}
