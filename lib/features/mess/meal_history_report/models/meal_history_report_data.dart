import '../../../../data/models/mess_models.dart';

class MealHistoryReportRow {
  final String date;
  final Map<String, double> mealsByMember;
  final double dailyTotal;
  final double mealRate;
  final double mealCost;

  const MealHistoryReportRow({
    required this.date,
    required this.mealsByMember,
    required this.dailyTotal,
    required this.mealRate,
    required this.mealCost,
  });
}

class MealHistoryReportSummary {
  final double totalMeals;
  final double totalMealCost;
  final double averageMealRate;
  final int totalActiveDays;

  const MealHistoryReportSummary({
    required this.totalMeals,
    required this.totalMealCost,
    required this.averageMealRate,
    required this.totalActiveDays,
  });
}

class MealHistoryReportData {
  final String monthKey;
  final String monthLabel;
  final List<Member> members;
  final List<MealHistoryReportRow> rows;
  final MealHistoryReportSummary summary;

  const MealHistoryReportData({
    required this.monthKey,
    required this.monthLabel,
    required this.members,
    required this.rows,
    required this.summary,
  });

  List<String> get headers => [
    'Date',
    ...members.map((member) => member.name),
    'Daily Total',
    'Meal Rate',
    'Meal Cost',
  ];

  List<List<String>> get tableData => rows
      .map(
        (row) => [
          row.date,
          ...members.map(
            (member) =>
                row.mealsByMember[member.id]?.toStringAsFixed(2) ?? '0.00',
          ),
          row.dailyTotal.toStringAsFixed(2),
          row.mealRate.toStringAsFixed(4),
          row.mealCost.toStringAsFixed(2),
        ],
      )
      .toList();
}
