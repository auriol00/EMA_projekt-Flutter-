import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;


String getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User ist offline.");
  return user.uid;
}

  
CollectionReference<Map<String, dynamic>> _userSymptomCollection() {
  final uid = getCurrentUserId();
  return _firestore.collection('Users').doc(uid).collection('symptoms');
}


class SymptomService {
  /// Speichert oder aktualisiert einen Symptomeintrag für den aktuellen Benutzer
  static Future<void> saveOrUpdateSymptomEntry(Map<String, dynamic> entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; 

    final uid = user.uid;
    final date = DateUtils.dateOnly(DateTime.parse(entry['date'])).toIso8601String();

    // Füge UID und gereinigtes Datum zum Eintrag hinzu
    entry['uid'] = uid;
    entry['date'] = date;

    final collection = _userSymptomCollection();

    // Suche nach einem vorhandenen Dokument für denselben Benutzer und Datum
    final existing = await collection
        .where('uid', isEqualTo: uid)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update existierendes Dokument
      await collection.doc(existing.docs.first.id).set(entry);
    } else {
      // Neues Dokument hinzufügen
      await collection.add(entry);
    }
  }

  static Future<Map<String, dynamic>?> getSymptomEntryForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final uid = user.uid;
    final isoDate = DateUtils.dateOnly(date).toIso8601String();

    final collection = _userSymptomCollection();

    final snapshot = await collection
        .where('uid', isEqualTo: uid)
        .where('date', isEqualTo: isoDate)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }
}
