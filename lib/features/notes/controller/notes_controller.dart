import 'package:get/get.dart';

import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';

class NotesController extends GetxController {
  NotesController() : _repository = NotesRepository();

  final NotesRepository _repository;
  final notes = <Note>[].obs;

  static NotesController get instance => Get.isRegistered<NotesController>()
      ? Get.find<NotesController>()
      : Get.put(NotesController());

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    notes.value = List<Note>.from(_repository.notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void saveNote({String? id, required String title, required String content}) {
    final trimmedTitle = title.trim().isEmpty ? 'Untitled note' : title.trim();
    final trimmedContent = content.trim();
    if (trimmedTitle.isEmpty && trimmedContent.isEmpty) return;

    final now = DateTime.now();
    final existingIndex = id == null
        ? -1
        : notes.indexWhere((note) => note.id == id);

    if (existingIndex == -1) {
      notes.add(
        Note(
          id: now.microsecondsSinceEpoch.toString(),
          title: trimmedTitle,
          content: trimmedContent,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      notes[existingIndex] = notes[existingIndex].copyWith(
        title: trimmedTitle,
        content: trimmedContent,
        updatedAt: now,
      );
      notes.refresh();
    }

    _persist();
  }

  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    _persist();
  }

  void _persist() {
    final sorted = notes.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notes.value = sorted;
    _repository.notes = sorted;
  }
}
