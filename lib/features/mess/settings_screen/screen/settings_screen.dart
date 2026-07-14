import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScreenController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                'Wipe All Data',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () => _showWipeConfirm(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  void _showWipeConfirm(
    BuildContext context,
    SettingsScreenController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Wipe All Data?'),
        content: const Text(
          'This will permanently delete all members, meals, expenses, and payments. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.wipeAllData();
              Get.snackbar(
                'Success',
                'All data has been wiped.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Wipe'),
          ),
        ],
      ),
    );
  }
}
