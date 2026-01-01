import 'package:expense_pro/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expenses = ref.watch(expenseProvider.notifier).filteredActive;
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        label: const Text("Add New"),
        icon: const Icon(Icons.add),
      ),
      body: expenses.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final item = expenses[index];

                // SAFETY CHECK: Prevents crash if category is missing/deleted
                final category = categories.firstWhere(
                  (c) => c.id == item.categoryId,
                  orElse: () =>
                      CategoryModel(id: 'unknown', name: 'Uncategorized'),
                );

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.horizontal,
                  // DELETE Background (Left to Right)
                  background: _buildSwipeBackground(
                    alignment: Alignment.centerLeft,
                    color: theme.colorScheme.errorContainer,
                    icon: Icons.delete_outline,
                    iconColor: theme.colorScheme.onErrorContainer,
                    padding: const EdgeInsets.only(left: 20),
                  ),
                  // ARCHIVE Background (Right to Left)
                  secondaryBackground: _buildSwipeBackground(
                    alignment: Alignment.centerRight,
                    color: theme.colorScheme.secondaryContainer,
                    icon: Icons.inventory_2_outlined,
                    iconColor: theme.colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.only(right: 20),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return await _confirmDelete(context, ref, item.id);
                    } else {
                      // Archive action
                      ref
                          .read(expenseProvider.notifier)
                          .archiveExpense(item.id);
                      _showSnackBar(context, "Expense archived");
                      return true;
                    }
                  },
                  child: _ExpenseCard(
                    item: item,
                    categoryName: category.name,
                    itemName: item.itemName,
                  ),
                );
              },
            ),
    );
  }

  /// Builds the visual background when swiping
  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required EdgeInsets padding,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: padding,
      child: Icon(icon, color: iconColor, size: 28),
    );
  }

  /// Improved Empty State UI
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            // ignore: deprecated_member_use
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No expenses found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              // ignore: deprecated_member_use
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            "Tap + to add your first expense",
            style: TextStyle(color: theme.colorScheme.outline),
          ),
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
            title: const Text("Delete Expense?"),
            content: const Text(
              "This action cannot be undone. Do you want to proceed?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  ref.read(expenseProvider.notifier).deleteExpense(id);
                  Navigator.of(ctx).pop(true);
                  _showSnackBar(context, "Expense deleted");
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

/// A separate widget for the Card to keep code clean
class _ExpenseCard extends StatelessWidget {
  final dynamic item;

  final dynamic itemName;

  final String categoryName;

  const _ExpenseCard({
    required this.item,
    required this.itemName,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##,###');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        // Subtle shadow for a "Pro" floating look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          // ignore: deprecated_member_use
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 1. Minimal Date Indicator
              _DateIndicator(date: item.date),

              const SizedBox(width: 16),

              // 2. Main Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Category Label
                        Text(
                          categoryName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: CircleAvatar(
                            radius: 2,
                            backgroundColor: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        // Purchase Type Tag
                        Text(
                          item.purchaseType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Amount Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rs. ${formatter.format(item.total)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900, // Extra bold for the number
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (item.quantity > 0)
                    Text(
                      "Qty: ${item.quantity}",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate Date Widget for clean code
class _DateIndicator extends StatelessWidget {
  final DateTime date;
  const _DateIndicator({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            months[date.month - 1].toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
