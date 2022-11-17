import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFavorite with ChangeNotifier {
  UserFavorite();

  List<String> _userFavList = [];

  List<String> get userFavoriteList {
    return [..._userFavList];
  }

  Future<void> fetchUserFavoriteListData(
      CollectionReference ref, String userId) async {
    List<String> pastUserFavoriteList = [];
    dynamic resultant = await ref.doc(userId).get();

    if (resultant == null || !resultant.exists) {
      print('Unable to retrieve');
    } else {
      for (int i = 0; i < resultant['favorites'].length; i++) {
        pastUserFavoriteList.add(resultant['favorites'][i].toString());
      }
    }
    _userFavList = pastUserFavoriteList;
    notifyListeners();
  }

  Future<void> updateUserFavorite(
      String userId, List<String> userFavoriteList) async {
    await FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        await FirebaseFirestore.instance
            .collection('userFavorites')
            .doc(userId)
            .update({
          'favorites': userFavoriteList,
        });
      } else {
        print('Document does not exist on the database');
        await FirebaseFirestore.instance
            .collection('userFavorites')
            .doc(userId)
            .set({
          'favorites': userFavoriteList,
        });
      }
    });

    _userFavList = userFavoriteList;

    notifyListeners();
  }

  bool isFavorite(String productId, List<String> userFavoriteList) {
    // notifyListeners();

    if (userFavoriteList.contains(productId)) {
      return true;
    }
    return false;
  }
}
