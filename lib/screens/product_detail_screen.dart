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

//Call from Product item
class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isMyProduct = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final productData = ModalRoute.of(context).settings.arguments as List;
    final showDream = productData[1];
    final productId = productData[0].toString();
    final cart = Provider.of<Cart>(context);

    final userFavoriteProvider = Provider.of<UserFavorite>(context);
    final pastUserFavoriteList = userFavoriteProvider.userFavoriteList;

    var newUserFavoriteList = pastUserFavoriteList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Dream Market'),
      ),
      body: StreamBuilder(
        stream: productData[1]
            ? FirebaseFirestore.instance
                .collection('dream')
                .doc(productId)
                .snapshots()
            : FirebaseFirestore.instance
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
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
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
                        '\$${productDocs['price']}',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      productDocs['creatorId'] != user.uid
                          ? IconButton(
                              icon: const Icon(
                                Icons.shopping_cart,
                              ),
                              onPressed: () async {
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
                                      FlatButton(
                                        child: Text('Confirm'),
                                        onPressed: () async {
                                          final timestamp = DateTime.now();
                                          print(timestamp);
                                          final orderTimeStamp =
                                              DateFormat('yyyy-MM-dd EEE')
                                                  .add_jm()
                                                  .format(timestamp);
                                          print(orderTimeStamp);

                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .add(
                                            {
                                              'creatorId': user.uid,
                                              'amount': productDocs['price'],
                                              'dateTime': orderTimeStamp,
                                              'title': productDocs['title'],
                                              'productId': productId,
                                              'status': 'pending'
                                            },
                                          );

                                          Navigator.of(ctx).pop(false);

                                          showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                    title: Text(
                                                        'Order Instruction'),
                                                    content: Text(
                                                      'Please send e-Transfer \$${productDocs['price']} to vancouverdreamchurch@gmail.com',
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop(false);
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    OrderScreen
                                                                        .routeName);
                                                          },
                                                          child: Text('Okay'))
                                                    ],
                                                  ));
                                        },
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              color: Theme.of(context).accentColor,
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Icon(Icons.star)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            child: productDocs['creatorId'] == user.uid
                                ? Text('Edit')
                                : Text('Chat'),
                            onPressed: () {
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
                                  : Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: productDocs['creatorId']);
                            }),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Description: ',
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                        Text(
                          productDocs['description'],
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ],
                    ),
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
