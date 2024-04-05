import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/slided_vid_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/video_fullscreen_profile_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/widget/view_like.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../constant/widget/custom_text_widget.dart';

class ScrollVid extends StatefulWidget {
  final SlidedVidDetailScreenArgument? arguments;
  const ScrollVid({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<ScrollVid> createState() => _ScrollVidState();
}

class _ScrollVidState extends State<ScrollVid> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  FlutterAliplayer? fAliplayer;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;

  final bool _isLock = false;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = true;
  bool isloading = false;
  bool isPlayAds = false;
  bool isMute = false;
  bool scroolUp = false;
  bool afterUploading = false;
  bool _showTipsWidget = false;
  bool _showLoading = false;
  bool _inSeek = false;
  bool _thumbnailSuccess = false;
  bool isActivePage = true;
  bool onTapCtrl = false;
  bool isActiveAds = false;

  String auth = '';
  String email = '';
  String postIdVisibility = '';
  String postIdVisibilityTemp = '';
  String _curPostId = '';
  String _lastCurPostId = '';
  String _snapShotPath = '';
  String _savePath = '';
  String _tipsContent = '';

  double lastOffset = 0;

  int itemIndex = 0;
  int _videoDuration = 1;
  int _curIdx = -1;
  int _currentPlayerState = 0;
  int _loadingPercent = 0;
  int _currentPositionText = 0;
  int _currentPosition = 0;
  int _currentAdsPosition = 0;
  int _currentAdsPositionText = 0;
  final int _videoAdsDuration = 1;

  List<ContentData>? vidData = [];
  int indexVid = 0;
  // int _lastCurIndex = -1;
  int _cardIndex = 0;

  bool toComment = false;

  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;

  Map<int, FlutterAliplayer> dataAli = {};

  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    isStopVideo = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ScrollVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<ScrollVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    lang = context.read<TranslateNotifierV2>().translate;
    vidData = widget.arguments?.vidData;
    indexVid = widget.arguments!.page ?? 0;
    notifier.vidData = widget.arguments?.vidData;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (fAliplayer == null && fAliplayer?.getPlayerName().toString() != 'VideoProfileScroll') {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'VideoProfileScroll');
        initAlipayer();
      }
      print("============== widget argument ${widget.arguments!.vidData}");
      notifier.itemScrollController.jumpTo(index: widget.arguments!.page!);
      // notifier.checkConnection();
    });
    var index = 0;
    var lastIndex = 0;
    itemPositionsListener.itemPositions.addListener(() async {
      index = itemPositionsListener.itemPositions.value.first.index;
      if (lastIndex != index) {
        if (index == vidData!.length - 2) {
          bool connect = await System().checkConnections();
          if (connect) {
            print("ini reload harusnya");
            if (!notifier.isLoadingLoadmore) {
              await notifier.loadMore(context, _scrollController, widget.arguments!.pageSrc!, widget.arguments?.key ?? '');
              if (mounted) {
                setState(() {
                  vidData = notifier.vidData;
                });
              } else {
                vidData = notifier.vidData;
              }
            }
          } else {
            if (mounted) {
              ShowGeneralDialog.showToastAlert(
                context,
                lang?.internetConnectionLost ?? ' Error',
                () async {},
              );
            }
          }
        }
        lastIndex = index;
      }
    });
    checkInet();

    super.initState();
  }

  void checkInet() async {
    var inet = await System().checkConnections();
    if (!inet) {
      TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
      ShowGeneralDialog.showToastAlert(
        context,
        tn.translate.internetConnectionLost ?? ' Error',
        () async {
          Routing().moveBack();
        },
      );
    }
  }

  void _initListener() {
    try {
      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);

      if (Platform.isAndroid) {
        getExternalStorageDirectories().then((value) {
          if ((value?.length ?? 0) > 0) {
            _snapShotPath = value![0].path;
            return _snapShotPath;
          }
        });
        getExternalStorageDirectories().then((value) {
          if (value?.isNotEmpty ?? [].isEmpty) {
            _savePath = "${value![0].path}/localCache/";
            return Directory(_savePath);
          }
        }).then((value) {
          return value!.exists();
        }).then((value) {
          if (!value) {
            Directory directory = Directory(_savePath);
            directory.create();
          }
          return _savePath;
        }).then((value) {
          GlobalSettings.mDirController = _savePath;
        });
      } else if (Platform.isIOS) {
        _savePath = "localCache";
        GlobalSettings.mDirController = _savePath;
      }

      fAliplayer?.setOnEventReportParams((params, playerId) {
        print("EventReportParams=$params");
      });
      fAliplayer?.setOnPrepared((playerId) {
        // Fluttertoast.showToast(msg: "OnPrepared ");
        fAliplayer?.getPlayerName().then((value) => print("getPlayerName==$value"));
        fAliplayer?.getMediaInfo().then((value) {
          print("getMediaInfo==$value");
          _videoDuration = value['duration'];
          if (mounted) {
            setState(() {
              isPrepare = true;
            });
          } else {
            isPrepare = true;
          }
        });
        // isPlay = true;
        // isPause = false;
      });
      fAliplayer?.setOnRenderingStart((playerId) {});
      fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {
        print('video size changed');
        // configAliplayer();
      });
      fAliplayer?.setOnStateChanged((newState, playerId) {
        _currentPlayerState = newState;
        print("aliyun : onStateChanged $newState ${_currentPlayerState = newState}");
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            // Wakelock.enable();
            try {
              setState(() {
                isloading = false;
                _showTipsWidget = false;
                _showLoading = false;
                isPause = false;
                isPlay = true;
              });
            } catch (e) {
              print('error AVPStatus_AVPStatusStarted: $e');
            }

            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPaused:
            isPause = true;
            // Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusStopped:
            isPlay = false;
            _showLoading = false;
            try {
              // Wakelock.disable();
              if (mounted) {
                setState(() {});
              }
            } catch (e) {
              e.logger();
            }

            break;
          case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
            // Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            // Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPrepared:
            // Wakelock.enable();
            try {
              if (mounted) {
                setState(() {
                  _showLoading = true;
                });
              } else {
                _showLoading = true;
              }
            } catch (e) {
              e.logger();
            }
            break;
          default:
        }
      });
      fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
        if (mounted) {
          try {
            setState(() {
              _loadingPercent = 0;
              _showLoading = true;
            });
          } catch (e) {
            print('error setOnLoadingStatusListener: $e');
          }
        }
      }, loadingProgress: (percent, netSpeed, playerId) {
        if (percent == 100) {
          _showLoading = false;
        }
        try {
          if (mounted) {
            setState(() {
              _loadingPercent = percent;
            });
          } else {
            _loadingPercent = percent;
          }
        } catch (e) {
          print('error loadingProgress: $e');
        }
      }, loadingEnd: (playerId) {
        try {
          if (mounted) {
            setState(() {
              _showLoading = false;
            });
          } else {
            _showLoading = false;
          }
        } catch (e) {
          print('error loadingEnd: $e');
        }
      });
      fAliplayer?.setOnSeekComplete((playerId) {
        _inSeek = false;
      });
      fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
        if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
          if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
            _currentPosition = extraValue ?? 0;
          }
          if (!_inSeek) {
            try {
              if (mounted) {
                setState(() {
                  _currentPositionText = extraValue ?? 0;
                });
              } else {
                _currentPositionText = extraValue ?? 0;
              }
            } catch (e) {
              print('error setOnInfo: $e');
            }
          }
        } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
          // _bufferPosition = extraValue ?? 0;
          if (mounted) {
            // setState(() {});
          }
        } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
          // Fluttertoast.showToast(msg: "AutoPlay");
        } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
          // Fluttertoast.showToast(msg: "Cache Success");
        } else if (infoCode == FlutterAvpdef.CACHEERROR) {
          // Fluttertoast.showToast(msg: "Cache Error $extraMsg");
        } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
          // Fluttertoast.showToast(msg: "Looping Start");
        } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
          // Fluttertoast.showToast(msg: "change to soft ware decoder");
          // mOptionsFragment.switchHardwareDecoder();
        }
      });
      fAliplayer?.setOnCompletion((playerId) {
        _showTipsWidget = true;
        _showLoading = false;
        _tipsContent = "Play Again";
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
        _showTipsWidget = true;
        _showLoading = false;
        _tipsContent = "$errorCode \n $errorMsg";
        setState(() {});
      });

      fAliplayer?.setOnTrackChanged((value, playerId) {
        AVPTrackInfo info = AVPTrackInfo.fromJson(value);
        if ((info.trackDefinition?.length ?? 0) > 0) {
          // trackFragmentKey.currentState.onTrackChanged(info);
          // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
        }
      });

      fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {
        _thumbnailSuccess = true;
      }, preparedFail: (playerId) {
        _thumbnailSuccess = false;
      });

      fAliplayer?.setOnThumbnailGetListener(
          onThumbnailGetSuccess: (bitmap, range, playerId) {
            // _thumbnailBitmap = bitmap;
            var provider = MemoryImage(bitmap);
            precacheImage(provider, context).then((_) {
              setState(() {
                // _imageProvider = provider;
              });
            });
          },
          onThumbnailGetFail: (playerId) {});

      fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
        if (mounted) {
          setState(() {
            // extSubTitleText = '';
          });
        }
      });

      fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
        if (mounted) {
          setState(() {
            // extSubTitleText = subtitle;
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void vidConfig() {
    var configMap = {
      'mStartBufferDuration': GlobalSettings.mStartBufferDuration, // The buffer duration before playback. Unit: milliseconds.
      'mHighBufferDuration': GlobalSettings.mHighBufferDuration, // The duration of high buffer. Unit: milliseconds.
      'mMaxBufferDuration': GlobalSettings.mMaxBufferDuration, // The maximum buffer duration. Unit: milliseconds.
      'mMaxDelayTime': GlobalSettings.mMaxDelayTime, // The maximum latency of live streaming. Unit: milliseconds. You can specify the latency only for live streams.
      'mNetworkTimeout': GlobalSettings.mNetworkTimeout, // The network timeout period. Unit: milliseconds.
      'mNetworkRetryCount': GlobalSettings.mNetworkRetryCount, // The number of retires after a network timeout. Unit: milliseconds.
      'mEnableLocalCache': GlobalSettings.mEnableCacheConfig,
      'mLocalCacheDir': GlobalSettings.mDirController,
      'mClearFrameWhenStop': true
    };
    // Configure the application.
    fAliplayer?.setConfig(configMap);
    var map = {
      "mMaxSizeMB": GlobalSettings.mMaxSizeMBController,

      /// The maximum space that can be occupied by the cache directory.
      "mMaxDurationS": GlobalSettings.mMaxDurationSController,

      /// The maximum cache duration of a single file.
      "mDir": GlobalSettings.mDirController,

      /// The cache directory.
      "mEnable": GlobalSettings.mEnableCacheConfig

      /// Specify whether to enable the cache feature.
    };
    fAliplayer?.setCacheConfig(map);
  }

  initAlipayer() {
    globalAliPlayer = fAliplayer;
    vidConfig();
    fAliplayer?.pause();
    fAliplayer?.setAutoPlay(true);

    // fAliplayer?.setLoop(true);
    fAliplayer?.setMuted(isMute);

    //Turn on mix mode
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(true);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
    }

    //set player
    fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
    fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    _initListener();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer?.destroy();
    isStopVideo = false;
    try {
      // final notifier = context.read<ScrollVidNotifier>();
      // notifier.pageController.dispose();
    } catch (e) {
      e.logger();
    }
    CustomRouteObserver.routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary");
    isStopVideo = false;
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    ScrollVidNotifier notifier = context.read<ScrollVidNotifier>();
    if (indexVid == (notifier.vidData?.length ?? 0)) {
      setState(() {
        indexVid = _curIdx - 1;
        print("=-=-=-=-=-  $indexVid =-==-=-=-=-=-=");
      });
    }
    // final notifier = context.read<ScrollVidNotifier>();
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.play();
    }

    // System().disposeBlock();
    if (toComment) {
      ScrollVidNotifier notifier = context.read<ScrollVidNotifier>();
      setState(() {
        vidData = notifier.vidData;
        toComment = false;
      });
    }

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    // final notifier = context.read<ScrollVidNotifier>();
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.pause();
    }

    super.didPushNext();
  }

  ScrollVidNotifier getNotifier(BuildContext context) {
    return context.read<ScrollVidNotifier>();
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      // setState(() {});
    });
  }

  Future start(BuildContext context, ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    isPrepare = false;
    fAliplayer?.stop();
    fAliplayer?.clearScreen();

    setState(() {
      isloading = true;
      dataSelected = data;
      isPlay = false;
    });
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    print("===== --- hit blur status ${data.reportedStatus}");
    // if (data.reportedStatus != 'BLURRED') {
    if (data.isApsara ?? false) {
      // _playMode = ModeTypeAliPLayer.auth;
      await getAuth(data.apsaraId ?? '');
    } else {
      // _playMode = ModeTypeAliPLayer.url;
      await getOldVideoUrl(data.postID ?? '');
    }
    // }
    if (mounted) {
      setState(() {
        isPause = false;
        // _isFirstRenderShow = false;
      });
    }

    if (data.reportedStatus == 'BLURRED') {
    } else {
      if (isActivePage) {
        print("=====prepare=====");
        fAliplayer?.prepare();
        fAliplayer?.play();
      }
    }

    // this syntax below to prevent video play after changing video
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (context.read<MainNotifier>().isInactiveState) {
    //     fAliplayer?.pause();
    //   }
    // });

    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    try {
      final fixContext = Routing.navigatorKey.currentContext;

      _showLoading = true;
      if (mounted) {
        setState(() {});
      }
      final notifier = PostsBloc();
      await notifier.getAuthApsara(fixContext ?? context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        print("==auth == $auth");

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: [DataSourceRelated.definitionList],
        );
      }
    } catch (e) {
      isloading = false;
      if (mounted) {
        setState(() {});
      }
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId) async {
    if (mounted) {
      setState(() {
        isloading = true;
      });
    }
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        fAliplayer?.setUrl(jsonMap['data']['url']);
        if (mounted) {
          setState(() {
            // isloading = false;
          });
        }
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future<VideoIndicator> navigateTo(List<ContentData>? vidData, int changevalue, int index) async {
    return await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => VideoFullProfilescreenPage(
            vidData: vidData,
            enableWakelock: true,
            pageSrc: widget.arguments?.pageSrc ?? PageSrc.selfProfile,
            thumbnail: (dataSelected?.isApsara ?? false) ? (dataSelected?.mediaThumbEndPoint ?? '') : '${dataSelected?.fullThumbPath}',
            onClose: () {
              setState(() {
                isPlay = true;
              });
            },
            slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, dataSelected ?? ContentData()),
            videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
            index: index,
            loadMoreFunction: () {
              // widget.loadMoreFunction?.call();
            },
            isAutoPlay: true,
            isLanding: true),
        settings: const RouteSettings(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<ScrollVidNotifier>();
    // final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    // final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Scaffold(
      backgroundColor: kHyppeLightSurface,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, '$_cardIndex');
          return false;
        },
        child: Consumer3<ScrollVidNotifier, TranslateNotifierV2, HomeNotifier>(
          builder: (_, vidNotifier, translateNotifier, homeNotifier, __) => SafeArea(
            child: SizedBox(
              child: Column(
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(transform: Matrix4.translationValues(-18.0, 0.0, 0.0), margin: const EdgeInsets.symmetric(horizontal: 10), child: widget.arguments?.titleAppbar ?? Container()),
                        if (vidData?.isNotEmpty ?? false)
                          if (vidData?[indexVid].email != email && (vidData?[indexVid].isNewFollowing ?? false) && (widget.arguments?.isProfile ?? false))
                            Consumer<PreviewPicNotifier>(
                              builder: (context, picNot, child) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context.handleActionIsGuest(() {
                                      if (vidData?[indexVid].insight?.isloadingFollow != true) {
                                        picNot.followUser(context, vidData![indexVid], isUnFollow: vidData?[indexVid].following, isloading: vidData?[indexVid].insight!.isloadingFollow ?? false);
                                      }
                                    });
                                  },
                                  child: vidData?[indexVid].insight?.isloadingFollow ?? false
                                      ? const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Center(
                                            child: CustomLoading(),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              (vidData?[indexVid].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                              style: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                      ],
                    ),
                    leading: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: kHyppeTextLightPrimary,
                        ),
                        onPressed: () {
                          Navigator.pop(context, '$_cardIndex');
                        }),
                  ),
                  Expanded(
                    child: (vidData?.isEmpty ?? true)
                        ? const NoResultFound()
                        : RefreshIndicator(
                            onRefresh: () async {
                              bool connect = await System().checkConnections();
                              if (connect) {
                                setState(() {
                                  isloading = true;
                                });
                                await vidNotifier.reload(context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                                setState(() {
                                  vidData = vidNotifier.vidData;
                                });
                              } else {
                                if (mounted) {
                                  ShowGeneralDialog.showToastAlert(
                                    context,
                                    lang?.internetConnectionLost ?? ' Error',
                                    () async {},
                                  );
                                }
                              }
                            },
                            child: NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return false;
                              },
                              child: ScrollablePositionedList.builder(
                                itemScrollController: vidNotifier.itemScrollController,
                                itemPositionsListener: itemPositionsListener,
                                scrollOffsetController: scrollOffsetController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: false,
                                padding: const EdgeInsets.symmetric(horizontal: 11.5),
                                itemCount: vidData?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  if (vidData == null || homeNotifier.isLoadingVid) {
                                    vidData?[index].fAliplayer?.pause();
                                    // _lastCurIndex = -1;
                                    return CustomShimmer(
                                      margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
                                      height: context.getHeight() / 8,
                                      width: double.infinity,
                                    );
                                  } else if (index == vidData?.length) {
                                    return const CustomLoading(size: 5);
                                  }
                                  // if (_curIdx == 0 && vidData?[0].reportedStatus == 'BLURRED') {
                                  //   isPlay = false;
                                  //   vidData?[index].fAliplayer?.stop();
                                  // }
                                  // final vidData = vidData?[index];

                                  return itemVid(vidNotifier, index);
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemVid(ScrollVidNotifier notifier, int index) {
    var map = {
      DataSourceRelated.vidKey: vidData?[index].apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(
            top: 18,
            left: 6,
            right: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      username: '${vidData?[index].username}',
                      featureType: FeatureType.other,
                      // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                      isCelebrity: false,
                      imageUrl: '${System().showUserPicture(vidData?[index].avatar?.mediaEndpoint)}',
                      onTapOnProfileImage: () => System().navigateToProfile(context, vidData?[index].email ?? ''),
                      createdAt: '2022-02-02',
                      musicName: vidData?[index].music?.musicTitle ?? '',
                      location: vidData?[index].location ?? '',
                      isIdVerified: vidData?[index].privacy?.isIdVerified,
                      badge: vidData?[index].urluserBadge,
                    ),
                  ),
                  if (vidData?[index].email != email && (vidData?[index].isNewFollowing ?? false) && !(widget.arguments?.isProfile ?? false))
                    Consumer<PreviewPicNotifier>(
                      builder: (context, picNot, child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            context.handleActionIsGuest(() {
                              if (vidData?[index].insight?.isloadingFollow != true) {
                                picNot.followUser(context, vidData![index], isUnFollow: vidData?[index].following, isloading: vidData?[index].insight!.isloadingFollow ?? false);
                              }
                            });
                          },
                          child: vidData?[index].insight?.isloadingFollow ?? false
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomLoading(),
                                  ),
                                )
                              : Text(
                                  (vidData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                  style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      context.handleActionIsGuest(() async {
                        fAliplayer?.pause();
                        if (vidData?[index].email != email) {
                          // FlutterAliplayer? fAliplayer
                          context.read<PreviewPicNotifier>().reportContent(context, vidData?[index] ?? ContentData(), fAliplayer: vidData?[index].fAliplayer, onCompleted: () async {
                            bool connect = await System().checkConnections();
                            if (connect) {
                              setState(() {
                                isloading = true;
                              });
                              await notifier.reload(Routing.navigatorKey.currentContext ?? context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                              setState(() {
                                vidData = notifier.vidData;
                              });
                              fAliplayer?.play();
                            } else {
                              if (mounted) {
                                ShowGeneralDialog.showToastAlert(
                                  context,
                                  lang?.internetConnectionLost ?? ' Error',
                                  () async {},
                                );
                              }
                            }
                          });
                        } else {
                          if (_curIdx != -1) {
                            print('Vid Landing Page: pause $_curIdx');
                            vidData?[_curIdx].fAliplayer?.pause();
                          }

                          await ShowBottomSheet().onShowOptionContent(
                            context,
                            contentData: vidData?[index] ?? ContentData(),
                            captionTitle: hyppeVid,
                            onDetail: false,
                            isShare: vidData?[index].isShared,
                            onUpdate: () {
                              if (index == (vidData?.length ?? 0 - 1)) {
                                setState(() {
                                  indexVid = index - 1;
                                });
                              }
                              setState(() {});
                              context.read<HomeNotifier>().onUpdate();
                            },
                            fAliplayer: vidData?[index].fAliplayer,
                          );
                          vidData?[index].fAliplayer?.pause();
                          fAliplayer?.play();
                        }
                      });
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
                key: Key(vidData?[index].postID ?? index.toString()),
                onVisibilityChanged: (info) {
                  print("visibleFraction: ${info.visibleFraction}");
                  if (info.visibleFraction >= 0.6) {
                    _cardIndex = index;
                    if (_curIdx != index) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        fAliplayer?.pause();
                        try {
                          widget.arguments?.scrollController?.jumpTo(System().scrollAuto(_cardIndex, widget.arguments?.heightTopProfile ?? 0, widget.arguments?.heightBox?.toInt() ?? 100));
                        } catch (e) {
                          print("ini error $e");
                        }
                        try {
                          if (_curIdx != -1) {
                            print('Vid Landing Page: pause $_curIdx ${vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                            if (vidData?[_curIdx].fAliplayer != null) {
                              vidData?[_curIdx].fAliplayer?.pause();
                            } else {
                              dataAli[_curIdx]?.pause();
                            }

                            // vidData?[_curIdx].fAliplayerAds?.pause();
                            // setState(() {
                            //   _curIdx = -1;
                            // });
                          }
                        } catch (e) {
                          e.logger();
                        }
                        // System().increaseViewCount2(context, vidData);
                      });
                      if (vidData?[index].certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                    }
                  }
                },
                child: (vidData?[index].reportedStatus == 'BLURRED')
                    ? blurContentWidget(context, vidData![index])
                    : !notifier.connectionError
                        ? postIdVisibility != (vidData?[index].postID ?? '')
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    postIdVisibility = vidData?[index].postID ?? '';
                                    fAliplayer?.stop();
                                    fAliplayer?.clearScreen();
                                    start(context, vidData?[index] ?? ContentData());
                                  });
                                  var vidNotifier = context.read<PreviewVidNotifier>();
                                  double position = 0.0;
                                  for (var i = 0; i < index; i++) {
                                    position += vidNotifier.vidData?[i].height ?? 0.0;
                                  }
                                  // widget.scrollController?.animateTo(
                                  //   position,
                                  //   duration: const Duration(milliseconds: 700),
                                  //   curve: Curves.easeOut,
                                  // );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                      width: MediaQuery.of(context).size.width,
                                      child: VideoThumbnail(
                                        videoData: vidData?[index],
                                        onDetail: false,
                                        fn: () {},
                                        withMargin: true,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      child: SizedBox(
                                          // color: Colors.red,
                                          width: MediaQuery.of(context).size.width,
                                          // height: MediaQuery.of(context).size.height,
                                          child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, vidData?[index] ?? ContentData()))),
                                    ),
                                    //Show Button Play
                                    if (dataSelected != vidData?[index])
                                      Center(
                                          child: Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                          width: MediaQuery.of(context).size.width,
                                          child: const CustomIconWidget(
                                            defaultColor: false,
                                            width: 40,
                                            iconData: '${AssetPath.vectorPath}pause2.svg',
                                            // color: kHyppeLightButtonText,
                                          ),
                                        ),
                                      ))
                                    //     : Container(),
                                  ],
                                ),
                              )
                            : videoPlayerWidget(notifier, vidData?[index] ?? ContentData(), index)
                        : GestureDetector(
                            onTap: () {
                              notifier.checkConnection();
                            },
                            child: Container(
                                decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                width: SizeConfig.screenWidth,
                                height: 250,
                                alignment: Alignment.center,
                                child: CustomTextWidget(textToDisplay: lang?.couldntLoadVideo ?? 'Error')),
                          ),
              ),
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      (vidData![index].boosted.isEmpty) &&
                      (vidData?[index].reportedStatus != 'OWNED' && vidData?[index].reportedStatus != 'BLURRED' && vidData?[index].reportedStatus2 != 'BLURRED') &&
                      vidData?[index].email == email
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: vidData?[index] ?? ContentData(),
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              vidData?[index].email == SharedPreference().readStorage(SpKeys.email) && (vidData?[index].reportedStatus == 'OWNED' || vidData?[index].reportedStatus == 'OWNED')
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 11.0),
                      child: ContentViolationWidget(
                        data: vidData?[index] ?? ContentData(),
                        text: lang?.thisHyppeVidisSubjectToModeration ?? '',
                      ),
                    )
                  : Container(),
              if (vidData?[index].email == email && (vidData?[index].boostCount ?? 0) >= 0 && (vidData?[index].boosted.isNotEmpty ?? [].isEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
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
                          "${vidData?[index].boostJangkauan ?? '0'} ${lang?.reach}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                        Consumer<LikeNotifier>(
                          builder: (context, likeNotifier, child) => Align(
                            alignment: Alignment.bottomRight,
                            child: vidData?[index].insight?.isloading ?? false
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
                                      color: (vidData?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                      iconData: '${AssetPath.vectorPath}${(vidData?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                      height: 28,
                                    ),
                                    onTap: () {
                                      if (vidData != null) {
                                        likeNotifier.likePost(context, vidData?[index] ?? ContentData()).then((value) {
                                          List<ContentData>? vidData = context.read<PreviewVidNotifier>().vidData;
                                          int idx = vidData!.indexWhere((e) => e.postID == value['_id']);
                                          vidData[idx].insight?.isPostLiked = value['isPostLiked'];
                                          vidData[idx].insight?.likes = value['likes'];
                                          vidData[idx].isLiked = value['isLiked'];
                                        });
                                      }
                                    },
                                  ),
                          ),
                        ),
                        if (vidData?[index].allowComments ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                toComment = true;
                                Routing().move(Routes.commentsDetail,
                                    argument: CommentsArgument(
                                      postID: vidData?[index].postID ?? '',
                                      fromFront: true,
                                      data: vidData?[index] ?? ContentData(),
                                      pageDetail: true,
                                    ));
                              },
                              child: const CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}comment2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((vidData?[index].isShared ?? false))
                          Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                context.read<VidDetailNotifier>().createdDynamicLink(context, data: vidData?[index] ?? ContentData());
                              },
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}share2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((vidData?[index].saleAmount ?? 0) > 0 && email != vidData?[index].email)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await context.handleActionIsGuest(() async {
                                  vidData?[index].fAliplayer?.pause();
                                  await ShowBottomSheet.onBuyContent(context, data: vidData?[index] ?? ContentData(), fAliplayer: vidData?[index].fAliplayer);
                                });
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
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "${vidData?[index].insight?.likes} ${lang!.like}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: vidData?[index].postID ?? '',
                                          eventType: 'LIKE',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const TextSpan(
                          text: " • ",
                          style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        TextSpan(
                          text: "${vidData?[index].insight!.views?.getCountShort()} ${lang!.views}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: vidData?[index].postID ?? '',
                                          eventType: 'VIEW',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              twelvePx,
              CustomNewDescContent(
                email: vidData?[index].email ?? '',
                username: vidData?[index].username ?? '',
                desc: "${vidData?[index].description}",
                trimLines: 2,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.less}',
                seeMore: ' ${lang?.more}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppePrimary),
                expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (vidData?[index].allowComments ?? true)
                GestureDetector(
                  onTap: () {
                    toComment = true;
                    Routing().move(Routes.commentsDetail,
                        argument: CommentsArgument(
                          postID: vidData?[index].postID ?? '',
                          fromFront: true,
                          data: vidData?[index] ?? ContentData(),
                          pageDetail: true,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${lang?.seeAll} ${vidData?[index].comments} ${lang?.comment}",
                      style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                    ),
                  ),
                ),
              (vidData?[index].comment?.length ?? 0) > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (vidData?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                        itemBuilder: (context, indexComment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CustomNewDescContent(
                              // desc: "${vidData?.description}",
                              email: vidData?[index].email ?? '',
                              username: vidData?[index].comment?[indexComment].userComment?.username ?? '',
                              desc: vidData?[index].comment?[indexComment].txtMessages ?? '',
                              trimLines: 2,
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
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${System().readTimestamp(
                    DateTime.parse(System().dateTimeRemoveT(vidData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}",
                  style: TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ],
          ),
        ),
        vidData?.length == index && notifier.isLoadingLoadmore
            ? const SizedBox(
                height: 50,
                child: CustomLoading(),
              )
            : Container(),
      ],
    );
  }

  Widget videoPlayerWidget(ScrollVidNotifier vidNotifier, ContentData data, int index) {
    return GestureDetector(
      onTap: () async {
        if (isPlay) print('page fullscreen $isPause $isPlay');
        setState(() {
          onTapCtrl = true;
        });

        int changevalue;
        changevalue = _currentPosition + 1000;
        if (changevalue > _videoDuration) {
          changevalue = _videoDuration;
        }

        "=============== pause 3".logger();
        // fAliplayer?.pause();
        // setState(() {
        //   isloading = true;
        // });
        if (!isPlay) {
          fAliplayer?.play();
          setState(() {
            isPause = false;
          });
        } else {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          if ((data.metadata?.height ?? 0) < (data.metadata?.width ?? 0)) {
            print('Landscape VidPlayerPage');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            print('Portrait VidPlayerPage');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          }

          fAliplayer?.pause();
          VideoIndicator value = await navigateTo(vidNotifier.vidData, changevalue, index);

          if (mounted) {
            if (_curIdx != vidNotifier.lastScrollIndex) {
              vidNotifier.itemScrollController.jumpTo(index: vidNotifier.lastScrollIndex);
              // fAliplayer?.stop();
              postIdVisibility = vidNotifier.vidData?[vidNotifier.lastScrollIndex].postID ?? '';
              await start(context, vidNotifier.vidData?[vidNotifier.lastScrollIndex] ?? ContentData());
            }
            setState(() {
              _videoDuration = value.videoDuration ?? 0;
              _currentPosition = value.seekValue ?? 0;
              _currentPositionText = value.positionText ?? 0;
              _showTipsWidget = value.showTipsWidget ?? false;
              isMute = value.isMute ?? false;
              isPlay = !_showTipsWidget;
            });
          } else {
            _videoDuration = value.videoDuration ?? 0;
            _currentPosition = value.seekValue ?? 0;
            _currentPositionText = value.positionText ?? 0;
            _showTipsWidget = value.showTipsWidget ?? false;
            isMute = value.isMute ?? false;
            isPlay = !_showTipsWidget;
          }

          if (_currentPosition > 0) {
            fAliplayer?.seekTo(_currentPosition.ceil(), FlutterAvpdef.ACCURATE);
          }
          fAliplayer?.play();

          // int changevalue;
          // changevalue = _currentPosition + 1000;
          // if (changevalue > _videoDuration) {
          //   changevalue = _videoDuration;
          // }
        }
      },
      onDoubleTap: () {
        final likeNotifier = context.read<LikeNotifier>();
        likeNotifier.likePost(context, data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: AspectRatio(
            aspectRatio: 19 / 10,
            child: Stack(
              children: [
                AliPlayerView(
                  onCreated: onViewPlayerCreated,
                  x: 0,
                  y: 0,
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  aliPlayerViewType: AliPlayerViewTypeForAndroid.textureview,
                ),
                if (!isPlay)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                    width: MediaQuery.of(context).size.width,
                    child: VideoThumbnail(
                      videoData: data,
                      onDetail: false,
                      fn: () {},
                      withMargin: true,
                    ),
                  ),
                if (isloading)
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: kHyppePrimary,
                      ),
                    ),
                  ),
                _buildProgressBar(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                if (isPlay)
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, data))),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildController(
                      Colors.transparent,
                      Colors.white,
                      120,
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * 0.8,
                      data,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget(BuildContext context, ContentData data) {
    return isPause
        ? AnimatedOpacity(
            // opacity: onTapCtrl || isPause ? 1.0 : 0.0,
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            onEnd: _onPlayerHide,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sixPx,
                  if (onTapCtrl || isPause)
                    if (data.tagPeople?.isNotEmpty ?? false)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                fAliplayer?.pause();
                                context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, title: lang!.inThisVideo, fAliplayer: fAliplayer);
                              },
                              child: const CustomIconWidget(
                                iconData: '${AssetPath.vectorPath}tag-people-light.svg',
                                defaultColor: false,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                  _currentPosition <= 0
                      ? Container()
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            System.getTimeformatByMs(isActiveAds ? _currentAdsPositionText : _currentPositionText),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                ],
              ),
            )))
        : AnimatedOpacity(
            opacity: onTapCtrl || isPause ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: _currentPosition <= 0
                  ? Container()
                  : Container(
                      // decoration: orientation == Orientation.portrait
                      // ?
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          end: const Alignment(0.0, -1),
                          begin: const Alignment(0.0, 1),
                          colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
                        ),
                      ),
                      // : null,
                      child: Stack(
                        children: [
                          // if (!widget.fromFullScreen)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sixPx,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            '${System.getTimeformatByMs(isActiveAds ? _currentAdsPositionText : _currentPositionText)} / ${System.getTimeformatByMs(isActiveAds ? _videoAdsDuration : _videoDuration)}',
                                            style: const TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                        )),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isMute = !isMute;
                                        });
                                        fAliplayer?.setMuted(isMute);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 2.0),
                                        child: CustomIconWidget(
                                          iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                                          defaultColor: false,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    overlayShape: SliderComponentShape.noThumb,
                                    activeTrackColor: const Color(0xAA7d7d7d),
                                    inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                                    trackHeight: 3.0,
                                    thumbColor: Colors.purple,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                  ),
                                  child: Slider(
                                      min: 0,
                                      max: isActiveAds
                                          ? _videoAdsDuration == 0
                                              ? 1
                                              : _videoAdsDuration.toDouble()
                                          : _videoDuration == 0
                                              ? 1
                                              : _videoDuration.toDouble(),
                                      value: isActiveAds ? _currentAdsPosition.toDouble() : _currentPosition.toDouble(),
                                      activeColor: Colors.purple,
                                      thumbColor: Colors.purple,
                                      onChangeStart: (value) {
                                        _inSeek = true;
                                        _showLoading = false;
                                        setState(() {});
                                      },
                                      onChangeEnd: (value) {
                                        _inSeek = false;
                                        setState(() {
                                          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
                                            setState(() {
                                              _showTipsWidget = false;
                                            });
                                          }
                                        });
                                        fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                                      },
                                      onChanged: (value) {
                                        if (_thumbnailSuccess) {
                                          fAliplayer?.requestBitmapAtPosition(value.ceil());
                                        }
                                        setState(() {
                                          _currentPosition = value.ceil();
                                        });
                                      }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
            ),
          );
  }

  Widget _buildController(Color backgroundColor, Color iconColor, double barHeight, double width, double height, ContentData data) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      onEnd: _onPlayerHide,
      child: Container(
        width: width * .8,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlayPause(iconColor, barHeight, data),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPause(
    Color iconColor,
    double barHeight,
    ContentData data,
  ) {
    return GestureDetector(
      onTap: () {
        // if (context.read<VideoNotifier>().mapInContentAds[data.postID ?? ''] == null) {

        if (isPause) {
          fAliplayer?.play();
          isPause = false;
          setState(() {});
        } else {
          "=============== pause 2".logger();
          fAliplayer?.pause();
          isPause = true;
          setState(() {});
        }
        if (_showTipsWidget) {
          fAliplayer?.prepare();
          fAliplayer?.play();
        }

        // }
      },
      child: CustomIconWidget(
        iconData: isPause ? '${AssetPath.vectorPath}pause2.svg' : "${AssetPath.vectorPath}pause3.svg",
        defaultColor: false,
        width: 42,
      ),
      // Icon(
      //   isPause ? Icons.pause : Icons.play_arrow_rounded,
      //   color: iconColor,
      //   size: 200,
      // ),
    );
  }

  _buildProgressBar(double width, double height) {
    if (_showLoading) {
      return Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 3.0,
                ),
                fourPx,
                Text(
                  "$_loadingPercent%",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildBody(context, data, width) {
    // final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PicTopItem(data: data),
        ),
        if (data?.tagPeople?.isNotEmpty ?? false)
          Positioned(
            bottom: 18,
            left: 12,
            child: GestureDetector(
              onTap: () {
                context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID, title: lang!.inThisVideo);
              },
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}tag_people.svg',
                defaultColor: false,
                height: 20,
              ),
            ),
          ),

        Positioned(
            bottom: 18,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                System().formatDuration(Duration(seconds: data?.metadata?.duration ?? 0).inMilliseconds),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )),
        // Positioned(bottom: 0, left: 0, child: PicBottomItem(data: data, width: width)),
        (data?.reportedStatus == "BLURRED")
            ? Positioned.fill(
                child: VideoThumbnailReport(
                  videoData: data,
                  seeContent: false,
                ),
              )
            : Container(),
        // data?.reportedStatus == 'BLURRED'
        //     ? ClipRect(
        //         child: BackdropFilter(
        //           filter: ImageFilter.blur(
        //             sigmaX: 30.0,
        //             sigmaY: 30.0,
        //           ),
        //           child: Container(
        //             alignment: Alignment.center,
        //             width: SizeConfig.screenWidth,
        //             height: 200.0,
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: const [
        //                 CustomIconWidget(
        //                   iconData: "${AssetPath.vectorPath}eye-off.svg",
        //                   defaultColor: false,
        //                   height: 50,
        //                   color: Colors.white,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       )
        //     : Container(),
      ],
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 19 / 13,
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(8.0),
                  child: CustomBackgroundLayer(
                    sigmaX: 10,
                    sigmaY: 10,
                    thumbnail: (data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : '${data.fullThumbPath}',
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      twelvePx,
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 24,
                        color: Colors.white,
                      ),
                      fourPx,
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      fourPx,
                      Text("${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          )),
                      data.email == SharedPreference().readStorage(SpKeys.email)
                          ? GestureDetector(
                              onTap: () async {
                                System().checkConnections().then((value) {
                                  if (value) {
                                    Routing().move(Routes.appeal, argument: data);
                                  }
                                });
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                                  child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      thirtyTwoPx,
                    ],
                  ),
                )),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        data.reportedStatus = '';
                      });

                      // start(data);
                      // context.read<ReportNotifier>().seeContent(context, data, hyppeVid);
                      data.fAliplayer?.prepare();
                      data.fAliplayer?.play();
                      // context.read<ReportNotifier>().seeContent(context, videoData!, hyppeVid);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      margin: const EdgeInsets.all(8),
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
                        "${transnot.translate.see} Vid",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // void finish(ContentData data) async {
  //
  //   data.fAliplayer?.stop();
  //   setState(() {
  //     dataSelected?.isDiaryPlay = false;
  //     isPlay = false;
  //   });
  //   dataSelected = data;
  // }
  //
  // void start(ContentData data) async{
  //   finish(data);
  //   _lastCurIndex = _curIdx;
  //
  //   if (data.reportedStatus != 'BLURRED') {
  //     if (data.isApsara ?? false) {
  //       _playMode = ModeTypeAliPLayer.auth;
  //       await getAuth(data);
  //     } else {
  //       _playMode = ModeTypeAliPLayer.url;
  //       await getOldVideoUrl(data);
  //     }
  //   }
  //
  //   setState(() {
  //     isPause = false;
  //   });
  //   if (data.reportedStatus == 'BLURRED') {
  //   } else {
  //     data.fAliplayer?.prepare();
  //   }
  // }
}
