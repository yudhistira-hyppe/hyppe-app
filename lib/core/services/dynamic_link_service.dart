import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/screen.dart';

import 'shared_preference.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';

class DynamicLinkService {
  static final DynamicLinkService _instance = DynamicLinkService._internal();

  factory DynamicLinkService() {
    return _instance;
  }

  DynamicLinkService._internal();

  static final _routing = Routing();
  static final _sharedPrefs = SharedPreference();

  // To prevent dynamic link from being called multiple times
  static bool _linkProcessed = false;

  static PendingDynamicLinkData? _pendingDynamicLinkData;

  static Future handleDynamicLinks() async {
    if (_linkProcessed) {
      // Do not process the link if it has been processed already.
      return;
    }

    // Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // Set [_pendingDynamicLinkData] to the initial dynamic link
    _pendingDynamicLinkData ??= data;

    // handle link that has been retrieved
    _handleDeepLink(data);

    // Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink.listen(
      (event) {
        // handle link that has been retrieved
        _handleDeepLink(event);
      },
      onError: (e) {
        'Link Failed: ${e.toString()}'.logger();
      },
    );
  }

  static void _handleDeepLink(PendingDynamicLinkData? data) async {
    Uri? deepLink = data?.link;
    if (deepLink != null) {
      // Set [_pendingDynamicLinkData] to the initial dynamic link
      _pendingDynamicLinkData ??= data;

      final _userToken = _sharedPrefs.readStorage(SpKeys.userToken);
      if (_userToken != null) {
        // Auto follow user if app is install from a dynamic link
        try {
          followSender(Routing.navigatorKey.currentContext!);
        } catch (e) {
          'Error in followSender $e'.logger();
        }

        final _path = deepLink.path;
        switch (_path) {
          case Routes.storyDetail:
            _routing.moveReplacement(
              _path,
              argument: StoryDetailScreenArgument()
                ..postID = deepLink.queryParameters['postID'],
            );
            break;
          case Routes.vidDetail:
            _routing.moveReplacement(
              _path,
              argument: VidDetailScreenArgument()
                ..postID = deepLink.queryParameters['postID'],
            );
            break;
          case Routes.diaryDetail:
            _routing.moveReplacement(
              _path,
              argument: DiaryDetailScreenArgument()
                ..postID = deepLink.queryParameters['postID'],
            );
            break;
          case Routes.picDetail:
            _routing.moveReplacement(
              _path,
              argument: PicDetailScreenArgument()
                ..postID = deepLink.queryParameters['postID'],
            );
            break;
          // TO DO: If register from referral link, then hit to backend
          case Routes.otherProfile:
            _routing.moveReplacement(
              _path,
              argument: OtherProfileArgument()
                ..senderEmail = deepLink.queryParameters['sender_email'],
            );
            break;
        }

        // Set [_linkProcessed] to true
        _linkProcessed = true;
        '_handleDeepLink | deeplink: $deepLink'.logger();
      } else {
        '_handleDeepLink | userToken is null'.logger();
      }
    } else {
      'App open not from dynamic link'.logger();
    }
  }

  static Future followSender(BuildContext context) async {
    try {
      final _receiverParty =
          _pendingDynamicLinkData?.link.queryParameters['sender_email'];

      'Link | followSender | receiverParty: $_receiverParty'.logger();

      if (_receiverParty != null) {
        final notifier = FollowBloc();
        await notifier.followUserBlocV2(
          context,
          withAlertConnection: false,
          data: FollowUserArgument(
            receiverParty: _receiverParty,
            eventType: InteractiveEventType.following,
          ),
        );
        final fetch = notifier.followFetch;
        if (fetch.followState == FollowState.followUserSuccess) {
          'followUser | followUserSuccess'.logger();
        } else {
          'followUser | followUserFailed'.logger();
        }
        _pendingDynamicLinkData = null;
      } else {
        'followUser | _receiverParty is null'.logger();
      }
    } catch (e) {
      'follow user: ERROR: $e'.logger();
    }
  }
}

/**
 *  [hyppePicDetail] => pathSegments
    flutter: /hyppePicDetail => path
    flutter: userID=gy1Yz7nqs&postID=2FSjMJ_Qr&postType=pic => query
    flutter: {userID: gy1Yz7nqs, postID: 2FSjMJ_Qr, postType: pic} => queryParameters

    Map structure => userID=$userID&postID=$postID&postType=$postType
 */
