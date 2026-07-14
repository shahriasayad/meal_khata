// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../controller/summary_screen_controller.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SummaryScreenController.instance;

    return Obx(() {
      final memberList = controller.members;
      final totalMeals = controller.totalMeals;
      final totalExpenses = controller.totalExpenses;
      final rate = controller.mealRate;
      final byCategory = controller.categoryBreakdown();

      return Scaffold(
        appBar: AppBar(
          title: Text('Summary — ${controller.monthLabel}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Export PDF',
              onPressed: controller.exportPdf,
            ),
          ],
        ),
        body: memberList.isEmpty
            ? const AppEmptyHint(message: 'No data yet.')
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        SumRow('Total Meals', totalMeals.toStringAsFixed(2)),
                        const Divider(color: Colors.white24, height: 16),
                        SumRow(
                          'Total Expenses',
                          '৳${totalExpenses.toStringAsFixed(2)}',
                        ),
                        const Divider(color: Colors.white24, height: 16),
                        SumRow(
                          'Meal Rate (per meal)',
                          '৳${rate.toStringAsFixed(4)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Per Member Summary'),
                  const SizedBox(height: 10),
                  ...memberList.map((member) {
                    final meals = controller.memberMeals(member.id);
                    final gross = controller.memberGrossCost(member.id);
                    final paid = controller.memberPaid(member.id);
                    final balance = controller.memberBalance(member.id);
                    return SummaryMemberCard(
                      member: member,
                      meals: meals,
                      grossCost: gross,
                      paid: paid,
                      balance: balance,
                    );
                  }),
                  const SizedBox(height: 20),
                  if (byCategory.isNotEmpty) ...[
                    const SectionHeader(title: 'Expense by Category'),
                    const SizedBox(height: 10),
                    ...byCategory.entries.map(
                      (entry) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.label_outline,
                            color: AppColors.accent,
                          ),
                          title: Text(entry.key),
                          trailing: Text(
                            '৳${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      );
    });
  }
}
