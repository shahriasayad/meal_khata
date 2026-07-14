import 'package:get/get.dart';

import '../../../../features/mess/view_models/mess_view_model.dart';

class SettingsScreenController extends GetxController {
  SettingsScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static SettingsScreenController get instance =>
      Get.isRegistered<SettingsScreenController>()
      ? Get.find<SettingsScreenController>()
      : Get.put(SettingsScreenController());

  void wipeAllData() => _viewModel.wipeAllData();
}
