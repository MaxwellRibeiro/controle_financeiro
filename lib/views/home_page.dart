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
    final theme = Theme.of(context); // Obtém o tema atual
    final viewModel = Provider.of<TransactionViewModel>(context);

    return Scaffold(
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
        backgroundColor: theme.colorScheme.primary, // Adapta ao tema
        foregroundColor: theme.colorScheme.onPrimary, // Cor do texto adaptada
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
