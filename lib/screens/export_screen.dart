import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String selectedFilter = "Active";

  final List<String> filters = ["Active", "Archived", "All"];

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expenseProvider);
    final categories = ref.watch(categoryProvider);

    // Filter expenses based on selected filter
    final expenses = allExpenses.where((e) {
      if (selectedFilter == "Active") return !e.isArchived;
      if (selectedFilter == "Archived") return e.isArchived;
      return true; // All
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Export CSV")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedFilter,
                underline: const SizedBox(),
                isExpanded: true,
                items: filters
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Export CSV"),
                onPressed: () async {
                  if (expenses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No expenses to export!")),
                    );
                    return;
                  }
                  await _exportCSV(expenses, categories);
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "CSV will be saved in app documents folder and can be shared.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCSV(expenses, categories) async {
    List<List<dynamic>> rows = [];

    // Headers
    rows.add([
      "Date",
      "Item Name",
      "Category",
      "Purchase Type",
      "Quantity",
      "Rate",
      "Total",
      "Vendor",
      "Notes",
    ]);

    // Data
    for (var item in expenses) {
      final category = categories
          .firstWhere((c) => c.id == item.categoryId)
          .name;

      rows.add([
        "${item.date.day}/${item.date.month}/${item.date.year}",
        item.itemName,
        category,
        item.purchaseType,
        item.quantity,
        item.rate ?? '',
        item.total,
        item.vendor ?? '',
        item.notes ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/expenses_export.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Expense Pro CSV Export");
  }
}
