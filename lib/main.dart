import 'package:flutter/material.dart';
import 'ui/catculator_screen.dart';

void main() => runApp(const CatculatorApp());

class CatculatorApp extends StatelessWidget {
  const CatculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB7CE),
          brightness: Brightness.dark,
        ),
      ),
      home: const CatculatorScreen(),
    );
  }
}