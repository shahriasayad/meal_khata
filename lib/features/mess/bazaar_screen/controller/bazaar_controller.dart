import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../view_models/mess_view_model.dart';

class BazaarController extends GetxController with GetSingleTickerProviderStateMixin {
  static BazaarController get instance => Get.isRegistered<BazaarController>()
      ? Get.find<BazaarController>()
      : Get.put(BazaarController());

  final MessViewModel _viewModel = Get.find<MessViewModel>();

  late TabController tabController;

  // Schedule Generation Inputs
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final selectedMembersForRotation = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // --- Shopping List ---
  List<ShoppingItem> get shoppingList => _viewModel.shoppingList;

  void addShoppingItem(String name, String quantity) {
    if (name.trim().isEmpty) return;
    _viewModel.addShoppingItem(name, quantity);
  }

  void toggleShoppingItem(String id) {
    _viewModel.toggleShoppingItem(id);
  }

  void deleteShoppingItem(String id) {
    _viewModel.deleteShoppingItem(id);
  }

  // --- Bazaar Schedule ---
  List<BazaarScheduleEntry> get bazaarSchedule => _viewModel.bazaarSchedule;
  List<Member> get members => _viewModel.members;

  String getMemberName(String id) {
    return members.firstWhereOrNull((m) => m.id == id)?.name ?? 'Unknown';
  }

  void generateSchedule() {
    if (selectedStartDate.value == null || selectedEndDate.value == null || selectedMembersForRotation.isEmpty) {
      Get.snackbar('Error', 'Please select dates and at least one member.');
      return;
    }
    
    _viewModel.generateBazaarSchedule(
      selectedStartDate.value!,
      selectedEndDate.value!,
      selectedMembersForRotation,
    );
    
    Get.back(); // close bottom sheet
    Get.snackbar('Success', 'Bazaar schedule generated successfully.');
  }

  void updateScheduleDate(String dateStr, String memberId) {
    _viewModel.updateScheduleDate(dateStr, memberId);
  }

  void toggleMemberForRotation(String memberId) {
    if (selectedMembersForRotation.contains(memberId)) {
      selectedMembersForRotation.remove(memberId);
    } else {
      selectedMembersForRotation.add(memberId);
    }
  }

  Future<void> exportPdf({required bool share}) async {
    await _viewModel.exportBazaarPdf(share: share);
  }
}
