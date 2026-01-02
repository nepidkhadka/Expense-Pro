import 'package:expense_pro/models/category_model.dart';
import 'package:expense_pro/screens/edit_expense_screen.dart';
import 'package:expense_pro/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import 'add_expense_screen.dart';

// --- Filter Providers ---
final searchQueryProvider = StateProvider<String>((ref) => "");
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##,###');

    // Watch data and filters
    final allActiveExpenses = ref
        .watch(expenseProvider.notifier)
        .filteredActive;
    final categories = ref.watch(categoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCatId = ref.watch(selectedCategoryIdProvider);
    final dateRange = ref.watch(dateRangeProvider);

    // --- Core Filtering Logic ---
    final filteredExpenses = allActiveExpenses.where((expense) {
      final matchesSearch = expense.itemName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesCategory =
          selectedCatId == null || expense.categoryId == selectedCatId;

      bool matchesDate = true;
      if (dateRange != null) {
        matchesDate =
            expense.date.isAfter(
              dateRange.start.subtract(const Duration(days: 1)),
            ) &&
            expense.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    // Calculate Total for the visible list
    final double totalVisible = filteredExpenses.fold(
      0,
      (sum, item) => sum + item.total,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Date Range Picker Button
          IconButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: dateRange,
              );
              if (picked != null) {
                ref.read(dateRangeProvider.notifier).state = picked;
              }
            },
            icon: Icon(
              Icons.calendar_month_outlined,
              color: dateRange != null ? theme.colorScheme.primary : null,
            ),
          ),
          // Global Reset
          if (searchQuery.isNotEmpty ||
              selectedCatId != null ||
              dateRange != null)
            IconButton(
              onPressed: () {
                ref.read(searchQueryProvider.notifier).state = "";
                ref.read(selectedCategoryIdProvider.notifier).state = null;
                ref.read(dateRangeProvider.notifier).state = null;
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        label: const Text("Add New"),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 1. Total Summary Card
          // _buildSummaryCard(theme, totalVisible, formatter, dateRange),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: "Search item name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 3. Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: "All",
                    isSelected: selectedCatId == null,
                    onTap: () =>
                        ref.read(selectedCategoryIdProvider.notifier).state =
                            null,
                  );
                }
                final cat = categories[index - 1];
                return _FilterChip(
                  label: cat.name,
                  isSelected: selectedCatId == cat.id,
                  onTap: () =>
                      ref.read(selectedCategoryIdProvider.notifier).state =
                          cat.id,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 4. List of Expenses
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState(
                    theme,
                    (searchQuery.isNotEmpty ||
                        selectedCatId != null ||
                        dateRange != null),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final item = filteredExpenses[index];
                      final category = categories.firstWhere(
                        (c) => c.id == item.categoryId,
                        orElse: () =>
                            CategoryModel(id: 'unknown', name: 'Uncategorized'),
                      );

                      return Dismissible(
                        key: Key(item.id),
                        background: _buildSwipeBackground(
                          Alignment.centerLeft,
                          theme.colorScheme.errorContainer,
                          Icons.delete_outline,
                        ),
                        secondaryBackground: _buildSwipeBackground(
                          Alignment.centerRight,
                          theme.colorScheme.secondaryContainer,
                          Icons.inventory_2_outlined,
                        ),

                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // DELETE CONFIRMATION
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Expense?"),
                                content: const Text(
                                  "Are you sure you want to delete this expense? This action cannot be undone.",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Delete"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              ref
                                  .read(expenseProvider.notifier)
                                  .deleteExpense(item.id);
                            }

                            return shouldDelete ?? false;
                          }
                          // ARCHIVE CONFIRMATION
                          else {
                            final shouldArchive = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Archive Expense?"),
                                content: const Text(
                                  "Do you want to archive this expense? You can restore it later.",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    child: const Text("Archive"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (shouldArchive == true) {
                              ref
                                  .read(expenseProvider.notifier)
                                  .archiveExpense(item.id);
                            }

                            return shouldArchive ?? false;
                          }
                        },

                        /// 👇 **WRAPPED WITH GESTURE DETECTOR**
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailScreen(item: item),
                              ),
                            );
                          },
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(item: item),
                              ),
                            );
                          },
                          child: _ExpenseCard(
                            item: item,
                            categoryName: category.name,
                            itemName: item.itemName,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    double total,
    NumberFormat fmt,
    DateTimeRange? range,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            range == null
                ? "Total Active Spending"
                : "Spending: ${DateFormat('d MMM').format(range.start)} - ${DateFormat('d MMM').format(range.end)}",
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rs. ${fmt.format(total)}",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isFiltering) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltering ? Icons.filter_list_off : Icons.receipt_long,
            size: 60,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            isFiltering ? "No match found" : "Empty history",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(Alignment align, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
