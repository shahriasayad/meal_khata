import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/mess_models.dart';
import 'hive_constants.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  late Box<dynamic> _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(HiveConstants.boxName);
    if (rawCategories.isEmpty) {
      rawCategories = HiveConstants.defaultCategories;
    }
  }

  List<Member> get rawMembers {
    final String data =
        _box.get(HiveConstants.membersKey, defaultValue: '[]') as String;
    return (jsonDecode(data) as List)
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set rawMembers(List<Member> value) {
    _box.put(
      HiveConstants.membersKey,
      jsonEncode(value.map((e) => e.toJson()).toList()),
    );
  }

  List<MealEntry> get rawMeals {
    final String data =
        _box.get(HiveConstants.mealsKey, defaultValue: '[]') as String;
    return (jsonDecode(data) as List)
        .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set rawMeals(List<MealEntry> value) {
    _box.put(
      HiveConstants.mealsKey,
      jsonEncode(value.map((e) => e.toJson()).toList()),
    );
  }

  List<Expense> get rawExpenses {
    final String data =
        _box.get(HiveConstants.expensesKey, defaultValue: '[]') as String;
    return (jsonDecode(data) as List)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set rawExpenses(List<Expense> value) {
    _box.put(
      HiveConstants.expensesKey,
      jsonEncode(value.map((e) => e.toJson()).toList()),
    );
  }

  List<Payment> get rawPayments {
    final String data =
        _box.get(HiveConstants.paymentsKey, defaultValue: '[]') as String;
    return (jsonDecode(data) as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  set rawPayments(List<Payment> value) {
    _box.put(
      HiveConstants.paymentsKey,
      jsonEncode(value.map((e) => e.toJson()).toList()),
    );
  }

  List<String> get rawCategories {
    final String data =
        _box.get(HiveConstants.categoriesKey, defaultValue: '[]') as String;
    return List<String>.from(jsonDecode(data) as List);
  }

  set rawCategories(List<String> value) {
    _box.put(HiveConstants.categoriesKey, jsonEncode(value));
  }

  Map<String, dynamic> exportAll() => {
    'members': rawMembers.map((e) => e.toJson()).toList(),
    'mealEntries': rawMeals.map((e) => e.toJson()).toList(),
    'expenses': rawExpenses.map((e) => e.toJson()).toList(),
    'payments': rawPayments.map((e) => e.toJson()).toList(),
    'categories': rawCategories,
  };

  void importAll(Map<String, dynamic> data) {
    rawMembers = (data['members'] as List)
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
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
