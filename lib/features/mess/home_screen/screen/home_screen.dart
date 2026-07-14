import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard_screen/screen/dashboard_screen.dart';
import '../../expense_screen/screen/expense_screen.dart';
import '../../meal_entry_screen/screen/meal_entry_screen.dart';
import '../controller/home_screen_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    MealEntryScreen(),
    ExpenseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = HomeScreenController.instance;
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentTabIndex.value,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentTabIndex.value,
          onDestinationSelected: controller.setTabIndex,
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
