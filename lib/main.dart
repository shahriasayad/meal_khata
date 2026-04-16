import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class Member {
  String id;
  String name;

  Member({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Member.fromJson(Map<String, dynamic> j) =>
      Member(id: j['id'], name: j['name']);
}

class MealEntry {
  String memberId;
  String date; // yyyy-MM-dd
  double meals;

  MealEntry({required this.memberId, required this.date, required this.meals});

  Map<String, dynamic> toJson() => {
    'memberId': memberId,
    'date': date,
    'meals': meals,
  };

  factory MealEntry.fromJson(Map<String, dynamic> j) => MealEntry(
    memberId: j['memberId'],
    date: j['date'],
    meals: (j['meals'] as num).toDouble(),
  );
}

class Expense {
  String id;
  String date; // yyyy-MM-dd
  double amount;
  String category;
  String note;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amount': amount,
    'category': category,
    'note': note,
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'],
    date: j['date'],
    amount: (j['amount'] as num).toDouble(),
    category: j['category'],
    note: j['note'] ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA STORE (Hive-backed singleton)
// ─────────────────────────────────────────────────────────────────────────────

class DataStore {
  static final DataStore _i = DataStore._();
  factory DataStore() => _i;
  DataStore._();

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('messData');
    // seed default categories if absent
    if (categories.isEmpty) {
      categories = ['Groceries', 'Gas', 'Utilities', 'Miscellaneous'];
      _save();
    }
  }

  // ── Members ──
  List<Member> get members {
    final raw = _box.get('members', defaultValue: '[]') as String;
    return (jsonDecode(raw) as List).map((e) => Member.fromJson(e)).toList();
  }

  set members(List<Member> v) =>
      _box.put('members', jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Meal Entries ──
  List<MealEntry> get mealEntries {
    final raw = _box.get('mealEntries', defaultValue: '[]') as String;
    return (jsonDecode(raw) as List).map((e) => MealEntry.fromJson(e)).toList();
  }

  set mealEntries(List<MealEntry> v) =>
      _box.put('mealEntries', jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Expenses ──
  List<Expense> get expenses {
    final raw = _box.get('expenses', defaultValue: '[]') as String;
    return (jsonDecode(raw) as List).map((e) => Expense.fromJson(e)).toList();
  }

  set expenses(List<Expense> v) =>
      _box.put('expenses', jsonEncode(v.map((e) => e.toJson()).toList()));

  // ── Categories ──
  List<String> get categories {
    final raw = _box.get('categories', defaultValue: '[]') as String;
    return List<String>.from(jsonDecode(raw));
  }

  set categories(List<String> v) => _box.put('categories', jsonEncode(v));

  void _save() {} // placeholder; setters write immediately

  // ── Helpers ──
  String get _selectedMonth =>
      _box.get(
            'selectedMonth',
            defaultValue: DateFormat('yyyy-MM').format(DateTime.now()),
          )
          as String;

  set selectedMonth(String v) => _box.put('selectedMonth', v);
  String get selectedMonth => _selectedMonth;

  // ── JSON export/import ──
  Map<String, dynamic> exportAll() => {
    'members': members.map((e) => e.toJson()).toList(),
    'mealEntries': mealEntries.map((e) => e.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'categories': categories,
  };

  void importAll(Map<String, dynamic> data) {
    members = (data['members'] as List).map((e) => Member.fromJson(e)).toList();
    mealEntries = (data['mealEntries'] as List)
        .map((e) => MealEntry.fromJson(e))
        .toList();
    expenses = (data['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList();
    categories = List<String>.from(data['categories'] ?? []);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStore().init();
  runApp(const MessApp());
}

class MessApp extends StatelessWidget {
  const MessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mess Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME (Bottom Nav)
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    DashboardScreen(),
    MealEntryScreen(),
    ExpenseScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(icon: Icon(Icons.summarize), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ds = DataStore();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final month = _ds.selectedMonth; // yyyy-MM
    final members = _ds.members;
    final meals = _ds.mealEntries
        .where((e) => e.date.startsWith(month))
        .toList();
    final expenses = _ds.expenses
        .where((e) => e.date.startsWith(month))
        .toList();

    final totalMeals = meals.fold<double>(0, (s, e) => s + e.meals);
    final totalExpenses = expenses.fold<double>(0, (s, e) => s + e.amount);
    final mealRate = totalMeals > 0 ? totalExpenses / totalMeals : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard — ${_monthLabel(month)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
            tooltip: 'Change Month',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatCard(
              icon: Icons.people,
              label: 'Members',
              value: members.length.toString(),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.restaurant,
              label: 'Total Meals',
              value: totalMeals.toStringAsFixed(1),
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.monetization_on,
              label: 'Total Expenses',
              value: '৳ ${totalExpenses.toStringAsFixed(2)}',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.calculate,
              label: 'Meal Rate',
              value: '৳ ${mealRate.toStringAsFixed(2)} / meal',
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            if (members.isNotEmpty) ...[
              const Text(
                'Member Costs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...members.map((m) {
                final memberMeals = meals
                    .where((e) => e.memberId == m.id)
                    .fold<double>(0, (s, e) => s + e.meals);
                final cost = memberMeals * mealRate;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Text(
                        m.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(m.name),
                    subtitle: Text('${memberMeals.toStringAsFixed(1)} meals'),
                    trailing: Text(
                      '৳ ${cost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final parts = _ds.selectedMonth.split('-');
    final initial = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Month',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      _ds.selectedMonth = DateFormat('yyyy-MM').format(picked);
      setState(() {});
    }
  }

  String _monthLabel(String m) {
    final parts = m.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(dt);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 26,
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEAL ENTRY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final _ds = DataStore();
  DateTime _date = DateTime.now();
  final Map<String, TextEditingController> _controllers = {};

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _loadControllers();
  }

  void _loadControllers() {
    final entries = _ds.mealEntries;
    for (final m in _ds.members) {
      final entry = entries
          .where((e) => e.memberId == m.id && e.date == _dateStr)
          .firstOrNull;
      _controllers[m.id] = TextEditingController(
        text: entry != null ? entry.meals.toString() : '',
      );
    }
  }

  void _refreshControllers() {
    for (final c in _controllers.values) c.dispose();
    _controllers.clear();
    _loadControllers();
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _date = picked;
      _refreshControllers();
    }
  }

  void _save() {
    final entries = _ds.mealEntries.where((e) => e.date != _dateStr).toList();
    for (final m in _ds.members) {
      final txt = _controllers[m.id]?.text.trim() ?? '';
      if (txt.isNotEmpty) {
        final v = double.tryParse(txt) ?? 0;
        if (v > 0) {
          entries.add(MealEntry(memberId: m.id, date: _dateStr, meals: v));
        }
      }
    }
    _ds.mealEntries = entries;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Meals saved!')));
  }

  void _copyPrevious() {
    final prev = _date.subtract(const Duration(days: 1));
    final prevStr = DateFormat('yyyy-MM-dd').format(prev);
    final prevEntries = _ds.mealEntries
        .where((e) => e.date == prevStr)
        .toList();
    if (prevEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data for previous day.')),
      );
      return;
    }
    for (final e in prevEntries) {
      _controllers[e.memberId]?.text = e.meals.toString();
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = _ds.members;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyPrevious,
            tooltip: 'Copy Previous Day',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(child: Text('Add members first in Settings.'))
          : Column(
              children: [
                // Date selector
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    color: const Color(0xFF2E7D32).withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy').format(_date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: members.length,
                    itemBuilder: (_, i) {
                      final m = members[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF2E7D32),
                                child: Text(
                                  m.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  m.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              // Decrement
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  final v =
                                      double.tryParse(
                                        _controllers[m.id]!.text,
                                      ) ??
                                      0;
                                  if (v >= 0.5) {
                                    _controllers[m.id]!.text = (v - 0.5)
                                        .toString();
                                    setState(() {});
                                  }
                                },
                              ),
                              SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: _controllers[m.id],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              // Increment
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  final v =
                                      double.tryParse(
                                        _controllers[m.id]!.text,
                                      ) ??
                                      0;
                                  _controllers[m.id]!.text = (v + 0.5)
                                      .toString();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Meals',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _save,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPENSE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _ds = DataStore();

  @override
  Widget build(BuildContext context) {
    final month = _ds.selectedMonth;
    final expenses =
        _ds.expenses.where((e) => e.date.startsWith(month)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: Text('Expenses — ${_monthLabel(month)}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2E7D32).withOpacity(0.08),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses', style: TextStyle(fontSize: 15)),
                Text(
                  '৳ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses this month.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: expenses.length,
                    itemBuilder: (_, i) {
                      final e = expenses[i];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(
                              Icons.receipt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            '৳ ${e.amount.toStringAsFixed(2)} — ${e.category}',
                          ),
                          subtitle: Text(
                            '${e.date}${e.note.isNotEmpty ? ' • ${e.note}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editExpense(e),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteExpense(e),
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
  }

  Future<void> _addExpense() async {
    final result = await _showExpenseDialog();
    if (result != null) {
      _ds.expenses = [..._ds.expenses, result];
      setState(() {});
    }
  }

  Future<void> _editExpense(Expense e) async {
    final result = await _showExpenseDialog(existing: e);
    if (result != null) {
      _ds.expenses = _ds.expenses
          .map((x) => x.id == e.id ? result : x)
          .toList();
      setState(() {});
    }
  }

  void _deleteExpense(Expense e) {
    _ds.expenses = _ds.expenses.where((x) => x.id != e.id).toList();
    setState(() {});
  }

  Future<Expense?> _showExpenseDialog({Expense? existing}) async {
    final amtCtrl = TextEditingController(
      text: existing?.amount.toString() ?? '',
    );
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    String category =
        existing?.category ??
        (_ds.categories.isNotEmpty ? _ds.categories[0] : '');
    DateTime date = existing != null
        ? DateFormat('yyyy-MM-dd').parse(existing.date)
        : DateTime.now();

    return showDialog<Expense>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Expense' : 'Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('dd MMM yyyy').format(date)),
                    onTap: () async {
                      final p = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (p != null) setS(() => date = p);
                    },
                  ),
                  const Divider(),
                  TextField(
                    controller: amtCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (৳)',
                      prefixText: '৳ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category.isNotEmpty ? category : null,
                    items: _ds.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setS(() => category = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amtCtrl.text.trim());
                  if (amt == null || amt <= 0 || category.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter valid amount and category.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(
                    ctx,
                    Expense(
                      id:
                          existing?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      date: DateFormat('yyyy-MM-dd').format(date),
                      amount: amt,
                      category: category,
                      note: noteCtrl.text.trim(),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _monthLabel(String m) {
    final parts = m.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMM yyyy').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY + PDF
// ─────────────────────────────────────────────────────────────────────────────

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _ds = DataStore();

  @override
  Widget build(BuildContext context) {
    final month = _ds.selectedMonth;
    final members = _ds.members;
    final meals = _ds.mealEntries
        .where((e) => e.date.startsWith(month))
        .toList();
    final expenses = _ds.expenses
        .where((e) => e.date.startsWith(month))
        .toList();

    final totalMeals = meals.fold<double>(0, (s, e) => s + e.meals);
    final totalExpenses = expenses.fold<double>(0, (s, e) => s + e.amount);
    final mealRate = totalMeals > 0 ? totalExpenses / totalMeals : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary — ${_monthLabel(month)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePDF(
              members,
              meals,
              expenses,
              totalMeals,
              totalExpenses,
              mealRate,
            ),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(child: Text('No members yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryHeader(totalMeals, totalExpenses, mealRate),
                const SizedBox(height: 16),
                const Text(
                  'Per Member Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...members.map((m) {
                  final mMeals = meals
                      .where((e) => e.memberId == m.id)
                      .fold<double>(0, (s, e) => s + e.meals);
                  final cost = mMeals * mealRate;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2E7D32),
                            child: Text(
                              m.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Meals: ${mMeals.toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳ ${cost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const Text(
                                'Payable',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Expense Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(() {
                  final Map<String, double> byCat = {};
                  for (final e in expenses) {
                    byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
                  }
                  return byCat.entries.map(
                    (entry) => Card(
                      child: ListTile(
                        title: Text(entry.key),
                        trailing: Text(
                          '৳ ${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                })(),
              ],
            ),
    );
  }

  Widget _summaryHeader(
    double totalMeals,
    double totalExpenses,
    double mealRate,
  ) {
    return Card(
      color: const Color(0xFF2E7D32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerRow('Total Meals', totalMeals.toStringAsFixed(1)),
            const Divider(color: Colors.white38),
            _headerRow(
              'Total Expenses',
              '৳ ${totalExpenses.toStringAsFixed(2)}',
            ),
            const Divider(color: Colors.white38),
            _headerRow('Meal Rate', '৳ ${mealRate.toStringAsFixed(2)} / meal'),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(String m) {
    final parts = m.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(dt);
  }

  Future<void> _generatePDF(
    List<Member> members,
    List<MealEntry> meals,
    List<Expense> expenses,
    double totalMeals,
    double totalExpenses,
    double mealRate,
  ) async {
    final month = _ds.selectedMonth;
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
              'Month: ${_monthLabel(month)}',
              style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          // Summary
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['Metric', 'Value'],
            data: [
              ['Total Meals', totalMeals.toStringAsFixed(1)],
              ['Total Expenses', '৳ ${totalExpenses.toStringAsFixed(2)}'],
              ['Meal Rate', '৳ ${mealRate.toStringAsFixed(2)} / meal'],
            ],
          ),
          pw.SizedBox(height: 16),

          // Members
          pw.Text(
            'Member-wise Summary',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['Member', 'Total Meals', 'Payable (৳)'],
            data: members.map((m) {
              final mMeals = meals
                  .where((e) => e.memberId == m.id)
                  .fold<double>(0, (s, e) => s + e.meals);
              final cost = mMeals * mealRate;
              return [
                m.name,
                mMeals.toStringAsFixed(1),
                cost.toStringAsFixed(2),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),

          // Expenses
          pw.Text(
            'Expense Details',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Amount (৳)', 'Note'],
            data: expenses
                .map(
                  (e) => [
                    e.date,
                    e.category,
                    e.amount.toStringAsFixed(2),
                    e.note,
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

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN (Members + Categories + Backup/Restore)
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _ds = DataStore();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Categories'),
            Tab(text: 'Backup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _MembersTab(onChanged: () => setState(() {})),
          _CategoriesTab(onChanged: () => setState(() {})),
          _BackupTab(),
        ],
      ),
    );
  }
}

// ── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatefulWidget {
  final VoidCallback onChanged;
  const _MembersTab({required this.onChanged});

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  final _ds = DataStore();

  @override
  Widget build(BuildContext context) {
    final members = _ds.members;
    return Column(
      children: [
        Expanded(
          child: members.isEmpty
              ? const Center(child: Text('No members yet. Add one!'))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: members.length,
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return Card(
                      key: ValueKey(m.id),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2E7D32),
                          child: Text(
                            m.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(m.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editMember(m),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteMember(m),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onReorder: (o, n) {
                    if (n > o) n--;
                    final list = List<Member>.from(_ds.members);
                    list.insert(n, list.removeAt(o));
                    _ds.members = list;
                    setState(() {});
                    widget.onChanged();
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
              onPressed: _addMember,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addMember() async {
    final name = await _nameDialog('Add Member');
    if (name != null && name.isNotEmpty) {
      _ds.members = [
        ..._ds.members,
        Member(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
        ),
      ];
      setState(() {});
      widget.onChanged();
    }
  }

  Future<void> _editMember(Member m) async {
    final name = await _nameDialog('Edit Member', initial: m.name);
    if (name != null && name.isNotEmpty) {
      _ds.members = _ds.members
          .map((x) => x.id == m.id ? Member(id: m.id, name: name) : x)
          .toList();
      setState(() {});
      widget.onChanged();
    }
  }

  void _deleteMember(Member m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member?'),
        content: Text(
          'Remove "${m.name}"? All meal records for this member will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _ds.members = _ds.members.where((x) => x.id != m.id).toList();
              _ds.mealEntries = _ds.mealEntries
                  .where((e) => e.memberId != m.id)
                  .toList();
              Navigator.pop(context);
              setState(() {});
              widget.onChanged();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<String?> _nameDialog(String title, {String initial = ''}) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Categories Tab ───────────────────────────────────────────────────────────

class _CategoriesTab extends StatefulWidget {
  final VoidCallback onChanged;
  const _CategoriesTab({required this.onChanged});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  final _ds = DataStore();

  @override
  Widget build(BuildContext context) {
    final cats = _ds.categories;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: cats.length,
            itemBuilder: (_, i) => Card(
              child: ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(cats[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    final list = List<String>.from(_ds.categories);
                    list.removeAt(i);
                    _ds.categories = list;
                    setState(() {});
                  },
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
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              onPressed: _addCategory,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addCategory() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      _ds.categories = [..._ds.categories, name];
      setState(() {});
    }
  }
}

// ── Backup Tab ───────────────────────────────────────────────────────────────

class _BackupTab extends StatelessWidget {
  final _ds = DataStore();

  _BackupTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Backup & Restore',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your data as a JSON file to backup, or import a previously exported JSON file to restore.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.upload_file),
            label: const Text(
              'Export Data as JSON',
              style: TextStyle(fontSize: 15),
            ),
            onPressed: () => _export(context),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.download),
            label: const Text(
              'Import Data from JSON',
              style: TextStyle(fontSize: 15),
            ),
            onPressed: () => _import(context),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'App Version: 1.0.0\nData stored locally on device.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final data = jsonEncode(_ds.exportAll());
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/mess_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json',
      );
      await file.writeAsString(data);
      await Share.shareXFiles([XFile(file.path)], text: 'Mess Manager Backup');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _import(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;
      final content = await File(result.files.single.path!).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      _ds.importAll(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data restored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }
}
