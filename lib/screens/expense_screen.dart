import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../providers/category_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseModel item;

  const ExpenseDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final categories = ref.watch(categoryProvider);
    final category = categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse: () => categories.first,
    );

    final currencyFormat = NumberFormat('#,##,###');
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          "Transaction Details",
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // -------- Amount + Date --------
            Text(
              "Rs. ${currencyFormat.format(item.total)}",
              style: tt.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateFormat.format(item.date),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 32),

            // -------- MAIN CARD --------
            _roundedCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name + Category Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("ITEM", tt, cs),
                            const SizedBox(height: 4),
                            Text(
                              item.itemName,
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _chip(category.name, cs, tt),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quantity + Rate
                  Row(
                    children: [
                      if (item.purchaseType != "Total")
                        Expanded(
                          child: _iconStat(
                            context,
                            icon: Icons.layers_outlined,
                            label: "Quantity",
                            value: "${item.quantity}",
                          ),
                        ),

                      if (item.purchaseType != "Total")
                        Container(
                          width: 1,
                          height: 36,
                          color: cs.outlineVariant,
                        ),

                      Expanded(
                        child: _iconStat(
                          context,
                          icon: Icons.sell_outlined,
                          label: "Rate",
                          value: item.rate?.toStringAsFixed(2) ?? "-",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Purchase Type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: cs.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Type: ${item.purchaseType}",
                          style: tt.labelLarge?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------- SECONDARY CARD --------
            _roundedCard(
              context: context,
              child: Column(
                children: [
                  _detailRow(
                    icon: Icons.storefront_outlined,
                    label: "Vendor",
                    value: item.vendor ?? "N/A",
                    tt: tt,
                    cs: cs,
                  ),

                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _detailRow(
                      icon: Icons.notes_rounded,
                      label: "Notes",
                      value: item.notes!,
                      tt: tt,
                      cs: cs,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- COMPONENTS -----------------

  Widget _roundedCard({required BuildContext context, required Widget child}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: child,
    );
  }

  Widget _label(String text, TextTheme tt, ColorScheme cs) {
    return Text(
      text,
      style: tt.labelMedium?.copyWith(
        color: cs.onSurfaceVariant,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _chip(String label, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _iconStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required TextTheme tt,
    required ColorScheme cs,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: cs.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(value, style: tt.bodyLarge?.copyWith(color: cs.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}
