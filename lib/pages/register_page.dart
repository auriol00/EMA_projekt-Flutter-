import 'package:flutter/material.dart';
import 'package:moonflow/components/Formtextflield.dart';
import 'package:moonflow/helper/CheckUserNameExists.dart';
import 'package:moonflow/services/auth/auth_services.dart';
import 'package:moonflow/helper/helper_functions.dart';
import 'package:moonflow/helper/my_loading_circle.dart';
import 'package:provider/provider.dart';
import '../components/button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void register(BuildContext context) async {
    final auth = Provider.of<AuthServices>(context, listen: false);
    bool exists = await checkUserNameExists(_userNameController.text);

    if (exists && context.mounted) {
      displayMessageToUser("Username schon besetzt, wähle einen anderen", context);
      return;
    }

    if (_formKey.currentState!.validate()) {
    

      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          await auth.signUpWithEmailPassword(
            _emailController.text.trim(),
            _userNameController.text.trim(),
            _passwordController.text.trim(),
          );

        
      
        } catch (e) {
          if (context.mounted) {
            hideLoadingCircle(context);
            displayMessageToUser(getFriendlyErrorMessage(e.toString()), context);
          }
        }
      } else {
          if (context.mounted) hideLoadingCircle(context);
        if (context.mounted) displayMessageToUser("Passwörter stimmen nicht überein", context);
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
         // padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Lass uns dein Konto erstellen',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                autovalidateMode: _autoValidateMode,
                child: Column(
                  children: [
                    FormTextField(
                      controller: _userNameController,
                      hintText: 'Username (optional)',
                      obscureText: false,
                      //validator: (value) =>
                          //(value == null || value.isEmpty) ? 'Username erforderlich' : null,
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email erforderlich';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                          return 'Ungültige Email-Adresse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: _passwordController,
                      hintText: 'Passwort',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Passwort erforderlich';
                        if (value.length < 6) return 'Mindestens 6 Zeichen';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Passwort bestätigen',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Bestätigung erforderlich';
                        if (value != _passwordController.text) return 'Passwörter stimmen nicht überein';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Registrieren",
                onTap: () => register(context),
                backgroundColor: colorScheme.secondary,
                textColor: Colors.white,
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Schon Mitglied?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Jetzt Einloggen',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
