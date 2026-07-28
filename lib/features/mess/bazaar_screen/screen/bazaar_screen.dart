import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../controller/bazaar_controller.dart';

class BazaarScreen extends StatelessWidget {
  const BazaarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BazaarController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazaar'),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Shopping List'),
            Tab(text: 'Schedule'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showExportOptions(context, controller),
          ),
        ],
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _ShoppingListTab(controller: controller),
          _BazaarScheduleTab(controller: controller),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, BazaarController controller) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('View PDF'),
              onTap: () {
                Navigator.pop(ctx);
                controller.exportPdf(share: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share PDF'),
              onTap: () {
                Navigator.pop(ctx);
                controller.exportPdf(share: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingListTab extends StatelessWidget {
  final BazaarController controller;

  const _ShoppingListTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final list = controller.shoppingList;
            if (list.isEmpty) {
              return const AppEmptyHint(message: 'Shopping list is empty.');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.isCompleted,
                      onChanged: (_) => controller.toggleShoppingItem(item.id),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        color: item.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: item.quantity.isNotEmpty ? Text(item.quantity) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.deleteShoppingItem(item.id),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Shopping Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Item Name (e.g. Rice)'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity (e.g. 2 kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addShoppingItem(nameCtrl.text, qtyCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _BazaarScheduleTab extends StatelessWidget {
  final BazaarController controller;

  const _BazaarScheduleTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final schedule = controller.bazaarSchedule.toList()
              ..sort((a, b) => a.date.compareTo(b.date));
              
            final futureSchedule = schedule.where((e) => 
                DateTime.parse(e.date).isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();

            if (futureSchedule.isEmpty) {
              return const AppEmptyHint(message: 'No upcoming bazaar schedule.');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: futureSchedule.length,
              itemBuilder: (context, index) {
                final entry = futureSchedule[index];
                final date = DateTime.parse(entry.date);
                final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isToday ? AppColors.primary.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isToday ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isToday ? AppColors.primary : Colors.grey[300],
                      child: Icon(Icons.shopping_basket, color: isToday ? Colors.white : Colors.grey[600]),
                    ),
                    title: Text(
                      DateFormat('EEEE, dd MMM').format(date),
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('Assigned: ${controller.getMemberName(entry.memberId)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => _showReassignDialog(context, entry.date, entry.memberId),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showGenerateWizard(context),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Generate Rotation'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  void _showReassignDialog(BuildContext context, String dateStr, String currentMemberId) {
    String selectedId = currentMemberId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reassign ${DateFormat('dd MMM').format(DateTime.parse(dateStr))}'),
        content: DropdownButtonFormField<String>(
          value: selectedId,
          items: controller.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
          onChanged: (val) {
            if (val != null) selectedId = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateScheduleDate(dateStr, selectedId);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGenerateWizard(BuildContext context) {
    controller.selectedStartDate.value = DateTime.now();
    controller.selectedEndDate.value = DateTime.now().add(const Duration(days: 6));
    controller.selectedMembersForRotation.value = controller.members.map((m) => m.id).toList();

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
              'Generate Rotation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(
                    start: controller.selectedStartDate.value!,
                    end: controller.selectedEndDate.value!,
                  ),
                );
                if (picked != null) {
                  controller.selectedStartDate.value = picked.start;
                  controller.selectedEndDate.value = picked.end;
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                '${DateFormat('dd MMM').format(controller.selectedStartDate.value!)} - ${DateFormat('dd MMM yyyy').format(controller.selectedEndDate.value!)}',
              ),
            )),
            const SizedBox(height: 16),
            const Text('Select Members (Rotation Order)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => ListView(
                children: controller.members.map((m) {
                  final isSelected = controller.selectedMembersForRotation.contains(m.id);
                  return CheckboxListTile(
                    title: Text(m.name),
                    value: isSelected,
                    onChanged: (_) => controller.toggleMemberForRotation(m.id),
                    dense: true,
                  );
                }).toList(),
              )),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.generateSchedule,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Generate'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
