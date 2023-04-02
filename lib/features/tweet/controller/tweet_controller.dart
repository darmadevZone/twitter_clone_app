import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/apis/storage_api.dart';
import 'package:twitter_clone_app/apis/tweet_api.dart';
import 'package:twitter_clone_app/core/core.dart';
import 'package:twitter_clone_app/core/enums/notification_type_enum.dart';
import 'package:twitter_clone_app/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone_app/models/tweet_model.dart';
import 'package:twitter_clone_app/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});
final getTweetByIdProvider = FutureProvider.family((ref, String id) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

final getRepliesToTweetsProvider =
    FutureProvider.family((ref, TweetModel tweet) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getRepliesToTweet(tweet);
});

final getTweetsByHashtagProvider = FutureProvider.family((ref, String hashtag) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetsByHashtag(hashtag);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<TweetModel>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, "Please enter text");
      return;
    }
    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    //hashtag and links get from text
    final hashtags = _getHashtagsFromText(text);
    final String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImage(images);
    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId,
          );
        }
      },
    );
    state = false;
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    //hashtag and links get from text
    final hashtags = _getHashtagsFromText(text);
    final String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId,
          );
        }
      },
    );
    state = false;
  }

  String _getLinkFromText(String text) {
    String link = "";
    List<String> wordsInSentence = text.split(" ");
    for (String word in wordsInSentence) {
      if (word.startsWith("https://") || word.startsWith("www.")) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentence = text.split(" ");
    for (String word in wordsInSentence) {
      if (word.startsWith("#")) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }

  Future<List<TweetModel>> getRepliesToTweet(TweetModel tweet) async {
    final documents = await _tweetAPI.getRepliesToTweet(tweet);
    //Map<String,dynamic> -> [tweetModel,...]
    return documents.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  Future<List<TweetModel>> getTweetsByHashtag(String hashtag) async {
    final documents = await _tweetAPI.getTweetsByHashtag(hashtag);
    //Map<String,dynamic> -> [tweetModel,...]
    return documents.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  void likeTweet(
    TweetModel tweet,
    UserModel user,
  ) async {
    List<String> likes = tweet.likes;
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }

    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold(
      (l) {
        print(l.message);
      },
      (r) {
        _notificationController.createNotification(
          text: '${user.name} liked your tweet!',
          postId: tweet.id,
          notificationType: NotificationType.like,
          uid: tweet.id,
        );
      },
    );
  }

  void reshareTweet(
    TweetModel tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    //現物のtweetを＋1しようとしている。+ retweetedBy user_name
    tweet = tweet.copyWith(
      reshareCount: tweet.reshareCount + 1,
      retweetedBy: currentUser.name,
      commentIds: [],
      likes: [],
    );
    //update resharecount + 1
    final res = await _tweetAPI.updateReshareCount(tweet);
    res.fold(
      (l) {
        return showSnackBar(context, l.message);
      },
      (r) async {
        tweet = tweet.copyWith(
          id: ID.unique(),
          reshareCount: 0,
          tweetedAt: DateTime.now(),
        );
        final res2 = await _tweetAPI.shareTweet(tweet);
        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            return showSnackBar(
              context,
              "Retweeted!!!!",
            );
          },
        );
      },
    );
  }

  Future<TweetModel> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return TweetModel.fromMap(tweet.data);
  }
}
