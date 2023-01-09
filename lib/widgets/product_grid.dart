import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';
import '../providers/products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_favorite.dart';

class ProductsGrid extends StatefulWidget {
  bool showDream;
  String choosenCategory;
  bool showFavorites;
  ProductsGrid(this.showDream, this.choosenCategory, this.showFavorites);

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  final user = FirebaseAuth.instance.currentUser;

  final CollectionReference userFavoriteList =
      FirebaseFirestore.instance.collection('userFavorites');

  String categoryOption;
  bool showFavorites;

  var isLoading = false;
  var showItem = false;

  @override
  Widget build(BuildContext context) {
    final userFavoriteData = Provider.of<UserFavorite>(context, listen: false);
    final userFavoriteList = userFavoriteData.userFavoriteList;

    categoryOption = widget.choosenCategory;
    var selectedProduct = [];

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('type', isEqualTo: 'market')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final productDocs = productSnapshot.data.docs;
          selectedProduct = [];
          for (int idx = 0; idx < productDocs.length; idx++) {
            if (productDocs[idx]['status'] == 'Available') {
              if (widget.showFavorites &&
                  userFavoriteList.contains(productDocs[idx].id) &&
                  (categoryOption.toString() == 'All' ||
                      productDocs[idx]['category'] ==
                          categoryOption.toString())) {
                selectedProduct.add(productDocs[idx]);
              } else if (!widget.showFavorites &&
                  (categoryOption.toString() == 'All' ||
                      productDocs[idx]['category'] ==
                          categoryOption.toString())) {
                selectedProduct.add(productDocs[idx]);
              }
            }
          }

          if (selectedProduct.length > 0) {
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: selectedProduct.length,
              itemBuilder: (ctx, i) {
                return ProductItem(
                  widget.showDream,
                  selectedProduct[i].id,
                  selectedProduct[i]['category'],
                  selectedProduct[i]['createdAt'],
                  selectedProduct[i]['creatorId'],
                  selectedProduct[i]['creatorName'],
                  selectedProduct[i]['description'],
                  selectedProduct[i]['imageUrl'],
                  selectedProduct[i]['location'],
                  selectedProduct[i]['price'],
                  selectedProduct[i]['status'],
                  selectedProduct[i]['title'],
                  selectedProduct[i]['type'],
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            );
          } else {
            return Center(
              child: const Text(
                'There is no new item.',
              ),
            );
          }
        });
  }
}
