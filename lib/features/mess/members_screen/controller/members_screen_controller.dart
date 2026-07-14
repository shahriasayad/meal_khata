import 'package:get/get.dart';

import '../../../../data/models/mess_models.dart';
import '../../../../features/mess/view_models/mess_view_model.dart';

class MembersScreenController extends GetxController {
  MembersScreenController() : _viewModel = Get.find<MessViewModel>();

  final MessViewModel _viewModel;

  static MembersScreenController get instance =>
      Get.isRegistered<MembersScreenController>()
      ? Get.find<MembersScreenController>()
      : Get.put(MembersScreenController());

  List<Member> get members => _viewModel.members.toList();

  void addMember(String name) => _viewModel.addMember(name);
  void updateMember(String id, String name) =>
      _viewModel.updateMember(id, name);
  void deleteMember(String id) => _viewModel.deleteMember(id);
  void reorderMembers(int oldIndex, int newIndex) =>
      _viewModel.reorderMembers(oldIndex, newIndex);
}
