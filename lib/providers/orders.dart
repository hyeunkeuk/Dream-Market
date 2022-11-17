import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  // final String userId;
  Orders();
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders(String uid) async {
    final List<OrderItem> loadedOrders = [];
    try {
      final extractedData = await FirebaseFirestore.instance
          .collection('orders')
          .where('creatorId', isEqualTo: uid)
          .snapshots();
      print('im here in fetch and set orders' + extractedData.toString());
      if (extractedData == null) {
        return;
      }
    } catch (error) {
      print(error);
    }
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(
      String uid, List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    await FirebaseFirestore.instance.collection('orders').add(
      {
        'creatorId': uid,
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
        'status': 'pending'
      },
    );

    try {
      _orders.insert(
        0,
        OrderItem(
          id: uid,
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
