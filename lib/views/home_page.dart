import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/category_form.dart';
import '../widgets/chart.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';
import 'expenses_chart_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  /// Abre o modal para criar nova transação
  void _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final viewModel = Provider.of<TransactionViewModel>(
          context,
          listen: false,
        );
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransactionForm(viewModel.addTransaction),
        );
      },
    );
  }

  /// Faz logout do FirebaseAuth
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TransactionViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Despesas Pessoais',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Gráfico de Gastos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpensesChartPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Categorias',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoryForm()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut,
          ),
        ],
      ),
      body: viewModel.transactions.isEmpty && viewModel.categories.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Chart(viewModel.recentTransactions),
            TransactionList(
              viewModel.transactions,
              viewModel.removeTransaction,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
        onPressed: () => _openTransactionFormModal(context),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
