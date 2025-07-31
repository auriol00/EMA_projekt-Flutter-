import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/pages/home_page.dart';
import 'package:moonflow/pages/questions_page.dart';
import 'package:moonflow/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isProfileComplete(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return doc.exists && doc.data()?['profileComplete'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (user == null) {
          return const LoginOrRegister();
        }

        return FutureBuilder<bool>(
          future: isProfileComplete(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting ||
                !profileSnapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final isComplete = profileSnapshot.data!;
            return isComplete ? const HomePage() : const QuestionsPage();
          },
        );
      },
    );
  }
}
