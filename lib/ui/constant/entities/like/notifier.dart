import 'package:hyppe/core/bloc/like/bloc.dart';
import 'package:hyppe/core/bloc/like/state.dart';
import 'package:hyppe/core/bloc/reaction/bloc.dart';
import 'package:hyppe/core/bloc/reaction/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/comment/comments.dart';
import 'package:hyppe/core/models/collection/comment/update_comment_reaction.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/reaction/post_reaction.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';
import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/ui/inner/home/content/diary/playlist/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';

class LikeNotifier with ChangeNotifier {
  bool? change;
  Future<void> likePost(BuildContext context, ContentData postData) async {
    final notifier = LikeBloc();
    print(postData.isLiked);

    try {
      // System().actionReqiredIdCard(
      //   context,
      //   uploadContentAction: false,
      //   action: () async {

      if (postData.email == SharedPreference().readStorage(SpKeys.email)) {
        // Prevent user from liking his own post
        return;
      }
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
}
