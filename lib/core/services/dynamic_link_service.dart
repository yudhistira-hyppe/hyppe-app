import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/main_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/arguments/referral_argument.dart';
import 'package:hyppe/core/bloc/referral/bloc.dart';
import 'package:hyppe/core/bloc/referral/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/services/system.dart';

import '../../app.dart';
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
  static bool isOpening = false; // the local bool

  static Future handleDynamicLinks() async {
    if (_linkProcessed) {
      // Do not process the link if it has been processed already.
      return;
    }

    // Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    // Set [_pendingDynamicLinkData] to the initial dynamic link
    _pendingDynamicLinkData ??= data;

    // handle link that has been retrieved
    print("ini event handledeeplink");
    _handleDeepLink(data);

    // Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink.listen(
      (event) {
        print("ini event $event");
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
    deepLink.logger();
    if (deepLink != null) {
      // Set [pendingDynamicLinkData] to the initial dynamic link
      _pendingDynamicLinkData ??= data;
      _sharedPrefs.writeStorage(SpKeys.referralFrom, _pendingDynamicLinkData?.link.queryParameters['sender_email']);
      final _userToken = _sharedPrefs.readStorage(SpKeys.userToken);
      // final email = _sharedPrefs.readStorage(SpKeys.email);
      if (_userToken != null) {
        // Auto follow user if app is install from a dynamic link

        if (isOpening == false) {
          // await Future.delayed(const Duration(seconds: 1));
          if (deepLink.queryParameters['referral'] != '1') {
            try {
              print('masuk sini dynamic');
              followSender(Routing.navigatorKey.currentContext!);
            } catch (e) {
              'Error in followSender $e'.logger();
            }
          }
          deepLink.path.logger();
          final path = deepLink.path;
          isHomeScreen = false;
          'deepLink isOnHomeScreen $isHomeScreen'.logger();
          switch (path) {
            case Routes.storyDetail:
              '_handleDeepLink storyDetail'.logger();
              _routing.move(
                path,
                argument: StoryDetailScreenArgument()
                  ..postID = deepLink.queryParameters['postID']
                  ..backPage = false,
              );
              break;
            case Routes.vidDetail:
              '_handleDeepLink vidDetail'.logger();
              if (isFromSplash) {
                isFromSplash = false;
                _routing.moveAndRemoveUntil(Routes.lobby, Routes.lobby);
                Future.delayed(const Duration(seconds: 2), () async {
                  await _routing.move(
                    path,
                    argument: VidDetailScreenArgument(fromDeepLink: true)
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              } else {
                _routing.moveAndRemoveUntil(Routes.lobby, Routes.lobby);
                // Future.delayed(const Duration(seconds: 1), () async {
                _routing.move(
                  path,
                  argument: VidDetailScreenArgument(fromDeepLink: true)
                    ..postID = deepLink.queryParameters['postID']
                    ..backPage = false,
                );
                // });
              }

              break;
            case Routes.diaryDetail:
              '_handleDeepLink diaryDetail $isFromSplash'.logger();
              if (isFromSplash) {
                isFromSplash = false;
                Future.delayed(const Duration(seconds: 2), () async {
                  await _routing.move(
                    path,
                    argument: DiaryDetailScreenArgument(type: TypePlaylist.none)
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              } else {
                if (!isHomeScreen) {
                  // _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false, page: 0));
                }
                Future.delayed(const Duration(milliseconds: 500), () {
                  _routing.move(
                    path,
                    argument: DiaryDetailScreenArgument(type: TypePlaylist.none)
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              }

              break;
            case Routes.picDetail:
              '_handleDeepLink picDetail'.logger();
              if (isFromSplash) {
                isFromSplash = false;
                Future.delayed(const Duration(seconds: 2), () async {
                  await _routing.move(
                    path,
                    argument: PicDetailScreenArgument()
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              } else {
                // _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                Future.delayed(const Duration(milliseconds: 500), () {
                  _routing.move(
                    path,
                    argument: PicDetailScreenArgument()
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              }

              break;
            case Routes.picSlideDetailPreview:
              '_handleDeepLink picSlideDetailPreview'.logger();
              if (isFromSplash) {
                isFromSplash = false;
                Future.delayed(const Duration(seconds: 2), () async {
                  await _routing.move(
                    path,
                    argument: SlidedPicDetailScreenArgument(type: TypePlaylist.none)
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                  isFromSplash = false;
                });
              } else {
                // _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                Future.delayed(const Duration(milliseconds: 500), () {
                  _routing.move(
                    path,
                    argument: SlidedPicDetailScreenArgument(type: TypePlaylist.none)
                      ..postID = deepLink.queryParameters['postID']
                      ..backPage = false,
                  );
                });
              }

              break;
            // TO DO: If register from referral link, then hit to backend
            case Routes.otherProfile:
              '_handleDeepLink otherProfile'.logger();
              _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
              Future.delayed(const Duration(milliseconds: 500), () {
                _routing.move(
                  path,
                  argument: OtherProfileArgument()..senderEmail = deepLink.queryParameters['sender_email'],
                );
              });
              break;

            case Routes.chalengeDetail:
              '_handleDeepLink otherProfile'.logger();
              _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
              Future.delayed(const Duration(milliseconds: 500), () {
                _routing.move(
                  path,
                  argument: GeneralArgument()
                    ..id = deepLink.queryParameters['postID']
                    ..index = 1,
                );
              });
              break;
          }
          // SharedPreference().writeStorage(SpKeys.isPreventRoute, false);
          // Set [_linkProcessed] to true
          _linkProcessed = true;
          isOpening = false;
          '_handleDeepLink | deeplink: $deepLink'.logger();
        } else {
          '_handleDeepLink | userToken is null'.logger();
          '_handleDeepLink | deeplink: $deepLink'.logger();
        }
      }
    } else {
      'App open not from dynamic link'.logger();
    }
  }

  static Future followSender(BuildContext context) async {
    final _receiverParty = _pendingDynamicLinkData?.link.queryParameters['sender_email'];
    if (_sharedPrefs.readStorage(SpKeys.email) != _receiverParty) {
      try {
        if (_pendingDynamicLinkData?.link.queryParameters['referral'] == '1') {
          return;
        }

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

  static Future hitReferralBackend(BuildContext context) async {
    try {
      if (_pendingDynamicLinkData?.link.queryParameters['referral'] != '1') {
        return;
      }

      final _referralEmail = _pendingDynamicLinkData?.link.queryParameters['sender_email'];
      print('ini apa ya $_referralEmail');

      'Link | referralSender | receiverParty: $_referralEmail'.logger();
      String realDeviceID = await System().getDeviceIdentifier();

      if (_referralEmail != null) {
        final notifier = ReferralBloc();
        await notifier.referralUserBloc(
          context,
          withAlertConnection: false,
          data: ReferralUserArgument(email: _referralEmail, imei: realDeviceID != "" ? realDeviceID : _sharedPrefs.readStorage(SpKeys.fcmToken)),
        );
        final fetch = notifier.referralFetch;
        if (fetch.referralState == ReferralState.referralUserSuccess) {
          'referralUser | referralUserSuccess'.logger();
        } else {
          'referralUser | referralUserFailed'.logger();
        }
        _pendingDynamicLinkData = null;
      } else {
        'referralUser | _receiverParty is null'.logger();
      }
    } catch (e) {
      'referral user: ERROR: $e'.logger();
    }
  }

  static String getPendingReferralEmailDynamicLinks() {
    try {
      if (_pendingDynamicLinkData?.link.queryParameters['referral'] != '1') {
        return "";
      }

      // final _referralEmail = _pendingDynamicLinkData?.link.queryParameters['sender_email'];
      final _referralEmail = SharedPreference().readStorage(SpKeys.referralFrom);

      'Link | referralSender | _referralEmail: $_referralEmail'.logger();

      if (_referralEmail != null) {
        _pendingDynamicLinkData = null;
        return _referralEmail;
      } else {
        'referralUser | _referralEmail is null'.logger();
      }
    } catch (e) {
      'follow user: ERROR: $e'.logger();
    }
    return "";
  }
}

/**
 *  [hyppePicDetail] => pathSegments
    flutter: /hyppePicDetail => path
    flutter: userID=gy1Yz7nqs&postID=2FSjMJ_Qr&postType=pic => query
    flutter: {userID: gy1Yz7nqs, postID: 2FSjMJ_Qr, postType: pic} => queryParameters

    Map structure => userID=$userID&postID=$postID&postType=$postType
 */
