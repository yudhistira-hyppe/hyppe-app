import 'package:hyppe/core/constants/enum.dart';

class GetFollowerUsersArgument {
  final InteractiveEventType eventType;
  bool withDetail = true;
  List<InteractiveEvent>? withEvents;
  String postID = '';
  final int pageRow;
  final int pageNumber;
  String senderOrReceiver = '';
  String searchText = '';

  GetFollowerUsersArgument({
    required this.eventType,
    required this.pageRow,
    required this.pageNumber,
  });
}
