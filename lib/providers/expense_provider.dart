import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<ExpenseModel>>((ref) {
      return ExpenseNotifier();
    });

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  ExpenseNotifier() : super(HiveService.expenseBox.values.toList());

  void addExpense({
    required String categoryId,
    required String itemName,
    required String purchaseType,
    required double quantity,
    double? rate,
    required double total,
    String? vendor,
    String? notes,
  }) {
    final id = const Uuid().v4();

    final expense = ExpenseModel(
      id: id,
      categoryId: categoryId,
      itemName: itemName, // Save the item name to Hive
      purchaseType: purchaseType,
      quantity: quantity,
      rate: rate,
      total: total,
      vendor: vendor,
      notes: notes,
      date: DateTime.now(),
    );

    HiveService.expenseBox.put(id, expense);
    state = HiveService.expenseBox.values.toList();
  }

  void deleteExpense(String id) {
    HiveService.expenseBox.delete(id);
    state = HiveService.expenseBox.values.toList();
  }

  void archiveExpense(String id) {
    final expense = HiveService.expenseBox.get(id);
    if (expense != null) {
      expense.isArchived = true;
      expense.save();
      state = HiveService.expenseBox.values.toList();
    }
  }

  void unarchiveExpense(String id) {
    final expense = HiveService.expenseBox.get(id);
    if (expense != null) {
      expense.isArchived = false;
      expense.save();
      state = HiveService.expenseBox.values.toList();
    }
  }

  List<ExpenseModel> get filteredActive =>
      state.where((e) => e.isArchived == false).toList();

  List<ExpenseModel> get archived =>
      state.where((e) => e.isArchived == true).toList();

  List<ExpenseModel> filterByCategory(String id) =>
      state.where((e) => e.categoryId == id && !e.isArchived).toList();

  List<ExpenseModel> filterByDateRange(DateTime start, DateTime end) => state
      .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
      .toList();
}
