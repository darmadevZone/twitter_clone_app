import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone_app/features/tweet/widgets/tweet_card.dart';

import '../../../common/common.dart';
import '../../../constants/constants.dart';
import '../../../models/tweet_model.dart';

class TwitterReplyScreen extends ConsumerWidget {
  static route(TweetModel tweet) => MaterialPageRoute(
        builder: (context) => TwitterReplyScreen(tweet: tweet),
      );
  final TweetModel tweet;
  const TwitterReplyScreen({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tweet"),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getRepliesToTweetsProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = TweetModel.fromMap(data.payload);

                          bool isTweetAlreadyPresent = false;
                          for (final tweetModel in tweets) {
                            if (tweetModel.id == latestTweet.id) {
                              isTweetAlreadyPresent = true;
                              break;
                            }
                          }

                          if (!isTweetAlreadyPresent &&
                              latestTweet.repliedTo == tweet.id) {
                            if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create',
                            )) {
                              tweets.insert(
                                  0, TweetModel.fromMap(data.payload));
                            } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update',
                            )) {
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endPoint =
                                  data.events[0].lastIndexOf('.update');
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
                              tweets.removeWhere(
                                  (element) => element.id == tweetId);

                              tweet = TweetModel.fromMap(data.payload);
                              tweets.insert(tweetIndex, tweet);
                            }
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, int i) {
                                final tweet = tweets[i];
                                return TweetCard(tweet: tweet);
                              },
                            ),
                          );
                        },
                        error: (e, stackTrace) =>
                            ErrorText(error: e.toString()),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, int i) {
                                final tweet = tweets[i];
                                return TweetCard(tweet: tweet);
                              },
                            ),
                          );
                        },
                      );
                },
                error: (e, stackTrace) => ErrorText(error: e.toString()),
                loading: () => const Loader(),
              ),
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (text) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: text,
            context: context,
            repliedTo: tweet.id,
            repliedToUserId: tweet.uid,
          );
        },
        decoration: const InputDecoration(hintText: "Tweet your reply"),
      ),
    );
  }
}
