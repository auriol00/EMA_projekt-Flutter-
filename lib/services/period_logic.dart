import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/period_model.dart';
import 'package:moonflow/utilities/app_localizations.dart';


extension LastOrNull<T> on List<T> {
  T? get lastOrNull => isNotEmpty ? last : null;
}

List<PeriodData> sortPeriods(List<PeriodData> periods) =>
    (List.from(periods)..sort((a, b) => a.start.compareTo(b.start)));

List<PeriodData> getRelevantPeriods(List<PeriodData> all,[DateTime? referenceDate]) {
  final realPeriods = all.where((p) => p.source != 'quiz').toList();
  return realPeriods.isNotEmpty ? realPeriods : all;
}

PeriodData? getLastPeriod(List<PeriodData> periods) {
  final relevant = getRelevantPeriods(periods);
  return relevant.isEmpty ? null : sortPeriods(relevant).last;
}

int calculateCycleLength(List<PeriodData> periods, {int? quizCycleLength, DateTime? reference, required DateTime referenceDate}) {
  final now = DateTime.now();

  final manualThisMonth = periods.where((p) =>
    p.source != 'quiz' &&
    p.start.month == now.month &&
    p.start.year == now.year
  ).toList();

  final manualAll = periods.where((p) => p.source != 'quiz').toList();

  final usedPeriods = manualThisMonth.length >= 2
      ? manualThisMonth
      : manualAll.length >= 2
          ? manualAll
          : periods;

  final starts = sortPeriods(usedPeriods).map((p) => p.start).toList();
  if (starts.length < 2){
    return quizCycleLength ?? 28;
  } 

  final intervals = [
    for (var i = 1; i < starts.length; i++)
      starts[i].difference(starts[i - 1]).inDays
  ];
  final avg = intervals.reduce((a, b) => a + b) / intervals.length;
  return avg.round();
}


int calculatePeriodLength(List<PeriodData> periods , {int? quizPeriodLength , DateTime? referenceDate}) {
  final now = DateTime.now();

  final manualThisMonth = periods.where((p) =>
    p.source != 'quiz' &&
    p.start.month == now.month &&
    p.start.year == now.year
  ).toList();

  final usedPeriods = manualThisMonth.isNotEmpty
      ? manualThisMonth
      : periods.where((p) => p.source != 'quiz').toList().isNotEmpty
          ? periods.where((p) => p.source != 'quiz').toList()
          : periods;

  if (usedPeriods.isEmpty){
     return quizPeriodLength ?? 5;
  } 

  final lengths = usedPeriods
      .map((p) => p.end.difference(p.start).inDays + 1)
      .toList();
  final avg = lengths.reduce((a, b) => a + b) / lengths.length;
  return avg.round();
}

DateTime? calculateOvulationDate(List<PeriodData> periods, {
  int lutealPhase = 14,
  DateTime? referenceDate,
}) {
  final relevant = getRelevantPeriods(periods, referenceDate);
  final last = relevant.isEmpty ? null : sortPeriods(relevant).last;
  if (last == null) return null;

final cycle = calculateCycleLength(
    relevant,
    referenceDate: referenceDate ?? DateTime.now(),
  );  return last.start.add(Duration(days: cycle - lutealPhase));
}


bool isDateInPeriod(DateTime date, PeriodData period) {
  return !date.isBefore(period.start) && !date.isAfter(period.end);
}

Map<String, Color> getDayColors(String type) {
  switch (type) {
    case 'periode':
      return {
        'bg': Colors.pink.shade100,
        'text': Colors.pink.shade700,
      };
    case 'eisprung':
      return {
        'bg': Colors.blue.shade200,
        'text': Colors.blue.shade900,
      };
    case 'fruchtbar':
      return {
        'bg': Colors.lightBlue.shade100,
        'text': Colors.blue.shade300,
      };
    default:
      return {
        'bg': Colors.grey.shade200,
        'text': Colors.black,
      };
  }
}

Map<String, DateTime>? calculateFertileWindow(List<PeriodData> periods, {int lutealPhase = 14, required DateTime referenceDate}) {
  final ovulationDate = calculateOvulationDate(periods, lutealPhase: lutealPhase , referenceDate: referenceDate);
  if (ovulationDate == null) return null;

  final start = ovulationDate.subtract(const Duration(days: 2));
  final end = ovulationDate.add(const Duration(days: 2)).subtract(const Duration(days: 1));

  return {
    'start': start,
    'end': end,
  };
}

List<Map<String, dynamic>> generatePredictedDays({
  required List<PeriodData> periods,
  required int cycleLength,
  required int periodLength,
  int cyclesToPredict = 6,
}) {
  final relevant = getRelevantPeriods(periods);
  final last = relevant.isEmpty ? null : sortPeriods(relevant).last;
  if (last == null) return [];

  final predictions = <Map<String, dynamic>>[];
  DateTime baseDate = DateUtils.dateOnly(last.start);

  for (int i = 1; i <= cyclesToPredict; i++) {
    final nextStart = baseDate.add(Duration(days: i * cycleLength));
    final nextEnd = nextStart.add(Duration(days: periodLength - 1));

    final ovulation = nextStart.subtract(Duration(days: cycleLength - 14));
    final fertileStart = ovulation.subtract(const Duration(days: 2));
    final fertileEnd = ovulation.add(const Duration(days: 2));

    predictions.add({
      'periode': [DateUtils.dateOnly(nextStart), DateUtils.dateOnly(nextEnd)],
      'eisprung': DateUtils.dateOnly(ovulation),
      'fruchtbar': [
        DateUtils.dateOnly(fertileStart),
        DateUtils.dateOnly(fertileEnd.subtract(const Duration(days: 1)))
      ],
    });
  }

  return predictions;
}

String getDayType({
  required DateTime date,
  required List<PeriodData> periods,
  required int cycleLength,
  required int periodLength,
}) {
  final d = DateUtils.dateOnly(date);

  // 1. Périodes réelles
  for (final p in getRelevantPeriods(periods)) {
    final start = DateUtils.dateOnly(p.start);
    final end = DateUtils.dateOnly(p.end);
    if (!d.isBefore(start) && !d.isAfter(end)) return 'periode';
  }

  final predictions = generatePredictedDays(
    periods: periods,
    cycleLength: cycleLength,
    periodLength: periodLength,
  );

  for (final pred in predictions) {
    final ovulation = DateUtils.dateOnly(pred['eisprung']);
    if (d == ovulation) return 'eisprung';

    final fertile = pred['fruchtbar'] as List<DateTime>;
    if (!d.isBefore(fertile[0]) && !d.isAfter(fertile[1])) {
      return 'fruchtbar';
    }

    final periodRange = pred['periode'] as List<DateTime>;
    if (!d.isBefore(periodRange[0]) && !d.isAfter(periodRange[1])) {
      return 'periode';
    }
  }

  return 'normal';
}

String? getFormattedLastPeriod(BuildContext context, List<PeriodData> periods) {
  final manualPeriods = periods.where((p) => p.source != 'quiz').toList();

  if (manualPeriods.isEmpty) return null;

  manualPeriods.sort((a, b) => a.start.compareTo(b.start));
  final last = manualPeriods.last;

  final formatter = DateFormat('dd.MM.yyyy');
  return '${AppLocalizations.translate(context, 'last_period')}: '
         '${formatter.format(last.start)} '
         '${AppLocalizations.translate(context, 'to')} '
         '${formatter.format(last.end)}';
}
