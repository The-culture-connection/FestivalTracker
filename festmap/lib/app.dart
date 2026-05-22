import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/festmap_theme.dart';

class FestMapApp extends StatelessWidget {
  const FestMapApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FestMap',
      debugShowCheckedModeBanner: false,
      theme: buildFestMapTheme(),
      home: firebaseReady ? const HomeScreen() : const SetupScreen(),
    );
  }
}
