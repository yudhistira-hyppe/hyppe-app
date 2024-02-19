import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
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
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import '../../app.dart';
import '../bloc/posts_v2/bloc.dart';
import '../models/collection/posts/content_v2/content_data.dart';
import 'shared_preference.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
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
    print("======= masuk sini lagi dong");
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
    handleDeepLink(data);

    // Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink.listen(
      (event) {
        print("ini event handledeeplink 202020202 $event");
        // handle link that has been retrieved
        handleDeepLink(event);
      },
      onError: (e) {
        'Link Failed: ${e.toString()}'.logger();
      },
    );
  }

  Future<ContentData?> getDetailPost(BuildContext context, String postID, String visibility) async {
    try {
      // loadPic = true;
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(context, postID: postID, pageRows: 1, pageNumber: 1, type: FeatureType.diary, visibility: visibility);
      final fetch = notifier.postsFetch;

      final _res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();
      if (_res != null) {
        if (_res.isNotEmpty) {
          return _res.first;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      e.logger();
    } finally {
      // loadPic = false;
    }
    return null;
  }

  static void handleDeepLink(PendingDynamicLinkData? data) async {
    Uri? deepLink = data?.link;
    deepLink.logger();
    if (deepLink != null) {
      // Set [pendingDynamicLinkData] to the initial dynamic link
      _pendingDynamicLinkData ??= data;
      print("====--- $_pendingDynamicLinkData");
      _sharedPrefs.writeStorage(SpKeys.referralFrom, _pendingDynamicLinkData?.link.queryParameters['sender_email']);
      final userToken = _sharedPrefs.readStorage(SpKeys.userToken);
      // final email = _sharedPrefs.readStorage(SpKeys.email);
      if (userToken != null) {
        // Auto follow user if app is install from a dynamic link

        if (isOpening == false) {
          // await Future.delayed(const Duration(seconds: 1));
          print("======222222 email ${deepLink.queryParameters['referral']}");
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
            case Routes.showStories:
              '_handleDeepLink storyDetail'.logger();
              _routing.move(
                path,
                argument: StoryDetailScreenArgument(peopleIndex: 0)
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

                Future.delayed(const Duration(milliseconds: 500), () async {
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
              bool isRealGuest = false;
              if (deepLink.queryParameters['referral'] == '1') {
                print("-=-=-=-=-=-=-==-= masuk referral");


                final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
                if(isGuest ?? false){
                  isRealGuest = true;
                }else{
                  hitReferralBackend(Routing.navigatorKey.currentContext!, data: data);
                  followSender(Routing.navigatorKey.currentContext!);
                }
              }
              if (isFromSplash) {
                print("isFromSplash: $isFromSplash");
                _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                Future.delayed(const Duration(seconds: 2), () async {

                  if(isRealGuest){
                    ShowBottomSheet().onLoginApp(Routing.navigatorKey.currentContext!);
                  }else{
                    await _routing.move(
                      path,
                      argument: OtherProfileArgument()..senderEmail = deepLink.queryParameters['sender_email'],
                    );
                  }
                });
              } else {
                print("isFromSplash: $isFromSplash $isRealGuest");
                _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                Future.delayed(const Duration(milliseconds: 1000), () async {

                  if(isRealGuest){
                    ShowBottomSheet().onLoginApp(Routing.navigatorKey.currentContext!);
                  }else{
                    await _routing.move(
                      path,
                      argument: OtherProfileArgument()..senderEmail = deepLink.queryParameters['sender_email'],
                    );
                  }
                });
              }

              break;

            case Routes.chalengeDetail:
              '_handleDeepLink otherProfile'.logger();
              if (isFromSplash) {
                // _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                Future.delayed(const Duration(milliseconds: 2000), () {
                  _routing.move(
                    path,
                    argument: GeneralArgument()
                      ..id = deepLink.queryParameters['postID']
                      ..index = 0,
                  );
                });
              } else {
                Future.delayed(const Duration(milliseconds: 1000), () {
                  _routing.moveAndRemoveUntil(Routes.lobby, Routes.root, argument: MainArgument(canShowAds: false));
                  _routing.move(
                    path,
                    argument: GeneralArgument()
                      ..id = deepLink.queryParameters['postID']
                      ..index = 0,
                  );
                  _routing.moveReplacement(
                    path,
                    argument: GeneralArgument()
                      ..id = deepLink.queryParameters['postID']
                      ..index = 0,
                  );
                });
              }
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
    final receiverParty = _pendingDynamicLinkData?.link.queryParameters['sender_email'];
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    if (_sharedPrefs.readStorage(SpKeys.email) != receiverParty && !(isGuest ?? false)) {
      try {
        // if (_pendingDynamicLinkData?.link.queryParameters['referral'] == '1') {
        //   return;
        // }

        'Link | followSender | receiverParty: $receiverParty'.logger();

        if (receiverParty != null) {
          final notifier = FollowBloc();
          await notifier.followUserBlocV2(
            context,
            withAlertConnection: false,
            data: FollowUserArgument(
              receiverParty: receiverParty,
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

  static Future hitReferralBackend(BuildContext context, {PendingDynamicLinkData? data}) async {
    try {
      if (data != null) {
        _pendingDynamicLinkData = data;
      }
      print('ini apa ya $_pendingDynamicLinkData');
      if (_pendingDynamicLinkData?.link.queryParameters != null && _pendingDynamicLinkData?.link.queryParameters['referral'] != '1') {
        return;
      }

      final referralEmail = _pendingDynamicLinkData?.link.queryParameters['sender_email'];
      print('ini apa ya $referralEmail');

      'Link | referralSender | receiverParty: $referralEmail'.logger();
      String realDeviceID = await System().getDeviceIdentifier();

      if (referralEmail != null) {
        final notifier = ReferralBloc();
        await notifier.referralUserBloc(
          context,
          withAlertConnection: false,
          data: ReferralUserArgument(email: referralEmail, imei: realDeviceID != "" ? realDeviceID : _sharedPrefs.readStorage(SpKeys.fcmToken)),
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
      final referralEmail = SharedPreference().readStorage(SpKeys.referralFrom);

      'Link | referralSender | _referralEmail: $referralEmail'.logger();

      if (referralEmail != null) {
        _pendingDynamicLinkData = null;
        return referralEmail;
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
