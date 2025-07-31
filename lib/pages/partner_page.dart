import 'package:flutter/material.dart';
import 'package:moonflow/components/CustomApp_Bar.dart';
import 'package:moonflow/components/my_drawer.dart';
import 'package:moonflow/pages/customCalendar_page.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  PartnerPageState createState() => PartnerPageState();
}

class PartnerPageState extends State<PartnerPage> {
  String generatedCode = '';
  bool codeVisible = false;

  void generateCode() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final code =
        'PM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    await FirebaseFirestore.instance.collection('PartnerCodes').doc(userId).set(
      {'userId': userId, 'code': code},
    );

    setState(() {
      generatedCode = code;
      codeVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppLocalizations.translate(context, 'partner_mode')),
        onCalendarPressed: () async {
          final periods = await PeriodFirestoreService.loadAllPeriods();
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomCalendarPage(periods: periods),
            ),
          );
        },
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.translate(context, 'partner_title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.translate(context, 'partner_welcome'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/Partner.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.translate(context, 'partner_mood_prompt'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              items:
                  [
                        AppLocalizations.translate(context, 'mood_stars'),
                        AppLocalizations.translate(context, 'mood_sunset'),
                        AppLocalizations.translate(context, 'mood_glitch'),
                      ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: generateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                AppLocalizations.translate(context, 'generate_code'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 236, 237, 235),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (codeVisible) ...[
              Text(
                AppLocalizations.translate(context, 'your_partner_code'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withAlpha((0.25 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SelectableText(
                  generatedCode,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.translate(context, 'share_code_message'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.translate(context, 'preview_partner_see'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
