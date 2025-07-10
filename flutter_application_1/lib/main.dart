import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

// PALETA DE CORES 
const Color corFundo = Color(0xFF060704);
const Color corLaranja = Color(0xFFF4A921);
const Color corVerde = Color(0xFF73AC32);
const Color corCard = Color(0xFF1C1C1E); 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cripto Duelo',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: corFundo,

        appBarTheme: const AppBarTheme(
          backgroundColor: corLaranja,
          foregroundColor: corFundo,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: corFundo,
          ),
        ),

        
        cardTheme: CardThemeData( 
          color: corCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: corCard,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),

        colorScheme: const ColorScheme.dark(
          primary: corLaranja,
          secondary: corVerde,
          background: corFundo,
          surface: corCard,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}