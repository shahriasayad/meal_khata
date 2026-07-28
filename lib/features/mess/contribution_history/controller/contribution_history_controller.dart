import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../view_models/mess_view_model.dart';

class ContributionHistoryController extends GetxController {
  ContributionHistoryController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;
  
  final selectedMemberId = RxnString();
  final selectedMonth = RxnString();
  final selectedYear = RxnString();
  final dateRange = Rxn<DateTimeRange>();

  static ContributionHistoryController get instance =>
      Get.isRegistered<ContributionHistoryController>()
      ? Get.find<ContributionHistoryController>()
      : Get.put(ContributionHistoryController());

  List<Member> get members => _viewModel.members.toList();
  
  List<String> get availableYears {
    final years = _viewModel.payments.map((p) => p.date.year.toString()).toSet().toList();
    if (years.isEmpty) years.add(DateTime.now().year.toString());
    years.sort((a, b) => b.compareTo(a));
    return years;
  }
  
  List<String> get availableMonths {
    return [
      '01', '02', '03', '04', '05', '06', 
      '07', '08', '09', '10', '11', '12'
    ];
  }

  List<Payment> get filteredContributions {
    var list = _viewModel.payments.toList();
    
    if (selectedMemberId.value != null && selectedMemberId.value!.isNotEmpty) {
      list = list.where((p) => p.memberId == selectedMemberId.value).toList();
    }
    if (selectedYear.value != null && selectedYear.value!.isNotEmpty) {
      list = list.where((p) => p.date.year.toString() == selectedYear.value).toList();
    }
    if (selectedMonth.value != null && selectedMonth.value!.isNotEmpty) {
      list = list.where((p) => p.date.month.toString().padLeft(2, '0') == selectedMonth.value).toList();
    }
    if (dateRange.value != null) {
      final start = dateRange.value!.start;
      final end = dateRange.value!.end.add(const Duration(days: 1));
      list = list.where((p) => p.date.isAfter(start) && p.date.isBefore(end)).toList();
    }
    
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalContribution => 
    filteredContributions.fold(0.0, (sum, p) => sum + p.amount);

  String getMemberName(String id) {
    try {
      return members.firstWhere((m) => m.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  void clearFilters() {
    selectedMemberId.value = null;
    selectedMonth.value = null;
    selectedYear.value = null;
    dateRange.value = null;
  }
}
