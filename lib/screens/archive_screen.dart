// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/expense_provider.dart';
// import '../providers/category_provider.dart';

// class ArchiveScreen extends ConsumerWidget {
//   const ArchiveScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final archivedExpenses = ref.watch(expenseProvider.notifier).archived;
//     final categories = ref.watch(categoryProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Archived Expenses")),
//       body: archivedExpenses.isEmpty
//           ? const Center(
//               child: Text(
//                 "No archived expenses.",
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: archivedExpenses.length,
//               itemBuilder: (context, index) {
//                 final item = archivedExpenses[index];
//                 final category = categories.firstWhere(
//                   (c) => c.id == item.categoryId,
//                 );

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         blurRadius: 4,
//                         color: Colors.black.withOpacity(0.06),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// CATEGORY + DATE
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             category.name,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             "${item.date.day}/${item.date.month}/${item.date.year}",
//                             style: const TextStyle(color: Colors.black54),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text("Purchase Type: ${item.purchaseType}"),
//                       const SizedBox(height: 6),
//                       Text(
//                         "Rs. ${item.total.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton.icon(
//                             icon: const Icon(Icons.unarchive_outlined),
//                             label: const Text("Unarchive"),
//                             onPressed: () {
//                               ref
//                                   .read(expenseProvider.notifier)
//                                   .unarchiveExpense(item.id);
//                             },
//                           ),
//                           TextButton.icon(
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             label: const Text(
//                               "Delete",
//                               style: TextStyle(color: Colors.red),
//                             ),
//                             onPressed: () {
//                               ref
//                                   .read(expenseProvider.notifier)
//                                   .deleteExpense(item.id);
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:expense_pro/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final archivedExpenses = ref.watch(expenseProvider.notifier).archived;
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Archive"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: archivedExpenses.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archivedExpenses.length,
              itemBuilder: (context, index) {
                final item = archivedExpenses[index];

                // ERROR HANDLING: Safe category lookup
                // final category = categories.firstWhere(
                //   (c) => c.id == item.categoryId,
                //   orElse: () =>
                //       const Category(id: 'unknown', name: 'Unknown Category'),
                // );

                // 1. Find the category object
                // Safely find the category object
                final category = categories.firstWhere(
                  (c) => c.id == item.categoryId,
                  // We return a temporary CategoryModel object so '.name' always exists
                  orElse: () =>
                      CategoryModel(id: 'unknown', name: 'Uncategorized'),
                );

                return Dismissible(
                  key: Key(item.id),
                  // SWIPE RIGHT: Unarchive (Green)
                  background: _buildSwipeBackground(
                    alignment: Alignment.centerLeft,
                    color: Colors.green,
                    icon: Icons.unarchive,
                    label: "Restore",
                  ),
                  // SWIPE LEFT: Delete (Red)
                  secondaryBackground: _buildSwipeBackground(
                    alignment: Alignment.centerRight,
                    color: theme.colorScheme.error,
                    icon: Icons.delete_forever,
                    label: "Delete",
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Delete Direction
                      return await _confirmDelete(context, ref, item.id);
                    } else {
                      // Unarchive Direction
                      ref
                          .read(expenseProvider.notifier)
                          .unarchiveExpense(item.id);
                      _showSnackBar(context, "Expense restored to Dashboard");
                      return true;
                    }
                  },
                  child: _ArchiveCard(item: item, categoryName: category.name),
                );
              },
            ),
    );
  }

  /// Visuals for the empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Archive is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Visuals for the Swipe Background
  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Permanently?"),
            content: const Text(
              "This will remove the expense forever. You cannot undo this.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ref.read(expenseProvider.notifier).deleteExpense(id);
                  Navigator.of(ctx).pop(true);
                  _showSnackBar(context, "Expense deleted permanently");
                },
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Dedicated Card Widget for Archived Items
class _ArchiveCard extends StatelessWidget {
  final dynamic item;
  final String categoryName;

  const _ArchiveCard({required this.item, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainer, // Slightly darker than main list
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Greyed out icon to signify "Archived" state
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.archive_outlined,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  "${item.date.day}/${item.date.month}/${item.date.year}",
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Rs. ${item.total.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(
                0.6,
              ), // Dimmed text
            ),
          ),
        ],
      ),
    );
  }
}
