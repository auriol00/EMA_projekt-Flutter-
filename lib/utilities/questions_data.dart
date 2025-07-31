import '../models/question_model.dart';

final List<QuestionModel> questionsData = [
  /**  QuestionModel(
    question: 'In welcher Altersgruppe befindest du dich?',
    options: ['Unter 16', '16–30', 'Über 30'],
  ),
  QuestionModel(
    question: 'Ist dein Zyklus regelmäßig?',
    options: ['Ja, ziemlich regelmäßig', 'Nein, sehr unregelmäßig', 'Ich weiß es nicht'],
  ), */
  QuestionModel(
  question: 'Wie viele Tage dauert deine Periode normalerweise?',
  type: QuestionType.number,
  ),


  QuestionModel(
  question: 'Wie lang ist dein Zyklus im Durchschnitt?',
  type: QuestionType.number,
  ),
  QuestionModel(
  question: 'Wann war der erste Tag deiner letzten Periode?',
  type: QuestionType.date,
  ),

  /**QuestionModel(
    question: 'Verfolgst du deinen Zyklus aktuell?',
    options: ['Ja, mit einer App', 'Ja, manuell (Kalender)', 'Nein'],
  ),
  QuestionModel(
    question: 'Was ist dein Hauptziel bei der Nutzung dieser App?',
    options: ['Besseres Verständnis meines Körpers', 'Zyklus verfolgen', 'Verhütung oder Schwangerschaftsplanung'],
  ),
  QuestionModel(
    question: 'Wie würdest du dein Wissen über deinen Zyklus einschätzen?',
    options: ['Ich weiß ziemlich viel', 'Ich weiß das Nötigste', 'Ich bin mir oft unsicher'],
  ), */
];

