import 'package:flutter/material.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final _firestoreService = FirestoreService();
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  // 프로필 로드
  Future<void> loadProfile(String uid) async {
    _profile = await _firestoreService.getUserProfile(uid);
    notifyListeners();
  }

  // 프로필 저장 및 업데이트
  Future<void> saveProfile(UserProfile profile) async {
    await _firestoreService.saveUserProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  // 프로필 초기화 (테스트용)
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
