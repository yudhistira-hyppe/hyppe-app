import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/query_request/comment_data_query.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/sub_comment_list_tile.dart';
import 'package:hyppe/core/extension/custom_extension.dart';

class CommentNotifierV2 with ChangeNotifier {
  String? postID;
  String? parentID;
  bool fromFront = true;
  Map<String?, List<Widget>> repliesComments = {};
  bool _showTextInput = false;

  CommentDataQuery commentQuery = CommentDataQuery()..limit = 25;

  int get itemCount => _commentData == null
      ? 1
      : commentQuery.hasNext
          ? (_commentData?.length ?? 0) + 1
          : (_commentData?.length ?? 0);

  bool get hasNext => commentQuery.hasNext;

  bool get isCommentEmpty {
    return _commentData == null || (_commentData?.isEmpty ?? true);
  }

  List<CommentsLogs>? _commentData;

  List<CommentsLogs>? get commentData => _commentData;

  bool get showTextInput => _showTextInput;

  set showTextInput(bool value) {
    _showTextInput = value;
    notifyListeners();
  }

  set commentData(List<CommentsLogs>? val) {
    _commentData = val;
    notifyListeners();
  }

  void initState(
    BuildContext context,
    String? postID,
    bool fromFront,
    DisqusLogs? parentComment,
  ) {
    this.postID = postID;
    this.fromFront = fromFront;
    getComment(context, reload: true).then((_) {
      if (parentComment != null) {
        showTextInput = true;
        onReplayCommentV2(
          context,
          comment: parentComment,
          parentCommentID: parentComment.lineID,
        );
      }
    });
  }

  void onDispose() {
    _showTextInput = false;
  }

  Future<void> getComment(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<CommentDataV2>> _resFuture;

    commentQuery.postID = postID ?? '';

    try {
      if (reload) {
        _resFuture = commentQuery.reload(context);
      } else {
        _resFuture = commentQuery.loadNext(context);
      }

      final res = await _resFuture;

      if (reload) {
        commentData = res.firstOrNull()?.disqusLogs ?? [];
      } else {
        commentData = [...(commentData ?? [] as List<CommentsLogs>)] + res.firstOrNull()!.disqusLogs!;
      }
    } catch (e) {
      'load comments list: ERROR: $e'.logger();
    }
  }

  Future<void> addComment(BuildContext context) async {
    inputNode.unfocus();
    if (commentController.value.text.isEmpty) {
      return;
    }

    loading = true;

    commentQuery
      ..postID = postID ?? ''
      ..parentID = parentID ?? ''
      ..txtMessages = commentController.text;

    try {
      final _resFuture = commentQuery.addComment(context);

      final res = await _resFuture;

      if (res != null) {
        if (parentID == null) {
          _commentData?.insert(0, res);
        } else {
          final _parentIndex = _commentData?.indexWhere((element) => element.comment?.lineID == parentID);
          _commentData?[_parentIndex!].replies.insert(0, res.comment!);
          repliesComments[parentID]?.insertAll(0, [
            const SizedBox(height: 16),
            SubCommentListTile(data: res.comment, parentID: parentID, fromFront: fromFront),
          ]);
        }

        // delete text controller
        commentController.clear();
        onChangeHandler('');
      }
    } catch (e) {
      'add comments: ERROR: $e'.logger();
    } finally {
      parentID = null;
      loading = false;
    }
  }

  void scrollListener(BuildContext context, ScrollController scrollController) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !commentQuery.loading &&
        hasNext) {
      getComment(context);
    }
  }

  void onReplayCommentV2(
    BuildContext context, {
    required DisqusLogs? comment,
    required String? parentCommentID,
  }) {
    parentID = parentCommentID;

    FocusScope.of(context).requestFocus(_inputNode);
    if (commentController.text.isNotEmpty && !commentController.text.contains('@')) {
      String _tmpString = '@${comment?.senderInfo?.username ?? '' ' ' + commentController.text}';
      commentController.clear();
      commentController.text = _tmpString;
    } else {
      commentController.text = '@${comment?.senderInfo?.username} ';
    }
  }

  void seeMoreReplies(CommentsLogs? comment) {
    if (repliesComments.containsKey(comment?.comment?.lineID)) {
      repliesComments.remove(comment?.comment?.lineID);
    } else {
      repliesComments[comment?.comment?.lineID] = [
        for (final subComment in comment?.replies ?? []) ...[
          const SizedBox(height: 16),
          SubCommentListTile(
            data: subComment,
            fromFront: fromFront,
            parentID: comment?.comment?.lineID,
          ),
        ],
      ];
    }

    notifyListeners();
  }

  final FocusNode _inputNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  Color? _sendButtonColor;
  bool _loading = false;

  bool get loading => _loading;
  FocusNode get inputNode => _inputNode;
  TextEditingController get commentController => _commentController;
  Color? get sendButtonColor => _sendButtonColor;

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  set sendButtonColor(Color? val) {
    _sendButtonColor = val;
    notifyListeners();
  }

  onChangeHandler(String v) {
    v.isNotEmpty ? sendButtonColor = const Color(0xff822E6E) : sendButtonColor = null;
    notifyListeners();
  }
}
