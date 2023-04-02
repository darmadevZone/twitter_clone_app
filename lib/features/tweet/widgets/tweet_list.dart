import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/common/error_page.dart';
import 'package:twitter_clone_app/common/loading_page.dart';
import 'package:twitter_clone_app/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone_app/models/tweet_model.dart';

import '../../../constants/appwrite_constants.dart';
import 'tweet_card.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create',
                    )) {
                      tweets.insert(0, TweetModel.fromMap(data.payload));
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update',
                    )) {
                      final startingPoint =
                          data.events[0].lastIndexOf('documents.');
                      final endPoint = data.events[0].lastIndexOf('.update');
                      //get tweet_ID
                      final tweetId = data.events[0]
                          .substring(startingPoint + 10, endPoint);

                      /**
                       * Trigar: documents chagened like, retweet with appwrite changed likeCount and retweetBy
                       * get latest tweet -> data.payload changes TweetModel
                       * -> latest tweet_id -> get element_id == tweet_id from tweets
                       * -> GET index of tweet changed -> removewhere tweets_List
                       * -> tweet insert(tweetIndex,tweet)
                       */
                      var tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;

                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);

                      tweet = TweetModel.fromMap(data.payload);
                      tweets.insert(tweetIndex, tweet);
                    }

                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int i) {
                        final tweet = tweets[i];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                  error: (e, stackTrace) => ErrorText(error: e.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int i) {
                        final tweet = tweets[i];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                );
          },
          error: (e, stackTrace) => ErrorText(error: e.toString()),
          loading: () => const Loader(),
        );
  }
}
