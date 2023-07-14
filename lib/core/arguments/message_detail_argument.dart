import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

class MessageDetailArgument {
  final Mate mate;
  final String photoReceiver;
  final String emailReceiver;
  final String usernameReceiver;
  final String fullnameReceiver;
  final String disqusID;
  final UserBadgeModel? badgeReceiver;
  final List<MessageDataV2>? discussData;

  MessageDetailArgument({
    required this.mate,
    required this.photoReceiver,
    required this.emailReceiver,
    required this.usernameReceiver,
    required this.fullnameReceiver,
    required this.disqusID,
    this.badgeReceiver,
    this.discussData,
  });
}
