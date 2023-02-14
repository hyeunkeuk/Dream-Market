import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/products.dart';
import '../widgets/user_product_item.dart';
// import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user_product_screen';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  var userStatus;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    _isLoading = true;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userStatus = userData['status'];
    });
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Your Products'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'REMINDER!',
                    ),
                    content: SizedBox(
                      height: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please note that you are donating your item to Vancouver Dream Church.',
                          ),
                          Text(
                            '\nAll the profit of your item goes to Vancouver Dream Church.',
                          ),
                          Text(
                            '\nDo you agree?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop(false);
                          Navigator.of(context)
                              .pushNamed(EditProductScreen.routeName);
                        },
                        child: Text(
                          'I Agree',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text(
                          'No',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        // drawer: AppDrawer(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    userStatus == 'admin'
                        ? Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Dream',
                                      style: TextStyle(
                                        // color: Colors.pink.shade300,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              SingleChildScrollView(
                                child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('products')
                                        .where('type', isEqualTo: 'dream')
                                        .orderBy('status')
                                        .snapshots(),
                                    builder: (ctx, productSnapshot) {
                                      if (productSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final productDocs =
                                          productSnapshot.data.docs;
                                      if (productDocs.length > 0) {
                                        return SingleChildScrollView(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: productDocs.length,
                                            itemBuilder: (_, i) {
                                              return Column(
                                                children: [
                                                  UserProductItem(
                                                    userStatus,
                                                    true,
                                                    productDocs[i].id,
                                                    productDocs[i]['category'],
                                                    productDocs[i]['createdAt'],
                                                    productDocs[i]['creatorId'],
                                                    productDocs[i]
                                                        ['description'],
                                                    productDocs[i]['imageUrl'],
                                                    productDocs[i]['location'],
                                                    productDocs[i]['price'],
                                                    productDocs[i]['status'],
                                                    productDocs[i]['title'],
                                                    productDocs[i]['type'],
                                                    productDocs[i]
                                                            .data()
                                                            .containsKey(
                                                                'soldTo')
                                                        ? productDocs[i]
                                                            ['soldTo']
                                                        : '',
                                                  ),
                                                  Divider(),
                                                ],
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                            ],
                          )
                        : Container(), //Don't show admin part on normal user screen
                    Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Products',
                                style: TextStyle(
                                  // color: Colors.pink.shade300,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                        SingleChildScrollView(
                          child: StreamBuilder(
                              stream: userStatus == 'admin'
                                  ? FirebaseFirestore.instance
                                      .collection('products')
                                      .where('type', isEqualTo: 'market')
                                      .orderBy('status')
                                      .snapshots()
                                  : FirebaseFirestore.instance
                                      .collection('products')
                                      .where('creatorId', isEqualTo: user.uid)
                                      .orderBy('status')
                                      .snapshots(),
                              builder: (ctx, productSnapshot) {
                                if (productSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final productDocs = productSnapshot.data.docs;
                                if (productDocs.length > 0) {
                                  return ConstrainedBox(
                                    constraints: new BoxConstraints(
                                      minHeight: 50.0,
                                      maxHeight: 500.0,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: productDocs.length,
                                      itemBuilder: (_, i) => Column(
                                        children: [
                                          UserProductItem(
                                            userStatus,
                                            false,
                                            productDocs[i].id,
                                            productDocs[i]['category'],
                                            productDocs[i]['createdAt'],
                                            productDocs[i]['creatorId'],
                                            productDocs[i]['description'],
                                            productDocs[i]['imageUrl'],
                                            productDocs[i]['location'],
                                            productDocs[i]['price'],
                                            productDocs[i]['status'],
                                            productDocs[i]['title'],
                                            productDocs[i]['type'],
                                            productDocs[i]
                                                    .data()
                                                    .containsKey('soldTo')
                                                ? productDocs[i]['soldTo']
                                                : '',
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    child: Text('Please add a new product.'),
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }
}
