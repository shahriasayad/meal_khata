import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../../../data/models/mess_models.dart';
import '../view_models/mess_view_model.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();

    return Obx(() {
      final List<Member> memberList = controller.members.toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Members')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context, controller),
          child: const Icon(Icons.add),
        ),
        body: memberList.isEmpty
            ? const AppEmptyHint(message: 'No members yet.\nTap + to add.')
            : ReorderableListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: memberList.length,
                itemBuilder: (_, int index) {
                  final Member member = memberList[index];
                  return Card(
                    key: ValueKey(member.id),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          (member.name.isNotEmpty ? member.name[0] : '?')
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(member.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                _showEditDialog(context, controller, member),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _showDeleteConfirm(context, controller, member),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onReorder: controller.reorderMembers,
              ),
      );
    });
  }

  Future<void> _showAddDialog(
    BuildContext context,
    MessViewModel controller,
  ) async {
    final TextEditingController textController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                controller.addMember(textController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    textController.dispose();
  }

  Future<void> _showEditDialog(
    BuildContext context,
    MessViewModel controller,
    Member member,
  ) async {
    final TextEditingController textController = TextEditingController(
      text: member.name,
    );
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Member'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                controller.updateMember(member.id, textController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    textController.dispose();
  }

  void _showDeleteConfirm(
    BuildContext context,
    MessViewModel controller,
    Member member,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member?'),
        content: Text(
          'Remove "${member.name}"? All meal and payment records for this member will also be removed.',
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
              controller.deleteMember(member.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
