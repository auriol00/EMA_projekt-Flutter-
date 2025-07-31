import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/infobubble.dart';
import 'package:moonflow/services/symptom_services.dart';
import 'package:moonflow/utilities/symptom_data.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class SymptomEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  const SymptomEntryPage({super.key, required this.selectedDate});

  @override
  State<SymptomEntryPage> createState() => _SymptomEntryPageState();
}

class _SymptomEntryPageState extends State<SymptomEntryPage> {
  final TextEditingController noteController = TextEditingController();

  List<String> selectedPhysical = [];
  List<String> selectedEmotional = [];
  List<String> selectedAusflusse = [];
  List<String> selectedFlux = [];

  double intensity = 0;

  void _toggleSelection(String value, List<String> list) {
    setState(() {
      list.contains(value) ? list.remove(value) : list.add(value);
    });
  }

  void _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final entry = {
      'date': DateUtils.dateOnly(widget.selectedDate).toIso8601String(),
      'physical': selectedPhysical,
      'emotional': selectedEmotional,
      'intensity': intensity.round(),
      'note': noteController.text,
      'ausflusse': selectedAusflusse,
      'flux': selectedFlux,
    };

    await SymptomService.saveOrUpdateSymptomEntry(entry);
    if (mounted) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.translate(context, 'symptoms saved')),
          backgroundColor: theme.colorScheme.secondaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    if (mounted) Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(context, 'enter symptoms')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.translate(context, 'date')}: '
              '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.translate(context, 'physical symptoms'),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children:
                  physicalSymptoms.map((symptom) {
                    return GestureDetector(
                      onTap:
                          () => _toggleSelection(
                            symptom['label']!,
                            selectedPhysical,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Infobubble(
                          message: AppLocalizations.translate(
                            context,
                            symptom['label']!,
                          ),
                          emoji: symptom['emoji'],
                          selected: selectedPhysical.contains(symptom['label']),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.translate(context, 'emotional symptoms'),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children:
                  emotionalSymptoms.map((symptom) {
                    return GestureDetector(
                      onTap:
                          () => _toggleSelection(
                            symptom['label']!,
                            selectedEmotional,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Infobubble(
                          message: AppLocalizations.translate(
                            context,
                            symptom['label']!,
                          ),
                          emoji: symptom['emoji'],
                          selected: selectedEmotional.contains(
                            symptom['label'],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.translate(context, 'discharge'),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children:
                  ausflusse.map((symptom) {
                    return GestureDetector(
                      onTap:
                          () => _toggleSelection(
                            symptom['label']!,
                            selectedAusflusse,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Infobubble(
                          message: AppLocalizations.translate(
                            context,
                            symptom['label']!,
                          ),
                          emoji: symptom['emoji'],
                          selected: selectedAusflusse.contains(
                            symptom['label'],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            Text(
              AppLocalizations.translate(context, 'flow'),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children:
                  flux.map((symptom) {
                    return GestureDetector(
                      onTap:
                          () =>
                              _toggleSelection(symptom['label']!, selectedFlux),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Infobubble(
                          message: AppLocalizations.translate(
                            context,
                            symptom['label']!,
                          ),
                          emoji: symptom['emoji'],
                          selected: selectedFlux.contains(symptom['label']),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            Text(
              AppLocalizations.translate(context, 'intensity'),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: intensity,
              min: 0,
              max: 5,
              divisions: 5,
              label: intensity.round().toString(),
              activeColor: colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  intensity = value;
                });
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.translate(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(AppLocalizations.translate(context, 'save')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
