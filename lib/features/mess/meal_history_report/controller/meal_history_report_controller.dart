import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/mess_models.dart';
import '../../view_models/mess_view_model.dart';
import '../models/meal_history_report_data.dart';

class MealHistoryReportController extends GetxController {
  MealHistoryReportController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;
  final selectedMonth = DateFormat('yyyy-MM').format(DateTime.now()).obs;
  final reportData = Rxn<MealHistoryReportData>();
  final List<Worker> _workers = [];

  static MealHistoryReportController get instance =>
      Get.isRegistered<MealHistoryReportController>()
      ? Get.find<MealHistoryReportController>()
      : Get.put(MealHistoryReportController());

  @override
  void onInit() {
    super.onInit();
    _workers.add(ever(selectedMonth, (_) => _rebuildReport()));
    _workers.add(ever(_viewModel.mealEntries, (_) => _rebuildReport()));
    _workers.add(ever(_viewModel.members, (_) => _rebuildReport()));
    _workers.add(ever(_viewModel.expenses, (_) => _rebuildReport()));
    _rebuildReport();
  }

  String get monthLabel => _formatMonth(selectedMonth.value);

  bool get hasRows => reportData.value?.rows.isNotEmpty ?? false;

  List<Member> get members => _viewModel.members.toList();

  void prevMonth() {
    selectedMonth.value = _shiftMonth(selectedMonth.value, -1);
  }

  void nextMonth() {
    selectedMonth.value = _shiftMonth(selectedMonth.value, 1);
  }

  void exportPdf() {
    final data = reportData.value;
    if (data == null) return;
    _viewModel.exportMealHistoryReportPdf(data, share: false);
  }

  void sharePdf() {
    final data = reportData.value;
    if (data == null) return;
    _viewModel.exportMealHistoryReportPdf(data, share: true);
  }

  void _rebuildReport() {
    final members = _viewModel.members.toList();
    final monthMealEntries = _viewModel.mealsForMonth(selectedMonth.value);
    final dates = monthMealEntries.map((entry) => entry.date).toSet().toList()
      ..sort();

    final totalMeals = _viewModel.totalMealsForMonth(selectedMonth.value);
    final totalMealCost = _viewModel.totalExpensesForMonth(selectedMonth.value);
    final mealRate = _viewModel.mealRateForMonth(selectedMonth.value);

    final rows = dates.map((date) {
      final mealsByMember = _viewModel.getDayMeals(date);
      final dailyTotal = mealsByMember.values.fold(
        0.0,
        (sum, value) => sum + value,
      );
      return MealHistoryReportRow(
        date: date,
        mealsByMember: mealsByMember,
        dailyTotal: dailyTotal,
        mealRate: mealRate,
        mealCost: dailyTotal * mealRate,
      );
    }).toList();

    reportData.value = MealHistoryReportData(
      monthKey: selectedMonth.value,
      monthLabel: monthLabel,
      members: members,
      rows: rows,
      summary: MealHistoryReportSummary(
        totalMeals: totalMeals,
        totalMealCost: totalMealCost,
        averageMealRate: mealRate,
        totalActiveDays: dates.length,
      ),
    );
  }

  String _shiftMonth(String yyyyMM, int delta) {
    try {
      final parts = yyyyMM.split('-');
      if (parts.length < 2) return DateFormat('yyyy-MM').format(DateTime.now());
      var year = int.tryParse(parts[0]) ?? DateTime.now().year;
      var month = (int.tryParse(parts[1]) ?? 1) + delta;

      while (month <= 0) {
        month += 12;
        year--;
      }
      while (month > 12) {
        month -= 12;
        year++;
      }

      return '$year-${month.toString().padLeft(2, '0')}';
    } catch (_) {
      return DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  String _formatMonth(String yyyyMM) {
    try {
      final parts = yyyyMM.split('-');
      if (parts.length < 2) return 'Invalid Month';
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null || month < 1 || month > 12) {
        return 'Invalid Month';
      }
      return DateFormat('MMMM yyyy').format(DateTime(year, month));
    } catch (_) {
      return 'Invalid Month';
    }
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}
