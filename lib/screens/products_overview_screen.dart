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
import 'notification/notification.dart';

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

class ProductOverviewScreen extends StatefulWidget {
  @override
  static const routeName = '/productoverview';

  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showDream = true;
  var _showFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  final user = FirebaseAuth.instance.currentUser;
  var userData;

  final products = FirebaseFirestore.instance.collection('products');
  var dreamProductData;
  var marketProductData;

  @override
  void initState() {
    // initializeFBM();

    super.initState();
  }

  Future<void> getUserData() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // print(userData);
  }

  Future<void> getAllProducts() async {
    var dreamProductData =
        products.where('type', isEqualTo: 'dream').snapshots();
    var marketProductData =
        products.where('type', isEqualTo: 'market').snapshots();
    // print('dream: ${dreamProductData}');
  }

  // @override
  void didChangeDependencies() {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // getAllProducts();
      getUserData().then((value) {
        initializeFBM(userData['status']).then((value) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
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
              Tab(icon: Icon(Icons.volunteer_activism)),
              Tab(icon: Icon(Icons.store_mall_directory_outlined)),
            ],
          ),
          title: const Text(
            'Dream Square',
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
                : AppDrawer(userData['firstName']),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  ProductsGrid(false, choosenCategoryToSting, _showFavorites),
                  DreamProductsGrid(true, _showFavorites),
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
