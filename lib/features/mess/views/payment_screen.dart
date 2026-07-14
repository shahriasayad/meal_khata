// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../../../data/models/mess_models.dart';
import '../view_models/mess_view_model.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();

    return Obx(() {
      final List<Member> memberList = controller.members.toList();
      final double totalPaid = controller.totalPaid;
      final double totalExpenses = controller.totalExpenses;
      final double netDue = totalExpenses - totalPaid;

      return Scaffold(
        appBar: AppBar(title: Text('Payments — ${controller.monthLabel}')),
        floatingActionButton: memberList.isEmpty
            ? null
            : FloatingActionButton.extended(
                heroTag: 'pay_fab',
                onPressed: () =>
                    _showAddPaymentDialog(context, controller, memberList),
                icon: const Icon(Icons.add),
                label: const Text('Add Payment'),
              ),
        body: Column(
          children: [
            Container(
              color: AppColors.primary.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  PayStat(
                    label: 'Total Expenses',
                    value: '৳${totalExpenses.toStringAsFixed(2)}',
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  PayStat(
                    label: 'Total Paid',
                    value: '৳${totalPaid.toStringAsFixed(2)}',
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 12),
                  PayStat(
                    label: netDue > 0 ? 'Due' : 'Advance',
                    value: '৳${netDue.abs().toStringAsFixed(2)}',
                    color: netDue > 0.01 ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
            Expanded(
              child: memberList.isEmpty
                  ? const AppEmptyHint(
                      message: 'Add members in Settings first.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: memberList.length,
                      itemBuilder: (_, int index) {
                        final Member member = memberList[index];
                        final double gross = controller.memberGrossCost(
                          member.id,
                        );
                        final double paid = controller.memberPaid(member.id);
                        final double balance = controller.memberBalance(
                          member.id,
                        );
                        final List<Payment> memberPayments = controller
                            .memberMonthPayments(member.id);

                        return MemberPaymentTile(
                          member: member,
                          grossCost: gross,
                          paid: paid,
                          balance: balance,
                          payments: memberPayments,
                          onDelete: controller.deletePayment,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showAddPaymentDialog(
    BuildContext context,
    MessViewModel controller,
    List<Member> members,
  ) async {
    String selectedMemberId = members.first.id;
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Record Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMemberId,
                  items: members
                      .map(
                        (member) => DropdownMenuItem<String>(
                          value: member.id,
                          child: Text(member.name),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) =>
                      setState(() => selectedMemberId = value ?? ''),
                  decoration: const InputDecoration(labelText: 'Member'),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final double balance = controller.memberBalance(
                    selectedMemberId,
                  );
                  if (balance <= 0) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        amountController.text = balance.toStringAsFixed(2);
                      },
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: Text('Fill due: ৳${balance.toStringAsFixed(2)}'),
                    ),
                  );
                }),
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
                controller.addPayment(
                  Payment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    memberId: selectedMemberId,
                    month: controller.selectedMonth.value,
                    amount: amount,
                    note: noteController.text.trim(),
                  ),
                );
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
