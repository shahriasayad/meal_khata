import 'package:get/get.dart';

import '../../../../features/mess/view_models/mess_view_model.dart';

class CategoriesScreenController extends GetxController {
  CategoriesScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static CategoriesScreenController get instance =>
      Get.isRegistered<CategoriesScreenController>()
      ? Get.find<CategoriesScreenController>()
      : Get.put(CategoriesScreenController());

  List<String> get categories => _viewModel.categories.toList();

  void addCategory(String name) => _viewModel.addCategory(name);
  void deleteCategory(int index) => _viewModel.deleteCategory(index);
}
