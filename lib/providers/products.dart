import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_storage/firebase_storage.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Black Crewneck \$30',
      description: 'A red shirt - it is pretty red!',
      price: 30,
      // imageUrl: 'assets/images/black2.jpeg',
    ),
    Product(
      id: 'p2',
      title: 'Grey Crewneck \$30',
      description: 'A nice pair of trousers.',
      price: 30,
      // imageUrl: 'assets/images/grey2.jpeg',
    ),
    Product(
      id: 'p3',
      title: 'Navy Hoodie \$40',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 40,
      // imageUrl: 'assets/images/navy.jpeg',
    ),
    Product(
      id: 'p4',
      title: 'White Hoodie \$40',
      description: 'Prepare any meal you want.',
      price: 40,
      // imageUrl: 'assets/images/white.jpeg',
    ),
    Product(
      id: 'p5',
      title: 'Grey Hoodie \$40',
      description: 'Prepare any meal you want.',
      price: 40,
      // imageUrl: 'assets/images/grey_hoodie2.jpeg',
    ),
    Product(
      id: 'p6',
      title: 'White T-Shirt \$15',
      description: 'Prepare any meal you want.',
      price: 15,
      // imageUrl: 'assets/images/white_short.jpeg',
    ),
  ]; //becoming private by adding _

  var _showFavoritesOnly = false;

  // final String authToken;
  // final String userId;

  Products();

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items]; //returning the copy of _item by adding ...
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetDreamProducts() async {
    final List<Product> loadedProducts = [];

    final extractedData = FirebaseFirestore.instance
        .collection('dream')
        .snapshots() as Map<String, dynamic>;
    extractedData.forEach(
      (prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            // isFavorite:
            //     favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ),
        );
      },
    );
    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final List<Product> loadedProducts = [];

    final extractedData = FirebaseFirestore.instance
        .collection('products')
        .snapshots() as Map<String, dynamic>;
    extractedData.forEach(
      (prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            // isFavorite:
            //     favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ),
        );
      },
    );
    _items = loadedProducts;
    notifyListeners();
  }

  Future addProduct(String uid, Product product) async {
    // // FocusScope.of(context).unfocus();
    // final user = await FirebaseAuth.instance.currentUser;
    // final userdata =
    //     await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

    // final userData = await FirebaseFirestore.instance.collection('users').doc(uid);

    // var isUserAdmin = userData['Admin'];

    var addedProduct =
        await FirebaseFirestore.instance.collection('products').add(
      {
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId': uid,
        'category': product.category,
        'createdAt': Timestamp.now(),
        'location': product.location,
      },
    );
    return addedProduct;
    // final newProduct = Product(
    //   title: product.title,
    //   description: product.description,
    //   price: product.price,
    //   imageUrl: product.imageUrl,
    //   id: product.id,
    //   category: product.category,
    //   location: product.location,
    // );
    // _items.add(newProduct);
  }

  Future<void> updateProduct(String uid, String id, Product newProduct) async {
    // print('im in products' + newProduct.imageUrl.toString());
    FirebaseFirestore.instance.collection('products').doc(id).update(
      {
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
        'creatorId': uid,
        'category': newProduct.category,
        'createdAt': Timestamp.now(),
        'location': newProduct.location,
      },
    );

    // _items[prodIndex] = newProduct;
    // notifyListeners();
  }

  Future<void> deleteProducts(String id) async {
    // final url = Uri.parse(
    //     'https://flutter-update-d7873-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    // final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    // var existingProduct = _items[existingProductIndex];

    // _items.removeAt(existingProductIndex);
    // notifyListeners();

    // final response = await http.delete(url);

    // if (response.statusCode >= 400) {
    //   _items.insert(existingProductIndex, existingProduct);
    //   notifyListeners();
    //   throw HttpException('Could not delete product.');
    // }
    // existingProduct = null;
  }

  Future<void> updateUserFavorite(
      String userId, List<String> userFavoriteList) async {
    await FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userId)
        .update({
      'favorites': userFavoriteList,
    });

    // notifyListeners();

    // final prodIndex = _items.indexWhere((prod) => prod.id == id);

    // if (prodIndex >= 0) {
    //   final url = Uri.parse(
    //       'https://flutter-update-d7873-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    //   final response = await http.put(
    //     url,
    //     body: json.encode(
    //       newProduct.isFavorite,
    //     ),
    //   );
    //   if (response.statusCode >= 400) {
    //     throw HttpException('Could not update product favorite status.');
    //   }
    //   _items[prodIndex] = newProduct;
    //   notifyListeners();
    // } else {
    //   //print('...');
    // }
  }
}
