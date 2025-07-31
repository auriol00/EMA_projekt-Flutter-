import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import '../models/period_model.dart';
import '../services/period_logic.dart';
import 'infoBox.dart';

class InfoBoxGrid extends StatelessWidget {
  final List<PeriodData> periods;
  final Map<String, dynamic> quizData;
  final DateTime referenceDate;

  const InfoBoxGrid({
    super.key,
    required this.periods,
    required this.quizData,
    required this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final relevant = getRelevantPeriods(periods, referenceDate);
    final hasManualPeriods = relevant.any((p) => p.source != 'quiz');

    final cycleLength = hasManualPeriods
        ? calculateCycleLength(
            relevant,
            quizCycleLength: quizData['cycleLength'],
            referenceDate: referenceDate,
          )
        : quizData['cycleLength'];

    final periodLength = hasManualPeriods
        ? calculatePeriodLength(
            relevant,
            quizPeriodLength: quizData['periodLength'],
            referenceDate: referenceDate,
          )
        : quizData['periodLength'];

    final predictions = generatePredictedDays(
      periods: relevant,
      cycleLength: cycleLength,
      periodLength: periodLength,
      cyclesToPredict: 6,
    );

    final pred = predictions.isNotEmpty ? predictions[0] : null;

    final ovulationDate = pred?['eisprung'] as DateTime?;
    final fertile = pred?['fruchtbar'] as List<DateTime>?;

    final fertileWindowStart = fertile != null ? fertile[0] : null;
    final fertileWindowEnd = fertile != null ? fertile[1] : null;

    final formattedOvulation = ovulationDate != null
        ? DateFormat('dd.MM.yyyy').format(ovulationDate)
        : '—';

    final fertileText = (fertileWindowStart != null && fertileWindowEnd != null)
        ? '${DateFormat('dd.MM').format(fertileWindowStart)}–${DateFormat('dd.MM').format(fertileWindowEnd)}'
        : '—';

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 5,
          shrinkWrap: true,
          childAspectRatio: 1.1,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            infoBox(
              title: AppLocalizations.translate(context, "cycle_duration"),
              icon: Icons.loop,
              iconOnTop: true,
              value: "$cycleLength Tage",
            ),
            infoBox(
              title: AppLocalizations.translate(context, "period_length"),
              icon: Icons.water_drop,
              iconOnTop: true,
              value: "$periodLength Tage",
            ),
            infoBox(
              title: AppLocalizations.translate(context, "next_ovulation"),
              icon: Icons.egg_alt,
              iconOnTop: true,
              value: formattedOvulation,
            ),
            infoBox(
              title: AppLocalizations.translate(context, "fertile_window"),
              icon: Icons.spa,
              iconOnTop: true,
              value: fertileText,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
