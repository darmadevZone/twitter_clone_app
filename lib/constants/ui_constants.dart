import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone_app/constants/assets_constants.dart';
import 'package:twitter_clone_app/features/explore/view/explore_view.dart';
import 'package:twitter_clone_app/features/notifications/views/notification_view.dart';
import 'package:twitter_clone_app/features/tweet/widgets/tweet_list.dart';
import 'package:twitter_clone_app/theme/pallete.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        height: 30,
        color: Pallete.blueColor,
      ),
      centerTitle: true,
    );
  }

  static const List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreView(),
    NotificationView()
  ];
}
