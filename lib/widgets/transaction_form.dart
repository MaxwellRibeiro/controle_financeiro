import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';

class TransactionForm extends StatefulWidget {
  final void Function(String, double, DateTime, String) onSubmit;

  const TransactionForm(this.onSubmit, {Key? key}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  String? _selectedCategory;

  _submitForm() {
    final title = _titleController.text;
    final value = double.tryParse(_valueController.text) ?? 0;

    if (title.isEmpty || value <= 0 || _selectedDate == null || _selectedCategory == null) {
      _showErrorDialog();
      return;
    }

    widget.onSubmit(title, value, _selectedDate!, _selectedCategory!);
    Navigator.of(context).pop();
  }

  _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Erro',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          content: const Text('Por favor, preencha todos os campos corretamente.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtém o tema atual
    final viewModel = Provider.of<TransactionViewModel>(context);
    final categories = viewModel.categories;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      color: theme.cardColor, // Cor do card adaptada ao tema
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: theme.colorScheme.surface, // Adapta ao tema
                labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Cor do texto
            ),
            const SizedBox(height: 10),

            // Campo de Valor
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: theme.colorScheme.surface, // Adapta ao tema
                labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color), // Cor do texto
            ),
            const SizedBox(height: 10),

            // Selecionar Data
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Nenhuma data selecionada!'
                        : 'Data: ${_selectedDate!.toLocal()}'.split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color, // Cor do texto
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showDatePicker,
                  child: const Text(
                    'Selecionar Data',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dropdown de Categoria
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: theme.colorScheme.surface, // Adapta ao tema
                labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              value: _selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Botão de Salvar
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: theme.colorScheme.primary, // Cor do botão adaptada ao tema
                foregroundColor: theme.colorScheme.onPrimary, // Cor do texto do botão
              ),
              child: const Text(
                'Salvar Transação',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
