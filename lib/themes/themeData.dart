import 'package:flutter/material.dart';

final Color customSeedColor = const Color.fromRGBO(90, 52, 116, 1);


final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF7E57C2),
    secondary: Color(0xFFC64995),
    tertiary: Color(0xFFB39DDB),
    secondaryContainer: Color(0xFFEDE7F6),
    tertiaryContainer: Color(0xFFD1C4E9),
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F8FA),      
  cardColor: Colors.white,
  dividerColor: const Color(0xFFE6ECF0),                 
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F0F0),                   
    hintStyle: TextStyle(color: Colors.grey[600]),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: customSeedColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Color.fromRGBO(239, 220, 252, 1.0),
    indicatorColor: const Color.fromARGB(200, 207, 144, 246),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
    ),
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(size: 22, color: Colors.black87),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0.5,
  ),
  iconTheme: const IconThemeData(color: Colors.black87),
  splashFactory: InkRipple.splashFactory,
);


final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(200, 207, 144, 246),
    surface: Color(0xFF15202B),
    secondary: Color(0xFFC64995),
    tertiary: Color.fromARGB(200, 147, 104, 186),
    secondaryContainer: Color(0xFF1E1A36),
    tertiaryContainer: Color(0xFF2D2252),
  ),
  scaffoldBackgroundColor: const Color(0xFF15202B),       // Twitter dark bg
  cardColor: const Color(0xFF192734),                     // tweet cards
  dividerColor: const Color(0xFF38444D),                  // lignes sombres Twitter
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2F3336),                         // champ sombre Twitter
    hintStyle: TextStyle(color: Color(0xFF8899A6)),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF38444D)),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(200, 207, 144, 246)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF192734),
    indicatorColor: const Color.fromARGB(200, 207, 144, 246),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
    ),
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(size: 22, color: Colors.white70),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF192734),
    foregroundColor: Colors.white,
    elevation: 0.5,
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  splashFactory: InkRipple.splashFactory,
);
