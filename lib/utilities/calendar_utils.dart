import 'package:flutter/material.dart';
import 'package:moonflow/pages/customCalendar_page.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/models/period_model.dart';

Future<Map<String, DateTime>?> openCalendarPicker(BuildContext context) async {
  
  List<PeriodData> periods = List.from(await PeriodFirestoreService.loadAllPeriods()); 
  // Ajoute une période par défaut si rien n'est enregistré

  return await Navigator.push<Map<String, DateTime>>(
    context,
    MaterialPageRoute(
      builder: (_) => CustomCalendarPage(
        periods: periods,
      ),
    ),
  );
}


