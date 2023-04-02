import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone_app/core/enums/notification_type_enum.dart';
import 'package:twitter_clone_app/models/notification_model.dart' as model;

import '../../../constants/constants.dart';
import '../../../theme/theme.dart';

class NotificationTile extends StatelessWidget {
  final model.NotificationModel notificationModel;
  const NotificationTile({
    super.key,
    required this.notificationModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notificationModel.notificationType == NotificationType.follow
          ? const Icon(
              Icons.person,
              color: Pallete.blueColor,
            )
          : notificationModel.notificationType == NotificationType.like
              ? SvgPicture.asset(
                  AssetsConstants.likeFilledIcon,
                  color: Pallete.redColor,
                  height: 20,
                )
              : notificationModel.notificationType == NotificationType.retweet
                  ? SvgPicture.asset(
                      AssetsConstants.retweetIcon,
                      color: Pallete.whiteColor,
                      height: 20,
                    )
                  : null,
      title: Text(notificationModel.text),
    );
  }
}
