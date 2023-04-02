import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/apis/user_api.dart';
import 'package:twitter_clone_app/models/user_model.dart';

final exploreControllerProvider = StateNotifierProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return ExploreController(userAPI: userAPI);
});

final searchUserProvider = FutureProvider.family((ref, String name) {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((user) => UserModel.fromMap(user.data)).toList();
  }
}
