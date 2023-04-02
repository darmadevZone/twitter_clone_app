import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/common/loading_page.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone_app/features/user_profile/view/user_profile_view.dart';

import '../../../theme/theme.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    if (currentUser == null) {
      return const Loader();
    }

    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.person, size: 20),
              title: const Text(
                'My Profile',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.push(context, UserProfileView.route(currentUser));
              },
            ),
            const Divider(
              color: Pallete.greyColor,
              height: 0,
            ),
            ListTile(
              leading: const Icon(
                Icons.payment,
                size: 20,
              ),
              title: const Text(
                'Twitter Blue',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                ref
                    .read(userProfileControllerProvider.notifier)
                    .updateUserProfile(
                      userModel: currentUser.copyWith(isTwitterBlue: true),
                      context: context,
                      bannerFile: null,
                      profileFile: null,
                    );
              },
            ),
            const Divider(
              color: Pallete.greyColor,
              height: 0,
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                size: 20,
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                ref.read(authControllerProvider.notifier).logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
