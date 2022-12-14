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
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //     alignment: Alignment.centerLeft,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Text(
                  //         'Pending Orders',
                  //         style: TextStyle(
                  //           // color: Colors.pink.shade300,
                  //           fontSize: 25,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     )),
                  SingleChildScrollView(
                    child: StreamBuilder(
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
                          if (orderSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final orderDocs = orderSnapshot.data.docs;

                          var pendingOrderDocs = new List();
                          var completedOrderDocs = new List();

                          for (var i = 0; i < orderDocs.length; i++) {
                            if (orderDocs[i]['status'] == 'pending') {
                              pendingOrderDocs.add(orderDocs[i]);
                            } else {
                              completedOrderDocs.add(orderDocs[i]);
                            }
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Pending Orders',
                                        style: TextStyle(
                                          // color: Colors.pink.shade300,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                                pendingOrderDocs.length > 0
                                    ? ConstrainedBox(
                                        constraints: new BoxConstraints(
                                          minHeight: 50.0,
                                          maxHeight: 500.0,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: pendingOrderDocs.length,
                                          itemBuilder: (_, i) => OrderItem(
                                            userStatus,
                                            pendingOrderDocs[i].id,
                                            pendingOrderDocs[i]['creatorId'],
                                            pendingOrderDocs[i]['status'],
                                            pendingOrderDocs[i]['amount'],
                                            pendingOrderDocs[i]['dateTime'],
                                            pendingOrderDocs[i]['productId'],
                                            pendingOrderDocs[i]['title'],
                                          ),
                                        ),
                                      )
                                    : Center(
                                        heightFactor: 5,
                                        child: Text(
                                          'No Pending Item',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                Divider(),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Order History',
                                        style: TextStyle(
                                          // color: Colors.pink.shade300,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                                completedOrderDocs.length > 0
                                    ? ConstrainedBox(
                                        constraints: new BoxConstraints(
                                          minHeight: 50.0,
                                          maxHeight: 500.0,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: completedOrderDocs.length,
                                          itemBuilder: (_, i) => OrderItem(
                                            userStatus,
                                            completedOrderDocs[i].id,
                                            completedOrderDocs[i]['creatorId'],
                                            completedOrderDocs[i]['status'],
                                            completedOrderDocs[i]['amount'],
                                            completedOrderDocs[i]['dateTime'],
                                            completedOrderDocs[i]['productId'],
                                            completedOrderDocs[i]['title'],
                                          ),
                                        ),
                                      )
                                    : Center(
                                        heightFactor: 5,
                                        child: Text(
                                          'No Order History',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
