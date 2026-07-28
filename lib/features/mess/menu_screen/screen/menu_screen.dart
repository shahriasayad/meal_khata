import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../members_screen/screen/members_screen.dart';
import '../../categories_screen/screen/categories_screen.dart';
import '../../../notes/screen/notes_screen.dart';
import '../../settings_screen/screen/settings_screen.dart';
import '../../meal_history_report/screen/meal_history_report_screen.dart';
import '../../contribution_history/screen/contribution_history_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & More'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _MenuGridItem(
            title: 'Members',
            icon: Icons.people_outline,
            color: Colors.blue,
            isDark: isDark,
            onTap: () => Get.to(() => const MembersScreen()),
          ),
          _MenuGridItem(
            title: 'Categories',
            icon: Icons.label_outline,
            color: Colors.orange,
            isDark: isDark,
            onTap: () => Get.to(() => const CategoriesScreen()),
          ),
          _MenuGridItem(
            title: 'Meal History',
            icon: Icons.table_view_outlined,
            color: Colors.teal,
            isDark: isDark,
            onTap: () => Get.to(() => const MealHistoryReportScreen()),
          ),
          _MenuGridItem(
            title: 'Contributions',
            icon: Icons.history_outlined,
            color: Colors.purple,
            isDark: isDark,
            onTap: () => Get.to(() => const ContributionHistoryScreen()),
          ),
          _MenuGridItem(
            title: 'Notes',
            icon: Icons.note_outlined,
            color: Colors.amber,
            isDark: isDark,
            onTap: () => Get.to(() => const NotesScreen()),
          ),
          _MenuGridItem(
            title: 'Settings',
            icon: Icons.settings_outlined,
            color: Colors.grey,
            isDark: isDark,
            onTap: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuGridItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
