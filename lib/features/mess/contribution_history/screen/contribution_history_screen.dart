import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../controller/contribution_history_controller.dart';

class ContributionHistoryScreen extends StatelessWidget {
  const ContributionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ContributionHistoryController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribution History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final list = controller.filteredContributions;
        final total = controller.totalContribution;
        final bool hasActiveFilters = controller.selectedMemberId.value != null ||
            controller.selectedMonth.value != null ||
            controller.selectedYear.value != null ||
            controller.dateRange.value != null;

        return Column(
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
                  const Text('Total Contribution', style: TextStyle(fontSize: 14)),
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
            if (hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Text('Filters applied', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.clearFilters,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: list.isEmpty
                  ? AppEmptyHint(
                      message: hasActiveFilters 
                        ? 'No contributions found for the selected filters.'
                        : 'No contributions recorded yet.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: list.length,
                      itemBuilder: (_, int index) {
                        final payment = list[index];
                        final memberName = controller.getMemberName(payment.memberId);
                        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(payment.date);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.withOpacity(0.15),
                              child: const Icon(
                                Icons.payments_outlined,
                                color: Colors.teal,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              memberName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '$dateStr${payment.note.isNotEmpty ? '\nNote: ${payment.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: payment.note.isNotEmpty,
                            trailing: Text(
                              '৳${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ContributionHistoryController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filter Contributions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedMemberId.value,
                  decoration: const InputDecoration(labelText: 'Member', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Members')),
                    ...controller.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
                  ],
                  onChanged: (val) => controller.selectedMemberId.value = val,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedMonth.value,
                        decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Months')),
                          ...controller.availableMonths.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                        ],
                        onChanged: (val) => controller.selectedMonth.value = val,
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedYear.value,
                        decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Years')),
                          ...controller.availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y))),
                        ],
                        onChanged: (val) => controller.selectedYear.value = val,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final range = controller.dateRange.value;
              final text = range == null 
                ? 'Select Date Range' 
                : '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}';
              
              return OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange: controller.dateRange.value,
                  );
                  if (picked != null) {
                    controller.dateRange.value = picked;
                    controller.selectedMonth.value = null; // Clear individual month/year when range is picked
                    controller.selectedYear.value = null;
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text(text),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
