import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/mess_widgets.dart';
import '../../../../data/models/mess_models.dart';
import '../models/meal_history_report_data.dart';

class MealHistoryMonthBanner extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MealHistoryMonthBanner({
    super.key,
    required this.monthLabel,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_view_outlined, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal History Report',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          MonthNavButton(icon: Icons.chevron_left, onTap: onPreviousMonth),
          const SizedBox(width: 8),
          MonthNavButton(icon: Icons.chevron_right, onTap: onNextMonth),
        ],
      ),
    );
  }
}

class MealHistorySpreadsheet extends StatelessWidget {
  final MealHistoryReportData reportData;

  const MealHistorySpreadsheet({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final double memberCellWidth = reportData.members.length > 4 ? 92 : 104;
    final double sheetWidth =
        122 + (reportData.members.length * memberCellWidth) + 110 + 110 + 112;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: sheetWidth,
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                  child: _SheetHeaderRow(
                    members: reportData.members,
                    memberCellWidth: memberCellWidth,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final row = reportData.rows[index];
                    return _SheetDataRow(
                      row: row,
                      members: reportData.members,
                      memberCellWidth: memberCellWidth,
                    );
                  }, childCount: reportData.rows.length),
                ),
                SliverToBoxAdapter(
                  child: MealHistorySummaryCard(summary: reportData.summary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MealHistorySummaryCard extends StatelessWidget {
  final MealHistoryReportSummary summary;

  const MealHistorySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Monthly Summary'),
          const SizedBox(height: 12),
          _SummaryLine(
            label: 'Total meals',
            value: summary.totalMeals.toStringAsFixed(2),
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Total meal cost',
            value: '৳${summary.totalMealCost.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Average meal rate',
            value: '৳${summary.averageMealRate.toStringAsFixed(4)}',
          ),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Total active days',
            value: summary.totalActiveDays.toString(),
          ),
        ],
      ),
    );
  }
}

class _SheetHeaderRow extends StatelessWidget {
  final List<Member> members;
  final double memberCellWidth;

  const _SheetHeaderRow({required this.members, required this.memberCellWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: 'Date', width: 122),
          ...members.map(
            (member) => _HeaderCell(label: member.name, width: memberCellWidth),
          ),
          const _HeaderCell(label: 'Daily Total', width: 110),
          const _HeaderCell(label: 'Meal Rate', width: 110),
          const _HeaderCell(label: 'Meal Cost', width: 112),
        ],
      ),
    );
  }
}

class _SheetDataRow extends StatelessWidget {
  final MealHistoryReportRow row;
  final List<Member> members;
  final double memberCellWidth;

  const _SheetDataRow({
    required this.row,
    required this.members,
    required this.memberCellWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isAlternate = row.date.hashCode.isEven;

    return Container(
      color: isAlternate
          ? Theme.of(context).colorScheme.surface
          : Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
      child: Row(
        children: [
          _BodyCell(label: row.date, width: 122, isStrong: true),
          ...members.map(
            (member) => _BodyCell(
              label: row.mealsByMember[member.id]?.toStringAsFixed(2) ?? '0.00',
              width: memberCellWidth,
            ),
          ),
          _BodyCell(label: row.dailyTotal.toStringAsFixed(2), width: 110),
          _BodyCell(label: row.mealRate.toStringAsFixed(4), width: 110),
          _BodyCell(
            label: row.mealCost.toStringAsFixed(2),
            width: 112,
            isStrong: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _HeaderCell({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String label;
  final double width;
  final bool isStrong;

  const _BodyCell({
    required this.label,
    required this.width,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isStrong ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
