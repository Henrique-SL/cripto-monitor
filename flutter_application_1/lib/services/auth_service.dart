import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para Entrar com E-mail e Senha
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      // Aqui tratamos erros específicos do Firebase (ex: senha errada, usuário não encontrado)
      print('Erro de Login do Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Ocorreu um erro inesperado: ${e.toString()}');
      return null;
    }
  }

  // Função para Cadastrar com E-mail e Senha
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {      
      print('Erro de Cadastro do Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Ocorreu um erro inesperado: ${e.toString()}');
      return null;
    }
  }

  // Função para Sair (Logout)
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: ${e.toString()}');
    }
  }

  // Isso nos diz em tempo real se o usuário está logado ou não.
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}