import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class ExpenseScreenController extends GetxController {
  ExpenseScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static ExpenseScreenController get instance =>
      Get.isRegistered<ExpenseScreenController>()
      ? Get.find<ExpenseScreenController>()
      : Get.put(ExpenseScreenController());

  List<Expense> get monthExpenses => _viewModel.monthExpenses;
  double get totalExpenses => _viewModel.totalExpenses;
  String get monthLabel => _viewModel.monthLabel;
  List<String> get categories => _viewModel.categories.toList();

  void deleteExpense(String id) => _viewModel.deleteExpense(id);

  Future<void> showExpenseDialog(
    BuildContext context, {
    Expense? existing,
  }) async {
    final amountController = TextEditingController(
      text: existing?.amount.toString() ?? '',
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    String category =
        existing?.category ?? (categories.isNotEmpty ? categories.first : '');
    DateTime selectedDate = existing != null
        ? DateFormat('yyyy-MM-dd').parse(existing.date)
        : DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Expense' : 'Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (৳)',
                    prefixText: '৳ ',
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: _viewModel.categories.contains(category)
                        ? category
                        : null,
                    items: _viewModel.categories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => category = value ?? ''),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(
                  amountController.text.trim(),
                );
                if (amount == null || amount <= 0) {
                  Get.snackbar(
                    'Error',
                    'Enter a valid amount.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                if (category.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Select a category.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                final expense = Expense(
                  id:
                      existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateFormat('yyyy-MM-dd').format(selectedDate),
                  amount: amount,
                  category: category,
                  note: noteController.text.trim(),
                );
                if (existing == null) {
                  _viewModel.addExpense(expense);
                } else {
                  _viewModel.updateExpense(expense);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    amountController.dispose();
    noteController.dispose();
  }
}
