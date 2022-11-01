import 'package:hyppe/core/bloc/like/bloc.dart';
import 'package:hyppe/core/bloc/postviewer/bloc.dart';
import 'package:hyppe/core/bloc/postviewer/state.dart';
import 'package:hyppe/core/bloc/reaction/bloc.dart';
import 'package:hyppe/core/bloc/reaction/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/comment/comments.dart';
import 'package:hyppe/core/models/collection/comment/update_comment_reaction.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/view_content.dart';
import 'package:hyppe/core/models/collection/utils/reaction/post_reaction.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';
import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/ui/inner/home/content/diary/playlist/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';

class LikeNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();

  translate(LocalizationModelV2 translate) {
    language = translate;

    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _skip = 0;
  int get skip => _skip;

  List<ViewContent>? _listLikeView;
  List<ViewContent>? get listLikeView => _listLikeView;

  List _visibiltyList = [];
  List get visibiltyList => _visibiltyList;

  String _visibilty = 'PUBLIC';
  String get visibilty => _visibilty;

  String _visibilitySelect = 'PUBLIC';
  String get visibilitySelect => _visibilitySelect;

  set visibilty(String val) {
    _visibilty = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set listLikeView(List<ViewContent>? val) {
    _listLikeView = val;
    notifyListeners();
  }

  set skip(int val) {
    _skip = val;
    notifyListeners();
  }

  set visibilitySelect(String val) {
    _visibilitySelect = val;
    notifyListeners();
  }

  set visibiltyList(List val) {
    _visibiltyList = val;

    notifyListeners();
  }

  bool? change;
  Future<void> likePost(BuildContext context, ContentData postData) async {
    final notifier = LikeBloc();
    print(postData.isLiked);

    try {
      // System().actionReqiredIdCard(
      //   context,
      //   uploadContentAction: false,
      //   action: () async {

      // if (postData.email == SharedPreference().readStorage(SpKeys.email)) {
      //   // Prevent user from liking his own post
      //   return;
      // }
      print('rijal ${postData.isLiked}');

      // if (!(postData.insight?.isPostLiked ?? false)) {
      //   postData.insight?.isPostLiked =
      //       !(postData.insight?.isPostLiked ?? false);
      //       print(('rijals ${postData.insight?.isPostLiked}'));
      //   if (postData.insight?.isPostLiked ?? false) {
      //     postData.insight?.likes = (postData.insight?.likes ?? 0) + 1;
      //   }
      //   notifyListeners();
      // }

      if (postData.isLiked == true) {
        //unlike
        postData.isLiked = false;
        postData.insight?.isPostLiked = false;
        postData.insight?.likes = postData.insight!.likes! - 1;

        notifyListeners();

        await notifier.likePostUserBloc(context, postId: postData.postID!, emailOwner: postData.email!, isLike: postData.isLiked!);
        // final fetch = notifier.likeFetch;
        // notifyListeners();

        // if (fetch.likeState == LikeState.likeUserPostSuccess) {
        //   "Like post success".logger();

        //   if (postData.isLiked == false) {
        //     postData.insight?.likes = (postData.insight?.likes ?? 0) - 1;
        //   }
        //   notifyListeners();
        // }
      } else if (postData.isLiked == false) {
        //like
        postData.isLiked = true;
        postData.insight?.isPostLiked = true;
        postData.insight?.likes = postData.insight!.likes! + 1;

        notifyListeners();

        // print('ini false ${postData.isLiked}');
        await notifier.likePostUserBloc(context, postId: postData.postID!, emailOwner: postData.email!, isLike: postData.isLiked!);
        // print('ini false');
        // final fetch = notifier.likeFetch;

        // notifyListeners();
        // if (fetch.likeState == LikeState.likeUserPostSuccess) {
        //   "Like post success".logger();

        //   if (postData.isLiked == true) {
        //     postData.insight?.likes = (postData.insight?.likes ?? 0) + 1;
        //   }
        //   notifyListeners();
        // }
      }

      // TODO: Future implementation
      // postData.insight?.isPostLiked = !(postData.insight?.isPostLiked ?? false);
      // if (postData.insight?.isPostLiked ?? false) {
      //   postData.insight?.likes = (postData.insight?.likes ?? 0) + 1;
      // } else {
      //   if ((postData.insight?.likes ?? 0) > 0) {
      //     postData.insight?.likes = (postData.insight?.likes ?? 0) - 1;
      //   }
      // }

      // await notifier.likePostUserBloc(context, postId: postData.postID!, emailOwner: postData.email!, isLike: postData.isLiked!);
      // final fetch = notifier.likeFetch;
      // if (fetch.likeState == LikeState.likeUserPostSuccess) {
      //   "Like post success".logger();
      // }
      // notifyListeners();

      //   },
      // );
    } catch (e) {
      e.logger();
    }
  }

  onLikeComment(BuildContext context, {required Comments comment, required ReactionInteractive rData}) async {
    final notifier = ReactionBloc();
    await notifier.addReactOnCommentBloc(
      context,
      function: () => onLikeComment(context, comment: comment, rData: rData),
      data: PostReaction(
        userID: SharedPreference().readStorage(SpKeys.userID),
        postID: comment.postID,
        commentID: comment.commentID,
        commentType: "m",
        reactionID: rData.reactionId,
        reaction: rData.icon,
        reactionType: "emoji",
        reactionUnicode: rData.utf,
      ),
    );
    final fetch = notifier.reactionFetch;
    if (fetch.reactionState == ReactionState.addReactOnCommentBlocSuccess) {
      notifyListeners();
      await notifier.getCommentReactionsBloc(context, postID: comment.postID, commentID: comment.commentID);
      final fetch2 = notifier.reactionFetch;
      if (fetch2.reactionState == ReactionState.getCommentReactionsBlocSuccess) {
        UpdateCommentReaction _result = fetch2.data;
        comment.isReacted = true;
        comment.count = _result.count;
        comment.reactions = _result.reactions;
        notifyListeners();
      }
      notifyListeners();
    }
  }

  void changeVisibility(BuildContext context, val) {
    _visibilty = val;
    _visibilitySelect = val;

    Provider.of<HomeNotifier>(context, listen: false).onRefresh(context);
    Provider.of<HomeNotifier>(context, listen: false).visibilty = val;
    notifyListeners();
  }

  void viewLikeContent(BuildContext context, postId, eventType, title, emailData, {StoryController? storyController}) {
    final email = SharedPreference().readStorage(SpKeys.email);
    if (email == emailData) ShowBottomSheet.onShowUserViewContent(context, postId: postId, eventType: eventType, title: title, storyController: storyController);
  }

  Future getLikeView(BuildContext context, postId, eventType, limit) async {
    isLoading = true;
    final notifier = PostViewerBloc();
    await notifier.likeViewContentBloc(context, postID: postId, eventType: eventType, limit: limit, skip: _skip);

    final fetch = notifier.postViewerFetch;
    if (fetch.postViewerState == PostViewerState.likeViewSuccess) {
      _listLikeView = [];
      fetch.data.forEach((v) {
        _listLikeView?.add(ViewContent.fromJson(v));
      });
      isLoading = false;
    }
  }
}
