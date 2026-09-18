import 'package:flutter/material.dart';
import 'package:rifa_gc/constants/app_colors.dart';
import 'package:rifa_gc/screens/home_screen.dart';

void main() {
  runApp(const RifaGcApp());
}

class RifaGcApp extends StatelessWidget {
  const RifaGcApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rifa GC',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: fondo,

        colorScheme: ColorScheme.fromSeed(
          seedColor: terracota,
          brightness: Brightness.light,
          surface: superficie,
        ).copyWith(
          primary: terracota,
          onPrimary: Colors.white,
          surface: superficie,
          onSurface: texto,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: fondo,
          foregroundColor: texto,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),

        cardTheme: const CardThemeData(
          color: superficie,
          elevation: 1,
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: superficie,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              color: Color(0xFFE2D8CC),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              color: Color(0xFFE2D8CC),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              color: terracota,
              width: 2,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: terracota,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: texto,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(
              color: Color(0xFFD8C9BC),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}