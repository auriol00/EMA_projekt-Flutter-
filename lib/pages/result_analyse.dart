import 'package:flutter/material.dart';
import 'package:moonflow/components/button.dart';
import 'package:moonflow/pages/home_page.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';

class ResultAnalyse extends StatelessWidget {
  final List<String> userAnswers;

  const ResultAnalyse({super.key, required this.userAnswers});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Dein Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Danke, dass du an dem kleinen Quiz teilgenommen hast.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            //Text(summary, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            MyButton(
              onTap: () async {
                await saveInitialPeriodToFirestore(userAnswers);
                if(!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              text: 'Weiter',
            ),

          ],
        ),
      ),
    );
  }
}

