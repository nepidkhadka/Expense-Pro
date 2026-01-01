import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
      return CategoryNotifier();
    });

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier() : super(HiveService.categoryBox.values.toList());

  void addCategory(String name) {
    final id = const Uuid().v4();
    final category = CategoryModel(id: id, name: name);

    HiveService.categoryBox.put(id, category);
    state = HiveService.categoryBox.values.toList();
  }

  /// Returns null if successful, or an error message if blocked
  String? deleteCategory(String id, List<dynamic> allExpenses) {
    // Check if any expense uses this category ID
    final hasExpenses = allExpenses.any((exp) => exp.categoryId == id);

    if (hasExpenses) {
      return "Cannot delete category with existing expenses.";
    }

    HiveService.categoryBox.delete(id);
    state = HiveService.categoryBox.values.toList();
    return null;
  }

  void renameCategory(String id, String newName) {
    final category = HiveService.categoryBox.get(id);
    if (category != null) {
      category.name = newName;
      category.save();
      state = HiveService.categoryBox.values.toList();
    }
  }
}
