import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../models/expense_model.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String selectedFilter = "Active";
  final List<String> filters = ["Active", "Archived", "All"];
  final formatter = NumberFormat('#,##,###');

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expenseProvider);
    final categories = ref.watch(categoryProvider);

    final expenses = allExpenses.where((e) {
      if (selectedFilter == "Active") return !e.isArchived;
      if (selectedFilter == "Archived") return e.isArchived;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Export Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Selection
            _buildSection(
              title: "Select Data Range",
              child: DropdownButtonFormField<String>(
                value: selectedFilter,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: filters
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => selectedFilter = v!),
              ),
            ),

            const SizedBox(height: 30),

            // Export Actions
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    label: "CSV", // Shorter label for cleaner look
                    icon: Icons.table_chart_rounded,
                    color: Colors.green.shade700,
                    onPressed: () =>
                        _handleExport(expenses, categories, isPdf: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ExportButton(
                    label: "PDF", // Shorter label for cleaner look
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.red.shade700,
                    onPressed: () =>
                        _handleExport(expenses, categories, isPdf: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _handleExport(expenses, categories, {required bool isPdf}) async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No records found for the selected filter."),
        ),
      );
      return;
    }

    if (isPdf) {
      await _generatePDF(expenses, categories);
    } else {
      await _exportCSV(expenses, categories);
    }
  }

  // --- PDF GENERATION LOGIC ---
  Future<void> _generatePDF(List<ExpenseModel> expenses, categories) async {
    final pdf = pw.Document();
    final totalAmount = expenses.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "EXPENSE REPORT",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Filter: $selectedFilter Records",
                    style: const pw.TextStyle(color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
            ],
          ),
          pw.Divider(height: 32),

          // Table
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Item', 'Category', 'Qty', 'Total'],
            data: expenses.map((item) {
              final catName = categories
                  .firstWhere((c) => c.id == item.categoryId)
                  .name;
              return [
                DateFormat('dd/MM/yy').format(item.date),
                item.itemName,
                catName,
                item.quantity.toString(),
                formatter.format(item.total),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
          ),

          // Summary Footer
          pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Column(
              children: [
                pw.Divider(thickness: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "GRAND TOTAL:  ",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    pw.Text(
                      "Rs. ${formatter.format(totalAmount)}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // --- CSV LOGIC (Stayed largely the same, optimized for readability) ---
  Future<void> _exportCSV(List<ExpenseModel> expenses, categories) async {
    List<List<dynamic>> rows = [
      [
        "Date",
        "Item",
        "Category",
        "Type",
        "Qty",
        "Rate",
        "Total",
        "Vendor",
        "Notes",
      ],
    ];

    for (var item in expenses) {
      final cat = categories.firstWhere((c) => c.id == item.categoryId).name;
      rows.add([
        DateFormat('dd-MM-yyyy').format(item.date),
        item.itemName,
        cat,
        item.purchaseType,
        item.quantity,
        item.rate ?? 0.0,
        item.total,
        item.vendor ?? '',
        item.notes ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/Expense_Pro_Export.csv");
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: "Expense Pro Export");
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.2)),
            // ignore: deprecated_member_use
            color: color.withOpacity(0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20), // Smaller icon
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // Refined text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
