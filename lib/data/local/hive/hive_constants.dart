class HiveConstants {
  static const String boxName = 'messData';
  static const String membersKey = 'members';
  static const String mealsKey = 'mealEntries';
  static const String expensesKey = 'expenses';
  static const String categoriesKey = 'categories';
  static const String paymentsKey = 'payments';

  static const List<String> defaultCategories = <String>[
    'Groceries',
    'Gas',
    'Utilities',
    'Miscellaneous',
  ];

  HiveConstants._();
}
