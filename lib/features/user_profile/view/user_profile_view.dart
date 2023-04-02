import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/common/error_page.dart';
import 'package:twitter_clone_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone_app/features/user_profile/widgets/user_profile.dart';
import 'package:twitter_clone_app/models/user_model.dart';

import '../../../constants/constants.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(builder: (context) {
        return UserProfileView(
          userModel: userModel,
        );
      });
  final UserModel userModel;
  const UserProfileView({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;

    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
          data: (user) {
            if (user.events.contains(
              'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${copyOfUser.uid}.update',
            )) {
              copyOfUser = UserModel.fromMap(user.payload);
            }
            return UserProfile(user: copyOfUser);
          },
          error: (e, st) {
            return ErrorText(error: e.toString());
          },
          loading: () => UserProfile(user: copyOfUser)),
    );
  }
}
