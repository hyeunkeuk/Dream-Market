import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';
import '../providers/products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_favorite.dart';

class DreamProductsGrid extends StatefulWidget {
  bool showDream;
  bool showFavorites;
  DreamProductsGrid(this.showDream, this.showFavorites);

  @override
  State<DreamProductsGrid> createState() => _DreamProductsGridState();
}

class _DreamProductsGridState extends State<DreamProductsGrid> {
  final user = FirebaseAuth.instance.currentUser;

  final CollectionReference userFavoriteList =
      FirebaseFirestore.instance.collection('userFavorites');

  String categoryOption;

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userFavoriteData = Provider.of<UserFavorite>(context, listen: false);
    final userFavoriteList = userFavoriteData.userFavoriteList;
    var selectedProduct = [];

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dream')
            // .where('creatorId', isEqualTo: 'dream')
            .snapshots(),
        builder: (ctx, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting ||
              !productSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final productDocs = productSnapshot.data.docs;

          for (int idx = 0; idx < productDocs.length; idx++) {
            if (widget.showFavorites &&
                userFavoriteList.contains(productDocs[idx].id)) {
              selectedProduct.add(productDocs[idx]);
            } else if (!widget.showFavorites) {
              selectedProduct.add(productDocs[idx]);
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
                  selectedProduct[i]['title'],
                  selectedProduct[i]['price'],
                  selectedProduct[i]['imageUrl'][0],
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
            return Container();
          }
        });
  }
}
