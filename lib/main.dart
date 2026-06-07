import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/landing_page.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: const SneakimyCareApp(),
    ),
  );
}

class SneakimyCareApp extends StatelessWidget {
  const SneakimyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneakimy Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B),
          primary: const Color(0xFF1F1F1F),
          secondary: const Color(0xFFF59E0B),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F1F1F),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
    );
  }
}