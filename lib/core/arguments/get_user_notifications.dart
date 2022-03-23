import 'package:hyppe/core/constants/enum.dart';

class GetUserNotificationArgument {
  int pageRow;
  int pageNumber;
  String postID = '';
  String senderOrReceiver = '';
  NotificationCategory? eventType;

  GetUserNotificationArgument({
    required this.pageRow,
    required this.pageNumber,
  });
}
