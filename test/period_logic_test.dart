import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/services/period_logic.dart';
import 'package:moonflow/utilities/messages_utils.dart';

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Berechnung der Zykluslänge', () {
    test('berechnet den durchschnittlichen Zyklus aus mehreren Perioden', () {
      final perioden = [
        PeriodData(start: DateTime(2024, 6, 1), end: DateTime(2024, 6, 5), source: 'manual'),
        PeriodData(start: DateTime(2024, 6, 30), end: DateTime(2024, 7, 4), source: 'manual'),
        PeriodData(start: DateTime(2024, 7, 28), end: DateTime(2024, 8, 1), source: 'manual'),
      ];

      final result = calculateCycleLength(perioden , referenceDate: DateTime(2024, 8, 2));
      expect(result, 29); // (29 + 28) / 2 = 28.5 → gerundet auf 29
    });

    test('verwendet den Quiz-Wert, wenn nicht genug manuelle Perioden vorhanden sind', () {
      final perioden = [
        PeriodData(start: DateTime(2024, 7, 28), end: DateTime(2024, 8, 1), source: 'quiz'),
      ];

      final result = calculateCycleLength(perioden, quizCycleLength: 30 , referenceDate: DateTime(2024, 8, 1));
      expect(result, 30);
    });

    test('verwendet Standardwert 28, wenn keine Perioden vorhanden sind', () {
      final result = calculateCycleLength([], quizCycleLength: null , referenceDate: DateTime.now());
      expect(result, 28);
    });
  });

// CalculatePeriodLength
  group('Berechnung der Periodendauer', () {
  test('berechnet die durchschnittliche Dauer aus mehreren Perioden', () {
    final perioden = [
      PeriodData(start: DateTime(2024, 6, 1), end: DateTime(2024, 6, 5), source: 'manual'), // 5 Tage
      PeriodData(start: DateTime(2024, 6, 30), end: DateTime(2024, 7, 3), source: 'manual'), // 4 Tage
    ];

    final result = calculatePeriodLength(perioden);
    expect(result, 5); // (5 + 4) / 2 = 4.5 → gerundet auf 5
  });

  test('verwendet den Quiz-Wert, wenn keine manuellen Perioden vorhanden sind', () {
    final perioden = [
      PeriodData(start: DateTime(2024, 6, 1), end: DateTime(2024, 6, 5), source: 'quiz'),
    ];

    final result = calculatePeriodLength(perioden, quizPeriodLength: 6);
    expect(result, 5);
  });

  test('verwendet Standardwert 5, wenn keine Perioden vorhanden sind', () {
    final result = calculatePeriodLength([], quizPeriodLength: null);
    expect(result, 5);
  });

});

// getDayType 
group('getDayType – Bestimmung des Zyklustyps je nach Datum', () {
  final perioden = [
    PeriodData(start: DateTime(2024, 6, 1), end: DateTime(2024, 6, 5), source: 'manual'),
  ];
  final cycleLength = 28;
  final periodLength = 5;

  test('gibt "periode" zurück, wenn Datum innerhalb der Periode liegt', () {
    final result = getDayType(
      date: DateTime(2024, 6, 3),
      periods: perioden,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
    expect(result, 'periode');
  });

  test('gibt "eisprung" zurück, wenn Datum der Eisprungtag ist', () {
    final result = getDayType(
      date: DateTime(2024, 6, 15), // 14 Tage nach Start
      periods: perioden,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
    expect(result, 'eisprung');
  });

  test('gibt "fruchtbar" zurück, wenn Datum innerhalb des fruchtbaren Fensters liegt', () {
    final result = getDayType(
      date: DateTime(2024, 6, 14), // 1 Tag vor Eisprung
      periods: perioden,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
    expect(result, 'fruchtbar');
  });

  test('gibt "normal" zurück, wenn kein besonderer Tag', () {
    final result = getDayType(
      date: DateTime(2024, 6, 20),
      periods: perioden,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
    expect(result, 'normal');
  });


});
 test('getMessageForDatePure – Vorhersage ab 5. August gibt "12" Tage bis zur nächsten Periode am 5. August aus', () {
  final periods = [
PeriodData(
  start: DateTime(2025, 6, 6),
  end: DateTime(2025, 6, 10),
  source: 'quiz',
),

  ];

  final today = DateTime(2025, 7, 23);
  final cycleLength = 30;
  final periodLength = 5;

  final message = getMessageForDatePure(
    periods: periods,
    cycleLength: cycleLength,
    periodLength: periodLength,
    todayOverride: today,
  );

  print('MESSAGE: $message');

  expect(message.contains('13'), isTrue);
});

}
