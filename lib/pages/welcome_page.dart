import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget{
  const WelcomePage({super.key});
  
  @override
  State<WelcomePage> createState() => _WelcomePageState();
  
  }

class _WelcomePageState extends State<WelcomePage> {
  
  @override
  void initState() {
    super.initState();
    // Attendre 4 secondes avant d’aller vers la page login
    Future.delayed(const Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/auth');
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/moonflow_logo.png',
                        height: 180,
                        ),
                      
                      const SizedBox(height: 40),
                      
                      const Text(
                        'Dein Zyklus. Dein MoonFlow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7E57C2)
                        ),
                      )
                    ],

                  )
              )
          ),
        )
    );
  }

}