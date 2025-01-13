import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1) // Define o ID único para o adaptador
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
