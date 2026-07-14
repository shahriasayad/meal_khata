import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class DashboardScreenController extends GetxController {
  DashboardScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static DashboardScreenController get instance =>
      Get.isRegistered<DashboardScreenController>()
      ? Get.find<DashboardScreenController>()
      : Get.put(DashboardScreenController());

  List<Member> get members => _viewModel.members;
  double get totalMeals => _viewModel.totalMeals;
  double get totalExpenses => _viewModel.totalExpenses;
  double get mealRate => _viewModel.mealRate;
  double get totalPaid => _viewModel.totalPaid;
  String get monthLabel => _viewModel.monthLabel;

  double memberMeals(String memberId) => _viewModel.memberMeals(memberId);
  double memberGrossCost(String memberId) =>
      _viewModel.memberGrossCost(memberId);
  double memberPaid(String memberId) => _viewModel.memberPaid(memberId);
  double memberBalance(String memberId) => _viewModel.memberBalance(memberId);

  void prevMonth() => _viewModel.prevMonth();
  void nextMonth() => _viewModel.nextMonth();
  void openDrawer() => scaffoldKey.currentState?.openDrawer();
  void wipeAllData() => _viewModel.wipeAllData();
}
