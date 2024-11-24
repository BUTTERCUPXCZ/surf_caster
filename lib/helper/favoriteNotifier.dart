import 'package:flutter/material.dart';

class Favoritenotifier with ChangeNotifier {
  final List<String> _favoritePostIds = [];
   List<String> get favoritePostIds => _favoritePostIds;

  void addFavorite(String postId) {
    if (!_favoritePostIds.contains(postId)) {
      _favoritePostIds.add(postId);
      notifyListeners();
    }
  }

 void removeFavorite(String postId) {
    if (_favoritePostIds.contains(postId)) {
      _favoritePostIds.remove(postId);
      notifyListeners();
    }
    }
}
