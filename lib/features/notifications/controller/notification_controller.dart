import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/apis/notification_api.dart';
import 'package:twitter_clone_app/core/enums/notification_type_enum.dart';
import 'package:twitter_clone_app/models/notification_model.dart' as model;

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
    notification: ref.watch(notificationAPIProvider),
  );
});

final getNotificationProvider = FutureProvider.family((ref, String uid) async {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return notificationController.getNotifications(uid);
});

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(notificationAPIProvider);
  return notificationAPI.getLatestNotification();
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;

  NotificationController({
    required NotificationAPI notification,
  })  : _notificationAPI = notification,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required NotificationType notificationType,
    required String uid,
  }) async {
    final notification = model.NotificationModel(
      text: text,
      postId: postId,
      id: '',
      uid: uid,
      notificationType: notificationType,
    );
    final res = await _notificationAPI.createNotification(notification);
    res.fold(
      (l) {
        print(l.message);
      },
      (r) => null,
    );
  }

  Future<List<model.NotificationModel>> getNotifications(String uid) async {
    final documents = await _notificationAPI.getNotifications(uid);
    return documents
        .map((e) => model.NotificationModel.fromMap(e.data))
        .toList();
  }
}
