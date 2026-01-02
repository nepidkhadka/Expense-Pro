import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(10) // New field! Use a unique index
  String itemName;

  @HiveField(2)
  String purchaseType;
  // "unit", "total", "volume", "per_item"

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double? rate;

  @HiveField(5)
  double total;

  @HiveField(6)
  String? vendor;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  bool isArchived;

  ExpenseModel({
    required this.id,
    required this.categoryId,
    required this.itemName,
    required this.purchaseType,
    required this.quantity,
    this.rate,
    required this.total,
    this.vendor,
    required this.date,
    this.notes,
    this.isArchived = false,
  });

  ExpenseModel copyWith({
    String? id,
    String? categoryId,
    String? itemName,
    String? purchaseType,
    double? quantity,
    double? rate,
    double? total,
    String? vendor,
    DateTime? date,
    String? notes,
    bool? isArchived,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      itemName: itemName ?? this.itemName,
      purchaseType: purchaseType ?? this.purchaseType,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      total: total ?? this.total,
      vendor: vendor ?? this.vendor,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
