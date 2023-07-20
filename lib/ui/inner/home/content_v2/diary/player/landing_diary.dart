import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../vid/widget/fullscreen/notifier.dart';

class LandingDiaryPage extends StatefulWidget {
  const LandingDiaryPage({Key? key}) : super(key: key);

  @override
  _LandingDiaryPageState createState() => _LandingDiaryPageState();
}

class _LandingDiaryPageState extends State<LandingDiaryPage> with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;

  int _loadingPercent = 0;
  int _currentPlayerState = 0;
  int _videoDuration = 1;
  int _currentPosition = 0;
  int _bufferPosition = 0;
  int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;

  String auth = '';
  String url = '';
  final Map _dataSourceMap = {};
  ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  String email = '';
  String statusKyc = '';

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LandingDiaryPage');
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);

    // stopwatch = new Stopwatch()..start();
    fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'DiaryLandingpage');

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
        // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      _initListener();
    });

    super.initState();
  }

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        setState(() {
          isPrepare = true;
          _showLoading = false;
        });
      });
      isPlay = true;
      dataSelected?.isDiaryPlay = true;
      _initAds(context);
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          setState(() {
            _showLoading = false;
            isPause = false;
          });
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      setState(() {
        _loadingPercent = 0;
        _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      _loadingPercent = percent;
      if (percent == 100) {
        _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      setState(() {
        _showLoading = false;
      });
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
        }
        // if (!_inSeek) {
        //   setState(() {
        //     _currentPositionText = extraValue ?? 0;
        //   });
        // }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        _bufferPosition = extraValue ?? 0;
        // if (mounted) {
        //   setState(() {});
        // }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      _showLoading = false;

      isPause = true;

      setState(() {
        _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      _showLoading = false;

      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });
    fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

    fAliplayer?.setOnThumbnailGetListener(
        onThumbnailGetSuccess: (bitmap, range, playerId) {
          // _thumbnailBitmap = bitmap;
          var provider = MemoryImage(bitmap);
          precacheImage(provider, context).then((_) {
            setState(() {});
          });
        },
        onThumbnailGetFail: (playerId) {});

    fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void start(ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    dataSelected = data;

    isPlay = false;
    dataSelected?.isDiaryPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    if (data.reportedStatus != 'BLURRED') {
      if (data.isApsara ?? false) {
        _playMode = ModeTypeAliPLayer.auth;
        await getAuth(data.apsaraId ?? '');
      } else {
        _playMode = ModeTypeAliPLayer.url;
        await getOldVideoUrl(data.postID ?? '');
      }
    }

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });
    // var configMap = {
    //   'mStartBufferDuration': GlobalSettings.mStartBufferDuration, // The buffer duration before playback. Unit: milliseconds.
    //   'mHighBufferDuration': GlobalSettings.mHighBufferDuration, // The duration of high buffer. Unit: milliseconds.
    //   'mMaxBufferDuration': GlobalSettings.mMaxBufferDuration, // The maximum buffer duration. Unit: milliseconds.
    //   'mMaxDelayTime': GlobalSettings.mMaxDelayTime, // The maximum latency of live streaming. Unit: milliseconds. You can specify the latency only for live streams.
    //   'mNetworkTimeout': GlobalSettings.mNetworkTimeout, // The network timeout period. Unit: milliseconds.
    //   'mNetworkRetryCount': GlobalSettings.mNetworkRetryCount, // The number of retires after a network timeout. Unit: milliseconds.
    //   'mEnableLocalCache': GlobalSettings.mEnableCacheConfig,
    //   'mLocalCacheDir': GlobalSettings.mDirController,
    //   'mClearFrameWhenStop': true
    // };
    // Configure the application.
    // fAliplayer?.setConfig(configMap);
    // var map = {
    //   "mMaxSizeMB": GlobalSettings.mMaxSizeMBController,

    //   /// The maximum space that can be occupied by the cache directory.
    //   "mMaxDurationS": GlobalSettings.mMaxDurationSController,

    //   /// The maximum cache duration of a single file.
    //   "mDir": GlobalSettings.mDirController,

    //   /// The cache directory.
    //   "mEnable": GlobalSettings.mEnableCacheConfig

    //   /// Specify whether to enable the cache feature.
    // };
    // fAliplayer?.setCacheConfig(map);
    if (data.reportedStatus == 'BLURRED') {
    } else {
      print("=====prepare=====");
      fAliplayer?.prepare();
    }

    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      isloading = true;
      _showLoading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: [DataSourceRelated.definitionList],
        );

        setState(() {
          isloading = false;
        });
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        fAliplayer?.setUrl(jsonMap['data']['url']);
        setState(() {
          isloading = false;
        });
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
    // _generatePlayConfigGen();
    // FlutterAliplayer.generatePlayerConfig().then((value) {
    //   fAliplayer?.setVidAuth(
    //       vid: "51b4d7a0adb771edbfb7442380ea0102",
    //       region: DataSourceRelated.regionKey,
    //       playAuth:
    //           "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNWJiSTg3d25xd1RocmFSYjBmVzAyb0ZkdVpicmJ6RXNqejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5MnZwaGxlU2lqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFVR3JNU3g0TXhQZ3dGc0ZMYkpNaUdnWG56dWM5UHFEc2lsenVodnpxK0VmNzdsdjFzZzRKcGx1NWhkdCtvR3FwNGQ1QUlWbDFDRTRBaVc3bFZZZGFGS2dpTml6US9TNGdMeGJaUW5vZ2lHUGdLUHJBSTZoeTVibFNvVWRxV0VOcnhqYUxnbEF3b2ttaStBNERLemJhY1ZKdVh1SmFlcEhSZFpJQWhuWXZMMzMiLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJENytSWlo1ek9xYUczMUZxczFjZVpjaVVVWXdhZWZMWHBsQ3dPYTY1b2xxRlVCTkVCQkpHQnJqKzJvQVNraHhXZFk5RlQ3UGF1S3RiUjIxZ3Z5dFFOd2lpdm1Vdlowbzl0K3ZoZHA5dmVTTT1cIixcIkNhbGxlclwiOlwiK3dSWk1ObW55NEhZR205ZTNqNVp5c2F0enZPRU10aGRadWx2czZKd3Nzdz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDctMDdUMDQ6NTU6MjNaXCIsXCJNZWRpYUlkXCI6XCI1MWI0ZDdhMGFkYjc3MWVkYmZiNzQ0MjM4MGVhMDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcInRvdEhOY1VqUTF5eHVtakVsZEZXbkJ1VUxoaz1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6IjUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyIiwiVGl0bGUiOiJlZDcyNDk5NC02Y2EzLTM0NGYtYmFlZi02N2Q4NTY1ZDNmMzQiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkLzUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyL3NuYXBzaG90cy83ZGI1YWQxMWQ5ZGI0MjEwYmJjZGZiODBhZGU0ZDIwYy0wMDAwMi5qcGciLCJEdXJhdGlvbiI6MjUuNDAzfSwiQWNjZXNzS2V5SWQiOiJTVFMuTlVuaHREc3MyMXR6bWFnN2pQeml3QnlvUCIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiI5R0xuV1BaZG50YTVOeDV1aTNaTGJkdVlpdDNkVUt3ckEyQUR4ZEFmaXMxWiIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    //       // definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
    //       playConfig: value);
    // });
  }

  // _generatePlayConfigGen() {
  //   FlutterAliplayer.createVidPlayerConfigGenerator();
  //   FlutterAliplayer.setPreviewTime(0);
  // }

  _initAds(BuildContext context) async {
    //for ads
    // getCountVid();
    // await _newInitAds(true);
    context.incrementAdsCount();
    if (context.getAdsCount() == null) {
      context.setAdsCount(0);
    } else {
      final adsNotifier = context.read<PreviewDiaryNotifier>();
      if (context.getAdsCount() == 2) {
        try {
          context.read<PreviewDiaryNotifier>().getAdsVideo(context, false);
        } catch (e) {
          'Failed to fetch ads data 0 : $e'.logger();
        }
      }
      if (context.getAdsCount() == 3 && adsNotifier.adsData != null) {
        fAliplayer?.pause();
        System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
          fAliplayer?.play();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    fAliplayer?.stop();
    // if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
    //   fAliplayer?.destroy();
    // }
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary");

    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext dari diary");
    fAliplayer?.play();

    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    fAliplayer?.pause();
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        fAliplayer?.pause();
        break;
      case AppLifecycleState.resumed:
        if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
          fAliplayer?.play();
        }
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        fAliplayer?.pause();
        break;
    }
  }

  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return Consumer2<PreviewDiaryNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
      return Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: notifier.itemCount == 0
                  ? const NoResultFound()
                  : NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        // controller: notifier.scrollController,
                        // scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: notifier.diaryData?.length,
                        padding: const EdgeInsets.symmetric(horizontal: 11.5),
                        itemBuilder: (context, index) {
                          if (notifier.diaryData == null || home.isLoadingDiary) {
                            fAliplayer?.pause();
                            _lastCurIndex = -1;
                            return CustomShimmer(
                              width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                              height: 168,
                              radius: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                            );
                          } else if (index == notifier.diaryData?.length && notifier.hasNext) {
                            return UnconstrainedBox(
                              child: Container(
                                alignment: Alignment.center,
                                width: 80 * SizeConfig.scaleDiagonal,
                                height: 80 * SizeConfig.scaleDiagonal,
                                child: const CustomLoading(),
                              ),
                            );
                          }
                          if (_curIdx == 0 && notifier.diaryData?[0].reportedStatus == 'BLURRED') {
                            isPlay = false;
                            fAliplayer?.stop();
                          }

                          return itemDiary(context, notifier, index, home);
                        },
                      ),
                    ),
            ),
            home.isLoadingLoadmore
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CustomLoading()),
                  )
                : Container(),
          ],
        ),
      );
    });
  }

  Widget itemDiary(BuildContext context,PreviewDiaryNotifier notifier, int index, HomeNotifier homeNotifier) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SelectableText("isApsara : ${notifier.diaryData?[index].isApsara}"),
              // SelectableText("post id : ${notifier.diaryData?[index].postID})"),
              // sixteenPx,
              // SelectableText((notifier.diaryData?[index].isApsara ?? false) ? (notifier.diaryData?[index].mediaThumbEndPoint ?? "") : "${notifier.diaryData?[index].fullThumbPath}"),
              // sixteenPx,
              // SelectableText((notifier.diaryData?[index].isApsara ?? false) ? (notifier.diaryData?[index].apsaraId ?? "") : "${UrlConstants.oldVideo + notifier.diaryData![index].postID!}"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ProfileLandingPage(
                      show: true,
                      // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
                      onFollow: () {},
                      following: true,
                      haveStory: false,
                      textColor: kHyppeTextLightPrimary,
                      username: notifier.diaryData?[index].username,
                      featureType: FeatureType.other,
                      // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                      isCelebrity: false,
                      imageUrl: '${System().showUserPicture(notifier.diaryData?[index].avatar?.mediaEndpoint)}',
                      onTapOnProfileImage: () => System().navigateToProfile(context, notifier.diaryData?[index].email ?? ''),
                      createdAt: '2022-02-02',
                      musicName: notifier.diaryData?[index].music?.musicTitle ?? '',
                      location: notifier.diaryData?[index].location ?? '',
                      isIdVerified: notifier.diaryData?[index].privacy?.isIdVerified,
                    ),
                  ),
                  if (notifier.diaryData?[index].email != email && (notifier.diaryData?[index].isNewFollowing ?? false))
                    Consumer<PreviewPicNotifier>(
                      builder: (context, picNot, child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (notifier.diaryData?[index].insight?.isloadingFollow != true) {
                              picNot.followUser(context, notifier.diaryData?[index] ?? ContentData(),
                                  isUnFollow: notifier.diaryData?[index].following, isloading: notifier.diaryData?[index].insight?.isloadingFollow ?? false);
                            }
                          },
                          child: notifier.diaryData?[index].insight?.isloadingFollow ?? false
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomLoading(),
                                  ),
                                )
                              : Text(
                                  (notifier.diaryData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                  style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      if (notifier.diaryData?[index].email != email) {
                        // FlutterAliplayer? fAliplayer
                        context.read<PreviewPicNotifier>().reportContent(context, notifier.diaryData?[index] ?? ContentData(), fAliplayer: fAliplayer);
                      } else {
                        fAliplayer?.setMuted(true);
                        fAliplayer?.pause();
                        ShowBottomSheet().onShowOptionContent(
                          context,
                          contentData: notifier.diaryData?[index] ?? ContentData(),
                          captionTitle: hyppeDiary,
                          onDetail: false,
                          isShare: notifier.diaryData?[index].isShared,
                          onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                          fAliplayer: fAliplayer,
                        );
                      }
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: kHyppeTextLightPrimary,
                    ),
                  ),
                ],
              ),
              tenPx,
              VisibilityDetector(
                key: Key(index.toString()),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction >= 0.6) {
                    _curIdx = index;
                    if (_lastCurIndex != _curIdx) {
                      fAliplayer?.stop();
                      Future.delayed(const Duration(milliseconds: 700), () {
                        start(notifier.diaryData?[index] ?? ContentData());
                        System().increaseViewCount2(context, notifier.diaryData?[index] ?? ContentData(), check: false).whenComplete(() async{
                          final count = context.getAdsCount();
                          if(count == 5){
                            final adsData = await context.getPopUpAds();
                            notifier.setAdsData(index, adsData);
                          }
                          context.incrementAdsCount();
                        });
                      });
                      if (notifier.diaryData?[index].certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                    }
                    _lastCurIndex = _curIdx;
                  }
                  if(info.visibleFraction > 0.5){
                    context.read<VideoNotifier>().currentPostID = '';
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.width * 16.0 / 10.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // color: Colors.yellow,
                  ),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      children: [
                        _curIdx == index
                            ? ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                child: AliPlayerView(
                                  onCreated: onViewPlayerCreated,
                                  x: 0,
                                  y: 0,
                                  height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                  width: MediaQuery.of(context).size.width,
                                  aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
                                ),
                              )
                            : Container(),
                        // _buildProgressBar(SizeConfig.screenWidth!, 500),
                        !notifier.connectionError
                            ? Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                    fAliplayer?.play();
                                    setState(() {
                                      isMute = !isMute;
                                    });
                                    fAliplayer?.setMuted(isMute);
                                  },
                                  onDoubleTap: () {
                                    final _likeNotifier = context.read<LikeNotifier>();
                                    if (notifier.diaryData?[index] != null) {
                                      _likeNotifier.likePost(context, notifier.diaryData?[index] ?? ContentData());
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    width: SizeConfig.screenWidth,
                                    height: SizeConfig.screenHeight,
                                  ),
                                ),
                              )
                            : Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                    homeNotifier.checkConnection();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                    width: SizeConfig.screenWidth,
                                    height: SizeConfig.screenHeight,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    child: notifier.diaryData?[index].reportedStatus == 'BLURRED'
                                        ? Container()
                                        : CustomTextWidget(
                                            textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                            maxLines: 3,
                                          ),
                                  ),
                                ),
                              ),
                        dataSelected?.postID == notifier.diaryData?[index].postID && isPlay
                            ? Container()
                            : CustomBaseCacheImage(
                                memCacheWidth: 100,
                                memCacheHeight: 100,
                                widthPlaceHolder: 80,
                                heightPlaceHolder: 80,
                                placeHolderWidget: Container(),
                                imageUrl: (notifier.diaryData?[index].isApsara ?? false) ? (notifier.diaryData?[index].mediaThumbEndPoint ?? "") : "${notifier.diaryData?[index].fullThumbPath}",
                                imageBuilder: (context, imageProvider) => notifier.diaryData?[index].reportedStatus == 'BLURRED'
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20), // Image border
                                        child: ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                          child: AspectRatio(
                                            aspectRatio: 9 / 16,
                                            child: Image(
                                              // width: SizeConfig.screenWidth,
                                              // height: MediaQuery.of(context).size.width * 16.0 / 11.0,
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                    : AspectRatio(
                                        aspectRatio: 9 / 16,
                                        child: Container(
                                          // const EdgeInsets.symmetric(horizontal: 4.5),
                                          // width: SizeConfig.screenWidth,
                                          // height: MediaQuery.of(context).size.width * 16.0 / 11.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                        ),
                                      ),
                                errorWidget: (context, url, error) {
                                  return GestureDetector(
                                    onTap: () {
                                      homeNotifier.checkConnection();
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                        width: SizeConfig.screenWidth,
                                        height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(20),
                                        child: CustomTextWidget(
                                          textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                          maxLines: 3,
                                        )),
                                  );
                                },
                                emptyWidget: GestureDetector(
                                  onTap: () {
                                    homeNotifier.checkConnection();
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                      width: SizeConfig.screenWidth,
                                      height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(20),
                                      child: CustomTextWidget(
                                        textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                        maxLines: 3,
                                      )),
                                ),
                              ),
                        _showLoading && !homeNotifier.connectionError
                            ? Positioned.fill(
                                child: Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              ))
                            : Container(),
                        _buildBody(context, SizeConfig.screenWidth, notifier.diaryData?[index] ?? ContentData()),
                        blurContentWidget(context, notifier.diaryData?[index] ?? ContentData()),
                      ],
                    ),
                  ),
                ),
              ),
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      (notifier.diaryData?[index].boosted.isEmpty ?? [].isEmpty) &&
                      (notifier.diaryData?[index].reportedStatus != 'OWNED' && notifier.diaryData?[index].reportedStatus != 'BLURRED' && notifier.diaryData?[index].reportedStatus2 != 'BLURRED') &&
                      notifier.diaryData?[index].email == email
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: notifier.diaryData?[index],
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              if (notifier.diaryData?[index].email == email && (notifier.diaryData?[index].boostCount ?? 0) >= 0 && (notifier.diaryData?[index].boosted.isNotEmpty ?? [].isEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kHyppeGreyLight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}reach.svg",
                        defaultColor: false,
                        height: 24,
                        color: kHyppeTextLightPrimary,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Text(
                          "${notifier.diaryData?[index].boostJangkauan ?? '0'} ${lang?.reach}",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                        ),
                      )
                    ],
                  ),
                ),
              Consumer<LikeNotifier>(
                builder: (context, likeNotifier, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Consumer<LikeNotifier>(
                            builder: (context, likeNotifier, child) => Align(
                              alignment: Alignment.bottomRight,
                              child: notifier.diaryData?[index].insight?.isloading ?? false
                                  ? const SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CircularProgressIndicator(
                                        color: kHyppePrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : InkWell(
                                      child: CustomIconWidget(
                                        defaultColor: false,
                                        color: (notifier.diaryData?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                        iconData: '${AssetPath.vectorPath}${(notifier.diaryData?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                        height: 28,
                                      ),
                                      onTap: () {
                                        if (notifier.diaryData?[index] != null) {
                                          likeNotifier.likePost(context, notifier.diaryData?[index] ?? ContentData());
                                        }
                                      },
                                    ),
                            ),
                          ),
                        ),
                        if (notifier.diaryData?[index].allowComments ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                Routing().move(Routes.commentsDetail,
                                    argument: CommentsArgument(postID: notifier.diaryData?[index].postID ?? '', fromFront: true, data: notifier.diaryData?[index] ?? ContentData()));
                              },
                              child: const CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}comment2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((notifier.diaryData?[index].isShared ?? false))
                          Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                context.read<DiariesPlaylistNotifier>().createdDynamicLink(context, data: notifier.diaryData?[index]);
                              },
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}share2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((notifier.diaryData?[index].saleAmount ?? 0) > 0 && email != notifier.diaryData?[index].email)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                fAliplayer?.pause();
                                await ShowBottomSheet.onBuyContent(context, data: notifier.diaryData?[index], fAliplayer: fAliplayer);
                                // fAliplayer?.play();
                              },
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: CustomIconWidget(
                                  defaultColor: false,
                                  color: kHyppeTextLightPrimary,
                                  iconData: '${AssetPath.vectorPath}cart.svg',
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    twelvePx,
                    Text(
                      "${notifier.diaryData?[index].insight?.likes}  ${lang?.like}",
                      style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
              twelvePx,
              CustomNewDescContent(
                // desc: "${data?.description}",
                username: notifier.diaryData?[index].username ?? '',
                desc: "${notifier.diaryData?[index].description}",
                trimLines: 3,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: () {
                  Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: notifier.diaryData?[index].postID ?? '', fromFront: true, data: notifier.diaryData?[index] ?? ContentData()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "${lang?.seeAll} ${notifier.diaryData?[index].comments} ${lang?.comment}",
                    style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                  ),
                ),
              ),
              (notifier.diaryData?[index].comment?.length ?? 0) > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (notifier.diaryData?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                        itemBuilder: (context, indexComment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CustomNewDescContent(
                              // desc: "${notifier.diaryData?[index]?.description}",
                              username: notifier.diaryData?[index].comment?[indexComment].userComment?.username ?? '',
                              desc: notifier.diaryData?[index].comment?[indexComment].txtMessages ?? '',
                              trimLines: 3,
                              textAlign: TextAlign.start,
                              seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                              seeMore: ' ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                              normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                              hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                              expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${System().readTimestamp(
                    DateTime.parse(System().dateTimeRemoveT(notifier.diaryData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}",
                  style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ],
          ),
        ),
        context.getAdsInBetween(notifier.diaryData?[index].adsData, notifier.diaryData?[index].postID ?? '', (info){
          fAliplayer?.stop();
        })
      ],
    );
  }

  _buildProgressBar(double width, double height) {
    if (_showLoading) {
      return Positioned(
        left: width / 2 - 20,
        top: height / 2 - 20,
        child: Column(
          children: [
            const CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "$_loadingPercent%",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned.fill(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PicTopItem(data: data),
          ),
          if (data.tagPeople?.isNotEmpty ?? false)
            Positioned(
              bottom: 18,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  fAliplayer?.pause();
                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, fAliplayer: fAliplayer);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMute = !isMute;
                });
                fAliplayer?.setMuted(isMute);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomIconWidget(
                  iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return data.reportedStatus == 'BLURRED'
        ? Positioned.fill(
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeDiary ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      // data.email == SharedPreference().readStorage(SpKeys.email)
                      //     ? GestureDetector(
                      //         onTap: () => Routing().move(Routes.appeal, argument: data),
                      //         child: Container(
                      //             padding: const EdgeInsets.all(8),
                      //             margin: const EdgeInsets.all(18),
                      //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                      //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      //       )
                      //     : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          data.reportedStatus = '';
                          start(data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppeDiary);
                          fAliplayer?.prepare();
                          fAliplayer?.play();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
                          margin: const EdgeInsets.only(bottom: 20, right: 8, left: 8),
                          width: SizeConfig.screenWidth,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            "${transnot.translate.see} HyppeDiary",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }
}
