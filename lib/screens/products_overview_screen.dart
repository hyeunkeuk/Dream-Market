import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shopping/screens/chat/message_inbox_screen.dart';
import '../widgets/product_grid.dart';
import '../widgets/dream_product_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum MarketOptions {
  Dream,
  Market,
}

enum FilterOptions {
  Favourties,
  Dream,
  All,
}
enum Categories {
  All,
  Baby,
  Clothes,
  Electronics,
  Foods,
  Furnitures,
  Others,
}

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

Future<void> initializeFBM() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final fbm = FirebaseMessaging.instance;

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

  //This needs to be changed to be toggled
  fbm.subscribeToTopic('products');
  //Enabling foreground notification on iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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

class ProductOverviewScreen extends StatefulWidget {
  @override
  static const routeName = '/productoverview';

  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showDream = true;
  var _showFavorites = false;
  var _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;
  var userData;
  var _isInit = true;

  @override
  void initState() {
    initializeFBM();
    super.initState();
  }

  Future<void> getUsername() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    // print(userData);
  }

  // @override
  void didChangeDependencies() {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      getUsername().then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    super.didChangeDependencies();
  }

  Categories choosenCategory = Categories.All;
  String choosenCategoryToSting = 'All';

  Color backGroundColor = Colors.purple[200];
  @override
  Widget build(BuildContext context) {
    choosenCategoryToSting = choosenCategoryToSting;
    // final productsContainer = Provider.of<Products>(context, listen: false);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        // backgroundColor: Colors.black,
        appBar: AppBar(
          // shape: ShapeBorder(),
          backgroundColor: Theme.of(context).primaryColor,
          // toolbarOpacity: 0.5,
          // foregroundColor: Colors.purple[200],
          titleSpacing: 0,
          bottom: TabBar(
            labelColor: Colors.purple[900],
            isScrollable: false,
            onTap: (index) {},
            tabs: const [
              Tab(icon: Icon(Icons.store_mall_directory_outlined)),
              Tab(icon: Icon(Icons.volunteer_activism)),
            ],
          ),
          title: const Text(
            'Dream Market',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (Categories selectedValue) {
                if (mounted) {
                  setState(() {
                    choosenCategory = selectedValue;
                    choosenCategoryToSting = choosenCategory.toString();
                    choosenCategoryToSting =
                        choosenCategoryToSting.replaceAll('Categories.', '');
                  });
                }
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Show All'),
                  value: Categories.All,
                ),
                PopupMenuItem(
                  child: Text('Baby & Kids'),
                  value: Categories.Baby,
                ),
                PopupMenuItem(
                  child: Text('Clothes'),
                  value: Categories.Clothes,
                ),
                PopupMenuItem(
                  child: Text('Electronics'),
                  value: Categories.Electronics,
                ),
                PopupMenuItem(
                  child: Text('Foods'),
                  value: Categories.Foods,
                ),
                PopupMenuItem(
                  child: Text('Furnitures'),
                  value: Categories.Furnitures,
                ),
                PopupMenuItem(
                  child: Text('Others'),
                  value: Categories.Others,
                ),
              ],
            ),
            ElevatedButton(
              child: IconButton(
                icon: Icon(
                  Icons.mail_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(MessageInboxScreen.routeName);
                },
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
                // padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(right: 8.0),
            //   child: Consumer<Cart>(
            //     builder: (_, cart, ch) => Badge(
            //       child: ch,
            //       value: cart.itemCount.toString(),
            //     ),
            //     child: IconButton(
            //       icon: Icon(
            //         Icons.shopping_cart,
            //       ),
            //       onPressed: () {
            //         Navigator.of(context).pushNamed(CartScreen.routeName);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
        drawer: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            // : AppDrawer('Dreamer'),
            : userData == null
                ? AppDrawer('Dreamer')
                : AppDrawer(userData['name']),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  DreamProductsGrid(true, _showFavorites),
                  ProductsGrid(false, choosenCategoryToSting, _showFavorites),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          // tooltip: 'hi',
          child: _showFavorites
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          onPressed: () {
            if (mounted) {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            }
          },
        ),
      ),
    );
  }
}
