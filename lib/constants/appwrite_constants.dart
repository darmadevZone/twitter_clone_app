import 'dart:io';

class AppwriteConstants {
  static const String databaseId = "63e48ee8ba51ec36ccf3";
  static const String projectId = "63e48be5bc8fce665d93";
  //ios
  static const String endPoint = "http://localhost:80/v1";

  //android
  //static const String endPoint = "http://192.168.3.9:80/v1";
  //  static const String endPoint = "http://{Local_IP_Address}:80/v1";
  //LOCAL_IP_ADDRESS can search  "ifconfig" command  ex)ifconfig | grep -I 192.....
  static const String usersCollection = '63ebb402da586d689564';
  static const String tweetsCollection = '63f2c301b8561a6f4260';
  static const String notificationsCollection = '64268e6d21efea569cec';

  static const String imagesBucket = "63f32d72a567d8656020";

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';

  static String platformType() {
    if (Platform.isIOS) {
      return endPoint;
    } else if (Platform.isAndroid) {
      const endPoint = 'http://192.168.3.2:80/v1';
      return endPoint;
    }
    print(endPoint);
    return endPoint;
  }
}
