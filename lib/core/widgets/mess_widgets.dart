// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../data/models/mess_models.dart';

class AppEmptyHint extends StatelessWidget {
  final String message;

  const AppEmptyHint({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const Spacer(),
      if (subtitle != null)
        Text(
          subtitle!,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
    ],
  );
}

class DrawerItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DrawerItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = const Color(0xFF1B5E20),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }
}

class MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MonthNavButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class MemberCostCard extends StatelessWidget {
  final Member member;
  final double meals;
  final double grossCost;
  final double paid;
  final double balance;
  final bool isDark;

  const MemberCostCard({
    super.key,
    required this.member,
    required this.meals,
    required this.grossCost,
    required this.paid,
    required this.balance,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDue = balance > 0.01;
    final bool isCredit = balance < -0.01;

    late final Color statusColor;
    late final String statusLabel;
    if (isDue) {
      statusColor = Colors.red;
      statusLabel = 'Due ৳${balance.toStringAsFixed(2)}';
    } else if (isCredit) {
      statusColor = Colors.teal;
      statusLabel = 'Adv ৳${balance.abs().toStringAsFixed(2)}';
    } else {
      statusColor = Colors.green;
      statusLabel = 'Settled';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1B5E20),
            radius: 22,
            child: Text(
              (member.name.isNotEmpty ? member.name[0] : '?').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meals.toStringAsFixed(1)} meals  •  Cost ৳${grossCost.toStringAsFixed(2)}  •  Paid ৳${paid.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const PayStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class MemberPaymentTile extends StatelessWidget {
  final Member member;
  final double grossCost;
  final double paid;
  final double balance;
  final List<Payment> payments;
  final void Function(String) onDelete;

  const MemberPaymentTile({
    super.key,
    required this.member,
    required this.grossCost,
    required this.paid,
    required this.balance,
    required this.payments,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDue = balance > 0.01;
    final Color statusColor = isDue ? Colors.orange : Colors.green;
    final String statusText = isDue
        ? 'Due ৳${balance.toStringAsFixed(2)}'
        : balance < -0.01
        ? 'Adv ৳${balance.abs().toStringAsFixed(2)}'
        : 'Settled';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B5E20),
          child: Text(
            (member.name.isNotEmpty ? member.name[0] : '?').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Gross ৳${grossCost.toStringAsFixed(2)}  •  Paid ৳${paid.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No payments recorded.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...payments.map(
              (payment) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(
                  Icons.payments_outlined,
                  color: Colors.teal,
                  size: 18,
                ),
                title: Text(
                  '৳${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: payment.note.isNotEmpty ? Text(payment.note) : null,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => onDelete(payment.id),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SumRow extends StatelessWidget {
  final String label;
  final String value;

  const SumRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ],
  );
}

class SummaryMemberCard extends StatelessWidget {
  final Member member;
  final double meals;
  final double grossCost;
  final double paid;
  final double balance;

  const SummaryMemberCard({
    super.key,
    required this.member,
    required this.meals,
    required this.grossCost,
    required this.paid,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDue = balance > 0.01;
    final bool isAdv = balance < -0.01;
    final Color balanceColor = isAdv
        ? Colors.teal
        : (isDue ? Colors.red : Colors.green);
    final String balanceLabel = isAdv
        ? 'Advance: ৳${balance.abs().toStringAsFixed(2)}'
        : isDue
        ? 'Due: ৳${balance.toStringAsFixed(2)}'
        : 'Settled ✓';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1B5E20),
                  radius: 18,
                  child: Text(
                    (member.name.isNotEmpty ? member.name[0] : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  balanceLabel,
                  style: TextStyle(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SmallStat(label: 'Meals', value: meals.toStringAsFixed(2)),
                SmallStat(
                  label: 'Meal Cost',
                  value: '৳${grossCost.toStringAsFixed(2)}',
                ),
                SmallStat(label: 'Paid', value: '৳${paid.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SmallStat extends StatelessWidget {
  final String label;
  final String value;

  const SmallStat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    ),
  );
}
