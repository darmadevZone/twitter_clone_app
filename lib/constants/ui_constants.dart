import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone_app/constants/assets_constants.dart';
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
    Text("Feed Page index 0"),
    Text("index 1"),
    Text("index 2"),
  ];
}
