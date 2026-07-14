import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/mess_widgets.dart';
import '../controller/meal_history_report_controller.dart';
import '../widgets/meal_history_report_widgets.dart';

class MealHistoryReportScreen extends StatelessWidget {
  const MealHistoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MealHistoryReportController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: controller.exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share PDF',
            onPressed: controller.sharePdf,
          ),
        ],
      ),
      body: Obx(() {
        final report = controller.reportData.value;
        if (report == null || report.rows.isEmpty) {
          return Column(
            children: [
              MealHistoryMonthBanner(
                monthLabel: controller.monthLabel,
                onPreviousMonth: controller.prevMonth,
                onNextMonth: controller.nextMonth,
              ),
              const Expanded(
                child: AppEmptyHint(
                  message: 'No meal records found for this month.',
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            MealHistoryMonthBanner(
              monthLabel: controller.monthLabel,
              onPreviousMonth: controller.prevMonth,
              onNextMonth: controller.nextMonth,
            ),
            Expanded(child: MealHistorySpreadsheet(reportData: report)),
          ],
        );
      }),
    );
  }
}
