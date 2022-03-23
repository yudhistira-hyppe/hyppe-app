import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';

mixin GeneralMixin {
  Future<bool> deletePostByID(BuildContext context, {required String postID, required String postType}) async {
    final notifier = PostsBloc();
    await notifier.deleteContentBlocV2(context, postId: postID, type: System().getFeatureTypeV2(postType));
    final fetch = notifier.postsFetch;
    if (fetch.postsState == PostsState.deleteContentsSuccess) {
      'Successfully delete post'.logger();
      return true;
    } else {
      'Failed delete post'.logger();
      return false;
    }
  }

  Future<bool> createdDynamicLinkMixin(
    BuildContext context, {
    required DynamicLinkData data,
    required bool copiedToClipboard,
  }) async {
    var _popupDialog = System().createPopupDialog(
      Container(
        alignment: Alignment.center,
        color: const Color(0xff1D2124).withOpacity(0.8),
        child: const UnconstrainedBox(child: CustomLoading()),
      ),
    );
    Overlay.of(context)!.insert(_popupDialog);
    var _result = await System()
        .createdDynamicLink(
          context,
          dynamicLinkData: data,
          copiedToClipboard: copiedToClipboard,
        )
        .whenComplete(() => _popupDialog.remove());

    return System().validateUrl(_result.toString());
  }
}
