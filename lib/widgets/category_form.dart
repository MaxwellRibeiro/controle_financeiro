import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';

class CategoryForm extends StatelessWidget {
  const CategoryForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final theme = Theme.of(context); // Obtém o tema atual

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Cor de fundo adaptada ao tema
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              'Cadastrar Nova Categoria',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold // Usa a cor primária do tema
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo de texto para Nome da Categoria
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface, // Adapta ao tema
                labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Cor do texto adaptada ao tema
            ),
            const SizedBox(height: 20),

            // Botão Salvar
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  Provider.of<TransactionViewModel>(context, listen: false)
                      .addCategory(_nameController.text);
                  _showErrorSucesso(context, _nameController);
                } else {
                  _showErrorDialog(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Cor do botão adaptada ao tema
                foregroundColor: theme.colorScheme.onPrimary, // Cor do texto do botão adaptada
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostra um diálogo de sucesso quando a categoria é salva
  void _showErrorSucesso(BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context); // Obtém o tema atual
        return AlertDialog(
          title: Text(
            'Sucesso',
            style: TextStyle(color: theme.colorScheme.primary), // Cor adaptada ao tema
          ),
          content: const Text('Categoria salva com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
              Navigator.of(ctx).pop();
              controller.clear();// Fecha o formulário após a confirmação/ Fecha o formulário após a confirmação
            },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  // Mostra um diálogo de erro se o nome da categoria estiver vazio
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context); // Obtém o tema atual
        return AlertDialog(
          title: Text(
            'Erro',
            style: TextStyle(color: theme.colorScheme.error), // Cor adaptada ao tema
          ),
          content: const Text('Por favor, insira um nome para a categoria.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
