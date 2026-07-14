import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view_models/mess_view_model.dart';
import 'dashboard_screen.dart';
import 'expense_screen.dart';
import 'meal_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    MealEntryScreen(),
    ExpenseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentTabIndex.value,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentTabIndex.value,
          onDestinationSelected: (int index) =>
              controller.currentTabIndex.value = index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant),
              label: 'Meals',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
          ],
        ),
      ),
    );
  }
}
