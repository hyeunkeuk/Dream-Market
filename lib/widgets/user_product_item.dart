// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import 'package:cached_network_image/cached_network_image.dart';

// import 'dart:io';

//Call from user product screen
class UserProductItem extends StatefulWidget {
  final String userStatus;
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
  final String soldTo;

  UserProductItem(
    this.userStatus,
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
    this.soldTo,
  );

  @override
  State<UserProductItem> createState() => _UserProductItemState();
}

class _UserProductItemState extends State<UserProductItem> {
  var buyerData;
  var isInit = true;
  var isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      if (widget.soldTo != '') {
        setState(() {
          isLoading = true;
        });
        getBuyerData().then((value) => setState(() {
              isLoading = false;
            }));
      }
      isInit = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> getBuyerData() async {
    buyerData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.soldTo)
        .get();
  }

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
    return isLoading
        ? CircularProgressIndicator()
        : ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: CircleAvatar(
                        backgroundImage: widget.imageUrl[0] != null
                            ? widget.imageUrl[0] != ''
                                ? CachedNetworkImageProvider(widget.imageUrl[0])
                                : null
                            : null,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                buyerData != null
                    ? widget.status == 'Sold'
                        ? Text(
                            'Sold To: ${buyerData['firstName']} ${buyerData['lastName']}')
                        : widget.status == 'Pending'
                            ? Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Color.fromARGB(255, 189, 144, 197),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                  ),
                                  Text(
                                      '${buyerData['firstName']} ${buyerData['lastName']}'),
                                ],
                              )
                            : SizedBox.shrink()
                    : SizedBox.shrink(),
              ],
            ),
            leading: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                color: widget.status == 'Available'
                    ? Colors.green
                    : widget.status == 'Pending'
                        ? Colors.yellow
                        : Colors.red,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 60),
                  child: Text('${widget.status}', textAlign: TextAlign.center),
                )),
            trailing: Container(
              width: 100,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.black,
                    // color: Theme.of(context).primaryColor,
                    onPressed: widget.status == 'Available'
                        ? () {
                            Navigator.of(context).pushNamed(
                                EditProductScreen.routeName,
                                arguments: [
                                  widget.id,
                                  widget.title,
                                  widget.imageUrl,
                                  widget.price,
                                  widget.description,
                                  widget.category,
                                ]);
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Theme.of(context).errorColor,
                    onPressed: widget.userStatus == 'admin' ||
                            widget.status == 'Available'
                        ? () {
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
                                        await storageReference
                                            .child('${widget.id}')
                                            .listAll()
                                            .then((value) {
                                          value.items.forEach((element) {
                                            FirebaseStorage.instance
                                                .ref(element.fullPath)
                                                .delete();
                                          });
                                        });
                                        await products.doc(widget.id).delete();
                                      } catch (error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
  }
}
