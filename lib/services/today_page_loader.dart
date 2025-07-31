import 'package:flutter/material.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/services/quiz_firestore_services.dart';
import 'package:moonflow/utilities/calendar_utils.dart';

class TodayPageLoadResult {
  final List<PeriodData> periods;
  final Map<String, dynamic>? quizData;
  final DateTime selectedDate;

  TodayPageLoadResult({
    required this.periods,
    required this.quizData,
    required this.selectedDate,
  });
}

class TodayPageLoader {
  static Future<Map<String, dynamic>?> loadQuizData() async {
    return await QuizFirestoreService.loadQuizAnswers();
  }

 
  static Future<List<PeriodData>> loadAllPeriodsIncludingQuiz() async {
    final fetched = await PeriodFirestoreService.loadAllPeriods();
    final quiz = await QuizFirestoreService.loadQuizAnswers();

    final quizPeriod = _extractPeriodFromQuiz(quiz);
    if (quizPeriod != null &&
      !fetched.any((p) =>
          p.source == 'quiz' &&
          p.start == quizPeriod.start &&
          p.end == quizPeriod.end)) {
    fetched.add(quizPeriod);
  }

    return fetched;
  }

  static PeriodData? _extractPeriodFromQuiz(Map<String, dynamic>? quiz) {
    if (quiz == null || quiz['firstPeriodDate'] == null || quiz['periodLength'] == null) {
      return null;
    }

    final start = DateTime.parse(quiz['firstPeriodDate']);
    final periodLen = quiz['periodLength'];
    final end = start.add(Duration(days: periodLen - 1));
    return PeriodData(start: start, end: end, source: 'quiz');
  }

  static Future<TodayPageLoadResult?> refreshPeriodsAfterCalendarInput(BuildContext context) async {
    final picked = await openCalendarPicker(context);
    if (picked == null || picked['start'] == null || picked['end'] == null) {
      return null;
    }

    final updated = await loadAllPeriodsIncludingQuiz();
    final quiz = await QuizFirestoreService.loadQuizAnswers();

    return TodayPageLoadResult(
      periods: updated,
      quizData: quiz,
      selectedDate: picked['start']!,
    );
  }
}