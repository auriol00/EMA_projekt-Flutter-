import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/button.dart';
import 'package:moonflow/components/infobubble.dart';
import 'package:moonflow/components/textField.dart';
import 'package:moonflow/helper/my_loading_circle.dart';
import 'package:moonflow/models/question_model.dart';
import 'package:moonflow/pages/result_analyse.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/services/quiz_firestore_services.dart';
import 'package:moonflow/utilities/questions_data.dart';
import 'package:moonflow/components/option_card.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final List<QuestionModel> _questions = questionsData;
  List<String> collectedAnswers = [];
  final TextEditingController _numberController = TextEditingController();
  String? _typedAnswer;
  DateTime? _selectedDate;

  int currentIndex = 0;
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (currentIndex + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFFC64995),
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Lerne deinen Zyklus kennen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Lass uns gemeinsam deinen Zyklus besser verstehen!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                const Infobubble(
                  message:
                      'Beantworte ein paar Fragen, damit wir dir passende Infos geben können.',
                ),
                const SizedBox(height: 24),
                Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (currentQuestion.type == QuestionType.number)
                  MyTextField(
                    controller: _numberController,
                    hintText: currentQuestion.question.contains("Periode")
                        ? 'z. B. 4'
                        : 'z. B. 28',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _typedAnswer = value;
                      });
                    },
                  )
                else if (currentQuestion.type == QuestionType.date)
                  MyButton(
                    text:
                        _selectedDate == null
                            ? 'Datum auswählen'
                            : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    backgroundColor: Colors.grey.shade300,
                    textColor: Colors.black,
                  )
                else
                  ...currentQuestion.options!.map(
                    (option) => OptionCard(
                      option: option,
                      isSelected: _selectedAnswer == option,
                      onTap: () {
                        setState(() {
                          _selectedAnswer = option;
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      Expanded(
                        child: MyButton(
                          text: "Zurück",
                          backgroundColor: Colors.grey.shade300,
                          textColor: Colors.black,
                          onTap: () {
                            setState(() {
                              currentIndex--;
                              _selectedAnswer = null;
                            });
                          },
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyButton(
                        text:
                            currentIndex == _questions.length - 1
                                ? "Schließen"
                                : "Next",
                      isDisabled: (currentQuestion.type == QuestionType.number && (_typedAnswer == null || _typedAnswer!.isEmpty)) ||
                                (currentQuestion.type == QuestionType.date && _selectedDate == null) ||
                                (currentQuestion.type == QuestionType.multipleChoice && _selectedAnswer == null),


                        onTap: () async {
                          final answer = currentQuestion.type == QuestionType.number
                              ? _typedAnswer
                              : currentQuestion.type == QuestionType.date
                                  ? _selectedDate?.toIso8601String()
                                  : _selectedAnswer;

                          if (answer == null) return;

                          if (currentQuestion.type == QuestionType.number && int.tryParse(answer) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Bitte gib eine gültige Zahl ein.")),
                            );
                            return;
                          }

                          collectedAnswers.add(answer);

                          if (currentIndex < _questions.length - 1) {
                            setState(() {
                              currentIndex++;
                              _selectedAnswer = null;
                              _typedAnswer = null;
                              _selectedDate = null;
                              if (currentQuestion.type == QuestionType.number) {
                                _numberController.clear();
                              }
                            });
                          } else {
                            showLoadingCircle(context);

                            Future.delayed(const Duration(seconds: 2), () async {
                              if (!context.mounted) return;

                              hideLoadingCircle(context);

                              await PeriodFirestoreService.clearManualPeriodsOnly();
                              //await saveInitialPeriodToFirestore(collectedAnswers);

                              await QuizFirestoreService.saveQuizAnswers(
                                periodLength: int.parse(collectedAnswers[0]),
                                cycleLength: int.parse(collectedAnswers[1]),
                                firstPeriodDate: DateTime.parse(collectedAnswers[2]),
                              );
                              /*
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({'profileComplete': true}); */
                              await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .set({'profileComplete': true}, SetOptions(merge: true));


                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultAnalyse(userAnswers: collectedAnswers),
                                ),
                              );
                            });
                          }
                        },

                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
            ),

          ),
        ),
      ),
    );
  }
}
