import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  HomeScreenController();

  static HomeScreenController get instance =>
      Get.isRegistered<HomeScreenController>()
      ? Get.find<HomeScreenController>()
      : Get.put(HomeScreenController());

  final currentTabIndex = 0.obs;

  void setTabIndex(int index) {
    currentTabIndex.value = index;
  }
}
