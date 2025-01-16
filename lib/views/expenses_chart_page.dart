import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/transaction_viewmodel.dart';

class ExpensesChartPage extends StatefulWidget {
  const ExpensesChartPage({Key? key}) : super(key: key);

  @override
  State<ExpensesChartPage> createState() => _ExpensesChartPageState();
}

class _ExpensesChartPageState extends State<ExpensesChartPage> {
  DateTime _selectedMonth = DateTime.now();
  bool _isMonthPickerOpen = false;
  bool _isModalOpen = false;

  /// Seleção de mês
  Future<void> _selectMonth(BuildContext context) async {
    if (_isMonthPickerOpen) return;

    _isMonthPickerOpen = true;
    final pickedMonth = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    _isMonthPickerOpen = false;

    if (pickedMonth != null) {
      setState(() {
        _selectedMonth = pickedMonth;
      });
    }
  }

  /// Detalhamento de transações da categoria tocada
  void _showTransactionsForCategory(String categoryId, BuildContext context) {
    if (_isModalOpen) return;

    _isModalOpen = true;
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    final transactions = viewModel.transactions
        .where((transaction) =>
    transaction.categoryId == categoryId &&
        transaction.date.month == _selectedMonth.month &&
        transaction.date.year == _selectedMonth.year)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor, // Cor adaptada ao tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: WillPopScope(
            onWillPop: () async {
              _isModalOpen = false;
              return true;
            },
            child: transactions.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nenhuma transação para esta categoria no mês selecionado.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: transactions.length,
              separatorBuilder: (ctx, index) => Divider(
                color: Theme.of(context).dividerColor, // Adapta ao tema
                thickness: 1,
              ),
              itemBuilder: (ctx, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.monetization_on,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    'R\$ ${transaction.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isModalOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<TransactionViewModel>(context);
    final expensesData = viewModel.expensesByCategoryForMonth(_selectedMonth);
    final categories = viewModel.categories;

    // Geração de cores únicas para cada categoria
    final Map<String, Color> categoryColors = {};
    for (int i = 0; i < categories.length; i++) {
      final categoryId = categories[i].id;
      categoryColors[categoryId] = Colors.primaries[i % Colors.primaries.length]
          .withOpacity(0.8);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos por Categoria'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shadowColor: theme.shadowColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mês Selecionado:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      '${_selectedMonth.month}/${_selectedMonth.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 5,
                shadowColor: theme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PieChart(
                          PieChartData(
                            sections: expensesData
                                .map((data) => PieChartSectionData(
                              value: data.value,
                              title: '${data.value.toStringAsFixed(1)}%',
                              color: categoryColors[data.categoryId],
                              radius: 70,
                              titleStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ))
                                .toList(),
                            sectionsSpace: 6,
                            centerSpaceRadius: 50,
                            startDegreeOffset: 180,
                            pieTouchData: PieTouchData(
                              touchCallback: (touchResponse) {
                                final touchedSection =
                                    touchResponse.touchedSection;
                                if (touchedSection != null) {
                                  final categoryId = expensesData[
                                  touchedSection.touchedSectionIndex]
                                      .categoryId;
                                  _showTransactionsForCategory(
                                      categoryId, context);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: expensesData.length,
                          itemBuilder: (context, index) {
                            final categoryId = expensesData[index].categoryId;
                            final categoryName = categories
                                .firstWhere((cat) => cat.id == categoryId)
                                .name;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: categoryColors[categoryId],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color:
                                        theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${expensesData[index].value.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
