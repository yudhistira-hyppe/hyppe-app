import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';

class FollowUserArgument {
  String receiverParty; // user yang mau di follow
  InteractiveEventType eventType;
  InteractiveEvent? replyEvent;
  String? idMediaStreaming;

  FollowUserArgument({
    this.replyEvent,
    required this.eventType,
    required this.receiverParty,
    this.idMediaStreaming,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receiverParty'] = receiverParty;
    data['eventType'] = System().convertEventTypeToString(eventType);
    if (replyEvent != null) {
      data['replyEventType'] = System().convertEventToString(replyEvent);
    }
    if (idMediaStreaming != null) {
      data['idMediaStreaming'] = idMediaStreaming;
    }

    return data;
  }
}
