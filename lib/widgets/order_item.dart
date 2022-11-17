import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';
import 'cart_item.dart';

class OrderItem extends StatefulWidget {
  final String userStatus;
  final String orderId;
  final String status;
  final num amount;
  final String dateTime;
  final String productId;
  final String title;

  OrderItem(this.userStatus, this.orderId, this.status, this.amount,
      this.dateTime, this.productId, this.title);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
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
    // print('im here');
    // print(widget.products);

    String currentStatus = widget.status;
    String newStatus = 'Available';
    if (currentStatus == 'pending') {
      newStatus = 'Sold';
    }
    CollectionReference productList =
        FirebaseFirestore.instance.collection('products');

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
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: widget.status == 'pending' ? Colors.yellow : Colors.green,
              child: widget.status == 'pending'
                  ? Text('Pending...')
                  : Text('Accepted'),
            ),
            title: Text('\$${widget.amount}'),
            subtitle: Text(widget.dateTime),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Column(
              children: [
                widget.userStatus == 'admin'
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                            onPressed: () {
                              updateProductAvailability();
                              setState(() {
                                updateOrderStatus();
                              });
                            },
                            child: widget.status == 'pending'
                                ? Text('Confirm')
                                : Text('Cancel')),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
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
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(false);
                                            },
                                            child: Text('No'),
                                          ),
                                          FlatButton(
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
                            child: Text('Cancel')),
                      ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.amount}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
