import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonflow/components/CustomApp_Bar.dart';
import 'package:moonflow/components/button.dart';
import 'package:moonflow/components/info_box_grid.dart';
import 'package:moonflow/components/my_drawer.dart';
import 'package:moonflow/components/symptom_card.dart';
import 'package:moonflow/pages/customCalendar_page.dart';
import 'package:moonflow/pages/symptom_bottom_sheet.dart';
import 'package:moonflow/pages/symptom_page.dart';
import 'package:moonflow/services/offline_notifier.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/services/period_logic.dart';
import 'package:moonflow/services/symptom_services.dart';
import 'package:moonflow/services/today_page_loader.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import 'package:moonflow/utilities/customCalenderWidget.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/utilities/language_provider.dart';
import 'package:moonflow/utilities/messages_utils.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => TodayPageState();
}

class TodayPageState extends State<TodayPage> with WidgetsBindingObserver {
  List<PeriodData> periods = [];
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? lastSymptom;
  bool isLoadingSymptom = true;
  bool isLoadingQuiz = true;
  Map<String, dynamic>? quizData;
  // ignore: unused_field
  late OfflineNotifier _offlineNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _offlineNotifier = OfflineNotifier(context: context);
  }

  Future<void> _loadData() async {
    await _loadPeriods();
    await _loadQuizData();
    _loadSymptomEntry();
  }

  Future<void> _loadQuizData() async {
    final data = await TodayPageLoader.loadQuizData();
    setState(() {
      quizData = data;
      isLoadingQuiz = false;
    });
  }

  Future<void> _loadSymptomEntry() async {
    final normalizedDate = DateUtils.dateOnly(selectedDate);
    final entry = await SymptomService.getSymptomEntryForDate(normalizedDate);
    if (!mounted) return;
    setState(() {
      lastSymptom = entry;
      isLoadingSymptom = false;
    });
  }

  Future<void> _loadPeriods() async {
    final updated = await TodayPageLoader.loadAllPeriodsIncludingQuiz();
    setState(() {
      periods = updated;
      selectedDate = updated.isNotEmpty ? updated.last.start : DateTime.now();
    });
  }

  Future<void> _refreshPeriodsAfterCalendarInput() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCalendarPage(periods: periods),
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      if (result.containsKey('periods')) {
        setState(() {
          periods = List<PeriodData>.from(result['periods']);
          selectedDate = result['start'] ?? DateTime.now();
        });
      } else {
        await _loadData();
      }
    }
  }

  void _openSymptomPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomEntryPage(selectedDate: selectedDate),
      ),
    );
    _loadSymptomEntry();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSymptomEntry();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSymptomEntry();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        final relevantPeriods = getRelevantPeriods(periods, selectedDate);
        final lastPeriodText = getFormattedLastPeriod(context, periods);
        final formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

        final cycleLength =
            relevantPeriods.isNotEmpty
                ? calculateCycleLength(
                  relevantPeriods,
                  quizCycleLength: quizData?['cycleLength'],
                  referenceDate: selectedDate,
                )
                : (quizData?['cycleLength'] ?? 28);

        final periodLength =
            relevantPeriods.isNotEmpty
                ? calculatePeriodLength(
                  relevantPeriods,
                  quizPeriodLength: quizData?['periodLength'],
                  referenceDate: selectedDate,
                )
                : (quizData?['periodLength'] ?? 5);

        final message = getMessageForDate(
          context: context,
          periods: periods,
          cycleLength: cycleLength,
          periodLength: periodLength,
        );

        final customAppBarWithCalendar = CustomAppBar(
          title: Text(formattedDate),
          actions: [
            IconButton(
              onPressed: _refreshPeriodsAfterCalendarInput,
              icon: Icon(Icons.calendar_month, color: colorScheme.onSurface),
            ),
          ],
        );

        if (isLoadingQuiz) {
          return Scaffold(
            appBar: customAppBarWithCalendar,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: customAppBarWithCalendar,
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _offlineNotifier.isOffline,
                  builder: (context, isOffline, _) {
                    return isOffline
                        ? Container(
                          color: Colors.redAccent,
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          child: Text(
                            AppLocalizations.translate(context, 'offline_mode'),
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 10),
                CustomCalendarWidget(
                  format: CalendarFormat.week,
                  periods: periods,
                  isInteractive: false,
                  onDateSelected: (start, end) async {
                    setState(() => selectedDate = start);
                    await _loadSymptomEntry();
                  },
                ),
                const SizedBox(height: 20),
                if (periods.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                MyButton(
                  text: AppLocalizations.translate(context, "open calender"),
                  onTap: _refreshPeriodsAfterCalendarInput,
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  backgroundColor: colorScheme.primary,
                ),
                const SizedBox(height: 10),
                MyButton(
                  text: AppLocalizations.translate(context, "reset"),
                  onTap: () async {
                    await PeriodFirestoreService.clearManualPeriodsOnly();
                    setState(() {
                      periods.clear();
                      selectedDate = DateTime.now();
                    });
                    await _loadPeriods();
                  },
                  backgroundColor: colorScheme.errorContainer,
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      InfoBoxGrid(
                        periods: periods,
                        quizData: quizData!,
                        referenceDate: DateTime.now(),
                      ),
                      const SizedBox(height: 30),
                      SymptomCard(
                        onTap: _openSymptomPage,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.translate(context, 'last symptom entry'),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () async {
                          await _loadSymptomEntry();
                          if (lastSymptom == null || !context.mounted) return;

                          showModalBottomSheet(
                            context: context,
                            builder:
                                (_) => buildSymptomBottomSheet(
                                  lastSymptom,
                                  textTheme,
                                  colorScheme,
                                ),
                          );
                        },
                        icon: Icon(
                          Icons.visibility,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        label: Text(
                          AppLocalizations.translate(context, 'view'),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onSecondaryContainer,
                        ),
                        onPressed: _openSymptomPage,
                        icon: Icon(
                          Icons.edit,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        label: Text(
                          AppLocalizations.translate(context, 'edit'),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (lastPeriodText != null)
                  Text(lastPeriodText, style: textTheme.bodyMedium),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
