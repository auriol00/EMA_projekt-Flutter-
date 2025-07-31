import 'package:flutter/material.dart';
import 'package:moonflow/models/period_model.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import 'package:moonflow/utilities/customCalenderWidget.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarPage extends StatefulWidget {
  final List<PeriodData> periods;

  const CustomCalendarPage({super.key, required this.periods});

  @override
  State<CustomCalendarPage> createState() => _CustomCalendarPageState();
}

class _CustomCalendarPageState extends State<CustomCalendarPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool isEditing = false;
  DateTime? initialStart;
  DateTime? initialEnd;

  List<PeriodData> _periods = [];

  Future<void> _loadPeriods() async {
    final periods = await PeriodFirestoreService.loadAllPeriods();
    setState(() {
      _periods = periods;
    });
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _endDate = now.add(const Duration(days: 4));
    initialStart = _startDate;
    initialEnd = _endDate;
    _loadPeriods();
  }

  void _onDateSelected(DateTime start, DateTime end) {
    if (!isEditing) return;

    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  void showStyledSnackBar(BuildContext context, String message, {
  IconData icon = Icons.info_outline,
  Color? backgroundColor,
}) {
  final cs = Theme.of(context).colorScheme;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 6,
      content: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}


  void _showEditOrDeleteDialog(PeriodData period) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
return AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  title: Row(
    children: [
      const Icon(Icons.calendar_month, color: Colors.deepPurple),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          AppLocalizations.translate(context, 'period_selected'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ],
  ),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 8),
      Text(
        AppLocalizations.translate(context, 'edit_or_delete')
            .replaceAll('{start}', '${period.start.day}.${period.start.month}')
            .replaceAll('{end}', '${period.end.day}.${period.end.month}'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  ),
  actionsAlignment: MainAxisAlignment.spaceEvenly,
  actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
  actions: [
    TextButton.icon(
      onPressed: () => Navigator.pop(context, 'delete'),
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: Text(
        AppLocalizations.translate(context, 'delete'),
        style: const TextStyle(color: Colors.red),
      ),
    ),
    TextButton.icon(
      onPressed: () => Navigator.pop(context, 'edit'),
      icon: const Icon(Icons.edit_outlined),
      label: Text(AppLocalizations.translate(context, 'edit')),
    ),
    TextButton.icon(
      onPressed: () => Navigator.pop(context, 'cancel'),
      icon: const Icon(Icons.close),
      label: Text(AppLocalizations.translate(context, 'cancel')),
    ),
  ],
);

      },
    );

    if (!mounted) return;
    if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text(
                AppLocalizations.translate(context, 'delete_period_title'),
              ),
              content: Text(
                AppLocalizations.translate(context, 'confirm_delete'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(AppLocalizations.translate(context, 'cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    AppLocalizations.translate(context, 'delete_confirm'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true && period.id != null && period.id!.isNotEmpty) {
        await PeriodFirestoreService.deletePeriod(period.id!);
        await _loadPeriods();
        if (!mounted) return;
        if (context.mounted) {
          showStyledSnackBar(context ,AppLocalizations.translate(context, 'period_deleted'), icon: Icons.delete, backgroundColor: Colors.red.shade100);
          Navigator.pop(context, {'start': period.start, 'end': period.end});
        }
      }
      
    } else if (result == 'edit') {
      setState(() {
        isEditing = true;
        _startDate = period.start;
        _endDate = period.end;
        initialStart = period.start;
        initialEnd = period.end;
      });
      if (context.mounted) {
        showStyledSnackBar(context , AppLocalizations.translate(context, 'edit_mode_activated'), icon: Icons.edit_outlined);
      }
    }
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 10,
          child: Icon(icon, size: 14, color: Colors.black54),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(context, 'moonflow')),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CustomCalendarWidget(
            key: ValueKey(_periods.length),
            format: CalendarFormat.month,
            periods: _periods,
            onDateSelected: _onDateSelected,
            isInteractive: isEditing,
            onPeriodTap: (period) {
              if (!isEditing) {
                _showEditOrDeleteDialog(period);
              }
            },
          ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                AppLocalizations.translate(context, 'editing period'),
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.translate(context, 'cancel'),
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),

                if (isEditing)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = initialStart;
                        _endDate = initialEnd;
                        isEditing = false;
                      });
                    },
                    child: Text(
                      AppLocalizations.translate(context, 'reset'),
                      style: TextStyle(color: cs.secondary),
                    ),
                  ),

                if (isEditing)
                  TextButton(
                    onPressed:
                        (_startDate == null)
                            ? null
                            : () async {
                              _endDate ??= _startDate;

                              final newPeriod = PeriodData(
                                id: '',
                                start: _startDate!,
                                end: _endDate!,
                                source: 'calendar',
                              );

                              final isModifying =
                                  isEditing && initialStart != null;

                              final overlapping =
                                  _periods.where((p) {
                                    final isSameAsOriginal =
                                        initialStart != null &&
                                        initialEnd != null &&
                                        p.start == initialStart &&
                                        p.end == initialEnd;

                                    return !isSameAsOriginal &&
                                        (_startDate!.isBefore(p.end) &&
                                            _endDate!.isAfter(p.start));
                                  }).toList();

                              final exactMatch = overlapping.any(
                                (p) =>
                                    p.start == _startDate && p.end == _endDate,
                              );

                              if (exactMatch) {
                              showStyledSnackBar(context,
                                  AppLocalizations.translate(context, 'period_exists'),
                                  icon: Icons.warning_amber_rounded,
                                  backgroundColor: Colors.orange.shade100,
                                );
                                return;
                              }

                              for (final p in overlapping) {
                                if (p.id != null && p.id!.isNotEmpty) {
                                  await PeriodFirestoreService.deletePeriod(
                                    p.id!,
                                  );
                                }
                              }

                              if (isModifying) {
                                final toUpdate = _periods.firstWhere(
                                  (p) =>
                                      p.start == initialStart &&
                                      p.end == initialEnd,
                                  orElse: () => newPeriod,
                                );

                                if (toUpdate.id != null &&
                                    toUpdate.id!.isNotEmpty) {
                                  await PeriodFirestoreService.updatePeriod(
                                    toUpdate.id!,
                                    newPeriod,
                                  );
                                } else {
                                  await PeriodFirestoreService.addPeriod(
                                    newPeriod,
                                  );
                                }
                              } else {
                                await PeriodFirestoreService.addPeriod(
                                  newPeriod,
                                );
                              }

                              await _loadPeriods();

                              if (context.mounted) {
                               showStyledSnackBar(context,
                                  AppLocalizations.translate(context, 'period_saved'),
                                  icon: Icons.check_circle,
                                  backgroundColor: Colors.green.shade100,
                                );
                                Navigator.pop(context, {
                                  'start': newPeriod.start,
                                  'end': newPeriod.end,
                                  'periods':_periods,
                                });
                              }
                            },
                    child: Text(
                      AppLocalizations.translate(context, 'save'),
                      style: TextStyle(color: cs.primary),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                        _startDate = null;
                        _endDate = null;
                        initialStart = null;
                        initialEnd = null;
                      });

                 showStyledSnackBar(context,
                        AppLocalizations.translate(context, 'select_date'),
                        icon: Icons.calendar_today,
                        backgroundColor: Colors.purple.shade100,
                      );
                    },
                    icon: Icon(Icons.edit, color: cs.primary),
                    label: Text(
                      AppLocalizations.translate(context, 'edit_period'),
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.translate(context, 'legend'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildLegendItem(
                      Colors.pink.shade100,
                      Icons.water_drop,
                      AppLocalizations.translate(context, 'legend_period'),
                    ),
                    _buildLegendItem(
                      Colors.blue.shade200,
                      Icons.bolt,
                      AppLocalizations.translate(context, 'legend_ovulation'),
                    ),
                    _buildLegendItem(
                      Colors.lightBlue.shade100,
                      Icons.spa,
                      AppLocalizations.translate(context, 'legend_fertile'),
                    ),
                    _buildLegendItem(
                      Colors.purple.shade400,
                      Icons.calendar_month,
                      AppLocalizations.translate(context, 'legend_selected'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
