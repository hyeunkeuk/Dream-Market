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
  final String status;
  final num amount;
  final String dateTime;
  final String productId;
  final String title;
  final Function orderScreenSetstate;

  OrderItem(
    this.userStatus,
    this.orderId,
    this.creatorId,
    this.status,
    this.amount,
    this.dateTime,
    this.productId,
    this.title,
    this.orderScreenSetstate,
  );

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var userData;
  var _isLoading = false;

  var productData;

  void initState() {
    fetchUserData();
    super.initState();
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    // print('---------------------');
    // print('im in fetchUserData');
    // print(widget.orderId);
    // print(widget.creatorId);
    // print(widget.productId);

    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.creatorId)
        .get();
    productData = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateOrderStatus() async {
    String currentStatus = widget.status;
    String newStatus = 'pending';
    if (currentStatus == 'pending') {
      newStatus = 'accepted';
    }
    CollectionReference orderList =
        FirebaseFirestore.instance.collection('orders');
    await orderList.doc(widget.orderId).update({'status': newStatus});
  }

  Future<void> updateProductAvailability() async {
    String currentStatus = widget.status;
    String newStatus = 'Available';
    if (currentStatus == 'pending') {
      newStatus = 'Sold';
    }
    CollectionReference productList =
        FirebaseFirestore.instance.collection('products');

    // Need a Workaround for updating product availability for dream products and normal products
    await productList.doc(widget.productId).update({
      'status': newStatus,
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
                  title: widget.userStatus == 'admin'
                      ? Text(
                          '${userData['firstName']} (${userData['email']})\n${widget.title}\nAmount: \$${widget.amount}')
                      : Text('${widget.title}\nAmount: \$${widget.amount}'),
                  subtitle: Text(widget.dateTime),
                  trailing: widget.userStatus == 'admin'
                      ? IconButton(
                          icon: Icon(_expanded
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _expanded = !_expanded;
                            });
                          },
                        )
                      : IconButton(
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
                            if (productData['type'] == 'market') {
                              updateProductAvailability();
                            }
                            setState(() {
                              updateOrderStatus();
                              _expanded = !_expanded;
                              widget.orderScreenSetstate();
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
