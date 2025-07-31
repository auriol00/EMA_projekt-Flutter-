import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moonflow/components/infoBox.dart';

class PartnerConnectPage extends StatefulWidget {
  final String partnerUid;

  const PartnerConnectPage({super.key, required this.partnerUid});

  @override
  State<PartnerConnectPage> createState() => _PartnerConnectPageState();
}

class _PartnerConnectPageState extends State<PartnerConnectPage> {
  String? partnerName;
  List<Map<String, dynamic>> combinedData = [];
  String? error;

  @override
  void initState() {
    super.initState();
    loadPartnerData();
  }

  Future<void> loadPartnerData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.partnerUid)
              .get();

      final periodsSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.partnerUid)
              .collection('periods')
              .orderBy('start', descending: true)
              .get();

      final symptomsSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.partnerUid)
              .collection('symptoms')
              .get();

      partnerName = userDoc.data()?['username'] ?? 'Partnerin';

      final symptoms = {
        for (var doc in symptomsSnapshot.docs) doc.data()['date']: doc.data(),
      };

      combinedData =
          periodsSnapshot.docs.map((doc) {
            final period = doc.data();
            final DateTime startDate = (period['start'] as Timestamp).toDate();
            final isoStartDate =
                DateUtils.dateOnly(startDate).toIso8601String();

            final symptomData = symptoms[isoStartDate];
            return {
              'start': period['start'],
              'end': period['end'],
              ...?symptomData,
            };
          }).toList();

      setState(() => error = null);
    } catch (e) {
      setState(() => error = "Fehler: ${e.toString()}");
    }
  }

  String formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return DateFormat('dd.MM.yyyy').format(date);
    }
    return value.toString();
  }

  String? getFirstMood(dynamic value) {
    if (value is String) return value;
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first;
    }
    return null;
  }

  String getSupportTip(String? mood) {
    switch (mood?.toLowerCase()) {
      case "traurig":
        return "🎁 Schenk ihr etwas Kleines oder hör ihr einfach zu.";
      case "gestresst":
        return "💐 Überrasche sie mit Blumen oder einem lieben Wort.";
      case "müde":
        return "☕ Mach ihr einen Tee oder Kaffee. Ruhe tut gut.";
      case "wütend":
        return "🎧 Lass sie Musik hören und sich entspannen.";
      case "glücklich":
        return "😊 Sag ihr, wie sehr du sie schätzt.";
      default:
        return "🫂 Frag sie, wie du helfen kannst.";
    }
  }

  String emojiForMood(String? mood) {
    switch (mood?.toLowerCase()) {
      case "traurig":
        return "😢";
      case "gestresst":
        return "😖";
      case "müde":
        return "😴";
      case "glücklich":
        return "😊";
      case "wütend":
        return "😡";
      default:
        return "💜";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "💞 Ihr seid verbunden",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/Partner.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        const TextSpan(text: "Du bist jetzt mit "),
                        TextSpan(
                          text: partnerName,
                          style: TextStyle(
                            color:
                                Colors
                                    .pink[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const TextSpan(text: " verbunden."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "So geht es ihr in den letzten Tagen.\nZeig ihr, dass du für sie da bist 💜",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            if (partnerName != null && combinedData.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (var cycle in combinedData) ...[
                Column(
                  children: [
                    infoBox(
                      title: "Zyklus",
                      value:
                          "${formatTimestamp(cycle['start'])} → ${formatTimestamp(cycle['end'])}",
                      icon: Icons.calendar_today,
                    ),
                    if (cycle['physical'] != null && cycle['physical'] is List)
                      infoBox(
                        title: "Physisch",
                        value: (cycle['physical'] as List).join(', '),
                        icon: Icons.fitness_center,
                      ),
                    if (cycle['emotional'] != null &&
                        cycle['emotional'] is List)
                      infoBox(
                        title: "Emotional",
                        value: (cycle['emotional'] as List).join(', '),
                        icon: Icons.psychology,
                      ),
                    if (cycle['ausflusse'] != null &&
                        cycle['ausflusse'] is List)
                      infoBox(
                        title: "Ausfluss",
                        value: (cycle['ausflusse'] as List).join(', '),
                        icon: Icons.water_drop,
                      ),
                    if (cycle['flux'] != null && cycle['flux'] is List)
                      infoBox(
                        title: "Fluss",
                        value: (cycle['flux'] as List).join(', '),
                        icon: Icons.waves,
                      ),
                    if (cycle['note'] != null &&
                        cycle['note'] is String &&
                        cycle['note'].isNotEmpty)
                      infoBox(
                        title: "Notiz",
                        value: cycle['note'],
                        icon: Icons.notes,
                      ),
                    infoBox(
                      title: "Tipp",
                      value: getSupportTip(getFirstMood(cycle['emotional'])),
                      icon: Icons.tips_and_updates,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ],
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Gruß gesendet!")));
              },
              icon: const Icon(Icons.favorite, color: Colors.pink),
              label: const Text("Kleinen Gruß senden"),
            ),
          ],
        ),
      ),
    );
  }
}