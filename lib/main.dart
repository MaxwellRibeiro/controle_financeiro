import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'views/login_page.dart';
import 'views/home_page.dart';
import 'viewmodels/transaction_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase

  runApp(
    ChangeNotifierProvider(
      create: (_) => TransactionViewModel()..initHive(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      // Verifica se há um usuário logado e direciona para a tela apropriada
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se o snapshot tem dados, significa que há um usuário logado
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Se não, vá para a tela de login
          return const LoginPage();
        },
      ),
    );
  }
}
