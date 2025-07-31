import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonflow/models/period_model.dart';

final _firestore = FirebaseFirestore.instance;

String getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User ist offline.");
  return user.uid;
}

CollectionReference<Map<String, dynamic>> _getUserPeriodsCollection() {
  final uid = getCurrentUserId();
  return _firestore.collection('Users').doc(uid).collection('periods');
}

class PeriodFirestoreService {
  /// Ajoute une nouvelle période (ID Firestore auto)
  static Future<void> addPeriod(PeriodData period) async {
    final collection = _getUserPeriodsCollection();
    await collection.add(period.toJson());
  }

  /// Met à jour une période existante (nécessite son id)
  static Future<void> updatePeriod(String id, PeriodData period) async {
    final collection = _getUserPeriodsCollection();
    await collection.doc(id).update(period.toJson());
  }

  /// Supprime une période (par son id)
  static Future<void> deletePeriod(String id) async {
    final collection = _getUserPeriodsCollection();
    await collection.doc(id).delete();
  }

  /// Récupère toutes les périodes, triées par date de début
  static Future<List<PeriodData>> loadAllPeriods() async {
    final collection = _getUserPeriodsCollection();
    final snapshots = await collection.get();

    return snapshots.docs.map((doc) {
      final data = doc.data();
      return PeriodData.fromJson(data, id: doc.id);
    }).toList();
    
  }

  /// Supprime toutes les périodes sauf celles du quiz
  static Future<void> clearManualPeriodsOnly() async {
    final collection = _getUserPeriodsCollection();
    final snapshots = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshots.docs) {
      final data = doc.data();
      final source = data['source'];
      if (source != 'quiz') {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }
}

/// Utilitaire : teste si une date appartient à une période
bool isDateInPeriod(DateTime date, PeriodData period) {
  return date.isAfter(period.start.subtract(const Duration(days: 1))) &&
         date.isBefore(period.end.add(const Duration(days: 1)));
}


Future<void> saveInitialPeriodToFirestore(List<String> answers) async {
  if (answers.length < 3) throw Exception("Nicht genug Antworten");

  final int periodLength = int.parse(answers[0]);
  final int cycleLength = int.parse(answers[1]);
  final DateTime startDate = DateTime.parse(answers[2]);

  final quizCollection = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('QuizAnswers');

  await quizCollection.doc('initialQuiz').set({
  'cycleLength': cycleLength,
  'periodLength': periodLength,
  'firstPeriodDate': startDate.toIso8601String(),
  'timestamp': FieldValue.serverTimestamp(),
});

}
/**
 * 
Future<void> saveInitialPeriodToFirestore(List<String> answers) async {
  if (answers.length < 3) throw Exception("Nicht genug Antworten");

  final int periodLength = int.parse(answers[0]);
  final int cycleLength = int.parse(answers[1]);
  final DateTime startDate = DateTime.parse(answers[2]);
  final endDate = startDate.add(Duration(days: periodLength));

  final period = PeriodData(
    id: '', // Firebase générera l’ID
    start: startDate,
    end: endDate,
    source: 'quiz',
  );

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final periodCollection = FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('periods');

  await periodCollection.add(period.toJson());

  // Sauvegarde également les réponses du quiz dans une autre collection
  final quizCollection = FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('QuizAnswers');

  await quizCollection.doc('initialQuiz').set({
  'cycleLength': cycleLength,
  'periodLength': periodLength,
  'firstPeriodDate': startDate.toIso8601String(),
  'timestamp': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

}
 */