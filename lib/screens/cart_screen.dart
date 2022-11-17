import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    var title;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        // color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                  cart.items.values.toList()[i].id,
                  cart.items.keys.toList()[i],
                  cart.items.values.toList()[i].price,
                  cart.items.values.toList()[i].quantity,
                  cart.items.values.toList()[i].title,
                  cart.items.values.toList()[i].imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var user = FirebaseAuth.instance.currentUser;
  var _isloading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isloading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isloading)
          ? null
          : () async {
              setState(() {
                _isloading = true;
              });
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
                        await Provider.of<Orders>(context, listen: false)
                            .addOrder(
                          user.uid,
                          widget.cart.items.values.toList(),
                          widget.cart.totalAmount,
                        );

                        Navigator.of(ctx).pop(false);

                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: Text('Order Instruction'),
                                  content: Text(
                                    'Please send e-Transfer \$${widget.cart.totalAmount} to vancouverdreamchurch@gmail.com',
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: Text('Okay'))
                                  ],
                                )).then((value) => widget.cart.clear());
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

              setState(() {
                _isloading = false;
              });
            },
      // textColor: Colors.black,
      // textColor: Theme.of(context).primaryColor,
    );
  }
}
