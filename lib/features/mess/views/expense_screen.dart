// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../../../data/models/mess_models.dart';
import '../view_models/mess_view_model.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();

    return Obx(() {
      final List<Expense> list = controller.monthExpenses
        ..sort((a, b) => b.date.compareTo(a.date));
      final double total = controller.totalExpenses;

      return Scaffold(
        appBar: AppBar(title: Text('Expenses — ${controller.monthLabel}')),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'expense_fab',
          onPressed: () => _showExpenseDialog(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.primary.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Total Expenses', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  Text(
                    '৳${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const AppEmptyHint(
                      message: 'No expenses this month.\nTap + to add one.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: list.length,
                      itemBuilder: (_, int index) {
                        final expense = list[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.15,
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${expense.category}   ৳${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${expense.date}${expense.note.isNotEmpty ? '  •  ${expense.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => _showExpenseDialog(
                                    context,
                                    controller,
                                    existing: expense,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      controller.deleteExpense(expense.id),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showExpenseDialog(
    BuildContext context,
    MessViewModel controller, {
    Expense? existing,
  }) async {
    final TextEditingController amountController = TextEditingController(
      text: existing?.amount.toString() ?? '',
    );
    final TextEditingController noteController = TextEditingController(
      text: existing?.note ?? '',
    );
    String category =
        existing?.category ??
        (controller.categories.isNotEmpty ? controller.categories.first : '');
    DateTime date = existing != null
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
                  title: Text(DateFormat('dd MMM yyyy').format(date)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => date = picked);
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
                    value: controller.categories.contains(category)
                        ? category
                        : null,
                    items: controller.categories
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) =>
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
                  date: DateFormat('yyyy-MM-dd').format(date),
                  amount: amount,
                  category: category,
                  note: noteController.text.trim(),
                );
                if (existing == null) {
                  controller.addExpense(expense);
                } else {
                  controller.updateExpense(expense);
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
