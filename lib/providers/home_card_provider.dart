import 'package:flutter/material.dart';
import 'package:myapp/models/home_card.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/services/firestore_service.dart';

class HomeCardProvider with ChangeNotifier {
  FirestoreService _firestoreService = FirestoreService();

  List<HomeCard> _cards = [];
  bool _isLoading = false;

  List<HomeCard> get cards => _cards;
  bool get isLoading => _isLoading;

  void updateFirestore(FirestoreService service) {
    _firestoreService = service;
  }

  // 카드 3개까지 불러오기
  Future<void> fetchRecommendedCards({
    required UserRole role,
    required StageType stageType,
    required int stageValue,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _firestoreService.getHomeCards(
        role: role,
        stageType: stageType,
        stageValue: stageValue,
        limit: 3,
      );
    } catch (e) {
      _cards = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
