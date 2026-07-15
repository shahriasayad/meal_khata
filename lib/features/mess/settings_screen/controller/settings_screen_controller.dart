import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/local/hive/hive_backup_service.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';
import '../../../notes/controller/notes_controller.dart';
import '../../../notes/screen/notes_screen.dart';

class SettingsScreenController extends GetxController {
  SettingsScreenController()
    : _viewModel = Get.find<MessViewModel>(),
      _backupService = HiveBackupService.instance;

  final MessViewModel _viewModel;
  final HiveBackupService _backupService;

  final isBusy = false.obs;

  static SettingsScreenController get instance =>
      Get.isRegistered<SettingsScreenController>()
      ? Get.find<SettingsScreenController>()
      : Get.put(SettingsScreenController());

  void openNotes() {
    Get.to(() => const NotesScreen());
  }

  Future<void> exportBackup() async {
    await _runBusyAction(() async {
      final fileName =
          'meal_khata_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final bytes = Uint8List.fromList(
        utf8.encode(_backupService.encodeBackup()),
      );
      final filePath = await FilePicker.saveFile(
        dialogTitle: 'Save backup file',
        fileName: fileName,
        allowedExtensions: const ['json'],
        type: FileType.custom,
        bytes: bytes,
      );

      if (filePath == null) {
        return;
      }

      Get.snackbar(
        'Backup Saved',
        'Backup exported to $filePath',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Future<void> shareBackup() async {
    await _runBusyAction(() async {
      final file = await _backupService.createTempBackupFile();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Meal Khata backup',
        ),
      );
    });
  }

  Future<void> restoreBackup() async {
    await _runBusyAction(() async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        allowMultiple: false,
      );

      final path = result?.files.single.path;
      if (path == null) {
        return;
      }

      final file = File(path);
      final backup = _backupService.decodeBackup(await file.readAsString());
      if (!_backupService.isValidBackup(backup)) {
        Get.snackbar(
          'Invalid Backup',
          'The selected file is not a valid Meal Khata backup.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
        );
        return;
      }

      _backupService.restoreBackup(backup);
      _viewModel.reload();
      NotesController.reloadIfRegistered();
      Get.snackbar(
        'Restore Complete',
        'Backup restored successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  void wipeAllData() {
    _viewModel.wipeAllData();
    NotesController.reloadIfRegistered();
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      await action();
    } catch (_) {
      Get.snackbar(
        'Action failed',
        'Please try again with a valid file.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBusy.value = false;
    }
  }
}
