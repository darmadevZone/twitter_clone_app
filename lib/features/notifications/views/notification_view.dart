import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/common/common.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone_app/features/notifications/widgets/notification_tile.dart';
import 'package:twitter_clone_app/models/notification_model.dart' as model;

import '../../../constants/constants.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationProvider(currentUser.uid)).when(
                data: (notificationModelData) {
                  return ref.watch(getLatestNotificationProvider).when(
                      data: (data) {
                        if (data.events.contains(
                          'databases.*.collections.${AppwriteConstants.notificationsCollection}.documents.*.create',
                        )) {
                          final latestNotif =
                              model.NotificationModel.fromMap(data.payload);
                          if (latestNotif.uid == currentUser.uid) {
                            notificationModelData.insert(0, latestNotif);
                          }
                        }

                        return ListView.builder(
                          itemCount: notificationModelData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final notification = notificationModelData[index];
                            return NotificationTile(
                              notificationModel: notification,
                            );
                          },
                        );
                      },
                      error: (e, st) => ErrorText(error: e.toString()),
                      loading: () {
                        return ListView.builder(
                          itemCount: notificationModelData.length,
                          itemBuilder: (context, i) {
                            final notificatonData = notificationModelData[i];
                            return NotificationTile(
                              notificationModel: notificatonData,
                            );
                          },
                        );
                      });
                },
                error: (e, st) => ErrorText(error: e.toString()),
                loading: () => const Loader(),
              ),
    );
  }
}
