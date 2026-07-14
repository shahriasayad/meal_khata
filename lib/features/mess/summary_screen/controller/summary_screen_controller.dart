import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class SummaryScreenController extends GetxController {
  SummaryScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static SummaryScreenController get instance =>
      Get.isRegistered<SummaryScreenController>()
      ? Get.find<SummaryScreenController>()
      : Get.put(SummaryScreenController());

  List<Member> get members => _viewModel.members.toList();
  double get totalMeals => _viewModel.totalMeals;
  double get totalExpenses => _viewModel.totalExpenses;
  double get mealRate => _viewModel.mealRate;
  String get monthLabel => _viewModel.monthLabel;
  List<Expense> get monthExpenses => _viewModel.monthExpenses;

  double memberMeals(String memberId) => _viewModel.memberMeals(memberId);
  double memberGrossCost(String memberId) =>
      _viewModel.memberGrossCost(memberId);
  double memberPaid(String memberId) => _viewModel.memberPaid(memberId);
  double memberBalance(String memberId) => _viewModel.memberBalance(memberId);

  Map<String, double> categoryBreakdown() {
    final map = <String, double>{};
    for (final expense in monthExpenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  void exportPdf() => _viewModel.generatePdf();
}
