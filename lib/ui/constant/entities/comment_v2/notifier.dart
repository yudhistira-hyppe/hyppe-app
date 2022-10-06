import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/delete_comment/bloc.dart';
import 'package:hyppe/core/bloc/delete_comment/state.dart';
import 'package:hyppe/core/bloc/postviewer/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/query_request/comment_data_query.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/sub_comment_list_tile.dart';
import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class CommentNotifierV2 with ChangeNotifier {
  String? postID;
  String? parentID;
  bool fromFront = true;
  Map<String?, List<Widget>> repliesComments = {};
  bool _showTextInput = false;

  int _startSearch = 0;
  int get startSearch => _startSearch;

  bool _isShowAutoComplete = false;
  bool get isShowAutoComplete => _isShowAutoComplete;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SearchPeolpleData> _searchPeolpleData = [];
  List<SearchPeolpleData> get searchPeolpleData => _searchPeolpleData;

  String _temporarySearch = '';
  String get temporarySearch => _temporarySearch;

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

  set startSearch(int value) {
    _startSearch = value;
    notifyListeners();
  }

  set isShowAutoComplete(bool value) {
    _isShowAutoComplete = value;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set searchPeolpleData(List<SearchPeolpleData> val) {
    _searchPeolpleData = val;
    notifyListeners();
  }

  set temporarySearch(String val) {
    _temporarySearch = val;
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
        print('test0');
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

    final _tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9\.-_!$%^&*()]+\w*", caseSensitive: false);

    List userTagCaption = [];
    _tagRegex.allMatches(commentController.text).map((z) {
      userTagCaption.add(z.group(0)?.substring(1));
    }).toList();

    commentQuery
      ..postID = postID ?? ''
      ..parentID = parentID ?? ''
      ..txtMessages = commentController.text
      ..tagComment = userTagCaption;

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
        onChangeHandler('', context);
      }
    } catch (e) {
      'add comments: ERROR: $e'.logger();
    } finally {
      parentID = null;
      loading = false;
    }
  }

  void scrollListener(BuildContext context, ScrollController scrollController) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !commentQuery.loading && hasNext) {
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
  TextEditingController _commentController = TextEditingController();
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

  set commentController(TextEditingController val) {
    _commentController = val;
    notifyListeners();
  }

  onChangeHandler(String v, BuildContext context) {
    v.isNotEmpty ? sendButtonColor = const Color(0xff822E6E) : sendButtonColor = null;
    _isLoading = !_isLoading;
    autoComplete(context, v);
    notifyListeners();
  }

  void autoComplete(BuildContext context, value) {
    final selection = _commentController.selection;
    String _text = value.toString().substring(0, selection.baseOffset);
    final _tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9]+\w*", caseSensitive: false);
    final sentences = _text.split('\n');
    for (var sentence in sentences) {
      final words = sentence.split(' ');
      String withat = words.last;
      if (_tagRegex.hasMatch(withat)) {
        String withoutat = withat.substring(1);
        if (withoutat.length > 2) {
          _startSearch = 0;
          _isShowAutoComplete = true;
          searchPeople(context, input: withoutat);
          _temporarySearch = withoutat;
        }
      } else {
        _isShowAutoComplete = false;
      }
    }
    notifyListeners();
  }

  Future searchPeople(BuildContext context, {input}) async {
    final notifier = UtilsBlocV2();
    if (input.length > 2) {
      if (_startSearch == 0) {
        _isLoading = true;
      }
      await notifier.getSearchPeopleBloc(context, input, _startSearch * 20, 20);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.searchPeopleSuccess) {
        if (_startSearch == 0) {
          _searchPeolpleData = [];
        }
        fetch.data.forEach((v) {
          _searchPeolpleData.add(SearchPeolpleData.fromJson(v));
        });
      }
      _isLoading = false;
    }
    notifyListeners();
  }

  void insertAutoComplete(index) {
    final text = _commentController.text;
    final selection = _commentController.selection;
    int searchLength = _temporarySearch.length;
    _isShowAutoComplete = false;

    final newText = text.replaceRange(selection.start - searchLength, selection.end, '${_searchPeolpleData[index].username} ');
    int length = _searchPeolpleData[index].username!.length;
    _commentController.value = TextEditingValue(
      text: "${newText}",
      selection: TextSelection.collapsed(offset: selection.baseOffset + length - searchLength + 1),
    );
    notifyListeners();
  }

  Future<void> deleteComment(BuildContext context, String lineID) async {
    final _routing = Routing();
    final notifier = DeleteCommentBloc();
    try {
      await notifier.postDeleteCommentBloc(context, lineID: lineID, withAlertConnection: true);
      final fetch = notifier.deletCommentFetch;
      if (fetch.deleteCommentState == DeleteCommentState.deleteCommentSuccess) {
        getComment(context, reload: true);
        _routing.moveBack();
      }
    } catch (e) {
      _routing.moveBack();
      e.logger();
    }
  }
}
