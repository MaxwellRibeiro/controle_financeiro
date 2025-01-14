import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/category.dart';

class ExpensesChartPage extends StatelessWidget {
  const ExpensesChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TransactionViewModel>(context);
    final expensesData = viewModel.expensesByCategory;
    final categories = viewModel.categories;

    // Associa as cores às categorias
    final List<Color> colors = Colors.primaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Gastos por Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Gráfico de Pizza
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: expensesData.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final categoryName = categories
                        .firstWhere((cat) => cat.id == data.key)
                        .name;

                    return PieChartSectionData(
                      value: data.value,
                      title: '${data.value.toStringAsFixed(2)}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  })
                      .toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Legenda
            Expanded(
              child: ListView.builder(
                itemCount: expensesData.length,
                itemBuilder: (context, index) {
                  final categoryId = expensesData.keys.toList()[index];
                  final categoryName = categories
                      .firstWhere((cat) => cat.id == categoryId)
                      .name;

                  return Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[index % colors.length],
                        ),
                      ),
                      Text(
                        categoryName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
