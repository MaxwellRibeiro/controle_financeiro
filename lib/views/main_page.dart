import 'package:flutter/material.dart';
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

  final List<Widget> _screens = [
    const ExpensesChartPage(), // Gráfico
    const HomePage(),            // Home
    const CategoryForm(),        // Cadastro de Categoria
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
