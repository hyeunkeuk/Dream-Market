import 'package:flutter/material.dart';
import 'dart:io';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrl;
  final String category;
  final String location;
  final String status;
  // File image;
  bool isFavorite;
  bool isDream;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.category,
    @required this.location,
    @required this.status,
    this.isFavorite = false,
    this.isDream = false,
  });

  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
