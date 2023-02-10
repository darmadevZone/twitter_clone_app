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
}
