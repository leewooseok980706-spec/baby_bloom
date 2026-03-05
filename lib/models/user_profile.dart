import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { father, mother }
enum StageType { trying, pregnant, postpartum }
enum Gender { male, female, other }

class UserProfile {
  final String uid;
  final String? name; // 이름 추가
  final Gender? gender; // 성별 추가
  final int? age; // 나이 추가
  final UserRole role;
  final StageType stageType;
  final int stageValue; // 주차 or 개월
  final DateTime createdAt;
  final String? familyId;

  const UserProfile({
    required this.uid,
    this.name,
    this.gender,
    this.age,
    required this.role,
    required this.stageType,
    required this.stageValue,
    required this.createdAt,
    this.familyId,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String?,
      gender: data['gender'] != null ? Gender.values.byName(data['gender']) : null,
      age: data['age'] as int?,
      role: UserRole.values.byName(data['role']),
      stageType: StageType.values.byName(data['stageType']),
      stageValue: data['stageValue'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
        'gender': gender?.name,
        'age': age,
        'role': role.name,
        'stageType': stageType.name,
        'stageValue': stageValue,
        'createdAt': Timestamp.fromDate(createdAt),
        'familyId': familyId,
      };

  UserProfile copyWith({
    String? name,
    Gender? gender,
    int? age,
    UserRole? role,
    StageType? stageType,
    int? stageValue,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      role: role ?? this.role,
      stageType: stageType ?? this.stageType,
      stageValue: stageValue ?? this.stageValue,
      createdAt: createdAt,
      familyId: familyId,
    );
  }
}
