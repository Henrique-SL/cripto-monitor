import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Ouve o estado de autenticação do usuário em tempo real
      stream: authService.user,
      builder: (context, snapshot) {
        // Enquanto está verificando, mostra uma tela de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se o snapshot tiver dados (ou seja, o objeto User não é nulo),
        // significa que o usuário está logado.
        if (snapshot.hasData) {
          // Então, mostre a tela de boas-vindas.
          return const WelcomeScreen();
        } else {
          // Senão, mostre a tela de login.
          return const LoginScreen();
        }
      },
    );
  }
}