import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping/screens/chat/chat_screen.dart';
import 'package:shopping/screens/edit_product_screen.dart';
import 'package:shopping/screens/orders_screen.dart';
import 'package:shopping/screens/user_products_screen.dart';
import 'package:shopping/widgets/image_scroller.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_favorite.dart';
import '../providers/cart.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shopping/widgets/update_alert.dart';

//Call from Product item
class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String version = '1.1.3';

  bool isMyProduct = false;
  var _isInit = true;
  var _isLoading = true;
  var creator;
  var productId;
  var showDream;
  var creatorId;
  var type;
  final user = FirebaseAuth.instance.currentUser;

  final CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');

  void updateUserCurrentScreen() async {
    usersList.doc(user.uid).update({
      'chattingWith': "",
    });
  }

  @override
  void initState() {
    updateUserCurrentScreen();
    super.initState();
  }

  void didChangeDependencies() async {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
      final productData = ModalRoute.of(context).settings.arguments as List;
      productId = productData[0].toString();
      showDream = productData[1];
      creatorId = productData[2];
      type = productData[3];
      // getAllProducts();
      getUserData().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    super.didChangeDependencies();
  }

  Future<void> getUserData() async {
    creator = await FirebaseFirestore.instance
        .collection('users')
        .doc(creatorId)
        .get();

    // print(userData);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    final userFavoriteProvider = Provider.of<UserFavorite>(context);
    final pastUserFavoriteList = userFavoriteProvider.userFavoriteList;

    var newUserFavoriteList = pastUserFavoriteList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Dream Square'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .snapshots(),
        builder: (ctx, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final productDocs = productSnapshot.data.data();

          if (productDocs.length > 0) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ImageScroller(productDocs),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: IconButton(
                          icon: userFavoriteProvider.isFavorite(
                                  productId, pastUserFavoriteList)
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border),
                          onPressed: () async {
                            setState(() {
                              if (pastUserFavoriteList.contains(productId)) {
                                newUserFavoriteList.remove(productId);
                              } else {
                                newUserFavoriteList.add(productId);
                              }
                              userFavoriteProvider.updateUserFavorite(
                                  user.uid, newUserFavoriteList);
                            });
                          },
                        ),
                      ),
                      Text(
                        '\$${productDocs['price']}      ',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                        ),
                      ),
                      productDocs['creatorId'] != user.uid
                          ? productDocs['status'] == 'Available'
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                  ),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    var versionID = await FirebaseFirestore
                                        .instance
                                        .collection('version')
                                        .doc('versionID')
                                        .get()
                                        .then(
                                      (value) {
                                        var versionNumber =
                                            value['versionNumber'];
                                        if (version != versionNumber) {
                                          update_alert(context);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                'Order Confirmation',
                                              ),
                                              content: Text(
                                                'Do you want to order the following item(s)?',
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () async {
                                                    final timestamp =
                                                        DateTime.now();
                                                    final orderTimeStamp =
                                                        DateFormat(
                                                                'yyyy-MM-dd HH:mm:ss.SSS')
                                                            .add_jm()
                                                            .format(timestamp);

                                                    if (type == 'market') {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'products')
                                                          .doc(productId)
                                                          .update({
                                                        'status': 'Pending',
                                                        'soldTo': user.uid,
                                                      });
                                                    } else {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'products')
                                                          .doc(productId)
                                                          .update({
                                                        'soldTo': user.uid,
                                                      });
                                                    }

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user.uid)
                                                        .get()
                                                        .then((userData) async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('orders')
                                                          .add(
                                                        {
                                                          'creatorId': user.uid,
                                                          'creatorName':
                                                              userData[
                                                                  'firstName'],
                                                          'creatorEmail':
                                                              userData['email'],
                                                          'dateModified':
                                                              orderTimeStamp,
                                                          'amount': productDocs[
                                                              'price'],
                                                          'dateTime':
                                                              orderTimeStamp,
                                                          'title': productDocs[
                                                              'title'],
                                                          'productId':
                                                              productId,
                                                          'productOwnerId':
                                                              productDocs[
                                                                  'creatorId'],
                                                          'status': 'Pending'
                                                        },
                                                      );
                                                    });

                                                    Navigator.of(ctx)
                                                        .pop(false);

                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            'Order Instruction'),
                                                        content: Text(
                                                          'Please send e-Transfer \$${productDocs['price']} to vdcfund@gmail.com',
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop(false);
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      OrderScreen
                                                                          .routeName);
                                                            },
                                                            child: Text(
                                                              'Okay',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx)
                                                        .pop(false);
                                                  },
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.lightGreen),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Pending...'),
                                    ),
                                  ),
                                )
                          : productDocs['status'] == 'Available'
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Icon(Icons.star),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.lightGreen),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Pending...'),
                                    ),
                                  ),
                                ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // _isLoading
                        //     ? CircularProgressIndicator()
                        //     : CircleAvatar(
                        //         backgroundColor: Colors.indigo.shade100,
                        //         backgroundImage: creator['imageUrl'] != null
                        //             ? creator['imageUrl'] != ''
                        //                 ? NetworkImage(creator['imageUrl'])
                        //                 : null
                        //             : null,
                        //       ),
                        _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                '  ${creator['firstName']}',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo.shade300,
                          ),
                          // onHover: (value) {
                          //   st
                          // },
                          child: productDocs['creatorId'] == user.uid
                              ? Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  'Chat',
                                  style: TextStyle(color: Colors.white),
                                ),
                          onPressed: () async {
                            var versionID = await FirebaseFirestore.instance
                                .collection('version')
                                .doc('versionID')
                                .get()
                                .then(
                              (value) async {
                                var versionNumber = value['versionNumber'];
                                if (version != versionNumber) {
                                  update_alert(context);
                                } else {
                                  CollectionReference chatRooms =
                                      FirebaseFirestore.instance
                                          .collection('chatRooms');
                                  productDocs['creatorId'] == user.uid
                                      ? Navigator.of(context).pushNamed(
                                          EditProductScreen.routeName,
                                          arguments: [
                                              productId,
                                              productDocs['title'],
                                              productDocs['imageUrl'],
                                              productDocs['price'],
                                              productDocs['description'],
                                              productDocs['category'],
                                            ])
                                      : await chatRooms
                                          .where('roomParticipants',
                                              arrayContainsAny: [
                                                '${user.uid}_${productDocs['creatorId']}',
                                                '${productDocs['creatorId']}_${user.uid}'
                                              ])
                                          .get()
                                          .then(
                                            (value) {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(
                                                    'REMINDER!',
                                                  ),
                                                  content: Text(
                                                    'Please note that all chat data are being monitored. Do you want to proceed?',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(ctx)
                                                            .pop(false);
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                ChatScreen
                                                                    .routeName,
                                                                arguments: [
                                                              productDocs[
                                                                  'creatorId'],
                                                              value.docs.isEmpty
                                                                  ? ""
                                                                  : value.docs
                                                                      .first.id,
                                                            ]);
                                                      },
                                                      child: Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(ctx)
                                                            .pop(false);
                                                      },
                                                      child: Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 20)
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: new BoxConstraints(
                          minHeight: 150,
                          minWidth: double.infinity,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Description: ',
                              //   textAlign: TextAlign.start,
                              //   softWrap: true,
                              // ),
                              SelectableText(
                                productDocs['description'],
                                // textAlign: TextAlign.center,
                                // softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
