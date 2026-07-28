class Member {
  final String id;
  final String name;

  const Member({required this.id, required this.name});

  Member copyWith({String? name}) => Member(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as String, name: json['name'] as String);
}

class MealEntry {
  final String memberId;
  final String date;
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

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    memberId: json['memberId'] as String,
    date: json['date'] as String,
    meals: (json['meals'] as num).toDouble(),
  );
}

class Expense {
  final String id;
  final String date;
  final double amount;
  final String category;
  final String memberId;
  final String note;

  const Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    this.memberId = '',
    this.note = '',
  });

  Expense copyWith({
    String? date,
    double? amount,
    String? category,
    String? memberId,
    String? note,
  }) => Expense(
    id: id,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    memberId: memberId ?? this.memberId,
    note: note ?? this.note,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amount': amount,
    'category': category,
    'memberId': memberId,
    'note': note,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    date: json['date'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    memberId: (json['memberId'] as String?) ?? '',
    note: (json['note'] as String?) ?? '',
  );
}

class Payment {
  final String id;
  final String memberId;
  final String month;
  final double amount;
  final String note;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(int.parse(id));

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

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    memberId: json['memberId'] as String,
    month: json['month'] as String,
    amount: (json['amount'] as num).toDouble(),
    note: (json['note'] as String?) ?? '',
  );
}

class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final bool isCompleted;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = '',
    this.isCompleted = false,
  });

  ShoppingItem copyWith({
    String? name,
    String? quantity,
    bool? isCompleted,
  }) => ShoppingItem(
    id: id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'isCompleted': isCompleted,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: (json['quantity'] as String?) ?? '',
    isCompleted: (json['isCompleted'] as bool?) ?? false,
  );
}

class BazaarScheduleEntry {
  final String date; // Format: yyyy-MM-dd
  final String memberId;

  const BazaarScheduleEntry({
    required this.date,
    required this.memberId,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'memberId': memberId,
  };

  factory BazaarScheduleEntry.fromJson(Map<String, dynamic> json) => BazaarScheduleEntry(
    date: json['date'] as String,
    memberId: json['memberId'] as String,
  );
}
