import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_favorite.dart';

//calls from product grid item
class ProductItem extends StatefulWidget {
  final bool showDream;
  final String id;
  final String title;
  final num price;
  final String imageUrl;

  ProductItem(
    this.showDream,
    this.id,
    this.title,
    this.price,
    this.imageUrl,
  );

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference userFavoriteList =
      FirebaseFirestore.instance.collection('userFavorites');
  CollectionReference productList;
  bool isLoading = false;
  String categoryOption;
  List<String> pastUserFavoriteList = [];

  var productData;
  var creator;

  var _isLoading = false;

  @override
  void initState() {
    fetchProductData();
    super.initState();
  }

  Future<void> fetchProductData() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.showDream) {
      productList = FirebaseFirestore.instance.collection('dream');
    } else {
      productList = FirebaseFirestore.instance.collection('products');
    }

    productData = await productList.doc(widget.id).get();
    creator = await FirebaseFirestore.instance
        .collection('users')
        .doc(productData['creatorId'])
        .get();
    // print(creator['name']);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final userFavoriteProvider = Provider.of<UserFavorite>(context);
    final pastUserFavoriteList = userFavoriteProvider.userFavoriteList;

    var newUserFavoriteList = pastUserFavoriteList;
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridTile(
              header: productData['creatorId'] != 'dream'
                  ? GridTileBar(
                      backgroundColor: Colors.black54,
                      leading: Row(
                        children: [
                          if (productData['creatorId'] != 'dream')
                            Text(
                              creator['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      title: Text(
                          ""), // provide empty space in the middle at the top banner
                      trailing: productData['creatorId'] != 'dream'
                          ? Text(
                              productData['location'],
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white),
                            )
                          : null,
                      // title: Text(
                      //   widget.title,
                      //   textAlign: TextAlign.center,
                      // ),
                    )
                  : null,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ProductDetailScreen.routeName,
                    arguments: [widget.id, widget.showDream],
                  );
                },
                child: widget.imageUrl != ''
                    ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                    : const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Image Not Available',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
              footer: GridTileBar(
                backgroundColor: Colors.black54,
                leading: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.price.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                ),
                trailing: IconButton(
                  icon: userFavoriteProvider.isFavorite(
                          widget.id, pastUserFavoriteList)
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () async {
                    setState(() {
                      if (pastUserFavoriteList.contains(widget.id)) {
                        newUserFavoriteList.remove(widget.id);
                      } else {
                        newUserFavoriteList.add(widget.id);
                      }
                      userFavoriteProvider.updateUserFavorite(
                          user.uid, newUserFavoriteList);
                    });
                  },
                ),
              ),
            ),
          );
  }
}
