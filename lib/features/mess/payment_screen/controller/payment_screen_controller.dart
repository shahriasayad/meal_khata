import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class PaymentScreenController extends GetxController {
  PaymentScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static PaymentScreenController get instance =>
      Get.isRegistered<PaymentScreenController>()
      ? Get.find<PaymentScreenController>()
      : Get.put(PaymentScreenController());

  List<Member> get members => _viewModel.members.toList();
  double get totalPaid => _viewModel.totalPaid;
  double get totalExpenses => _viewModel.totalExpenses;
  String get monthLabel => _viewModel.monthLabel;
  String get selectedMonth => _viewModel.selectedMonth.value;
  double netDue() => totalExpenses - totalPaid;

  double grossCost(String memberId) => _viewModel.memberGrossCost(memberId);
  double paid(String memberId) => _viewModel.memberPaid(memberId);
  double balance(String memberId) => _viewModel.memberBalance(memberId);
  List<Payment> paymentsFor(String memberId) =>
      _viewModel.memberMonthPayments(memberId);

  void deletePayment(String id) => _viewModel.deletePayment(id);

  void addPayment(Payment payment) => _viewModel.addPayment(payment);
}
