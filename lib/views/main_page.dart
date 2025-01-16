import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/category_form.dart';
import 'expenses_chart_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1; // Home será a tela inicial (índice 1)
  bool _isDarkMode = true; // Controlador para o modo escuro

  final List<Widget> _screens = [
    const ExpensesChartPage(), // Gráfico
    const HomePage(),          // Home
    const CategoryForm(),      // Cadastro de Categoria
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Alterna entre os temas
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login'); // Redireciona para a tela de login
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema escuro
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Alterna entre claro e escuro
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min, // Garante que o Row use apenas o espaço necessário
            children: [
              Icon(Icons.account_balance_wallet), // Ícone representando controle financeiro
              const SizedBox(width: 8), // Espaçamento entre o ícone e o texto
              const Text('Controle Financeiro'), // Texto ao lado do ícone
            ],
          ),
          centerTitle: true, // Centraliza o título da AppBar
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Altura da linha
            child: Container(
              color: Colors.grey, // Cor da linha
              height: 1.0, // Espessura da linha
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'theme') {
                  _toggleTheme(); // Alterna o tema ao selecionar a opção
                } else if (value == 'logout') {
                  _signOut(); // Faz logout
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 10),
                      Text(_isDarkMode ? 'Modo Claro' : 'Modo Escuro'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 10),
                      const Text('Sair'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _screens[_selectedIndex], // Exibe a tela correspondente ao índice selecionado
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.pie_chart),
              label: 'Gráfico',
            ),
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.category),
              label: 'Categorias',
            ),
          ],
        ),
      ),
    );
  }
}
