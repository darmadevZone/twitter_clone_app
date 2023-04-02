import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/apis/storage_api.dart';
import 'package:twitter_clone_app/apis/tweet_api.dart';
import 'package:twitter_clone_app/apis/user_api.dart';
import 'package:twitter_clone_app/core/enums/notification_type_enum.dart';
import 'package:twitter_clone_app/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone_app/models/tweet_model.dart';
import 'package:twitter_clone_app/models/user_model.dart';

import '../../../core/core.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  final storageAPI = ref.watch(storageAPIProvider);
  final userAPI = ref.watch(userAPIProvider);
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return UserProfileController(
    tweetAPI: tweetAPI,
    storageAPI: storageAPI,
    userAPI: userAPI,
    notificationController: notificationController,
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweet(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;
  UserProfileController({
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
    required NotificationController notificationController,
  })  : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<TweetModel>> getUserTweet(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      userModel = userModel.copyWith(
        bannerPic: bannerUrl[0],
      );
    }

    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImage([profileFile]);
      userModel = userModel.copyWith(
        profilePic: profileUrl[0],
      );
    }

    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    //現在のユーザが存在していたらuser,currentUserのFollowing Listから削除する

    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }
    final newUser = user.copyWith(followers: user.followers);
    final newCurrentUser =
        currentUser.copyWith(following: currentUser.following);

    final res = await _userAPI.followUser(newUser);

    res.fold((l) => showSnackBar(context, l.message), (r) async {
      final res2 = await _userAPI.addToFollowing(newCurrentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) async {
        print(newCurrentUser.following);
        print(newUser.following);
        _notificationController.createNotification(
          text: '${currentUser.name} followed you!',
          postId: '',
          notificationType: NotificationType.follow,
          uid: user.uid,
        );
      });
    });
  }
}
