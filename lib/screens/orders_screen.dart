import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference userList = FirebaseFirestore.instance.collection('users');
  var userData;
  var userStatus;
  bool _isLoading = false;
  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    userData = await userList.doc(user.uid).get();
    userStatus = userData['status'];
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Your Orders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: userStatus == 'admin'
                  ? FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('dateTime', descending: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('orders')
                      .where('creatorId', isEqualTo: user.uid)
                      .orderBy('dateTime', descending: true)
                      .snapshots(),
              builder: (ctx, orderSnapshot) {
                if (orderSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orderDocs = orderSnapshot.data.docs;
                if (orderDocs.length > 0) {
                  return ListView.builder(
                    itemCount: orderDocs.length,
                    itemBuilder: (_, i) => OrderItem(
                      userStatus,
                      orderDocs[i].id,
                      orderDocs[i]['creatorId'],
                      orderDocs[i]['status'],
                      orderDocs[i]['amount'],
                      orderDocs[i]['dateTime'],
                      orderDocs[i]['productId'],
                      orderDocs[i]['title'],
                    ),
                  );
                } else {
                  return Container();
                }
              }),
    );
  }
}
