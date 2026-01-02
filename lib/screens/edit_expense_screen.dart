// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/category_provider.dart';
// import '../providers/expense_provider.dart';
// import 'package:intl/intl.dart';

// class EditExpenseScreen extends ConsumerStatefulWidget {
//   final dynamic expense;

//   const EditExpenseScreen({super.key, required this.expense});

//   @override
//   ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
// }

// class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
//   late TextEditingController itemController;
//   late TextEditingController quantityController;
//   late TextEditingController rateController;
//   late TextEditingController vendorController;
//   late TextEditingController notesController;

//   String? selectedCategoryId;
//   String selectedPurchaseType = "Unit";
//   double total = 0.0;

//   final List<String> purchaseTypes = ["Unit", "Total", "Volume", "Per Item"];

//   @override
//   void initState() {
//     super.initState();

//     // Prefill from existing expense
//     final e = widget.expense;

//     itemController = TextEditingController(text: e.itemName);
//     quantityController = TextEditingController(text: e.quantity.toString());
//     rateController = TextEditingController(text: e.rate.toString());
//     vendorController = TextEditingController(text: e.vendor ?? "");
//     notesController = TextEditingController(text: e.notes ?? "");

//     selectedCategoryId = e.categoryId;
//     selectedPurchaseType = e.purchaseType;
//     total = e.total;

//     // Recalculate on change
//     quantityController.addListener(_calculateTotal);
//     rateController.addListener(_calculateTotal);
//   }

//   void _calculateTotal() {
//     double qty = double.tryParse(quantityController.text) ?? 0.0;
//     double rate = double.tryParse(rateController.text) ?? 0.0;

//     switch (selectedPurchaseType) {
//       case "Unit":
//       case "Volume":
//       case "Per Item":
//         total = qty * rate;
//         break;
//       case "Total":
//         total = rate;
//         break;
//       default:
//         total = 0.0;
//     }

//     setState(() {});
//   }

//   @override
//   void dispose() {
//     itemController.dispose();
//     quantityController.dispose();
//     rateController.dispose();
//     vendorController.dispose();
//     notesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = ref.watch(categoryProvider);
//     final formatter = NumberFormat('#,##,###');

//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Expense")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: itemController,
//               decoration: const InputDecoration(
//                 labelText: "Item Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Category Dropdown
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: DropdownButton<String>(
//                 value: selectedCategoryId,
//                 underline: const SizedBox(),
//                 isExpanded: true,
//                 items: categories
//                     .map(
//                       (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
//                     )
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCategoryId = value;
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Purchase Type
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: DropdownButton<String>(
//                 value: selectedPurchaseType,
//                 underline: const SizedBox(),
//                 isExpanded: true,
//                 items: purchaseTypes
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedPurchaseType = value!;
//                     _calculateTotal();
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             if (selectedPurchaseType != "Total") ...[
//               TextField(
//                 controller: quantityController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: "Quantity",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             TextField(
//               controller: rateController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: selectedPurchaseType == "Total" ? "Total" : "Rate",
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               controller: vendorController,
//               decoration: const InputDecoration(
//                 labelText: "Vendor (optional)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               controller: notesController,
//               decoration: const InputDecoration(
//                 labelText: "Notes (optional)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             Text(
//               "Total: Rs. ${formatter.format(total)}",
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),

//             const SizedBox(height: 20),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   final name = itemController.text.trim();
//                   if (name.isEmpty || selectedCategoryId == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Please fill all required fields"),
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                     return;
//                   }

//                   ref
//                       .read(expenseProvider.notifier)
//                       .updateExpense(
//                         id: widget.expense.id,
//                         itemName: name,
//                         categoryId: selectedCategoryId!,
//                         purchaseType: selectedPurchaseType,
//                         quantity:
//                             double.tryParse(quantityController.text) ?? 0.0,
//                         rate: double.tryParse(rateController.text) ?? 0.0,
//                         total: total,
//                         vendor: vendorController.text.isEmpty
//                             ? null
//                             : vendorController.text,
//                         notes: notesController.text.isEmpty
//                             ? null
//                             : notesController.text,
//                       );

//                   Navigator.pop(context);
//                 },
//                 child: const Text("Update Expense"),
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
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel item;

  const EditExpenseScreen({super.key, required this.item});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  late TextEditingController itemController;
  late TextEditingController quantityController;
  late TextEditingController rateController;
  late TextEditingController vendorController;
  late TextEditingController notesController;

  late String selectedCategoryId;
  late String selectedPurchaseType;
  late double total;

  final List<String> purchaseTypes = ["Unit", "Total", "Volume", "Per Item"];

  @override
  void initState() {
    super.initState();

    final data = widget.item;

    itemController = TextEditingController(text: data.itemName);
    quantityController = TextEditingController(text: data.quantity.toString());
    rateController = TextEditingController(text: data.rate?.toString() ?? "");
    vendorController = TextEditingController(text: data.vendor ?? "");
    notesController = TextEditingController(text: data.notes ?? "");

    selectedCategoryId = data.categoryId;
    selectedPurchaseType = data.purchaseType;
    total = data.total;

    quantityController.addListener(_calculateTotal);
    rateController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double qty = double.tryParse(quantityController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;

    switch (selectedPurchaseType) {
      case "Unit":
      case "Volume":
      case "Per Item":
        total = qty * rate;
        break;
      case "Total":
        total = rate;
        break;
      default:
        total = 0.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final formatter = NumberFormat('#,##,###');

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // CATEGORY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedCategoryId,
                underline: const SizedBox(),
                isExpanded: true,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedCategoryId = value!;
                }),
              ),
            ),
            const SizedBox(height: 16),

            // PURCHASE TYPE
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

            if (selectedPurchaseType != "Total")
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

            TextField(
              controller: vendorController,
              decoration: const InputDecoration(
                labelText: "Vendor (Optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: notesController,
              minLines: 4,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Notes (Optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Total: Rs. ${formatter.format(total)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Update Expense"),
                onPressed: () {
                  final updated = widget.item.copyWith(
                    itemName: itemController.text.trim(),
                    categoryId: selectedCategoryId,
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

                  ref
                      .read(expenseProvider.notifier)
                      .updateExpense(
                        id: updated.id,
                        itemName: updated.itemName,
                        categoryId: updated.categoryId,
                        purchaseType: updated.purchaseType,
                        quantity: updated.quantity,
                        rate: updated.rate ?? 0,
                        total: updated.total,
                        vendor: updated.vendor,
                        notes: updated.notes,
                      );

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
