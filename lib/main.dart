import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moonflow/services/auth/auth_gate.dart';
import 'package:moonflow/services/auth/auth_services.dart';
import 'package:moonflow/firebase_options.dart';
import 'package:moonflow/themes/themeData.dart';
import 'package:moonflow/themes/themeProvider.dart';
import 'package:moonflow/utilities/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  Provider.debugCheckInvalidValueType = null;

  await initializeDateFormatting('de_DE', null);
  Intl.defaultLocale = 'de_DE';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;


  }


  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServices>(create: (_) => AuthServices()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageProvider>(context); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:themeProvider.themeMode,
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
         Locale('en', 'US')],
      initialRoute: '/',
      routes: {

        '/': (context) => const AuthGate(),
      },
    );
  }
}
