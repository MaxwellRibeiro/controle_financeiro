import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> _signInWithGoogle() async {
    try {
      // 1. Faz o pedido de login via Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Usuário cancelou o login
        return;
      }

      // 2. Obtem os detalhes de autenticação
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Cria uma credencial para FirebaseAuth
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz o login no Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Se chegou até aqui, estamos logados!

    } catch (e) {
      // Trate os erros de login
      debugPrint('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login com Google"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Login com Google"),
          onPressed: _signInWithGoogle,
        ),
      ),
    );
  }
}