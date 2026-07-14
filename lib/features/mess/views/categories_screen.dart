import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../view_models/mess_view_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();

    return Obx(
      () => Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context, controller),
          child: const Icon(Icons.add),
        ),
        body: controller.categories.isEmpty
            ? const AppEmptyHint(message: 'No categories yet.')
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: controller.categories.length,
                itemBuilder: (_, int index) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: const Icon(
                      Icons.label_outline,
                      color: AppColors.accent,
                    ),
                    title: Text(controller.categories[index]),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => controller.deleteCategory(index),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    MessViewModel controller,
  ) async {
    final TextEditingController textController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Category Name'),
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
                controller.addCategory(textController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    textController.dispose();
  }
}
