import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../models/category.dart';
import '../models/transaction.dart';

class TransactionViewModel extends ChangeNotifier {
  late Box<Transaction> _transactionBox;
  late Box<Category> _categoryBox;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  List<ExpenseData> expensesByCategoryForMonth(DateTime selectedMonth) {
    final filteredTransactions = transactions.where((transaction) =>
    transaction.date.month == selectedMonth.month &&
        transaction.date.year == selectedMonth.year);

    final Map<String, double> groupedData = {};

    for (var transaction in filteredTransactions) {
      if (groupedData.containsKey(transaction.categoryId)) {
        groupedData[transaction.categoryId] =
            groupedData[transaction.categoryId]! + transaction.value;
      } else {
        groupedData[transaction.categoryId] = transaction.value;
      }
    }

    return groupedData.entries
        .map((entry) => ExpenseData(
      categoryId: entry.key,
      value: entry.value,
    ))
        .toList();
  }

  /// Retorna apenas transações dos últimos 7 dias
  List<Transaction> get recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      );
    }).toList();
  }

  Future<void> initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    // Registra os adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // Abre as boxes
    _transactionBox = await Hive.openBox<Transaction>('transactionsBox');
    _categoryBox = await Hive.openBox<Category>('categoriesBox');

    // Carrega dados locais iniciais
    _transactions = _transactionBox.values.toList();
    _categories = _categoryBox.values.toList();
    notifyListeners();

    // Configura listeners do Firestore
    _listenToFirestoreTransactions();
    _listenToFirestoreCategories();
  }

  /// Sincroniza transações do Firestore -> Hive
  void _listenToFirestoreTransactions() {
    _firestore.collection('transactions').snapshots().listen((querySnapshot) async {
      final firebaseTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Transaction(
          id: data['id'] as String,
          title: data['title'] as String,
          value: (data['value'] as num).toDouble(),
          date: DateTime.parse(data['date'] as String),
          categoryId: data['categoryId'] as String,
        );
      }).toList();

      await _transactionBox.clear();
      await _transactionBox.addAll(firebaseTransactions);

      _transactions = _transactionBox.values.toList();
      notifyListeners();
    });
  }

  /// Sincroniza categorias do Firestore -> Hive
  void _listenToFirestoreCategories() {
    _firestore.collection('categories').snapshots().listen((querySnapshot) async {
      final firebaseCategories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: data['id'] as String,
          name: data['name'] as String,
        );
      }).toList();

      await _categoryBox.clear();
      await _categoryBox.addAll(firebaseCategories);

      _categories = _categoryBox.values.toList();
      notifyListeners();
    });
  }

  /// Adiciona categoria localmente e no Firestore
  Future<void> addCategory(String name) async {
    final newCategory = Category(
      id: Random().nextDouble().toString(),
      name: name,
    );

    // Salvar no Hive (offline)
    await _categoryBox.add(newCategory);

    // Atualizar lista em memória e notificar
    _categories = _categoryBox.values.toList();
    notifyListeners();

    // Salvar no Firestore (online)
    await _firestore.collection('categories').doc(newCategory.id).set(newCategory.toMap());
  }

  /// Adiciona transação localmente e no Firestore
  Future<void> addTransaction(String title, double value, DateTime date, String categoryId) async {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
      categoryId: categoryId,
    );

    // Salvar no Hive (offline)
    await _transactionBox.add(newTransaction);

    // Atualizar lista em memória e notificar
    _transactions = _transactionBox.values.toList();
    notifyListeners();

    // Salvar no Firestore (online)
    await _firestore.collection('transactions').doc(newTransaction.id).set(newTransaction.toMap());
  }

  /// Remove transação local e do Firestore
  Future<void> removeTransaction(String id) async {
    final index = _transactions.indexWhere((tr) => tr.id == id);
    if (index < 0) return;

    // Remove local
    await _transactionBox.deleteAt(index);

    // Atualiza lista em memória
    _transactions = _transactionBox.values.toList();
    notifyListeners();

    // Remove do Firestore
    await _firestore.collection('transactions').doc(id).delete();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}


class ExpenseData {
  final String categoryId;
  final double value;

  ExpenseData({required this.categoryId, required this.value});
}