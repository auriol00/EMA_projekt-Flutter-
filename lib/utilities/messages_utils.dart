import 'package:flutter/material.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/services/period_logic.dart';
import 'package:moonflow/utilities/app_localizations.dart';

bool hasManualPeriodThisMonth(List<PeriodData> periods) {
  final now = DateTime.now();
  return periods.any((p) =>
      p.source != 'quiz' &&
      p.start.month == now.month &&
      p.start.year == now.year);
}

String getMessageForDatePure({
  required List<PeriodData> periods,
  required int cycleLength,
  required int periodLength,
  DateTime? todayOverride,
  Map<String, String> messages = const {
    'in_period': 'Du bist in deiner Periode.',
    'ovulation': 'Heute ist dein Eisprung.',
    'fertile_in': 'Du bist fruchtbar. Eisprung in {days} Tagen.',
    'next_period': 'Tag bis zur nächsten Periode: {days}'
  },
}) {
final today = DateUtils.dateOnly(todayOverride ?? DateTime.now());
final relevant = getRelevantPeriods(periods);

  for (final p in relevant) {
    if (!today.isBefore(p.start) && !today.isAfter(p.end)) {
      return messages['in_period']!;
    }
  }

  final predictions = generatePredictedDays(
    periods: relevant,
    cycleLength: cycleLength,
    periodLength: periodLength,
    cyclesToPredict: 6,
  );

  for (final pred in predictions) {
    final DateTime ovulation = DateUtils.dateOnly(pred['eisprung']);
    final List<DateTime> fertile = pred['fruchtbar'];
    final List<DateTime> periodRange = pred['periode'];

    if (DateUtils.isSameDay(ovulation, today)) {
      return messages['ovulation']!;
    }

if (today.isAfter(fertile[0].subtract(const Duration(days: 1))) &&
    today.isBefore(fertile[1].add(const Duration(days: 1)))) {
  final remaining = ovulation.difference(today).inDays;
  if (remaining > 0) {
    return messages['fertile_in']!.replaceFirst('{days}', remaining.toString());
  } else if (remaining == 0) {
    return messages['ovulation']!;
  }
}


    final DateTime start = DateUtils.dateOnly(periodRange[0]);
    if (today.isBefore(start)) {
      final remaining = start.difference(today).inDays;
      return messages['next_period']!.replaceFirst('{days}', remaining.toString());
    }
  }

  return '';
}

String getMessageForDate({
  required BuildContext context,
  required List<PeriodData> periods,
  required int cycleLength,
  required int periodLength,
  DateTime? todayOverride,
}) {
  return getMessageForDatePure(
    periods: periods,
    cycleLength: cycleLength,
    periodLength: periodLength,
    todayOverride: todayOverride,
    messages: {
      'in_period': AppLocalizations.translate(context, 'you_are_in_your_period'),
      'ovulation': AppLocalizations.translate(context, 'today_is_ovulation_day'),
      'fertile_in': AppLocalizations.translate(context, 'you_are_fertile_in'),
      'next_period': AppLocalizations.translate(context, 'days_until_next_period'),
    },
  );
}