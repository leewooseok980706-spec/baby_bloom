import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/home_card.dart';
import 'package:myapp/models/user_profile.dart';
import 'dart:developer' as developer;

class DBSeeder {
  final _db = FirebaseFirestore.instance;

  Future<void> seedInitialData() async {
    try {
      final collection = _db.collection('home_cards');
      
      // 이미 데이터가 충분히 있는지 확인 (최소 5개 이상이면 시딩 건너뜀)
      final snapshot = await collection.limit(5).get();
      if (snapshot.docs.length >= 5) {
        developer.log('Data already seeded. Skipping.', name: 'DBSeeder');
        return;
      }

      developer.log('Seeding initial data for various stages...', name: 'DBSeeder');

      final cards = [
        // 임신 12주차 (아빠)
        {
          'role': UserRole.father.name,
          'stageType': StageType.pregnant.name,
          'stageValue': 12,
          'title': '오늘 저녁, 아내 밥은 내가',
          'description': '직접 만들지 않아도 괜찮아요. 포장이든 배달이든, 차려주는 것 자체가 다예요.',
          'detailContent': '임신 초기엔 입맛이 자주 바뀌고 냄새에도 예민해집니다.\n'
              '무엇을 먹고 싶은지 먼저 물어보는 것부터 시작해보세요.',
          'perspective': Perspective.action.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        // 임신 준비 (공통/엄마)
        {
          'role': UserRole.mother.name,
          'stageType': StageType.trying.name,
          'stageValue': 0,
          'title': '엽산, 지금부터 시작하세요',
          'description': '임신 준비 단계에서 가장 중요한 영양소입니다.',
          'detailContent': '임신을 계획 중이라면 최소 3개월 전부터 엽산을 복용하는 것이 좋습니다.\n'
              '배아의 신경관 결손을 예방하는 데 필수적인 영양소이기 때문입니다.',
          'perspective': Perspective.info.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        // 출산 후 3개월 (아빠)
        {
          'role': UserRole.father.name,
          'stageType': StageType.postpartum.name,
          'stageValue': 3,
          'title': '아내에게 자유 시간 선물하기',
          'description': '단 1시간이라도 아내가 오롯이 혼자 쉴 수 있게 해주세요.',
          'detailContent': '출산 후 100일 즈음은 체력적으로나 정신적으로 매우 지치는 시기입니다.\n'
              '아이를 도맡아 보고 아내가 좋아하는 카페에 가거나 잠을 잘 수 있게 해주세요.',
          'perspective': Perspective.care.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        // 임신 준비 (아빠)
        {
          'role': UserRole.father.name,
          'stageType': StageType.trying.name,
          'stageValue': 0,
          'title': '함께 건강 검진 받기',
          'description': '아이를 맞이하기 전, 아빠의 건강 상태도 체크해 보세요.',
          'detailContent': '건강한 임신과 출산은 부부가 함께 노력해야 합니다.\n'
              '술과 담배를 줄이고 규칙적인 운동을 시작해 보세요.',
          'perspective': Perspective.action.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        // 출산 후 1개월 (엄마)
        {
          'role': UserRole.mother.name,
          'stageType': StageType.postpartum.name,
          'stageValue': 1,
          'title': '내 몸 회복에 집중할 시간',
          'description': '아이도 중요하지만 엄마의 산후 조리가 가장 우선입니다.',
          'detailContent': '산욕기인 첫 6주 동안은 몸이 원래대로 돌아가는 중요한 시기입니다.\n'
              '무거운 것을 들지 말고 충분한 수분 섭취와 휴식을 취하세요.',
          'perspective': Perspective.care.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _db.batch();
      for (final card in cards) {
        batch.set(collection.doc(), card);
      }
      await batch.commit();
      developer.log('Seeding complete.', name: 'DBSeeder');
    } catch (e) {
      developer.log('Error seeding data', name: 'DBSeeder', error: e);
    }
  }
}
