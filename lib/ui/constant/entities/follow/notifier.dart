import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/follow/follow.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:flutter/material.dart';

// TODO(Hendi Noviansyah): check if this class is still needed
class FollowRequestUnfollowNotifier with ChangeNotifier {

  StatusFollowing _statusFollow = StatusFollowing.none;
  StatusFollowing get statusFollow => _statusFollow;

  List<dynamic> _listFollow = [];
  List<dynamic> get listFollow => _listFollow;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool state){
    _isLoading = state;
    notifyListeners();
  }

  set listFollow(List<dynamic> val) {
    _listFollow = val;
    notifyListeners();
  }

  set statusFollow(StatusFollowing val) {
    _statusFollow = val;
    notifyListeners();
  }

  setStatusFollow(StatusFollowing val){
    _statusFollow = val;
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

  void _revertIfError(BuildContext context, ContentData currentValue) {
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

  Future<bool> followUser(BuildContext context, {bool checkIdCard = true, String? email, int? index, isUnFollow = false}) async {
    try {
      isLoading = true;
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: email ?? '',
          eventType: InteractiveEventType.following,
        ),
      );
      final fetch = notifier.followFetch;
      isLoading = false;
      if (fetch.followState == FollowState.followUserSuccess) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isLoading = false;
      return false;
    }
  }
}
