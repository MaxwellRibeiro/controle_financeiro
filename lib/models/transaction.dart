import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0) // Define o ID único para o adaptador
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double value;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categoryId; // Relaciona a transação a uma categoria

  Transaction({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'value': value,
    'date': date.toIso8601String(),
    'categoryId': categoryId,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      categoryId: map['categoryId'] as String,
    );
  }
}
