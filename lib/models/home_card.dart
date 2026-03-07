import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_profile.dart';

enum Perspective { action, care, info, expert, mission }

class HomeCard {
  final String id;
  final UserRole role; // mom, dad, both
  final StageType stageType; // pregnant, trying, postpartum
  final int stageValue; // week or month
  final String title;
  final String description; // message or doctor_tip summary
  final String detailContent; // detail contents combined
  final Perspective perspective;
  final bool isSponsored;
  final DateTime createdAt;
  
  // New specific fields for the 40-week curriculum
  final String? actionTip;
  final String? doctorTip;
  final String? bodyChanges;
  final String? checklist;
  final String? mission;
  final String? whyItMatters;

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
    this.actionTip,
    this.doctorTip,
    this.bodyChanges,
    this.checklist,
    this.mission,
    this.whyItMatters,
  });

  factory HomeCard.fromFirestore(Map<String, dynamic> data, String id) {
    return HomeCard(
      id: id,
      role: _parseRole(data['role']),
      stageType: StageType.values.byName(data['stageType'] ?? 'pregnant'),
      stageValue: data['stageValue'] as int? ?? 1,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      detailContent: data['detailContent'] as String? ?? '',
      perspective: Perspective.values.byName(data['perspective'] ?? 'info'),
      isSponsored: data['isSponsored'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionTip: data['actionTip'] as String?,
      doctorTip: data['doctorTip'] as String?,
      bodyChanges: data['bodyChanges'] as String?,
      checklist: data['checklist'] as String?,
      mission: data['mission'] as String?,
      whyItMatters: data['whyItMatters'] as String?,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'both') return UserRole.mother; // Defaulting both to mother for role matching or we can handle 'both' specially
    try {
      return UserRole.values.byName(role as String);
    } catch (_) {
      return UserRole.mother;
    }
  }
}
