import 'dart:convert';
import 'dart:io';

import 'package:meal_khata/data/repositories/mess_repository.dart';


class HiveBackupService {
  HiveBackupService._() : _repository = MessRepository();

  static final HiveBackupService instance = HiveBackupService._();

  static const String _format = 'meal_khata_backup';
  static const int _version = 1;

  final MessRepository _repository;

  Map<String, dynamic> createBackupMap() => {
    'format': _format,
    'version': _version,
    'createdAt': DateTime.now().toIso8601String(),
    'data': _repository.exportAll(),
  };

  String encodeBackup() => jsonEncode(createBackupMap());

  Map<String, dynamic> decodeBackup(String rawContent) {
    final dynamic decoded = jsonDecode(rawContent);
    if (decoded is! Map) {
      throw const FormatException('Invalid backup file');
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  bool isValidBackup(Map<String, dynamic> backup) {
    if (backup['format'] != _format || backup['version'] != _version) {
      return false;
    }

    final data = backup['data'];
    if (data is! Map) {
      return false;
    }

    final requiredKeys = <String>[
      'members',
      'mealEntries',
      'expenses',
      'payments',
      'categories',
      'notes',
    ];

    for (final key in requiredKeys) {
      if (data[key] is! List) {
        return false;
      }
    }

    return true;
  }

  void restoreBackup(Map<String, dynamic> backup) {
    if (!isValidBackup(backup)) {
      throw const FormatException('Invalid backup file');
    }

    final data = Map<String, dynamic>.from(backup['data'] as Map);
    _repository.importAll(data);
  }

  Future<File> writeBackupToFile(String filePath) async {
    final resolvedPath = filePath.endsWith('.json')
        ? filePath
        : '$filePath.json';
    final file = File(resolvedPath);
    await file.writeAsString(encodeBackup());
    return file;
  }

  Future<File> createTempBackupFile() async {
    final directory = await Directory.systemTemp.createTemp(
      'meal_khata_backup',
    );
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/meal_khata_backup_$stamp.json');
    await file.writeAsString(encodeBackup());
    return file;
  }

  Future<void> restoreFromJsonFile(File file) async {
    final content = await file.readAsString();
    final backup = decodeBackup(content);
    restoreBackup(backup);
  }
}
