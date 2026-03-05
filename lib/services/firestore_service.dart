import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/home_card.dart';
import 'package:myapp/models/user_profile.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // 사용자 프로필 저장
  Future<void> saveUserProfile(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toFirestore(), SetOptions(merge: true));
  }

  // 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!, uid);
  }

  // 핵심: role + stageType + stageValue 조건으로 카드 여러 개 조회
  Future<List<HomeCard>> getHomeCards({
    required UserRole role,
    required StageType stageType,
    required int stageValue,
    int? limit,
  }) async {
    var query = _db
        .collection('home_cards')
        .where('role', isEqualTo: role.name)
        .where('stageType', isEqualTo: stageType.name)
        .where('stageValue', isEqualTo: stageValue);

    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map((doc) => HomeCard.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // 기존 1개 조회용 메서드 (필요시 유지 또는 교체)
  Future<HomeCard?> getHomeCard({
    required UserRole role,
    required StageType stageType,
    required int stageValue,
  }) async {
    final cards = await getHomeCards(
      role: role,
      stageType: stageType,
      stageValue: stageValue,
    );
    return cards.isEmpty ? null : cards.first;
  }
}
