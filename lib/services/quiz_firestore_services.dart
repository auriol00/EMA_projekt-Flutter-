import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizFirestoreService {
  static Future<void> saveQuizAnswers({
    required int periodLength,
    required int cycleLength,
    required DateTime firstPeriodDate,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('QuizAnswers')
        .doc('initialQuiz');

    await docRef.set({
      'periodLength': periodLength,
      'cycleLength': cycleLength,
      'firstPeriodDate': firstPeriodDate.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> loadQuizAnswers() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('QuizAnswers')
        .doc('initialQuiz');

    final snapshot = await docRef.get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }
}
