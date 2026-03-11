import 'package:cronos_front/features/lesson/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PUCApp());
}

class PUCApp extends StatelessWidget {
  const PUCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronograma PUC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}
