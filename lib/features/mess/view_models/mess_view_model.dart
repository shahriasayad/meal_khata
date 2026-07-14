import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/models/mess_models.dart';
import '../../../data/repositories/mess_repository.dart';

class MessViewModel extends GetxController {
  MessViewModel({MessRepository? repository})
    : _repository = repository ?? MessRepository();

  final MessRepository _repository;

  final members = <Member>[].obs;
  final mealEntries = <MealEntry>[].obs;
  final expenses = <Expense>[].obs;
  final payments = <Payment>[].obs;
  final categories = <String>[].obs;

  final selectedMonth = ''.obs;
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    members.value = _repository.members;
    mealEntries.value = _repository.mealEntries;
    expenses.value = _repository.expenses;
    payments.value = _repository.payments;
    categories.value = _repository.categories;
    selectedMonth.value = DateFormat('yyyy-MM').format(DateTime.now());
  }

  List<MealEntry> get monthMeals =>
      mealEntries.where((e) => e.date.startsWith(selectedMonth.value)).toList();

  List<Expense> get monthExpenses =>
      expenses.where((e) => e.date.startsWith(selectedMonth.value)).toList();

  List<Payment> get monthPayments =>
      payments.where((p) => p.month == selectedMonth.value).toList();

  double get totalMeals => monthMeals.fold(0.0, (sum, e) => sum + e.meals);

  double get totalExpenses =>
      monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  double get mealRate => totalMeals > 0 ? totalExpenses / totalMeals : 0.0;

  double memberMeals(String memberId) => monthMeals
      .where((e) => e.memberId == memberId)
      .fold(0.0, (sum, e) => sum + e.meals);

  double memberGrossCost(String memberId) => memberMeals(memberId) * mealRate;

  double memberPaid(String memberId) => monthPayments
      .where((p) => p.memberId == memberId)
      .fold(0.0, (sum, p) => sum + p.amount);

  double memberBalance(String memberId) =>
      memberGrossCost(memberId) - memberPaid(memberId);

  double get totalPaid => monthPayments.fold(0.0, (sum, p) => sum + p.amount);

  void addMember(String name) {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    members.add(member);
    _repository.members = members.toList();
  }

  void updateMember(String id, String name) {
    final int index = members.indexWhere((m) => m.id == id);
    if (index == -1) return;
    members[index] = members[index].copyWith(name: name.trim());
    members.refresh();
    _repository.members = members.toList();
  }

  void deleteMember(String id) {
    members.removeWhere((m) => m.id == id);
    mealEntries.removeWhere((e) => e.memberId == id);
    payments.removeWhere((p) => p.memberId == id);
    _repository.members = members.toList();
    _repository.mealEntries = mealEntries.toList();
    _repository.payments = payments.toList();
  }

  void reorderMembers(int oldIndex, int newIndex) {
    final list = members.toList();
    list.insert(newIndex, list.removeAt(oldIndex));
    members.value = list;
    _repository.members = list;
  }

  void saveDayMeals(String date, Map<String, double> mealsMap) {
    mealEntries.removeWhere((e) => e.date == date);
    for (final entry in mealsMap.entries) {
      if (entry.value > 0) {
        mealEntries.add(
          MealEntry(memberId: entry.key, date: date, meals: entry.value),
        );
      }
    }
    _repository.mealEntries = mealEntries.toList();
  }

  double getMeal(String memberId, String date) {
    try {
      return mealEntries
          .firstWhere((e) => e.memberId == memberId && e.date == date)
          .meals;
    } catch (_) {
      return 0.0;
    }
  }

  Map<String, double> getDayMeals(String date) {
    final map = <String, double>{};
    for (final member in members) {
      map[member.id] = getMeal(member.id, date);
    }
    return map;
  }

  void addExpense(Expense expense) {
    expenses.add(expense);
    _repository.expenses = expenses.toList();
  }

  void updateExpense(Expense updated) {
    final int index = expenses.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    expenses[index] = updated;
    expenses.refresh();
    _repository.expenses = expenses.toList();
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    _repository.expenses = expenses.toList();
  }

  void addPayment(Payment payment) {
    payments.add(payment);
    _repository.payments = payments.toList();
  }

  void deletePayment(String id) {
    payments.removeWhere((p) => p.id == id);
    _repository.payments = payments.toList();
  }

  List<Payment> memberMonthPayments(String memberId) =>
      monthPayments.where((p) => p.memberId == memberId).toList();

  void addCategory(String name) {
    categories.add(name.trim());
    _repository.categories = categories.toList();
  }

  void deleteCategory(int index) {
    if (index >= 0 && index < categories.length) {
      categories.removeAt(index);
      _repository.categories = categories.toList();
    }
  }

  void setMonth(String yyyyMM) {
    selectedMonth.value = yyyyMM;
  }

  void prevMonth() {
    try {
      final parts = selectedMonth.value.split('-');
      if (parts.length < 2) return;
      var year = int.tryParse(parts[0]) ?? DateTime.now().year;
      var month = (int.tryParse(parts[1]) ?? 1) - 1;
      if (month == 0) {
        month = 12;
        year--;
      }
      selectedMonth.value = '$year-${month.toString().padLeft(2, '0')}';
    } catch (_) {
      selectedMonth.value = DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  void nextMonth() {
    try {
      final parts = selectedMonth.value.split('-');
      if (parts.length < 2) return;
      var year = int.tryParse(parts[0]) ?? DateTime.now().year;
      var month = (int.tryParse(parts[1]) ?? 1) + 1;
      if (month == 13) {
        month = 1;
        year++;
      }
      selectedMonth.value = '$year-${month.toString().padLeft(2, '0')}';
    } catch (_) {
      selectedMonth.value = DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  String get monthLabel {
    try {
      final parts = selectedMonth.value.split('-');
      if (parts.length < 2) return 'Invalid Month';
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null || month < 1 || month > 12) {
        return 'Invalid Month';
      }
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return 'Invalid Month';
    }
  }

  void wipeAllData() {
    members.clear();
    mealEntries.clear();
    expenses.clear();
    payments.clear();
    _repository.members = [];
    _repository.mealEntries = [];
    _repository.expenses = [];
    _repository.payments = [];
  }

  Future<void> generatePdf() async {
    final memberList = members.toList();
    final monthMealsList = monthMeals;
    final monthExpensesList = monthExpenses;
    final monthPaymentsList = monthPayments;
    final rate = mealRate;
    final totalMealsValue = totalMeals;
    final totalExpensesValue = totalExpenses;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Mess Manager Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Month: $monthLabel',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(),
          ],
        ),
        build: (_) => [
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headers: ['Metric', 'Value'],
            data: [
              ['Total Meals', totalMealsValue.toStringAsFixed(2)],
              [
                'Total Expenses',
                '${totalExpensesValue.toStringAsFixed(2)} BDT',
              ],
              ['Meal Rate', '${rate.toStringAsFixed(4)} BDT/meal'],
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Member Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headers: ['Member', 'Meals', 'Gross Cost', 'Paid', 'Balance'],
            data: memberList.map((member) {
              final meals = monthMealsList
                  .where((entry) => entry.memberId == member.id)
                  .fold(0.0, (sum, entry) => sum + entry.meals);
              final gross = meals * rate;
              final paid = monthPaymentsList
                  .where((payment) => payment.memberId == member.id)
                  .fold(0.0, (sum, payment) => sum + payment.amount);
              final balance = gross - paid;
              return [
                member.name,
                meals.toStringAsFixed(2),
                gross.toStringAsFixed(2),
                paid.toStringAsFixed(2),
                '${balance >= 0 ? 'Due: ' : 'Adv: '}${balance.abs().toStringAsFixed(2)}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Expense Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Note'],
            data: monthExpensesList
                .map(
                  (expense) => [
                    expense.date,
                    expense.category,
                    expense.amount.toStringAsFixed(2),
                    expense.note,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}
