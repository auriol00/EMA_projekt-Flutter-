import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodData {
  final String? id; 
  final DateTime start;
  final DateTime end;
  final String? source;
  final DateTime? createdAt;


  PeriodData({
    this.id,
    required this.start,
    required this.end,
    this.source,
    this.createdAt,
  });

factory PeriodData.fromJson(Map<String, dynamic> json, {String? id}) {
  DateTime parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    throw ArgumentError('Date format non supporté');
  }

  return PeriodData(
    id: id,
    start: parseDate(json['start']),
    end: parseDate(json['end']),
    source: json['source'] as String? ?? 'quiz',
    createdAt: json['createdAt'] != null ? parseDate(json['createdAt']) : null,
  );
}


/*
  Map<String, dynamic> toJson() {
  return {
    'start': start,
    'end': end,
    if (source != null) 'source': source,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}
 */
Map<String, dynamic> toJson() {
  return {
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
    if (source != null) 'source': source,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}



}
