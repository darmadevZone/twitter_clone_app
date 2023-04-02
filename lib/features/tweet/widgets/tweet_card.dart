import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone_app/constants/assets_constants.dart';
import 'package:twitter_clone_app/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone_app/features/tweet/views/twitter_reply_view.dart';
import 'package:twitter_clone_app/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone_app/features/tweet/widgets/hashtag_text.dart';
import 'package:twitter_clone_app/features/tweet/widgets/tweet_icon_button.dart';
import 'package:twitter_clone_app/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone_app/models/tweet_model.dart';
import 'package:twitter_clone_app/theme/pallete.dart';

import '../../../common/common.dart';

class TweetCard extends ConsumerWidget {
  final TweetModel tweet;
  const TweetCard({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final user = ref.watch(userDetailsProvider(tweet.uid));
    return currentUser == null
        ? const SizedBox()
        : user.when(
            data: (user) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    TwitterReplyScreen.route(tweet),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                UserProfileView.route(user),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //retweeted
                              if (tweet.retweetedBy.isNotEmpty)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsConstants.retweetIcon,
                                      height: 16,
                                      color: Pallete.greyColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${tweet.retweetedBy} retweeted',
                                      style: const TextStyle(
                                        color: Pallete.greyColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: user.isTwitterBlue ? 1 : 5),
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (user.isTwitterBlue)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: SvgPicture.asset(
                                        AssetsConstants.verifiedIcon,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  Text(
                                    "@${user.name} ${timeago.format(
                                      tweet.tweetedAt,
                                      locale: 'en_short',
                                    )}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Pallete.greyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              //replied to
                              if (tweet.repliedTo.isNotEmpty)
                                ref
                                    .watch(
                                        getTweetByIdProvider(tweet.repliedTo))
                                    .when(
                                      data: (repliedToTweet) {
                                        final replyingToUser = ref
                                            .watch(
                                              userDetailsProvider(
                                                repliedToTweet.uid,
                                              ),
                                            )
                                            .value;
                                        return RichText(
                                          text: TextSpan(
                                            text: 'Replying to',
                                            style: const TextStyle(
                                              color: Pallete.greyColor,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    ' @${replyingToUser?.name}',
                                                style: const TextStyle(
                                                  color: Pallete.blueColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      error: (error, st) => ErrorText(
                                        error: error.toString(),
                                      ),
                                      loading: () => const SizedBox(),
                                    ),
                              HashtagText(text: tweet.text),
                              if (tweet.tweetType == TweetType.image)
                                CarouselImage(imageLinks: tweet.imageLinks),
                              if (tweet.link.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: tweet.link,
                                )
                              ],
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TweetIconButton(
                                      pathName: AssetsConstants.viewsIcon,
                                      text: (tweet.commentIds.length +
                                              tweet.reshareCount +
                                              tweet.likes.length)
                                          .toString(),
                                      onTap: () {},
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.commentIcon,
                                      text:
                                          (tweet.commentIds.length).toString(),
                                      onTap: () {},
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.retweetIcon,
                                      text: (tweet.reshareCount).toString(),
                                      onTap: () {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .reshareTweet(
                                              tweet,
                                              currentUser,
                                              context,
                                            );
                                      },
                                    ),
                                    LikeButton(
                                      isLiked:
                                          tweet.likes.contains(currentUser.uid),
                                      onTap: (isLiked) async {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .likeTweet(tweet, user);
                                        return !isLiked;
                                      },
                                      size: 20,
                                      likeBuilder: (isLiked) {
                                        return isLiked
                                            ? SvgPicture.asset(
                                                AssetsConstants.likeFilledIcon,
                                                color: Pallete.redColor,
                                              )
                                            : SvgPicture.asset(
                                                AssetsConstants
                                                    .likeOutlinedIcon,
                                                color: Pallete.greyColor,
                                              );
                                      },
                                      likeCount: tweet.likes.length,
                                      countBuilder: (likeCount, isLiked, text) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Pallete.redColor
                                                  : Pallete.greyColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.shape_line_outlined,
                                        size: 15,
                                        color: Pallete.greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 0.5)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Pallete.greyColor,
                      height: 0,
                    )
                  ],
                ),
              );
            },
            error: (e, stackTrace) {
              return ErrorText(error: e.toString());
            },
            loading: () => const Loader(),
          );
  }
}
