import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class MealEntryScreenController extends GetxController {
  MealEntryScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;
  final selectedDate = DateTime.now().obs;
  final Map<String, TextEditingController> textControllers = {};

  static MealEntryScreenController get instance =>
      Get.isRegistered<MealEntryScreenController>()
      ? Get.find<MealEntryScreenController>()
      : Get.put(MealEntryScreenController());

  String get dateStr => DateFormat('yyyy-MM-dd').format(selectedDate.value);

  List<Member> get members => _viewModel.members.toList();
  List<MealEntry> get mealEntries => _viewModel.mealEntries.toList();

  TextEditingController controllerFor(String memberId) {
    if (!textControllers.containsKey(memberId)) {
      final double value = _viewModel.getMeal(memberId, dateStr);
      textControllers[memberId] = TextEditingController(
        text: value > 0
            ? (value == value.truncateToDouble()
                  ? value.toInt().toString()
                  : value.toString())
            : '',
      );
    }
    return textControllers[memberId]!;
  }

  String formatValue(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  double valueFor(String memberId) =>
      double.tryParse(textControllers[memberId]?.text.trim() ?? '') ?? 0.0;

  void increment(String memberId, double step) {
    final double current = valueFor(memberId);
    textControllers[memberId]!.text = formatValue(current + step);
  }

  void decrement(String memberId, double step) {
    final double current = valueFor(memberId);
    final double next = current - step;
    if (next < 0) return;
    textControllers[memberId]!.text = formatValue(next);
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedDate.value = picked;
      for (final member in _viewModel.members) {
        if (textControllers.containsKey(member.id)) {
          final double value = _viewModel.getMeal(member.id, dateStr);
          textControllers[member.id]!.text = value > 0
              ? formatValue(value)
              : '';
        }
      }
    }
  }

  void copyPreviousDay() {
    final DateTime previousDay = selectedDate.value.subtract(
      const Duration(days: 1),
    );
    final String previousDayStr = DateFormat('yyyy-MM-dd').format(previousDay);
    final List<MealEntry> found = _viewModel.mealEntries
        .where((entry) => entry.date == previousDayStr)
        .toList();
    if (found.isEmpty) {
      return;
    }
    for (final MealEntry entry in found) {
      if (textControllers.containsKey(entry.memberId)) {
        textControllers[entry.memberId]!.text = formatValue(entry.meals);
      }
    }
  }

  void saveMeals() {
    final map = <String, double>{};
    for (final member in _viewModel.members) {
      map[member.id] = valueFor(member.id);
    }
    _viewModel.saveDayMeals(dateStr, map);
  }

  String formattedDateLabel() =>
      DateFormat('EEEE, dd MMMM yyyy').format(selectedDate.value);
  String savedDateLabel() =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  @override
  void onClose() {
    for (final controller in textControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
