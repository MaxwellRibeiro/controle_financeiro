import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Usuário cancelou o login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50, // Fundo suave
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou Ícone
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.purple.shade100,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                "Bem-vindo ao Controle Financeiro!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtítulo
              Text(
                "Faça login para acessar suas finanças de forma segura e prática.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.purple.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botão de Login com Google
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/google_logo.png', // Certifique-se de ter o logo do Google em assets
                  height: 24,
                ),
                label: const Text(
                  "Login com Google",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  elevation: 3,
                ),
                onPressed: _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
