// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../../../data/models/mess_models.dart';
import '../view_models/mess_view_model.dart';
import 'categories_screen.dart';
import 'members_screen.dart';
import 'payment_screen.dart';
import 'summary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final MessViewModel controller = Get.find<MessViewModel>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final double totalMeals = controller.totalMeals;
      final double totalExpenses = controller.totalExpenses;
      final double rate = controller.mealRate;
      final double totalPaid = controller.totalPaid;
      final List<Member> memberList = controller.members.toList();

      return Scaffold(
        key: _scaffoldKey,
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
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      MiniStatCard(
                        label: 'Total Meals',
                        value: totalMeals.toStringAsFixed(1),
                        icon: Icons.restaurant,
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      MiniStatCard(
                        label: 'Meal Rate',
                        value: '৳${rate.toStringAsFixed(2)}',
                        icon: Icons.calculate,
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                      MiniStatCard(
                        label: 'Total Expenses',
                        value: '৳${totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.red,
                        isDark: isDark,
                      ),
                      MiniStatCard(
                        label: 'Total Paid',
                        value: '৳${totalPaid.toStringAsFixed(0)}',
                        icon: Icons.check_circle,
                        color: Colors.teal,
                        isDark: isDark,
                      ),
                    ],
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
                    ...memberList.map((dynamic member) {
                      final double meals = controller.memberMeals(member.id);
                      final double gross = controller.memberGrossCost(
                        member.id,
                      );
                      final double paid = controller.memberPaid(member.id);
                      final double balance = controller.memberBalance(
                        member.id,
                      );
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

  Widget _buildDrawer(BuildContext context, MessViewModel controller) {
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
          const Divider(height: 24, indent: 16, endIndent: 16),
          DrawerItemTile(
            icon: Icons.delete_forever_outlined,
            title: 'Wipe All Data',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _showWipeConfirm(context, controller);
            },
          ),
        ],
      ),
    );
  }

  void _showWipeConfirm(BuildContext context, MessViewModel controller) {
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
