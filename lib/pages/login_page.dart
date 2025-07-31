//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/Formtextflield.dart';
import 'package:moonflow/services/auth/auth_services.dart';
import 'package:moonflow/components/square_tile.dart';
import 'package:moonflow/helper/helper_functions.dart';
import 'package:moonflow/pages/forgot_pw_page.dart';
import 'package:provider/provider.dart';
import '../components/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moonflow/pages/PartnerConnectPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // for Form
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  //_loginPageState gere l'etat dynamique du Wigdet
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _partnerCodeController = TextEditingController();
  bool _showPartnerCodeField = false;
  String? _partnerError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // login

  void login(BuildContext context) async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        await authService.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

       
      } catch (e) {
        if (context.mounted) {
          displayMessageToUser(getFriendlyErrorMessage(e.toString()), context);
        }
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  Future<void> validatePartnerCode() async {
    final code = _partnerCodeController.text.trim();

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('PartnerCodes')
              .where('code', isEqualTo: code)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        setState(() => _partnerError = "Ungültiger Code.");
        return;
      }

      final partnerDoc = query.docs.first;
      final partnerUid = partnerDoc['userId'];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PartnerConnectPage(partnerUid: partnerUid),
        ),
      );
    } catch (e) {
      setState(() => _partnerError = "Fehler: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            ClipOval(
              child: AspectRatio(
                aspectRatio: 2.5 / 1.5, // Width/Height (200/300)
                child: Image.asset(
                  'assets/moonflow_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Willkommen zurück, wir haben dich vermisst',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E57C2),
              ),
            ),

            const SizedBox(height: 20),

            Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Column(
                children: [
                  FormTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email darf nicht leer sein';
                      }
                      if (!value.contains('@')) {
                        return 'Ungültige Email-Adresse';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  FormTextField(
                    controller: _passwordController,
                    hintText: 'Passwort',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Passwort muss mindestens 6 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ForgotPwPage();
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Passwort vergessen?',
                      style: TextStyle(color: Color(0xFFC64995)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            MyButton(
              text: "Login",
              onTap: () => login(context), //loginUser
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[400]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Oder weiter mit',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //SquareTile(
                //onTap: () => AuthServices().signInWithGoogle(),
                //imagePath: 'assets/apple_logo.png'),
                SquareTile(
                  imagePath: 'assets/google_logo.png',
                  onTap:
                      () =>
                          Provider.of<AuthServices>(
                            context,
                            listen: false,
                          ).signInWithGoogle(),
                  height: 55,
                  width: (MediaQuery.of(context).size.width * 0.8).toInt(),
                  text: 'Sign in with Google',
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mitglied werden?',
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(width: 4),

                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    'Jetzt registrieren',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPartnerCodeField = !_showPartnerCodeField;
                    });
                  },
                  child: Text(
                    _showPartnerCodeField
                        ? 'Partnercode verbergen'
                        : 'Hast du einen Partnercode?',
                    style: const TextStyle(
                      color: Color(0xFFC64995),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (_showPartnerCodeField) ...[
              const SizedBox(height: 12),

              // champ de texte centré
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _partnerCodeController,
                      decoration: InputDecoration(
                        labelText: 'Partnercode',
                        border: OutlineInputBorder(),
                        errorText: _partnerError,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: validatePartnerCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC64995),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Mit Partnerin verbinden',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
