import 'package:hyppe/core/constants/enum.dart';

class DiscussArgument {
  final String email;

  final String receiverParty;

  int pageRow = 0;

  int pageNumber = 0;

  String postID = '';

  String txtMessages = '';

  String reactionUri = '';

  bool isQuery = false;

  bool withDetail = false;

  bool detailOnly = false;

  FeatureType postType = FeatureType.txtMsg;

  DiscussEventType discussEventType = DiscussEventType.directMsg;

  List<dynamic> tagComment = [];

  String? streamID;

  DiscussArgument({
    required this.email,
    required this.receiverParty,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'receiverParty': receiverParty,
      'pageRow': pageRow,
      'pageNumber': pageNumber,
      'postID': postID,
      'txtMessages': txtMessages,
      'reactionUri': reactionUri,
      'isQuery': isQuery,
      'withDetail': withDetail,
      'detailOnly': detailOnly,
      'postType': postType.toString(),
      'messageEventType': discussEventType.toString(),
      'tagComment': tagComment,
      'streamID': streamID,
    };
  }
}
