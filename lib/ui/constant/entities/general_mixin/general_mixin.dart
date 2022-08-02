import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

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

  Future deleteMyTag(BuildContext context, postId, content) async {
    final connect = await System().checkConnections();
    final notifier = UtilsBlocV2();
    final email = SharedPreference().readStorage(SpKeys.email);

    print('delete in updload');
    if (connect) {
      print(postId);
      await notifier.deleteTagUsersBloc(context, postId);

      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.deleteUserTagSuccess) {
        context.read<PreviewVidNotifier>().onDeleteSelfTagUserContent(
              context,
              postID: postId,
              content: hyppeVid,
              email: email,
            );
        Routing().moveBack();
        showSnackBar(color: kHyppeLightSuccess, message: 'Your successfully removed from HyppeVid', icon: 'valid-invert.svg');
      } else {
        showSnackBar(color: kHyppeDanger, message: 'Somethink wrong', icon: 'info-icon.svg');
        Routing().moveBack();
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void showSnackBar({
    String? icon,
    required Color color,
    required String message,
  }) {
    Routing().showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              fromSnackBar: true,
              iconSvg: icon != null ? "${AssetPath.vectorPath}$icon" : null,
            ),
          ),
        ),
      ),
    );
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
