// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../../../../data/models/mess_models.dart';
import '../controller/expense_screen_controller.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExpenseScreenController.instance;

    return Obx(() {
      final List<Expense> list = controller.monthExpenses
        ..sort((a, b) => b.date.compareTo(a.date));
      final double total = controller.totalExpenses;

      return Scaffold(
        appBar: AppBar(title: Text('Expenses — ${controller.monthLabel}')),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'expense_fab',
          onPressed: () => controller.showExpenseDialog(context),
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
                                  onPressed: () => controller.showExpenseDialog(
                                    context,
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
}
