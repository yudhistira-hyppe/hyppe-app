import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/constants/enum.dart';

class CommentArgument extends DiscussArgument {
  String parentID = '';

  @override
  DiscussEventType get discussEventType => DiscussEventType.comment;

  CommentArgument()
      : super(
          email: '',
          receiverParty: '',
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postID'] = postID;
    data['isQuery'] = isQuery;
    data['pageRow'] = pageRow;
    data['parentID'] = parentID;
    data['pageNumber'] = pageNumber;
    data['txtMessages'] = txtMessages;
    data['postType'] = 'txt_msg';
    data['eventType'] = 'COMMENT';
    return data;
  }
}
