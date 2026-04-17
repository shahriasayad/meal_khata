// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════

class Member {
  final String id;
  final String name;

  const Member({required this.id, required this.name});

  Member copyWith({String? name}) => Member(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Member.fromJson(Map<String, dynamic> j) =>
      Member(id: j['id'] as String, name: j['name'] as String);
}

class MealEntry {
  final String memberId;
  final String date; // yyyy-MM-dd
  final double meals;

  const MealEntry({
    required this.memberId,
    required this.date,
    required this.meals,
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'date': date,
        'meals': meals,
      };

  factory MealEntry.fromJson(Map<String, dynamic> j) => MealEntry(
        memberId: j['memberId'] as String,
        date: j['date'] as String,
        meals: (j['meals'] as num).toDouble(),
      );
}

class Expense {
  final String id;
  final String date; // yyyy-MM-dd
  final double amount;
  final String category;
  final String note;

  const Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    this.note = '',
  });

  Expense copyWith({
    String? date,
    double? amount,
    String? category,
    String? note,
  }) =>
      Expense(
        id: id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'amount': amount,
        'category': category,
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        date: j['date'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: j['category'] as String,
        note: (j['note'] as String?) ?? '',
      );
}

/// Records how much a member has paid toward the mess fund for a given month.
class Payment {
  final String id;
  final String memberId;
  final String month; // yyyy-MM
  final double amount;
  final String note;

  const Payment({
    required this.id,
    required this.memberId,
    required this.month,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'month': month,
        'amount': amount,
        'note': note,
      };

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'] as String,
        memberId: j['memberId'] as String,
        month: j['month'] as String,
        amount: (j['amount'] as num).toDouble(),
        note: (j['note'] as String?) ?? '',
      );
}

// ════════════════════════════════════════════════════════════════════════════
// HIVE DATA STORE  (raw persistence layer – no reactive state here)
// ════════════════════════════════════════════════════════════════════════════

class HiveStore {
  static final HiveStore _i = HiveStore._();
  factory HiveStore() => _i;
  HiveStore._();

  late Box _box;

  static const _kMembers = 'members';
  static const _kMeals = 'mealEntries';
  static const _kExpenses = 'expenses';
  static const _kCategories = 'categories';
  static const _kPayments = 'payments';
  static const _kTheme = 'themeMode';

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('messData');
    if (rawCategories.isEmpty) {
      rawCategories = ['Groceries', 'Gas', 'Utilities', 'Miscellaneous'];
    }
  }

  // ── Members ──────────────────────────────────────────────────────────────
  List<Member> get rawMembers {
    final s = _box.get(_kMembers, defaultValue: '[]') as String;
    return (jsonDecode(s) as List).map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
  }

