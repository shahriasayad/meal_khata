import '../local/hive/hive_service.dart';
import '../models/note_model.dart';

class NotesRepository {
  NotesRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  List<Note> get notes => _hiveService.rawNotes;

  set notes(List<Note> value) => _hiveService.rawNotes = value;
}
