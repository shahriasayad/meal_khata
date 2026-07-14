import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/mess_widgets.dart';
import '../../../data/models/mess_models.dart';
import '../view_models/mess_view_model.dart';

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final MessViewModel _controller = Get.find<MessViewModel>();
  DateTime _date = DateTime.now();
  final Map<String, TextEditingController> _textControllers = {};

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  TextEditingController _getOrCreateController(String memberId) {
    if (!_textControllers.containsKey(memberId)) {
      final double value = _controller.getMeal(memberId, _dateStr);
      _textControllers[memberId] = TextEditingController(
        text: value > 0
            ? (value == value.truncateToDouble()
                  ? value.toInt().toString()
                  : value.toString())
            : '',
      );
    }
    return _textControllers[memberId]!;
  }

  String _fmt(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  double _val(String memberId) =>
      double.tryParse(_textControllers[memberId]?.text.trim() ?? '') ?? 0.0;

  void _increment(String memberId, double step) {
    final double current = _val(memberId);
    final double next = current + step;
    _textControllers[memberId]!.text = _fmt(next);
    setState(() {});
  }

  void _decrement(String memberId, double step) {
    final double current = _val(memberId);
    final double next = current - step;
    if (next < 0) return;
    _textControllers[memberId]!.text = _fmt(next);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _date = picked;
      for (final member in _controller.members) {
        if (_textControllers.containsKey(member.id)) {
          final double value = _controller.getMeal(member.id, _dateStr);
          _textControllers[member.id]!.text = value > 0 ? _fmt(value) : '';
        }
      }
      setState(() {});
    }
  }

  void _copyPrevDay() {
    final DateTime previousDay = _date.subtract(const Duration(days: 1));
    final String previousDayStr = DateFormat('yyyy-MM-dd').format(previousDay);
    final List<MealEntry> found = _controller.mealEntries
        .where((entry) => entry.date == previousDayStr)
        .toList();
    if (found.isEmpty) {
      _snack('No data for previous day.');
      return;
    }
    for (final MealEntry entry in found) {
      if (_textControllers.containsKey(entry.memberId)) {
        _textControllers[entry.memberId]!.text = _fmt(entry.meals);
      }
    }
    setState(() {});
  }

  void _save() {
    final map = <String, double>{};
    for (final member in _controller.members) {
      map[member.id] = _val(member.id);
    }
    _controller.saveDayMeals(_dateStr, map);
    _snack('Meals saved for ${DateFormat('dd MMM yyyy').format(_date)}');
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy Previous Day',
            onPressed: _copyPrevDay,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Obx(() {
        final memberList = _controller.members.toList();
        return memberList.isEmpty
            ? const AppEmptyHint(
                message: 'No members yet.\nAdd members in Settings.',
              )
            : Column(
                children: [
                  Material(
                    color: AppColors.primary.withOpacity(0.08),
                    child: InkWell(
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(_date),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: memberList.length,
                      itemBuilder: (_, int index) {
                        final member = memberList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 20,
                                  child: Text(
                                    (member.name.isNotEmpty
                                            ? member.name[0]
                                            : '?')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _decrement(member.id, 1),
                                  visualDensity: VisualDensity.compact,
                                ),
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: _getOrCreateController(
                                      member.id,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _increment(member.id, 1),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Meals',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: _save,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }
}
