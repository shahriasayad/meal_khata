import '../local/hive/hive_service.dart';
import '../models/note_model.dart';
import '../models/mess_models.dart';

class MessRepository {
  MessRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  Future<void> init() => _hiveService.init();

  List<Member> get members => _hiveService.rawMembers;
  set members(List<Member> value) => _hiveService.rawMembers = value;

  List<MealEntry> get mealEntries => _hiveService.rawMeals;
  set mealEntries(List<MealEntry> value) => _hiveService.rawMeals = value;

  List<Expense> get expenses => _hiveService.rawExpenses;
  set expenses(List<Expense> value) => _hiveService.rawExpenses = value;

  List<Payment> get payments => _hiveService.rawPayments;
  set payments(List<Payment> value) => _hiveService.rawPayments = value;

  List<String> get categories => _hiveService.rawCategories;
  set categories(List<String> value) => _hiveService.rawCategories = value;

  List<Note> get notes => _hiveService.rawNotes;
  set notes(List<Note> value) => _hiveService.rawNotes = value;

  Map<String, dynamic> exportAll() => _hiveService.exportAll();
  void importAll(Map<String, dynamic> data) => _hiveService.importAll(data);
}
