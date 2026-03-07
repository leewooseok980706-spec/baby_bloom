import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/home_card.dart';
import 'package:myapp/models/user_profile.dart';
import 'dart:developer' as developer;

class DBSeeder {
  final _db = FirebaseFirestore.instance;

  Future<void> seedInitialData({bool force = false}) async {
    try {
      final collection = _db.collection('home_cards');
      
      // force가 false일 때만 체크 (보통은 force: true로 호출하여 덮어쓰기 권장)
      if (!force) {
        final snapshot = await collection.limit(10).get();
        if (snapshot.docs.length >= 10) {
          developer.log('Data already exists. Skipping seed.', name: 'myapp.db_seeder');
          return;
        }
      }

      developer.log('STARTING FORCE SEEDING: Curriculum data...', name: 'myapp.db_seeder');

      // Load JSON from assets
      final String jsonString = await rootBundle.loadString('assets/data/curriculum.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List weeks = data['weeks'];

      // Batch size for Firestore is 500
      var batch = _db.batch();
      int count = 0;

      for (var weekData in weeks) {
        final int week = weekData['week'];

        // 1. Daily Cards
        for (var card in weekData['daily_cards']) {
          final docRef = collection.doc();
          batch.set(docRef, {
            'role': card['target'] == 'both' ? 'mother' : (card['target'] == 'mom' ? 'mother' : 'father'),
            'stageType': StageType.pregnant.name,
            'stageValue': week,
            'title': card['title'],
            'description': card['message'],
            'detailContent': card['message'],
            'actionTip': card['action_tip'],
            'perspective': Perspective.action.name,
            'isSponsored': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          count++;
          if (count % 400 == 0) {
            await batch.commit();
            batch = _db.batch();
          }
        }

        // 2. Expert Card
        final expert = weekData['expert_card'];
        final expertDocRef = collection.doc();
        batch.set(expertDocRef, {
          'role': 'mother',
          'stageType': StageType.pregnant.name,
          'stageValue': week,
          'title': expert['title'],
          'description': expert['doctor_tip'],
          'detailContent': expert['doctor_tip'],
          'doctorTip': expert['doctor_tip'],
          'bodyChanges': expert['body_changes'],
          'checklist': expert['checklist'],
          'perspective': Perspective.expert.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;

        // 3. Dad Mission
        final dadMission = weekData['dad_mission'];
        final dadDocRef = collection.doc();
        batch.set(dadDocRef, {
          'role': 'father',
          'stageType': StageType.pregnant.name,
          'stageValue': week,
          'title': dadMission['title'],
          'description': dadMission['mission'],
          'detailContent': dadMission['mission'],
          'mission': dadMission['mission'],
          'whyItMatters': dadMission['why_it_matters'],
          'perspective': Perspective.mission.name,
          'isSponsored': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
      }

      await batch.commit();
      developer.log('FORCE SEEDING COMPLETE. Total cards added: $count', name: 'myapp.db_seeder');
    } catch (e, s) {
      developer.log('Error seeding data', name: 'myapp.db_seeder', error: e, stackTrace: s);
    }
  }
}