  set rawMembers(List<Member> v) =>
      _box.put(_kMembers, jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Meal Entries ─────────────────────────────────────────────────────────
  List<MealEntry> get rawMeals {
    final s = _box.get(_kMeals, defaultValue: '[]') as String;
    return (jsonDecode(s) as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  set rawMeals(List<MealEntry> v) =>
      _box.put(_kMeals, jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Expenses ─────────────────────────────────────────────────────────────
  List<Expense> get rawExpenses {
    final s = _box.get(_kExpenses, defaultValue: '[]') as String;
    return (jsonDecode(s) as List).map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
  }

  set rawExpenses(List<Expense> v) =>
      _box.put(_kExpenses, jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Payments ─────────────────────────────────────────────────────────────
  List<Payment> get rawPayments {
    final s = _box.get(_kPayments, defaultValue: '[]') as String;
    return (jsonDecode(s) as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }

  set rawPayments(List<Payment> v) =>
      _box.put(_kPayments, jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Categories ───────────────────────────────────────────────────────────
  List<String> get rawCategories {
    final s = _box.get(_kCategories, defaultValue: '[]') as String;
    return List<String>.from(jsonDecode(s) as List);
  }

  set rawCategories(List<String> v) =>
      _box.put(_kCategories, jsonEncode(v));

  // ── Theme ─────────────────────────────────────────────────────────────────
  String get rawTheme => _box.get(_kTheme, defaultValue: 'system') as String;
  set rawTheme(String v) => _box.put(_kTheme, v);

  // ── Full export / import ─────────────────────────────────────────────────
  Map<String, dynamic> exportAll() => {
        'members': rawMembers.map((e) => e.toJson()).toList(),
        'mealEntries': rawMeals.map((e) => e.toJson()).toList(),
        'expenses': rawExpenses.map((e) => e.toJson()).toList(),
        'payments': rawPayments.map((e) => e.toJson()).toList(),
        'categories': rawCategories,
      };

  void importAll(Map<String, dynamic> data) {
    rawMembers =
        (data['members'] as List).map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
    rawMeals = (data['mealEntries'] as List)
        .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    rawExpenses = (data['expenses'] as List)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
    rawPayments = (data['payments'] as List? ?? [])
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
    rawCategories = List<String>.from(data['categories'] as List? ?? []);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// GETX CONTROLLER  – single source of truth for all reactive state
// ════════════════════════════════════════════════════════════════════════════

class MessController extends GetxController {
  final _store = HiveStore();

  // ── Reactive collections ─────────────────────────────────────────────────
  final members = <Member>[].obs;
  final mealEntries = <MealEntry>[].obs;
  final expenses = <Expense>[].obs;
  final payments = <Payment>[].obs;
  final categories = <String>[].obs;

  // ── Reactive UI state ────────────────────────────────────────────────────
  final selectedMonth = ''.obs; // yyyy-MM
  final themeMode = ThemeMode.system.obs;
  final currentTabIndex = 0.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    members.value = _store.rawMembers;
    mealEntries.value = _store.rawMeals;
    expenses.value = _store.rawExpenses;
    payments.value = _store.rawPayments;
    categories.value = _store.rawCategories;
    selectedMonth.value =
        DateFormat('yyyy-MM').format(DateTime.now());
    themeMode.value = _parseTheme(_store.rawTheme);
  }

  ThemeMode _parseTheme(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // CALCULATIONS  (pure, derived, always accurate)
  // ════════════════════════════════════════════════════════════════════════

  /// All meal entries for the currently selected month.
  List<MealEntry> get monthMeals =>
      mealEntries.where((e) => e.date.startsWith(selectedMonth.value)).toList();

  /// All expenses for the currently selected month.
  List<Expense> get monthExpenses =>
      expenses.where((e) => e.date.startsWith(selectedMonth.value)).toList();

  /// All payments for the currently selected month.
  List<Payment> get monthPayments =>
      payments.where((p) => p.month == selectedMonth.value).toList();

  /// Grand total of all meals in the month.
  double get totalMeals =>
      monthMeals.fold(0.0, (sum, e) => sum + e.meals);

  /// Grand total of all expenses in the month.
  double get totalExpenses =>
      monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Cost per single meal = totalExpenses / totalMeals.
  /// Returns 0 when there are no meals to avoid division by zero.
  double get mealRate => totalMeals > 0 ? totalExpenses / totalMeals : 0.0;

  /// Total meals consumed by a specific member this month.
  double memberMeals(String memberId) =>
      monthMeals
          .where((e) => e.memberId == memberId)
          .fold(0.0, (sum, e) => sum + e.meals);

  /// Gross cost a member owes based on meals × mealRate.
  double memberGrossCost(String memberId) => memberMeals(memberId) * mealRate;

  /// Total amount a member has already paid this month.
  double memberPaid(String memberId) =>
      monthPayments
          .where((p) => p.memberId == memberId)
          .fold(0.0, (sum, p) => sum + p.amount);

  /// Net amount a member still owes (gross cost − paid).
  /// Positive → member owes this much more.
  /// Negative → member has overpaid (credit).
  double memberBalance(String memberId) =>
      memberGrossCost(memberId) - memberPaid(memberId);

  /// Total amount paid by all members this month.
  double get totalPaid =>
      monthPayments.fold(0.0, (sum, p) => sum + p.amount);

  // ════════════════════════════════════════════════════════════════════════
  // MEMBERS
  // ════════════════════════════════════════════════════════════════════════

  void addMember(String name) {
    final m = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    members.add(m);
    _store.rawMembers = members.toList();
  }

  void updateMember(String id, String name) {
    final idx = members.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    members[idx] = members[idx].copyWith(name: name.trim());
    members.refresh();
    _store.rawMembers = members.toList();
  }

  void deleteMember(String id) {
    members.removeWhere((m) => m.id == id);
    mealEntries.removeWhere((e) => e.memberId == id);
    payments.removeWhere((p) => p.memberId == id);
    _store.rawMembers = members.toList();
    _store.rawMeals = mealEntries.toList();
    _store.rawPayments = payments.toList();
  }

  void reorderMembers(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final list = members.toList();
    list.insert(newIndex, list.removeAt(oldIndex));
    members.value = list;
    _store.rawMembers = list;
  }

  // ════════════════════════════════════════════════════════════════════════
  // MEAL ENTRIES
  // ════════════════════════════════════════════════════════════════════════

  /// Saves meal values for an entire day, replacing any existing entries.
  void saveDayMeals(String date, Map<String, double> mealsMap) {
    // Remove existing entries for this date.
    mealEntries.removeWhere((e) => e.date == date);
    // Add new entries (skip zero values).
    for (final entry in mealsMap.entries) {
      if (entry.value > 0) {
        mealEntries.add(MealEntry(
          memberId: entry.key,
          date: date,
          meals: entry.value,
        ));
      }
    }
    _store.rawMeals = mealEntries.toList();
  }

  /// Returns the meal value for a member on a specific date (0 if absent).
  double getMeal(String memberId, String date) {
    try {
      return mealEntries
          .firstWhere((e) => e.memberId == memberId && e.date == date)
          .meals;
    } catch (_) {
      return 0.0;
    }
  }

  /// Returns a map of memberId → meals for a given date.
  Map<String, double> getDayMeals(String date) {
    final map = <String, double>{};
    for (final m in members) {
      map[m.id] = getMeal(m.id, date);
    }
    return map;
  }

  // ════════════════════════════════════════════════════════════════════════
  // EXPENSES
  // ════════════════════════════════════════════════════════════════════════

  void addExpense(Expense e) {
    expenses.add(e);
    _store.rawExpenses = expenses.toList();
  }

  void updateExpense(Expense updated) {
    final idx = expenses.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    expenses[idx] = updated;
    expenses.refresh();
    _store.rawExpenses = expenses.toList();
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    _store.rawExpenses = expenses.toList();
  }

  // ════════════════════════════════════════════════════════════════════════
  // PAYMENTS
  // ════════════════════════════════════════════════════════════════════════

  void addPayment(Payment p) {
    payments.add(p);
    _store.rawPayments = payments.toList();
  }

  void deletePayment(String id) {
    payments.removeWhere((p) => p.id == id);
    _store.rawPayments = payments.toList();
  }

  List<Payment> memberMonthPayments(String memberId) =>
      monthPayments.where((p) => p.memberId == memberId).toList();

  // ════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ════════════════════════════════════════════════════════════════════════

  void addCategory(String name) {
    categories.add(name.trim());
    _store.rawCategories = categories.toList();
  }

  void deleteCategory(int index) {
    categories.removeAt(index);
    _store.rawCategories = categories.toList();
  }

  // ════════════════════════════════════════════════════════════════════════
  // MONTH NAVIGATION
  // ════════════════════════════════════════════════════════════════════════

  void setMonth(String yyyyMM) {
    selectedMonth.value = yyyyMM;
  }

  void prevMonth() {
    final parts = selectedMonth.value.split('-');
    var y = int.parse(parts[0]);
    var m = int.parse(parts[1]) - 1;
    if (m == 0) {
      m = 12;
      y--;
    }
    selectedMonth.value = '$y-${m.toString().padLeft(2, '0')}';
  }

  void nextMonth() {
    final parts = selectedMonth.value.split('-');
    var y = int.parse(parts[0]);
    var m = int.parse(parts[1]) + 1;
    if (m == 13) {
      m = 1;
      y++;
    }
    selectedMonth.value = '$y-${m.toString().padLeft(2, '0')}';
  }

  String get monthLabel {
    final parts = selectedMonth.value.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(dt);
  }

  // ════════════════════════════════════════════════════════════════════════
  // THEME
  // ════════════════════════════════════════════════════════════════════════

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    String key;
    switch (mode) {
      case ThemeMode.light:
        key = 'light';
        break;
      case ThemeMode.dark:
        key = 'dark';
        break;
      default:
        key = 'system';
    }
    _store.rawTheme = key;
    // Apply to running app
    Get.changeThemeMode(mode);
  }

  // ════════════════════════════════════════════════════════════════════════
  // BACKUP / RESTORE
  // ════════════════════════════════════════════════════════════════════════

  Future<void> exportJson() async {
    final data = jsonEncode(_store.exportAll());
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/mess_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json',
    );
    await file.writeAsString(data);
    await Share.shareXFiles([XFile(file.path)], text: 'Mess Manager Backup');
  }

  Future<bool> importJson() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return false;
    final content = await File(result.files.single.path!).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    _store.importAll(data);
    _load(); // refresh reactive state
    return true;
  }

  // ════════════════════════════════════════════════════════════════════════
  // PDF GENERATION
  // ════════════════════════════════════════════════════════════════════════

  Future<void> generatePdf() async {
    final memList = members.toList();
    final mMeals = monthMeals;
    final mExpenses = monthExpenses;
    final mPayments = monthPayments;
    final rate = mealRate;
    final tMeals = totalMeals;
    final tExp = totalExpenses;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Mess Manager Report',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Month: $monthLabel',
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 6),
            pw.Divider(),
          ],
        ),
        build: (_) => [
          // ── Summary ────────────────────────────────────────────────────
          pw.Text('Summary',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Table.fromTextArray(
            headers: ['Metric', 'Value'],
            data: [
              ['Total Meals', tMeals.toStringAsFixed(2)],
              ['Total Expenses', '${tExp.toStringAsFixed(2)} BDT'],
              ['Meal Rate', '${rate.toStringAsFixed(4)} BDT/meal'],
            ],
          ),
          pw.SizedBox(height: 14),

          // ── Members ────────────────────────────────────────────────────
          pw.Text('Member Summary',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Table.fromTextArray(
            headers: [
              'Member',
              'Meals',
              'Gross Cost',
              'Paid',
              'Balance',
            ],
            data: memList.map((m) {
              final meals = mMeals
                  .where((e) => e.memberId == m.id)
                  .fold(0.0, (s, e) => s + e.meals);
              final gross = meals * rate;
              final paid = mPayments
                  .where((p) => p.memberId == m.id)
                  .fold(0.0, (s, p) => s + p.amount);
              final bal = gross - paid;
              return [
                m.name,
                meals.toStringAsFixed(2),
                gross.toStringAsFixed(2),
                paid.toStringAsFixed(2),
                '${bal >= 0 ? 'Due: ' : 'Adv: '}${bal.abs().toStringAsFixed(2)}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 14),

          // ── Expenses ───────────────────────────────────────────────────
          pw.Text('Expense Details',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Note'],
            data: mExpenses
                .map((e) => [
                      e.date,
                      e.category,
                      e.amount.toStringAsFixed(2),
                      e.note,
                    ])
                .toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN
// ════════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStore().init();
  runApp(const MessApp());
}

// ════════════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════════════

const _kGreen = Color(0xFF1B5E20);
const _kGreenAccent = Color(0xFF43A047);

class MessApp extends StatelessWidget {
  const MessApp({super.key});

  ThemeData _buildLight() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _kGreen,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: _kGreen.withOpacity(0.15),
        ),
      );

  ThemeData _buildDark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _kGreen,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreenAccent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _kGreenAccent,
          foregroundColor: Colors.white,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Register controller globally
    Get.put(MessController());

    return GetMaterialApp(
      title: 'Mess Manager',
      debugShowCheckedModeBanner: false,
      theme: _buildLight(),
      darkTheme: _buildDark(),
      themeMode: Get.find<MessController>().themeMode.value,
      home: const HomeScreen(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HOME – bottom navigation shell
// ════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _screens = [
    DashboardScreen(),
    MealEntryScreen(),
    ExpenseScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: ctrl.currentTabIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: ctrl.currentTabIndex.value,
            onDestinationSelected: (i) => ctrl.currentTabIndex.value = i,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard'),
              NavigationDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: 'Meals'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Expenses'),
              NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings'),
            ],
          ),
        ));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD  (modern card layout)
// ════════════════════════════════════════════════════════════════════════════

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final totalMeals = ctrl.totalMeals;
      final totalExpenses = ctrl.totalExpenses;
      final rate = ctrl.mealRate;
      final totalPaid = ctrl.totalPaid;
      final totalDue = totalExpenses - totalPaid;
      final memberList = ctrl.members.toList();

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF1F8E9),
        body: CustomScrollView(
          slivers: [
            // ── Hero App Bar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: _kGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kGreen, _kGreenAccent],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mess Manager',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ctrl.monthLabel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            _MonthNavBtn(
                                icon: Icons.chevron_left,
                                onTap: ctrl.prevMonth),
                            const SizedBox(width: 4),
                            _MonthNavBtn(
                                icon: Icons.chevron_right,
                                onTap: ctrl.nextMonth),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Top 4-grid stats ──────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _MiniStatCard(
                        label: 'Total Meals',
                        value: totalMeals.toStringAsFixed(1),
                        icon: Icons.restaurant,
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      _MiniStatCard(
                        label: 'Meal Rate',
                        value: '৳${rate.toStringAsFixed(2)}',
                        icon: Icons.calculate,
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                      _MiniStatCard(
                        label: 'Total Expenses',
                        value: '৳${totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.red,
                        isDark: isDark,
                      ),
                      _MiniStatCard(
                        label: 'Total Paid',
                        value: '৳${totalPaid.toStringAsFixed(0)}',
                        icon: Icons.check_circle,
                        color: Colors.teal,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Outstanding balance banner ──────────────────────
                  _BalanceBanner(
                      totalExpenses: totalExpenses,
                      totalPaid: totalPaid,
                      totalDue: totalDue),

                  const SizedBox(height: 20),

                  // ── Member cost cards ─────────────────────────────────
                  if (memberList.isEmpty)
                    const _EmptyHint(
                        message: 'No members yet.\nGo to Settings to add some.')
                  else ...[
                    _SectionHeader(
                        title: 'Member Breakdown',
                        subtitle: '${memberList.length} members'),
                    const SizedBox(height: 10),
                    ...memberList.map((m) {
                      final meals = ctrl.memberMeals(m.id);
                      final gross = ctrl.memberGrossCost(m.id);
                      final paid = ctrl.memberPaid(m.id);
                      final balance = ctrl.memberBalance(m.id);
                      return _MemberCostCard(
                        member: m,
                        meals: meals,
                        grossCost: gross,
                        paid: paid,
                        balance: balance,
                        isDark: isDark,
                      );
                    }),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Payments',
                            icon: Icons.payments_outlined,
                            color: Colors.blue,
                            isDark: isDark,
                            onTap: () {
                              Get.to(() => const PaymentScreen());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Summary',
                            icon: Icons.summarize_outlined,
                            color: Colors.green,
                            isDark: isDark,
                            onTap: () {
                              Get.to(() => const SummaryScreen());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MonthNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[900])),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  final double totalExpenses;
  final double totalPaid;
  final double totalDue;

  const _BalanceBanner({
    required this.totalExpenses,
    required this.totalPaid,
    required this.totalDue,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = totalDue <= 0.01;
    final progress =
        totalExpenses > 0 ? (totalPaid / totalExpenses).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSettled
              ? [const Color(0xFF00695C), const Color(0xFF00897B)]
              : [const Color(0xFFE65100), const Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isSettled ? Icons.check_circle : Icons.pending_actions,
                  color: Colors.white,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                isSettled ? 'All payments settled!' : 'Outstanding Balance',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const Spacer(),
              if (!isSettled)
                Text(
                  '৳${totalDue.toStringAsFixed(2)} due',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '৳${totalPaid.toStringAsFixed(2)} collected of ৳${totalExpenses.toStringAsFixed(2)}',
            style:
                const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MemberCostCard extends StatelessWidget {
  final Member member;
  final double meals;
  final double grossCost;
  final double paid;
  final double balance;
  final bool isDark;

  const _MemberCostCard({
    required this.member,
    required this.meals,
    required this.grossCost,
    required this.paid,
    required this.balance,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = balance > 0.01;
    final isCredit = balance < -0.01;

    Color statusColor;
    String statusLabel;
    if (isDue) {
      statusColor = Colors.red;
      statusLabel = 'Due ৳${balance.toStringAsFixed(2)}';
    } else if (isCredit) {
      statusColor = Colors.teal;
      statusLabel = 'Adv ৳${balance.abs().toStringAsFixed(2)}';
    } else {
      statusColor = Colors.green;
      statusLabel = 'Settled';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: _kGreen,
            radius: 22,
            child: Text(member.name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.grey[900])),
                const SizedBox(height: 2),
                Text(
                  '${meals.toStringAsFixed(1)} meals  •  Cost ৳${grossCost.toStringAsFixed(2)}  •  Paid ৳${paid.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Status chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(statusLabel,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (subtitle != null)
            Text(subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// MEAL ENTRY SCREEN
// ════════════════════════════════════════════════════════════════════════════

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final _ctrl = Get.find<MessController>();
  DateTime _date = DateTime.now();
  // memberId → controller
  final Map<String, TextEditingController> _textCtrls = {};

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    for (final c in _textCtrls.values) c.dispose();
    _textCtrls.clear();
    for (final m in _ctrl.members) {
      final v = _ctrl.getMeal(m.id, _dateStr);
      _textCtrls[m.id] =
          TextEditingController(text: v > 0 ? _fmt(v) : '');
    }
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  double _val(String memberId) =>
      double.tryParse(_textCtrls[memberId]?.text.trim() ?? '') ?? 0.0;

  void _increment(String memberId, double step) {
    final cur = _val(memberId);
    final next = (cur + step);
    _textCtrls[memberId]!.text = _fmt(next);
    setState(() {});
  }

  void _decrement(String memberId, double step) {
    final cur = _val(memberId);
    final next = cur - step;
    if (next < 0) return;
    _textCtrls[memberId]!.text = _fmt(next);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (p != null) {
      _date = p;
      _rebuildControllers();
      setState(() {});
    }
  }

  void _copyPrevDay() {
    final prev = _date.subtract(const Duration(days: 1));
    final prevStr = DateFormat('yyyy-MM-dd').format(prev);
    final found = _ctrl.mealEntries.where((e) => e.date == prevStr).toList();
    if (found.isEmpty) {
      _snack('No data for previous day.');
      return;
    }
    for (final e in found) {
      if (_textCtrls.containsKey(e.memberId)) {
        _textCtrls[e.memberId]!.text = _fmt(e.meals);
      }
    }
    setState(() {});
  }

  void _save() {
    final map = <String, double>{};
    for (final m in _ctrl.members) {
      map[m.id] = _val(m.id);
    }
    _ctrl.saveDayMeals(_dateStr, map);
    _snack('Meals saved for ${DateFormat('dd MMM yyyy').format(_date)}');
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    for (final c in _textCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final memberList = _ctrl.members.toList();
      // Keep controllers in sync when members change
      for (final m in memberList) {
        if (!_textCtrls.containsKey(m.id)) {
          final v = _ctrl.getMeal(m.id, _dateStr);
          _textCtrls[m.id] =
              TextEditingController(text: v > 0 ? _fmt(v) : '');
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Meal Entry'),
          actions: [
            IconButton(
                icon: const Icon(Icons.copy_all),
                tooltip: 'Copy Previous Day',
                onPressed: _copyPrevDay),
            IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save',
                onPressed: _save),
          ],
        ),
        body: memberList.isEmpty
            ? const _EmptyHint(
                message: 'No members yet.\nAdd members in Settings.')
            : Column(
                children: [
                  // Date selector banner
                  Material(
                    color: _kGreen.withOpacity(0.08),
                    child: InkWell(
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: _kGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(_date),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _kGreen),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: _kGreen),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: memberList.length,
                      itemBuilder: (_, i) {
                        final m = memberList[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _kGreen,
                                  radius: 20,
                                  child: Text(m.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(m.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                // Decrement
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _decrement(m.id, 0.5),
                                  visualDensity: VisualDensity.compact,
                                ),
                                // Value field
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: _textCtrls[m.id],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                // Increment
                                IconButton(
                                  icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: _kGreen),
                                  onPressed: () =>
                                      _increment(m.id, 0.5),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Save button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14)),
                          icon: const Icon(Icons.save),
                          label: const Text('Save Meals',
                              style: TextStyle(fontSize: 16)),
                          onPressed: _save,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// EXPENSE SCREEN
// ════════════════════════════════════════════════════════════════════════════

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Obx(() {
      final list = ctrl.monthExpenses
        ..sort((a, b) => b.date.compareTo(a.date));
      final total = ctrl.totalExpenses;

      return Scaffold(
        appBar: AppBar(
          title: Text('Expenses — ${ctrl.monthLabel}'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'expense_fab',
          onPressed: () => _showExpenseDialog(context, ctrl),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        body: Column(
          children: [
            // total bar
            Container(
              color: _kGreen.withOpacity(0.08),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: _kGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text('Total Expenses',
                      style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  Text('৳${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _kGreen)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const _EmptyHint(
                      message:
                          'No expenses this month.\nTap + to add one.')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final e = list[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.15),
                              child: const Icon(Icons.receipt_long,
                                  color: Colors.redAccent, size: 20),
                            ),
                            title: Text(
                              '${e.category}   ৳${e.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${e.date}${e.note.isNotEmpty ? '  •  ${e.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 20),
                                  onPressed: () => _showExpenseDialog(
                                      context, ctrl,
                                      existing: e),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.red),
                                  onPressed: () =>
                                      ctrl.deleteExpense(e.id),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showExpenseDialog(
    BuildContext context,
    MessController ctrl, {
    Expense? existing,
  }) async {
    final amtCtrl =
        TextEditingController(text: existing?.amount.toString() ?? '');
    final noteCtrl =
        TextEditingController(text: existing?.note ?? '');
    String category = existing?.category ??
        (ctrl.categories.isNotEmpty ? ctrl.categories.first : '');
    DateTime date = existing != null
        ? DateFormat('yyyy-MM-dd').parse(existing.date)
        : DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title:
              Text(existing == null ? 'Add Expense' : 'Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title:
                      Text(DateFormat('dd MMM yyyy').format(date)),
                  onTap: () async {
                    final p = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030));
                    if (p != null) setSt(() => date = p);
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
                TextField(
                  controller: amtCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (৳)', prefixText: '৳ '),
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      value: ctrl.categories.contains(category)
                          ? category
                          : null,
                      items: ctrl.categories
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setSt(() => category = v ?? ''),
                      decoration: const InputDecoration(
                          labelText: 'Category'),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt =
                    double.tryParse(amtCtrl.text.trim());
                if (amt == null || amt <= 0) {
                  Get.snackbar('Error', 'Enter a valid amount.',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                if (category.isEmpty) {
                  Get.snackbar('Error', 'Select a category.',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                final exp = Expense(
                  id: existing?.id ??
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                  date: DateFormat('yyyy-MM-dd').format(date),
                  amount: amt,
                  category: category,
                  note: noteCtrl.text.trim(),
                );
                if (existing == null) {
                  ctrl.addExpense(exp);
                } else {
                  ctrl.updateExpense(exp);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    amtCtrl.dispose();
    noteCtrl.dispose();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PAYMENT SCREEN
// ════════════════════════════════════════════════════════════════════════════

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Obx(() {
      final memberList = ctrl.members.toList();
      final totalPaid = ctrl.totalPaid;
      final totalExpenses = ctrl.totalExpenses;
      final netDue = totalExpenses - totalPaid;

      return Scaffold(
        appBar: AppBar(
          title: Text('Payments — ${ctrl.monthLabel}'),
        ),
        floatingActionButton: memberList.isEmpty
            ? null
            : FloatingActionButton.extended(
                heroTag: 'pay_fab',
                onPressed: () =>
                    _showAddPaymentDialog(context, ctrl, memberList),
                icon: const Icon(Icons.add),
                label: const Text('Add Payment'),
              ),
        body: Column(
          children: [
            // Summary row
            Container(
              color: _kGreen.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _PayStat(
                      label: 'Total Expenses',
                      value: '৳${totalExpenses.toStringAsFixed(2)}',
                      color: Colors.red),
                  const SizedBox(width: 12),
                  _PayStat(
                      label: 'Total Paid',
                      value: '৳${totalPaid.toStringAsFixed(2)}',
                      color: Colors.teal),
                  const SizedBox(width: 12),
                  _PayStat(
                      label: netDue > 0 ? 'Due' : 'Advance',
                      value: '৳${netDue.abs().toStringAsFixed(2)}',
                      color:
                          netDue > 0.01 ? Colors.orange : Colors.green),
                ],
              ),
            ),

            Expanded(
              child: memberList.isEmpty
                  ? const _EmptyHint(
                      message: 'Add members in Settings first.')
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: memberList.length,
                      itemBuilder: (_, i) {
                        final m = memberList[i];
                        final gross = ctrl.memberGrossCost(m.id);
                        final paid = ctrl.memberPaid(m.id);
                        final balance = ctrl.memberBalance(m.id);
                        final memberPayments =
                            ctrl.memberMonthPayments(m.id);

                        return _MemberPaymentTile(
                          member: m,
                          grossCost: gross,
                          paid: paid,
                          balance: balance,
                          payments: memberPayments,
                          onDelete: ctrl.deletePayment,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showAddPaymentDialog(
    BuildContext context,
    MessController ctrl,
    List<Member> members,
  ) async {
    String selectedMemberId = members.first.id;
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Record Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMemberId,
                  items: members
                      .map((m) => DropdownMenuItem(
                          value: m.id, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) =>
                      setSt(() => selectedMemberId = v ?? ''),
                  decoration:
                      const InputDecoration(labelText: 'Member'),
                ),
                const SizedBox(height: 12),
                // Quick-fill balance button
                Obx(() {
                  final balance =
                      ctrl.memberBalance(selectedMemberId);
                  if (balance <= 0) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        amtCtrl.text =
                            balance.toStringAsFixed(2);
                      },
                      icon: const Icon(Icons.auto_fix_high,
                          size: 16),
                      label: Text(
                          'Fill due: ৳${balance.toStringAsFixed(2)}'),
                    ),
                  );
                }),
                TextField(
                  controller: amtCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (৳)',
                      prefixText: '৳ '),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt =
                    double.tryParse(amtCtrl.text.trim());
                if (amt == null || amt <= 0) {
                  Get.snackbar('Error', 'Enter a valid amount.',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                ctrl.addPayment(Payment(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  memberId: selectedMemberId,
                  month: ctrl.selectedMonth.value,
                  amount: amt,
                  note: noteCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    amtCtrl.dispose();
    noteCtrl.dispose();
  }
}

class _PayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PayStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      );
}

class _MemberPaymentTile extends StatelessWidget {
  final Member member;
  final double grossCost;
  final double paid;
  final double balance;
  final List<Payment> payments;
  final void Function(String) onDelete;

  const _MemberPaymentTile({
    required this.member,
    required this.grossCost,
    required this.paid,
    required this.balance,
    required this.payments,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = balance > 0.01;
    final statusColor = isDue ? Colors.orange : Colors.green;
    final statusText = isDue
        ? 'Due ৳${balance.toStringAsFixed(2)}'
        : balance < -0.01
            ? 'Adv ৳${balance.abs().toStringAsFixed(2)}'
            : 'Settled';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _kGreen,
          child: Text(member.name[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(member.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Gross ৳${grossCost.toStringAsFixed(2)}  •  Paid ৳${paid.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Text(statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        children: [
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No payments recorded.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...payments.map((p) => ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(Icons.payments_outlined,
                      color: Colors.teal, size: 18),
                  title: Text('৳${p.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: p.note.isNotEmpty ? Text(p.note) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => onDelete(p.id),
                    visualDensity: VisualDensity.compact,
                  ),
                )),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUMMARY SCREEN
// ════════════════════════════════════════════════════════════════════════════

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Obx(() {
      final memberList = ctrl.members.toList();
      final totalMeals = ctrl.totalMeals;
      final totalExpenses = ctrl.totalExpenses;
      final rate = ctrl.mealRate;

      // Category breakdown
      final Map<String, double> byCat = {};
      for (final e in ctrl.monthExpenses) {
        byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Summary — ${ctrl.monthLabel}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Export PDF',
              onPressed: ctrl.generatePdf,
            ),
          ],
        ),
        body: memberList.isEmpty
            ? const _EmptyHint(message: 'No data yet.')
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Header card ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kGreen, _kGreenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _SumRow('Total Meals',
                            totalMeals.toStringAsFixed(2)),
                        const Divider(color: Colors.white24, height: 16),
                        _SumRow('Total Expenses',
                            '৳${totalExpenses.toStringAsFixed(2)}'),
                        const Divider(color: Colors.white24, height: 16),
                        _SumRow('Meal Rate (per meal)',
                            '৳${rate.toStringAsFixed(4)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Per member ───────────────────────────────────────
                  const _SectionHeader(title: 'Per Member Summary'),
                  const SizedBox(height: 10),
                  ...memberList.map((m) {
                    final meals = ctrl.memberMeals(m.id);
                    final gross = ctrl.memberGrossCost(m.id);
                    final paid = ctrl.memberPaid(m.id);
                    final balance = ctrl.memberBalance(m.id);
                    return _SummaryMemberCard(
                      member: m,
                      meals: meals,
                      grossCost: gross,
                      paid: paid,
                      balance: balance,
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Category breakdown ───────────────────────────────
                  if (byCat.isNotEmpty) ...[
                    const _SectionHeader(title: 'Expense by Category'),
                    const SizedBox(height: 10),
                    ...byCat.entries.map((en) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.label_outline,
                                color: _kGreenAccent),
                            title: Text(en.key),
                            trailing: Text(
                              '৳${en.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _kGreen),
                            ),
                          ),
                        )),
                  ],
                ],
              ),
      );
    });
  }
}

class _SumRow extends StatelessWidget {
  final String label;
  final String value;
  const _SumRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      );
}

class _SummaryMemberCard extends StatelessWidget {
  final Member member;
  final double meals;
  final double grossCost;
  final double paid;
  final double balance;

  const _SummaryMemberCard({
    required this.member,
    required this.meals,
    required this.grossCost,
    required this.paid,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = balance > 0.01;
    final isAdv = balance < -0.01;
    Color balColor = isAdv ? Colors.teal : (isDue ? Colors.red : Colors.green);
    String balLabel = isAdv
        ? 'Advance: ৳${balance.abs().toStringAsFixed(2)}'
        : isDue
            ? 'Due: ৳${balance.toStringAsFixed(2)}'
            : 'Settled ✓';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _kGreen,
                  radius: 18,
                  child: Text(member.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Text(member.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text(balLabel,
                    style: TextStyle(
                        color: balColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SmallStat(
                    label: 'Meals',
                    value: meals.toStringAsFixed(2)),
                _SmallStat(
                    label: 'Meal Cost',
                    value: '৳${grossCost.toStringAsFixed(2)}'),
                _SmallStat(
                    label: 'Paid',
                    value: '৳${paid.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  const _SmallStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ════════════════════════════════════════════════════════════════════════════

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Categories'),
            Tab(text: 'Theme'),
            Tab(text: 'Backup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _MembersTab(),
          _CategoriesTab(),
          _ThemeTab(),
          _BackupTab(),
        ],
      ),
    );
  }
}

// ── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Obx(() {
      final memberList = ctrl.members.toList();
      return Column(
        children: [
          Expanded(
            child: memberList.isEmpty
                ? const _EmptyHint(
                    message: 'No members yet.\nTap + to add.')
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: memberList.length,
                    itemBuilder: (_, i) {
                      final m = memberList[i];
                      return Card(
                        key: ValueKey(m.id),
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _kGreen,
                            child: Text(m.name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                          title: Text(m.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                onPressed: () =>
                                    _editDialog(context, ctrl, m),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red),
                                onPressed: () =>
                                    _deleteConfirm(context, ctrl, m),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onReorder: ctrl.reorderMembers,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
                onPressed: () => _addDialog(context, ctrl),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _addDialog(
      BuildContext context, MessController ctrl) async {
    final c = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) {
                ctrl.addMember(c.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    c.dispose();
  }

  Future<void> _editDialog(
      BuildContext context, MessController ctrl, Member m) async {
    final c = TextEditingController(text: m.name);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Member'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) {
                ctrl.updateMember(m.id, c.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    c.dispose();
  }

  void _deleteConfirm(
      BuildContext context, MessController ctrl, Member m) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member?'),
        content: Text(
            'Remove "${m.name}"? All meal and payment records for this member will also be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () {
              ctrl.deleteMember(m.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Categories Tab ────────────────────────────────────────────────────────────

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Obx(() => Column(
          children: [
            Expanded(
              child: ctrl.categories.isEmpty
                  ? const _EmptyHint(message: 'No categories yet.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: ctrl.categories.length,
                      itemBuilder: (_, i) => Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: const Icon(Icons.label_outline,
                              color: _kGreenAccent),
                          title: Text(ctrl.categories[i]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            onPressed: () =>
                                ctrl.deleteCategory(i),
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                  onPressed: () => _addDialog(context, ctrl),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> _addDialog(
      BuildContext context, MessController ctrl) async {
    final c = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration:
              const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) {
                ctrl.addCategory(c.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    c.dispose();
  }
}

// ── Theme Tab ─────────────────────────────────────────────────────────────────

class _ThemeTab extends StatelessWidget {
  const _ThemeTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    const options = [
      (ThemeMode.system, Icons.brightness_auto, 'System Default',
          'Follow device setting'),
      (ThemeMode.light, Icons.light_mode, 'Light Mode',
          'Always use light theme'),
      (ThemeMode.dark, Icons.dark_mode, 'Dark Mode',
          'Always use dark theme'),
    ];

    return Obx(() => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Appearance',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              'Choose how Mess Manager looks. System Default follows your device\'s setting.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final (mode, icon, title, subtitle) = opt;
              final selected = ctrl.themeMode.value == mode;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: selected
                      ? const BorderSide(color: _kGreen, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Icon(icon,
                      color: selected ? _kGreen : Colors.grey),
                  title: Text(title,
                      style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  subtitle: Text(subtitle,
                      style: const TextStyle(fontSize: 12)),
                  trailing: selected
                      ? const Icon(Icons.check_circle,
                          color: _kGreen)
                      : null,
                  onTap: () => ctrl.setTheme(mode),
                ),
              );
            }),
          ],
        ));
  }
}

// ── Backup Tab ────────────────────────────────────────────────────────────────

class _BackupTab extends StatelessWidget {
  const _BackupTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MessController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Backup & Restore',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Export all data as JSON to keep a backup, or import a previously exported JSON file to restore.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.upload_file),
            label: const Text('Export Data as JSON',
                style: TextStyle(fontSize: 15)),
            onPressed: () async {
              try {
                await ctrl.exportJson();
              } catch (e) {
                Get.snackbar('Error', 'Export failed: $e',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: _kGreen)),
            icon: const Icon(Icons.download, color: _kGreen),
            label: const Text('Import Data from JSON',
                style: TextStyle(fontSize: 15, color: _kGreen)),
            onPressed: () async {
              try {
                final ok = await ctrl.importJson();
                Get.snackbar(
                  ok ? 'Success' : 'Cancelled',
                  ok
                      ? 'Data restored successfully!'
                      : 'No file selected.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar('Error', 'Import failed: $e',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'App Version: 2.0.0\nData stored locally on device.\nNo internet required.',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}