import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class HiveService {
  static late Box<CategoryModel> categoryBox;
  static late Box<ExpenseModel> expenseBox;

  static Future<void> init() async {
    categoryBox = await Hive.openBox<CategoryModel>("categories_box");
    expenseBox = await Hive.openBox<ExpenseModel>("expenses_box");
  }
}
