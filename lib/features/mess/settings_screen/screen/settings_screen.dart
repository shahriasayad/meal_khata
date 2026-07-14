import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/mess_widgets.dart';
import '../controller/settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScreenController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        final busy = controller.isBusy.value;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionCard(
              title: 'Backup & Restore',
              subtitle: 'Keep an offline copy of every saved record.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: busy ? null : controller.exportBackup,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save Backup'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: busy ? null : controller.shareBackup,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share Backup'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: busy ? null : controller.restoreBackup,
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Restore Backup'),
                  ),
                  if (busy) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Notes',
              subtitle: 'Use it for reminders, shopping lists, or quick ideas.',
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: controller.openNotes,
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Open Notes'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'About App',
              subtitle: 'App details are shown here in a subtle, readable way.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _AboutLine(
                    label: 'Developed by',
                    value: 'Shahria Sayad Oishorjo',
                  ),
                  SizedBox(height: 10),
                  _AboutLine(label: 'Version', value: '2.0'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Danger Zone',
              subtitle: 'Reset everything stored on this device.',
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showWipeConfirm(context, controller),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Wipe All Data'),
              ),
            ),
          ],
        );
      }),
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
          'This will permanently delete all members, meals, expenses, payments, categories, and notes. This action cannot be undone.',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AboutLine extends StatelessWidget {
  final String label;
  final String value;

  const _AboutLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
