import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:sneaker_care_app/screens/home_page.dart'; 
import 'package:sneaker_care_app/services/order_provider.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: const SneakerCareApp(),
    ),
  );
}


class SneakerCareApp extends StatelessWidget {
  const SneakerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Care Indramayu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), 
          primary: const Color(0xFF0D47A1),   
          secondary: const Color(0xFFFF6D00), 
          surface: Colors.white,
        ),
        fontFamily: 'Roboto', 
      ),

      home: const HomePage(), 
    );
  }
}