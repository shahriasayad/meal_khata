// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../../categories_screen/screen/categories_screen.dart';
import '../../meal_history_report/screen/meal_history_report_screen.dart';
import '../../members_screen/screen/members_screen.dart';
import '../../payment_screen/screen/payment_screen.dart';
import '../../settings_screen/screen/settings_screen.dart';
import '../../summary_screen/screen/summary_screen.dart';
import '../../../notes/screen/notes_screen.dart';
import '../controller/dashboard_screen_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardScreenController.instance;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final memberList = controller.members;
      final totalMeals = controller.totalMeals;
      final totalExpenses = controller.totalExpenses;
      final rate = controller.mealRate;
      final totalPaid = controller.totalPaid;

      return Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF1F8E9),
        drawer: _buildDrawer(context, controller),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: controller.openDrawer,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'meal khata',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.monthLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            MonthNavButton(
                              icon: Icons.chevron_left,
                              onTap: controller.prevMonth,
                            ),
                            const SizedBox(width: 4),
                            MonthNavButton(
                              icon: Icons.chevron_right,
                              onTap: controller.nextMonth,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: 160,
                          child: MiniStatCard(
                            label: 'Total Meals',
                            value: totalMeals.toStringAsFixed(1),
                            icon: Icons.restaurant,
                            color: Colors.orange,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: MiniStatCard(
                            label: 'Meal Rate',
                            value: '৳${rate.toStringAsFixed(2)}',
                            icon: Icons.calculate,
                            color: Colors.purple,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: MiniStatCard(
                            label: 'Total Expenses',
                            value: '৳${totalExpenses.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet,
                            color: Colors.red,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: MiniStatCard(
                            label: 'Total Paid',
                            value: '৳${totalPaid.toStringAsFixed(0)}',
                            icon: Icons.check_circle,
                            color: Colors.teal,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: MiniStatCard(
                            label: 'Remaining Balance',
                            value: '৳${(totalPaid - totalExpenses).toStringAsFixed(0)}',
                            icon: Icons.account_balance,
                            color: Colors.blue,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (memberList.isEmpty)
                    const AppEmptyHint(
                      message: 'No members yet.\nGo to Settings to add some.',
                    )
                  else ...[
                    SectionHeader(
                      title: 'Member Breakdown',
                      subtitle: '${memberList.length} members',
                    ),
                    const SizedBox(height: 10),
                    ...memberList.map((member) {
                      final meals = controller.memberMeals(member.id);
                      final gross = controller.memberGrossCost(member.id);
                      final paid = controller.memberPaid(member.id);
                      final balance = controller.memberBalance(member.id);
                      return MemberCostCard(
                        member: member,
                        meals: meals,
                        grossCost: gross,
                        paid: paid,
                        balance: balance,
                        isDark: isDark,
                      );
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            label: 'Payments',
                            icon: Icons.payments_outlined,
                            color: Colors.blue,
                            isDark: isDark,
                            onTap: () {
                              Get.to(() => const PaymentScreen());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionButton(
                            label: 'Summary',
                            icon: Icons.summarize_outlined,
                            color: Colors.green,
                            isDark: isDark,
                            onTap: () {
                              Get.to(() => const SummaryScreen());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrawer(
    BuildContext context,
    DashboardScreenController controller,
  ) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'meal khata',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your shared expenses',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DrawerItemTile(
            icon: Icons.person_add_outlined,
            title: 'Members',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const MembersScreen());
            },
          ),
          DrawerItemTile(
            icon: Icons.label_outline,
            title: 'Categories',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const CategoriesScreen());
            },
          ),
          DrawerItemTile(
            icon: Icons.note_outlined,
            title: 'Notes',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const NotesScreen());
            },
          ),
          DrawerItemTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SettingsScreen());
            },
          ),
          DrawerItemTile(
            icon: Icons.table_view_outlined,
            title: 'Meal History',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const MealHistoryReportScreen());
            },
          ),
        ],
      ),
    );
  }
}
