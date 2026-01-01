// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../providers/category_provider.dart';
// import '../providers/expense_provider.dart';
// import 'add_expense_screen.dart';
// import 'expense_list_screen.dart';
// import 'archive_screen.dart';
// import 'export_screen.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categories = ref.watch(categoryProvider);
//     final expenses = ref.watch(expenseProvider);

//     final activeExpenses = expenses.where((e) => !e.isArchived).toList();

//     final totalExpense = activeExpenses.fold(0.0, (sum, e) => sum + e.total);

//     final dailyTotal = activeExpenses
//         .where(
//           (e) =>
//               e.date.year == DateTime.now().year &&
//               e.date.month == DateTime.now().month &&
//               e.date.day == DateTime.now().day,
//         )
//         .fold(0.0, (sum, e) => sum + e.total);

//     final monthlyTotal = activeExpenses
//         .where(
//           (e) =>
//               e.date.year == DateTime.now().year &&
//               e.date.month == DateTime.now().month,
//         )
//         .fold(0.0, (sum, e) => sum + e.total);

//     // Category-wise totals
//     final Map<String, double> categoryTotals = {};
//     for (var cat in categories) {
//       final catTotal = activeExpenses
//           .where((e) => e.categoryId == cat.id)
//           .fold(0.0, (sum, e) => sum + e.total);
//       if (catTotal > 0) categoryTotals[cat.name] = catTotal;
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Expense Pro"), centerTitle: true),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () {
//       //     Navigator.push(
//       //       context,
//       //       MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
//       //     );
//       //   },
//       //   label: const Text("Add Expense"),
//       //   icon: const Icon(Icons.add),
//       // ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: "add_category",
//             onPressed: () => _showAddCategory(context, ref),
//             tooltip: "Add Category",
//             child: Icon(Icons.category_rounded),
//           ),
//           const SizedBox(height: 14),
//           FloatingActionButton.extended(
//             heroTag: "add_expense",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
//               );
//             },
//             label: const Text("Add Expense"),
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// TOTAL CARD
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Total Active Expense",
//                     style: TextStyle(fontSize: 16, color: Colors.black54),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Rs. ${totalExpense.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// Daily & Monthly Cards
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _summaryCard("Daily", dailyTotal, Colors.green.shade100),
//                 _summaryCard("Monthly", monthlyTotal, Colors.orange.shade100),
//               ],
//             ),

//             const SizedBox(height: 20),

//             /// Pie Chart
//             if (categoryTotals.isNotEmpty)
//               SizedBox(
//                 height: 200,
//                 child: PieChart(
//                   PieChartData(
//                     sections: categoryTotals.entries.map((e) {
//                       final color =
//                           Colors.primaries[categoryTotals.keys.toList().indexOf(
//                                 e.key,
//                               ) %
//                               Colors.primaries.length];
//                       return PieChartSectionData(
//                         value: e.value,
//                         title: "${e.key}\nRs.${e.value.toStringAsFixed(0)}",
//                         radius: 60,
//                         color: color,
//                         titleStyle: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.white,
//                         ),
//                       );
//                     }).toList(),
//                     sectionsSpace: 2,
//                     centerSpaceRadius: 30,
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 20),

//             /// QUICK BUTTONS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _homeBtn(
//                   title: "Expenses",
//                   icon: Icons.list,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ExpenseListScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 _homeBtn(
//                   title: "Archive",
//                   icon: Icons.archive,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ArchiveScreen()),
//                     );
//                   },
//                 ),
//                 _homeBtn(
//                   title: "Export",
//                   icon: Icons.file_download,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ExportScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Categories",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 12),

