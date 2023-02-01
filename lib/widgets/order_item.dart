import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';
import 'cart_item.dart';
import 'package:shopping/screens/orders_screen.dart' as orderScreen;

class OrderItem extends StatefulWidget {
  final String userStatus;
  final String orderId;
  final String creatorId;
  final String creatorName;
  final String creatorEmail;
  final String status;
  final num amount;
  final String dateTime;
  final String dateModified;
  final String productId;
  final String title;
  final Function orderScreenSetstate;

  OrderItem(
    this.userStatus,
    this.orderId,
    this.creatorId,
    this.creatorName,
    this.creatorEmail,
    this.status,
    this.amount,
    this.dateTime,
    this.dateModified,
    this.productId,
    this.title,
    this.orderScreenSetstate,
  );

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  // var userData;
  var _isLoading = false;
  var _isInit = true;
  var productData;
  var newOrderStatus;

  void didChangeDependencies() {
    if (_isInit) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // getAllProducts();
      fetchProductData().then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    super.didChangeDependencies();
  }

  Future<void> fetchProductData() async {
    // userData = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(widget.creatorId)
    //     .get();
    // print('---------------');
    // print(widget.productId);
    productData = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  Future<void> updateOrderStatus() async {
    newOrderStatus = widget.status == 'pending' ? 'accepted' : 'pending';
    // String previousOrderStatus = widget.status;
    // String newStatus = 'pending';
    // if (previousOrderStatus == 'pending') {
    //   newStatus = 'accepted';
    // }
    CollectionReference orderList =
        FirebaseFirestore.instance.collection('orders');

    final timestamp = DateTime.now();
    final modifiedTimeStamp =
        DateFormat("yyyy-MM-dd HH:mm:ss.SSS").add_jm().format(timestamp);
    await orderList.doc(widget.orderId).update({
      'status': newOrderStatus,
      'dateModified': modifiedTimeStamp,
    });
  }

  Future<void> updateProductAvailability() async {
    // print('newOrderStatus = ${newOrderStatus}');

    String newProductStatus =
        newOrderStatus == 'pending' ? 'Available' : 'Sold';
    // print('newProductStatus = ${newProductStatus}');

    // String currentStatus = widget.status;
    // String newStatus = 'Available';
    // if (currentStatus == 'pending') {
    //   newStatus = 'Sold';
    // }
    CollectionReference productList =
        FirebaseFirestore.instance.collection('products');
    print('widget.productId: ${widget.productId}');
    // Need a Workaround for updating product availability for dream products and normal products
    await productList.doc(widget.productId).update({
      'status': newProductStatus,
    });
  }

  Future<void> deleteOrder() async {
    CollectionReference orderList =
        FirebaseFirestore.instance.collection('orders');
    await orderList.doc(widget.orderId).delete();
  }

  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    // print(_isLoading);
    // print(widget.orderId);
    // print(widget.creatorId);
    // print(userData['firstName']);

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    color: widget.status == 'pending'
                        ? Colors.yellow
                        : Colors.green,
                    child: widget.status == 'pending'
                        ? Text(
                            'Pending...',
                          )
                        : Text(
                            'Accepted',
                          ),
                  ),
                  title: widget.userStatus == 'dreamer'
                      ? Text('${widget.title}\nAmount: \$${widget.amount}')
                      : Text(
                          '${widget.creatorName} (${widget.creatorEmail})\n${widget.title}\nAmount: \$${widget.amount}'),
                  subtitle: Text(
                      "${widget.dateModified.substring(0, 10)} ${widget.dateModified.substring(24)}"),
                  trailing: widget.userStatus == 'dreamer'
                      ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: widget.status == 'pending'
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        'Are you sure?',
                                      ),
                                      content: Text(
                                        'Do you want to cancel the order?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(ctx).pop(false);
                                            try {
                                              setState(() {
                                                deleteOrder();
                                              });
                                            } catch (error) {}
                                          },
                                          child: Text(
                                            'Confirm',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop(false);
                                          },
                                          child: Text(
                                            'No',
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
                              : null,
                        )
                      : IconButton(
                          icon: Icon(_expanded
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _expanded = !_expanded;
                            });
                          },
                        ),
                ),
                if (_expanded)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: ElevatedButton(
                          style: widget.status == 'pending'
                              ? ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                )
                              : ElevatedButton.styleFrom(
                                  primary: Colors.grey,
                                ),
                          onPressed: () {
                            // Only update the product availability if the product is a market product

                            setState(() {
                              fetchProductData().then((value) {
                                updateOrderStatus().then((value) {
                                  print(
                                      'productData[title]:${productData['title']}');
                                  print(
                                      'productData[type]:${productData['type']}');
                                  if (productData['type'] == 'market') {
                                    updateProductAvailability();
                                  }
                                  _expanded = !_expanded;
                                });

                                widget.orderScreenSetstate();
                              });
                            });
                          },
                          child: widget.status == 'pending'
                              ? Text(
                                  'Confirm',
                                )
                              : Text(
                                  'Cancel',
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: widget.status == 'pending'
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                      'Are you sure?',
                                    ),
                                    content: Text(
                                      'Do you want to cancel the order?',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(ctx).pop(false);
                                          try {
                                            setState(() {
                                              deleteOrder();
                                              widget.orderScreenSetstate();
                                            });
                                          } catch (error) {}
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  )
              ],
            ),
          );
  }
}
