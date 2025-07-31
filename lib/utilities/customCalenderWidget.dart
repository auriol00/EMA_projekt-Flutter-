import 'package:flutter/material.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/services/period_logic.dart';
import 'package:moonflow/services/quiz_firestore_services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';

class CustomCalendarWidget extends StatefulWidget {
  final CalendarFormat format;
  final Function(DateTime start, DateTime end)? onDateSelected;
  final List<PeriodData> periods;
  final bool isInteractive;
  final void Function(PeriodData period)? onPeriodTap;

  const CustomCalendarWidget({
    super.key,
    required this.format,
    required this.periods,
    this.onDateSelected,
    this.isInteractive = false,
    this.onPeriodTap,
  });

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;

  int? cycleLength;
  int? periodLength;
  bool isLoading = true;

  List<PeriodData> allPeriods = [];

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    calendarFormat = widget.format;
    _rangeSelectionMode = widget.isInteractive
        ? RangeSelectionMode.toggledOff
        : RangeSelectionMode.disabled;
    _loadData();
  }

  Future<void> _loadData() async {
    final quizData = await QuizFirestoreService.loadQuizAnswers();
    final List<PeriodData> mergedPeriods = List.from(widget.periods);

    cycleLength = quizData?['cycleLength'];
    periodLength = quizData?['periodLength'];

    final hasManualPeriods = mergedPeriods.any((p) => p.source != 'quiz');
    if (!hasManualPeriods && quizData != null) {
      final DateTime start = DateTime.parse(quizData['firstPeriodDate']);
      final int periodLen = quizData['periodLength'];
      mergedPeriods.add(
        PeriodData(
          start: start,
          end: start.add(Duration(days: periodLen - 1)),
          source: 'quiz',
        ),
      );
    }

    setState(() {
      allPeriods = mergedPeriods;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || cycleLength == null || periodLength == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TableCalendar(
      rowHeight: 48,
      firstDay: DateTime(2025),
      lastDay: DateTime(2050),
      focusedDay: _focusedDay,
      calendarFormat: calendarFormat,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode: _rangeSelectionMode,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12),
      ),

      

      onRangeSelected: (start, end, focusedDay) {
        if (!widget.isInteractive) return;

        final now = DateTime.now();
        if ((start != null && start.isAfter(now)) ||
            (end != null && end.isAfter(now))) {
          return;
        }

        setState(() {
          _rangeStart = start;
          _rangeEnd = end;
          _focusedDay = focusedDay;
          _rangeSelectionMode = RangeSelectionMode.toggledOn;
        });

        if (widget.onDateSelected != null && start != null && end != null) {
          widget.onDateSelected!(start, end);
        }
      },

      onFormatChanged: (format) {
        setState(() => calendarFormat = format);
      },

calendarBuilders: CalendarBuilders(
  defaultBuilder: (context, day, _) {
    final type = getDayType(
      date: day,
      periods: allPeriods,
      cycleLength: cycleLength!,
      periodLength: periodLength!,
    );

    final colors = getDayColors(type);
    final bgColor = colors['bg']!;
    final textColor = colors['text']!;

    final isInRange = _rangeStart != null &&
        _rangeEnd != null &&
        !day.isBefore(_rangeStart!) &&
        !day.isAfter(_rangeEnd!);

    final tappedPeriod = allPeriods.firstWhereOrNull(
      (p) => !day.isBefore(p.start) && !day.isAfter(p.end),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {
          if (tappedPeriod != null && tappedPeriod.source != 'quiz') {
            if (!widget.isInteractive && widget.onPeriodTap != null) {
              widget.onPeriodTap!(tappedPeriod);
              return;
            }
          }

          if (!widget.isInteractive) return;

          if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
            setState(() {
              _rangeStart = day;
              _rangeEnd = null;
              _focusedDay = day;
              _rangeSelectionMode = RangeSelectionMode.toggledOn;
            });
          } else if (_rangeStart != null && _rangeEnd == null) {
            if (day.isBefore(_rangeStart!)) {
              setState(() {
                _rangeEnd = _rangeStart;
                _rangeStart = day;
              });
            } else {
              setState(() {
                _rangeEnd = day;
              });

              if (widget.onDateSelected != null) {
                widget.onDateSelected!(_rangeStart!, _rangeEnd!);
              }
            }
          } else {
            setState(() {
              _rangeStart = day;
              _rangeEnd = null;
              _focusedDay = day;
              _rangeSelectionMode = RangeSelectionMode.toggledOn;
            });
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isInRange ? Colors.green.shade100 : bgColor,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  },
),

    );
  }
}
