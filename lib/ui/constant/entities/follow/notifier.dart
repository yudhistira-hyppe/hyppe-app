import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/post_follow_user.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
// import 'package:hyppe/ui/inner/home/content/diary/preview/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/pic/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/vid/notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/follow/follow.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:hyppe/core/extension/custom_extension.dart';

// TODO(Hendi Noviansyah): check if this class is still needed
class FollowRequestUnfollowNotifier with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => false;

  String? _statusFollow;
  String? get statusFollow => _statusFollow;

  List<dynamic> _listFollow = [];
  List<dynamic> get listFollow => _listFollow;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set listFollow(List<dynamic> val) {
    _listFollow = val;
    notifyListeners();
  }

  set statusFollow(String? val) {
    _statusFollow = val;
    notifyListeners();
  }

  Future<StatusFollowing> followRequestUnfollowUser(
    BuildContext context, {
    required String fUserId,
    required ContentData currentValue,
    required StatusFollowing statusFollowing,
  }) async {
    late StatusFollowing _statusFollowing;

    final connect = await System().checkConnections();
    if (connect) {
      _setPreSuccess(currentValue, context);
      String? myID = SharedPreference().readStorage(SpKeys.userID);
      final notifier = FollowBloc();
      notifier.followUserBloc(context,
          data: FollowUser(
            userID: myID,
            fUserID: fUserId,
            sts: System().postStatusFollow(statusFollowing),
          ));
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserError) {
        print('Action failed');
        _revertIfError(context, currentValue);
        _statusFollowing = statusFollowing;
      } else {
        _statusFollowing = System().getStatusFollow(System().postStatusFollow(statusFollowing));
        print('Action success');
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }

    return _statusFollowing;
  }

  void _setPreSuccess(ContentData currentValue, BuildContext context) {
    // context.read<PreviewVidNotifier>().vidData?.data.updateFollowingData(currentValue.userID, true);
    // context.read<PreviewDiaryNotifier>().diaryData?.data.updateFollowingData(currentValue.userID, true);
    // context.read<PreviewPicNotifier>().pic?.data.updateFollowingData(currentValue.userID, true);
    notifyListeners();
  }

  void _revertIfError(BuildContext context, ContentData currentValue) {
    // context.read<PreviewVidNotifier>().vidData?.data.updateFollowingData(currentValue.userID, false);
    // context.read<PreviewDiaryNotifier>().diaryData?.data.updateFollowingData(currentValue.userID, false);
    // context.read<PreviewPicNotifier>().pic?.data.updateFollowingData(currentValue.userID, false);
    notifyListeners();
    ShowBottomSheet.onShowSomethingWhenWrong(context);
  }

  bool emailcheck(String? email) => email == SharedPreference().readStorage(SpKeys.email) ? true : false;

  String label(String? tile) {
    String label = '';
    try{
      if (tile == 'requested') {
        label = 'Requested';
      } else {
        final index = _listFollow.indexWhere((element) => element["code"] == tile);
        label = _listFollow[index]['name'];
      }
    }catch(e){
      'get Label Error : $e'.logger();
    }

    print(label);

    return label;
  }

  Future<bool> followUser(BuildContext context, {bool checkIdCard = true, String? email, int? index}) async {
    try {
      // statusFollowing = StatusFollowing.requested;
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: email ?? '',
          eventType: InteractiveEventType.following,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // 'follow user: ERROR: $e'.logger();
      return false;
    }
  }
}
