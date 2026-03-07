import 'package:flutter/material.dart';
import 'package:myapp/models/home_card.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/services/firestore_service.dart';
import 'dart:developer' as developer;

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

    developer.log('Fetching cards for Role: ${role.name}, Stage: ${stageType.name}, Week: $stageValue', name: 'myapp.provider');

    try {
      _cards = await _firestoreService.getHomeCards(
        role: role,
        stageType: stageType,
        stageValue: stageValue,
        limit: 3,
      );
      developer.log('Successfully fetched ${_cards.length} cards.', name: 'myapp.provider');
      if (_cards.isEmpty) {
        developer.log('WARNING: No cards found for this criteria in Firestore!', name: 'myapp.provider');
      }
    } catch (e, s) {
      developer.log('Error fetching cards', name: 'myapp.provider', error: e, stackTrace: s);
      _cards = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
