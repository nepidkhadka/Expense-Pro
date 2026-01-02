// import 'package:flutter/material.dart';

// class AddExpenseScreen extends StatefulWidget {
//   const AddExpenseScreen({super.key});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();

//   String selectedUnit = "Unit";

//   final List<String> unitTypes = ["Unit", "Total", "Volume", "Per Item"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Expense")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Title Input
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(
//                 labelText: "Item Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// Amount Input
//             TextField(
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Amount",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// Unit Type Dropdown
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: DropdownButton<String>(
//                 value: selectedUnit,
//                 underline: const SizedBox(),
//                 isExpanded: true,
//                 items: unitTypes
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedUnit = value!;
//                   });
//                 },
//               ),
//             ),

//             const Spacer(),

//             /// Save Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, {
//                     "title": titleController.text,
//                     "amount": amountController.text,
//                     "unit": selectedUnit,
//                   });
//                 },
//                 child: const Text("Save Expense"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedCategoryId;
  String selectedPurchaseType = "Unit";

  final List<String> purchaseTypes = ["Unit", "Total", "Volume", "Per Item"];

  double total = 0.0;

  void _calculateTotal() {
    double qty = double.tryParse(quantityController.text) ?? 0.0;
    double rate = double.tryParse(rateController.text) ?? 0.0;

    switch (selectedPurchaseType) {
      case "Unit":
      case "Volume":
      case "Per Item":
        total = qty * rate;
        break;
      case "Total":
        total = rate; // total given directly
        break;
      default:
        total = 0.0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    quantityController.addListener(_calculateTotal);
    rateController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    itemController.dispose();
    vendorController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final formatter = NumberFormat('#,##,###');
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Item Name
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedCategoryId,
                underline: const SizedBox(),
                hint: const Text("Select Category"),
                isExpanded: true,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            /// Purchase Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedPurchaseType,
                underline: const SizedBox(),
                isExpanded: true,
                items: purchaseTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPurchaseType = value!;
                    _calculateTotal();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            /// Quantity (hidden if Total type)
            if (selectedPurchaseType != "Total") ...[
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// Rate / Total
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: selectedPurchaseType == "Total" ? "Total" : "Rate",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Vendor (Optional)
            TextField(
              controller: vendorController,
              decoration: const InputDecoration(
                labelText: "Vendor (Optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Notes (Optional)
            TextField(
              controller: notesController,
              minLines: 4,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textAlignVertical:
                  TextAlignVertical.top, // makes text start from top
              decoration: InputDecoration(
                labelText: "Notes (Optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Total Display
            Text(
              "Total: Rs. ${formatter.format(total)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = itemController.text.trim(); // Get the item name
                  if (name.isEmpty ||
                      selectedCategoryId == null ||
                      total <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please fill all required fields"),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  ref
                      .read(expenseProvider.notifier)
                      .addExpense(
                        itemName: name,
                        categoryId: selectedCategoryId!,
                        purchaseType: selectedPurchaseType,
                        quantity: double.tryParse(quantityController.text) ?? 0,
                        rate: double.tryParse(rateController.text),
                        total: total,
                        vendor: vendorController.text.isEmpty
                            ? null
                            : vendorController.text,
                        notes: notesController.text.isEmpty
                            ? null
                            : notesController.text,
                      );

                  Navigator.pop(context);
                },
                child: const Text("Save Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
