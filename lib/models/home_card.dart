import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_profile.dart';

enum Perspective { action, care, info }

class HomeCard {
  final String id;
  final UserRole role;
  final StageType stageType;
  final int stageValue;
  final String title;
  final String description;
  final String detailContent; // "자세히 보기" 화면용
  final Perspective perspective;
  final bool isSponsored; // 항상 false (광고 구조만 유지)
  final DateTime createdAt;

  const HomeCard({
    required this.id,
    required this.role,
    required this.stageType,
    required this.stageValue,
    required this.title,
    required this.description,
    required this.detailContent,
    required this.perspective,
    this.isSponsored = false,
    required this.createdAt,
  });

  factory HomeCard.fromFirestore(Map<String, dynamic> data, String id) {
    return HomeCard(
      id: id,
      role: UserRole.values.byName(data['role']),
      stageType: StageType.values.byName(data['stageType']),
      stageValue: data['stageValue'] as int,
      title: data['title'] as String,
      description: data['description'] as String,
      detailContent: data['detailContent'] as String,
      perspective: Perspective.values.byName(data['perspective']),
      isSponsored: data['isSponsored'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}