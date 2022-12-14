import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
// import 'dart:io';

//Call from user product screen
class UserProductItem extends StatelessWidget {
  final bool isDreamProduct;
  final String id;
  final String category;
  final Timestamp createdAt;
  final String creatorId;
  final String description;
  final List imageUrl;
  final String location;
  final num price;
  final String status;
  final String title;
  final String type;

  UserProductItem(
    this.isDreamProduct,
    this.id,
    this.category,
    this.createdAt,
    this.creatorId,
    this.description,
    this.imageUrl,
    this.location,
    this.price,
    this.status,
    this.title,
    this.type,
  );

  @override
  Widget build(BuildContext context) {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    var storageReference =
        FirebaseStorage.instance.ref().child('product_image');

    // if (isDreamProduct) {
    //   products = FirebaseFirestore.instance.collection('dream');
    //   storageReference =
    //       FirebaseStorage.instance.ref().child('dream_image/${id}');
    // }

    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundImage: imageUrl[0] != null
                  ? imageUrl[0] != ''
                      ? NetworkImage(imageUrl[0])
                      : null
                  : null,
            ),
          ),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        color: status == 'Available' ? Colors.green : Colors.red,
        child: status == 'Available' ? Text('Available') : Text('Sold'),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.black,
              // color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: [
                  id,
                  title,
                  imageUrl,
                  price,
                  description,
                  category,
                ]);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'Are you sure?',
                    ),
                    content: Text(
                      'Do you want to remove the item from your products?',
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
                            await storageReference
                                .child('${id}')
                                .listAll()
                                .then((value) {
                              value.items.forEach((element) {
                                FirebaseStorage.instance
                                    .ref(element.fullPath)
                                    .delete();
                                // .then((value) => print('Storage Deleted'))
                                // .catchError((error) => print(
                                //     'Failed to delete the storage data: ${error}'));
                              });
                            });

                            await products.doc(id).delete();
                            // .then((_) => print('Product Deleted'))
                            // .catchError((_) =>
                            //     print('Failed to delete the product'));
                          } catch (error) {
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleting failed',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
