import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/Formtextflield.dart';
import 'package:moonflow/components/button.dart';
import 'package:moonflow/helper/helper_functions.dart';

class ForgotPwPage extends StatefulWidget {
  const ForgotPwPage({super.key});

  @override
  State<ForgotPwPage> createState() => _ForgotPwPageState();
}

class _ForgotPwPageState extends State<ForgotPwPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future pwReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        displayMessageToUser(
          "Password reset link sent! Check your email",
          context,
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      if (mounted) {
        displayMessageToUser(e.message.toString(), context);
      }
    }
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 40),

          FormTextField(
            controller: _emailController,
            hintText: 'email',
            obscureText: false,
          ),

          const SizedBox(height: 10),

          MyButton(
            onTap: () => pwReset(),
            text: 'Reset passWord',
          ),
        ],
      ),
    );
  }
}
