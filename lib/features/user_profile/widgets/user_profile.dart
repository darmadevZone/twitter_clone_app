import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone_app/common/error_page.dart';
import 'package:twitter_clone_app/common/loading_page.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone_app/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone_app/features/user_profile/widgets/follow_count.dart';
import 'package:twitter_clone_app/models/user_model.dart';
import 'package:twitter_clone_app/theme/theme.dart';

import '../../../constants/constants.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  expandedHeight: 150,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(color: Pallete.blueColor)
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(15).copyWith(bottom: 10),
                        child: OutlinedButton(
                            onPressed: () {
                              if (currentUser.uid == user.uid) {
                                Navigator.push(
                                    context, EditProfileView.route());
                              } else {
                                ref
                                    .read(
                                        userProfileControllerProvider.notifier)
                                    .followUser(
                                      user: user,
                                      context: context,
                                      currentUser: currentUser,
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Pallete.whiteColor,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text(
                              currentUser.uid == user.uid
                                  ? 'Edit Profile'
                                  : currentUser.following.contains(user.uid)
                                      ? 'Unfollow'
                                      : 'follow',
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                                fontSize: 14,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8).copyWith(bottom: 3),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (user.isTwitterBlue)
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: SvgPicture.asset(
                                  AssetsConstants.verifiedIcon,
                                  fit: BoxFit.contain),
                            ),
                        ],
                      ),
                      Text(
                        '@${user.name}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Pallete.greyColor,
                        ),
                      ),
                      Text(
                        user.bio,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FollowCount(
                            count: user.following.length,
                            text: 'Following',
                          ),
                          const SizedBox(width: 10),
                          FollowCount(
                            count: user.followers.length,
                            text: 'Followers',
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Divider(
                        color: Pallete.whiteColor,
                      ),
                    ],
                  )),
                )
              ];
            },
            body: ref
                .watch(
              getUserTweetsProvider(user.uid),
            )
                .when(data: (tweets) {
              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (BuildContext context, int index) {
                  final tweet = tweets[index];
                  return TweetCard(tweet: tweet);
                },
              );
            }, error: (e, st) {
              return ErrorText(error: e.toString());
            }, loading: () {
              return const Loader();
            }),
          );
  }
}
