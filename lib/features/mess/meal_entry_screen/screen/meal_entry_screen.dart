import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../controller/meal_entry_screen_controller.dart';

class MealEntryScreen extends StatelessWidget {
  const MealEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MealEntryScreenController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy Previous Day',
            onPressed: controller.copyPreviousDay,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: controller.saveMeals,
          ),
        ],
      ),
      body: Obx(() {
        final memberList = controller.members;
        return memberList.isEmpty
            ? const AppEmptyHint(
                message: 'No members yet.\nAdd members in Settings.',
              )
            : Column(
                children: [
                  Material(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: InkWell(
                      onTap: () => controller.pickDate(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              controller.formattedDateLabel(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: memberList.length,
                      itemBuilder: (_, int index) {
                        final member = memberList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 20,
                                  child: Text(
                                    (member.name.isNotEmpty
                                            ? member.name[0]
                                            : '?')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      controller.decrement(member.id, 1),
                                  visualDensity: VisualDensity.compact,
                                ),
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: controller.controllerFor(
                                      member.id,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                    ),
                                    onChanged: (_) {},
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      controller.increment(member.id, 1),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Meals',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: controller.saveMeals,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }
}
