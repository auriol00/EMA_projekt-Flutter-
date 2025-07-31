import 'package:flutter/material.dart';
import 'package:moonflow/components/infoBox.dart';
import 'package:moonflow/utilities/app_localizations.dart';

Widget buildSymptomBottomSheet(
  Map<String, dynamic>? symptom,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  return Builder(
    builder: (context) {
      if (symptom == null || symptom.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.translate(context, "no symptoms saved"),
            style: textTheme.bodyMedium,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((symptom['physical'] as List?)?.isNotEmpty ?? false)
                  infoBox(
                    title: AppLocalizations.translate(context, "physical"),
                    value: (symptom['physical'] as List).join(', '),
                    icon: Icons.local_hospital,
                  ),
                if ((symptom['emotional'] as List?)?.isNotEmpty ?? false)
                  infoBox(
                    title: AppLocalizations.translate(context, "emotional"),
                    value: (symptom['emotional'] as List).join(', '),
                    icon: Icons.mood,
                  ),
                if ((symptom['ausflusse'] as List?)?.isNotEmpty ?? false)
                  infoBox(
                    title: AppLocalizations.translate(context, "discharge"),
                    value: (symptom['ausflusse'] as List).join(', '),
                    icon: Icons.water_drop_outlined,
                  ),
                if ((symptom['flux'] as List?)?.isNotEmpty ?? false)
                  infoBox(
                    title: AppLocalizations.translate(context, "flow"),
                    value: (symptom['flux'] as List).join(', '),
                    icon: Icons.bloodtype_outlined,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    },
  );
}