//             Expanded(
//               child: ListView(
//                 children: [
//                   for (final cat in categories)
//                     ListTile(
//                       title: Text(cat.name),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           ref
//                               .read(categoryProvider.notifier)
//                               .deleteCategory(cat.id);
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // Center(
//             //   child: ElevatedButton.icon(
//             //     onPressed: () => _showAddCategory(context, ref),
//             //     icon: const Icon(Icons.add),
//             //     label: const Text("Add Category"),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryCard(String title, double amount, Color color) {
//     return Container(
//       width: 150,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Text(title, style: const TextStyle(color: Colors.black54)),
//           const SizedBox(height: 8),
//           Text(
//             "Rs. ${amount.toStringAsFixed(2)}",
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _homeBtn({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: onTap,
//       child: Container(
//         height: 90,
//         width: 90,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 28),
//             const SizedBox(height: 6),
//             Text(title),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddCategory(BuildContext context, WidgetRef ref) {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (c) {
//         return AlertDialog(
//           title: const Text("New Category"),
//           content: TextField(
//             controller: controller,
//             decoration: const InputDecoration(
//               hintText: "Brick, Cement, Pebbles...",
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(c),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text.isNotEmpty) {
//                   ref
//                       .read(categoryProvider.notifier)
//                       .addCategory(controller.text);
//                 }
//                 Navigator.pop(c);
//               },
//               child: const Text("Add"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'archive_screen.dart';
import 'export_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoryProvider);
    final expenses = ref.watch(expenseProvider);

    // --- LOGIC START ---
    final activeExpenses = expenses.where((e) => !e.isArchived).toList();
    final totalExpense = activeExpenses.fold(0.0, (sum, e) => sum + e.total);
    final now = DateTime.now();
    final dailyTotal = activeExpenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, e) => sum + e.total);

    final monthlyTotal = activeExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.total);

    final Map<String, double> categoryTotals = {};
    for (var cat in categories) {
      final catTotal = activeExpenses
          .where((e) => e.categoryId == cat.id)
          .fold(0.0, (sum, e) => sum + e.total);
      if (catTotal > 0) categoryTotals[cat.name] = catTotal;
    }
    // --- LOGIC END ---

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // Minimal AppBar with no shadow
      appBar: AppBar(
        title: Text(
          "Overview",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, // Add profile or settings logic here later
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton.small(
          //   heroTag: "add_category",
          //   onPressed: () => _showAddCategory(context, ref),
          //   backgroundColor: theme.colorScheme.secondaryContainer,
          //   elevation: 2,
          //   child: Icon(
          //     Icons.category_outlined,
          //     color: theme.colorScheme.onSecondaryContainer,
          //   ),
          // ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "add_expense",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ),
            // Use 'onPrimary' to guarantee the text/icon pops against the blue background
            foregroundColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.colorScheme.primary,
            elevation: 4,
            // Using a slightly thicker weight for better legibility
            label: const Text(
              "New Expense",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            icon: const Icon(Icons.add_rounded, size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. CONSOLIDATED HERO CARD
            _buildSummaryCard(context, totalExpense, dailyTotal, monthlyTotal),

            const SizedBox(height: 24),

            /// 2. QUICK ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(context, "History", Icons.history, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpenseListScreen(),
                    ),
                  );
                }),
                _actionButton(
                  context,
                  "Archive",
                  Icons.inventory_2_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                    );
                  },
                ),
                _actionButton(context, "Export", Icons.ios_share, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExportScreen()),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            /// 3. CHART & CATEGORIES
            if (categoryTotals.isNotEmpty) ...[
              const Text(
                "Spending Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40, // Makes it a donut
                    sections: categoryTotals.entries.map((e) {
                      final index = categoryTotals.keys.toList().indexOf(e.key);
                      // Generate a palette based on primary color
                      final color = theme.colorScheme.primary
                          .withBlue(index * 40 % 255)
                          .withOpacity(0.8);

                      return PieChartSectionData(
                        value: e.value,
                        title:
                            "${(e.value / totalExpense * 100).toStringAsFixed(0)}%",
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 50,
                        color: color,
                        badgeWidget: _badge(e.key),
                        badgePositionPercentageOffset: 1.3,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            /// 4. CATEGORY LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showAddCategory(context, ref),
                  child: const Text("Add New"),
                ),
              ],
            ),

            // Render list directly in Column to scroll with the page
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "No categories yet.",
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          cat.name[0].toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          ref
                              .read(categoryProvider.notifier)
                              .deleteCategory(cat.id, expenses);
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  /// Consolidates 3 cards into one clean dashboard view
  Widget _buildSummaryCard(
    BuildContext context,
    double total,
    double daily,
    double monthly,
  ) {
    final theme = Theme.of(context);
    final formatter = NumberFormat(
      '#,##,###',
    ); // Standard Indian/South Asian format
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance",
            style: TextStyle(
              // ignore: deprecated_member_use
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rs. ${formatter.format(total)}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(context, "Daily", daily),
              Container(
                width: 1,
                height: 30,
                color: theme.colorScheme.onPrimary.withOpacity(0.3),
              ),
              _miniStat(context, "Monthly", monthly),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, double value) {
    final formatter = NumberFormat(
      '#,##,###',
    ); // Standard Indian/South Asian format
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
        Text(
          "Rs. ${formatter.format(value)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 80, // Wider click area
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Simple badge for chart labels to prevent clutter
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }

  void _showAddCategory(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          title: const Text("New Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "e.g., Groceries",
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(categoryProvider.notifier)
                      .addCategory(controller.text);
                }
                Navigator.pop(c);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
