import 'package:flutter/material.dart';
// import 'screens/home_screen.dart'; // Não precisa mais deste import aqui
import 'screens/welcome_screen.dart'; // <-- ADICIONE O IMPORT DA NOVA TELA

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor Cripto',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.from(alpha: 1, red: 0.404, green: 0.227, blue: 0.718),
        
      ),      
      home: const WelcomeScreen(),
    );
  }
}