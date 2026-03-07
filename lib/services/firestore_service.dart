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

  // 핵심: stageType + stageValue 조건으로 카드 여러 개 조회 (Role은 코드에서 필터링하거나 모두 허용)
  Future<List<HomeCard>> getHomeCards({
    required UserRole role,
    required StageType stageType,
    required int stageValue,
    int? limit,
  }) async {
    // 1차: stageType과 stageValue로만 쿼리 (role에 상관없이 해당 주차의 모든 카드를 일단 가져옴)
    var query = _db
        .collection('home_cards')
        .where('stageType', isEqualTo: stageType.name)
        .where('stageValue', isEqualTo: stageValue);

    if (limit != null) {
      query = query.limit(limit * 2); // 넉넉히 가져온 후 필터링
    }

    final querySnapshot = await query.get();

    final allCards = querySnapshot.docs
        .map((doc) => HomeCard.fromFirestore(doc.data(), doc.id))
        .toList();

    // 2차: 사용자 역할에 맞는 카드 우선순위 필터링
    // (여기서는 일단 해당 주차의 모든 카드를 보여주는 것으로 완화)
    if (allCards.isEmpty) return [];

    // 필터링 예: 본인 역할 카드 + 공통(있다면) 순으로 정렬하거나 필터링
    final filtered = allCards.where((c) => c.role == role || c.role == UserRole.mother).toList(); // 임시로 완화

    return filtered.take(limit ?? 5).toList();
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
