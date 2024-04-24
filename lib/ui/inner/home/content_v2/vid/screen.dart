import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/ads/ads_player_page.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/video_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/ads_cta_layout.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/widget/view_like.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../app.dart';
import '../../../../../core/config/ali_config.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../../ux/path.dart';
import '../../../../../ux/routing.dart';
import '../../../../constant/entities/like/notifier.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../constant/widget/custom_background_layer.dart';

class HyppePreviewVid extends StatefulWidget {
  final ScrollController? scrollController;
  final bool? afterUploading;
  const HyppePreviewVid({
    Key? key,
    this.scrollController,
    this.afterUploading,
  }) : super(key: key);

  @override
  _HyppePreviewVidState createState() => _HyppePreviewVidState();
}

class _HyppePreviewVidState extends State<HyppePreviewVid> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  FlutterAliplayer? fAliplayer;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  AdsPlayerPage? adsPlayerPage;
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;

  final bool _isLock = false;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
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
  // int _lastCurIndex = -1;

  Map<String, FlutterAliplayer> dataAli = {};
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    isStopVideo = false;
    isactivealiplayer = true;
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<PreviewVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    notifier.pageController.addListener(() => notifier.scrollListener(context));
    notifier.initAdsCounter();
    lang = context.read<TranslateNotifierV2>().translate;
    lastOffset = -10;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (fAliplayer == null && fAliplayer?.getPlayerName().toString() != 'VideoLandingpage') {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'VideoLandingpage');
        initAlipayer();
      }
      //scroll
      // if (mounted) {
      //   Future.delayed(const Duration(milliseconds: 500), () {
      //     print("=========== global key prirnt ${widget.scrollController} ");
      //     widget.scrollController?.addListener(() {
      //       double offset = widget.scrollController?.position.pixels ?? 0;
      //       if (mounted) toPosition(offset);
      //     });
      //   });
      // }
    });

    _initializeTimer();
    print("===========dari init");
    super.initState();
  }

  initAlipayer() {
    globalAliPlayer = fAliplayer;
    vidConfig();
    fAliplayer?.pause();
    fAliplayer?.setAutoPlay(false);

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
              setState(() {
                _showLoading = false;
              });
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
        final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
        if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
          if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
            _currentPosition = extraValue ?? 0;
            final detik = (_currentPosition / 1000).round();

            if (notifier.adsTime == detik) {
              if (notifier.tempAdsData != null) {
                fAliplayer?.pause();
                final tempAds = notifier.tempAdsData;
                if (tempAds != null) {
                  notifier.setMapAdsContent(dataSelected?.postID ?? '', tempAds);
                  final fixAds = notifier.mapInContentAds[dataSelected?.postID ?? ''];

                  if (fixAds != null) {
                    context.read<PreviewVidNotifier>().setAdsData(_curIdx, fixAds, context);
                  }
                }
              }
            }
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
        autScroll();
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

  void toPosition(offset) async {
    // _initializeTimer();
    double totItemHeight = 0;
    double totItemHeightParam = 0;
    final notifier = context.read<PreviewVidNotifier>();

    if (offset < 10) {
      itemIndex = 0;
    }

    // if (offset > lastOffset) {
    if (!scroolUp) {
      for (var i = 0; i <= itemIndex; i++) {
        if (i == itemIndex) {
          totItemHeightParam += (notifier.vidData?[i].height ?? 0.0) * 30 / 100;
        } else {
          totItemHeightParam += notifier.vidData?[i].height ?? 0.0;
        }
        totItemHeight += notifier.vidData?[i].height ?? 0.0;
      }

      if (offset >= totItemHeightParam && !homeClick) {
        var position = totItemHeight;
        if (itemIndex != ((notifier.vidData?.length ?? 0) - 2)) {
          if (mounted) {
            widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
            itemIndex++;
          }
        }
      }
    } else {
      if (!homeClick) {
        for (var i = 0; i < itemIndex; i++) {
          if (i == itemIndex - 1) {
            totItemHeightParam += (notifier.vidData?[i].height ?? 0.0) * 75 / 100;
          } else if (i == itemIndex) {
          } else {
            totItemHeightParam += notifier.vidData?[i].height ?? 0.0;
          }
          totItemHeight += notifier.vidData?[i].height ?? 0.0;
        }
        if (itemIndex > 0) {
          totItemHeight -= notifier.vidData?[itemIndex - 1].height ?? 0.0;
        }
        if (offset <= totItemHeightParam && offset > 0) {
          var position = totItemHeight;
          if (itemIndex != ((notifier.vidData?.length ?? 0) - 1)) {
            if (mounted) {
              widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
              itemIndex--;
            }
          }
        }
      }
    }
    lastOffset = offset;
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    // fAliplayer?.destroy();
    isActivePage = false;
    isStopVideo = false;
    "================ ondispose vid".logger();
    _pauseScreen();
    try {
      final notifier = context.read<PreviewVidNotifier>();
      notifier.pageController.dispose();
    } catch (e) {
      e.logger();
    }
    CustomRouteObserver.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    print("============= deactivate dari vid");
    isStopVideo = false;
    fAliplayer?.pause();
    _pauseScreen();
    super.deactivate();
  }

  @override
  void didPop() {
    print("============= didpop dari vid");
    super.didPop();
  }

  @override
  void didPopNext() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    isActivePage = true;
    final vidNot = context.read<VideoNotifier>();
    vidNot.adsAliplayer?.play();
    isHomeScreen = true;
    // print("============= didPopNext dari vid");
    final notifier = context.read<PreviewVidNotifier>();

    _initializeTimer();
    if (_curIdx != -1) {
      // notifier.vidData?[_curIdx].fAliplayer?.play();
    }
    if (postIdVisibility == '') {
      setState(() {
        postIdVisibility == '';
      });
      Future.delayed(Duration(milliseconds: 400), () {
        setState(() {
          postIdVisibility = postIdVisibilityTemp;
        });
      });
    }

    var temp1 = notifier.vidData?[_curIdx];
    var temp2 = notifier.vidData![notifier.currentIndex];

    print("===========dari didpopnext ${_curIdx} ${notifier.currentIndex}");

    if (_curIdx < notifier.currentIndex) {
      setState(() {
        // notifier.vidData?[_curIdx].fAliplayer?.stop();
        _curIdx = notifier.currentIndex;
        // pn.diaryData!.removeRange(_curIdx, pn.currentIndex);
        notifier.vidData!.removeRange(0, notifier.currentIndex);
        widget.scrollController?.animateTo(0, duration: const Duration(milliseconds: 50), curve: Curves.ease);
      });
    } else if (_curIdx > notifier.currentIndex) {
      setState(() {
        notifier.vidData?[_curIdx] = temp2;
        notifier.vidData?[notifier.currentIndex] = temp1!;
      });
    }

    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    isHomeScreen = false;
    fAliplayer?.pause();
    isActivePage = false;
    print("=============== didPushNext dari vid");
    final notifier = context.read<PreviewVidNotifier>();
    final vidNot = context.read<VideoNotifier>();
    vidNot.adsAliplayer?.pause();
    _pauseScreen();
    if (_curIdx != -1) {
      "=============== pause 6".logger();
      notifier.vidData?[_curIdx].fAliplayer?.pause();
    }

    super.didPushNext();
  }

  @override
  void didUpdateWidget(covariant HyppePreviewVid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.afterUploading ?? false) {
      afterUploading = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final notifier = context.read<PreviewVidNotifier>();
    switch (state) {
      case AppLifecycleState.inactive:
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.resumed:
        print("============= canPlayOpenApps ${context.read<PreviewVidNotifier>().canPlayOpenApps}-- isInactiveState: ${context.read<MainNotifier>().isInactiveState} $isActivePage");
        if (isHomeScreen) _initializeTimer();
        if (context.read<PreviewVidNotifier>().canPlayOpenApps && !context.read<MainNotifier>().isInactiveState && isActivePage) {
          try {
            // notifier.vidData?[_curIdx].fAliplayer?.prepare();
            // notifier.vidData?[_curIdx].fAliplayer?.play();
            print("masuk lagi video ${fAliplayer?.getVideoHeight()}");
            // fAliplayer?.prepare();
            fAliplayer?.play();
          } catch (e) {
            print(e);
          }
        }
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.detached:
        _pauseScreen();
        break;
      default:
        break;
    }
  }

  PreviewVidNotifier getNotifier(BuildContext context) {
    return context.read<PreviewVidNotifier>();
  }

  void scrollAuto() {
    print("====== nomor index $_curIdx");
    // itemScrollController.scrollTo(index: _curIdx + 1, duration: Duration(milliseconds: 500));
  }

  _pauseScreen() async {
    print("===========pause scren=======");
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
  }

  void _initializeTimer() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initWakelockTimer(onShowInactivityWarning: _handleInactivity);
  }

  void _handleInactivity() {
    if (isHomeScreen) {
      final notifier = (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>();
      (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps = false;
      context.read<MainNotifier>().isInactiveState = true;
      "=============== pause 7".logger();
      notifier.vidData?[_curIdx].fAliplayer?.pause();
      _pauseScreen();
      ShowBottomSheet().onShowColouredSheet(
        (Routing.navigatorKey.currentContext ?? context),
        (Routing.navigatorKey.currentContext ?? context).read<TranslateNotifierV2>().translate.warningInavtivityVid,
        maxLines: 2,
        color: kHyppeLightBackground,
        textColor: kHyppeTextLightPrimary,
        textButtonColor: kHyppePrimary,
        iconSvg: 'close.svg',
        textButton: (Routing.navigatorKey.currentContext ?? context).read<TranslateNotifierV2>().translate.stringContinue ?? '',
        onClose: () {
          (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().isInactiveState = false;
          notifier.vidData?[_curIdx].fAliplayer?.play();
          print("===========dari close popup");
          _initializeTimer();
          (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps = true;
        },
      );
    }
  }

  void autScroll() {
    double position = 0.0;
    PreviewVidNotifier notifier = context.read<PreviewVidNotifier>();
    for (var i = 0; i <= _curIdx; i++) {
      position += notifier.vidData?[i].height ?? 0.0;
    }
    widget.scrollController?.animateTo(
      position,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
    );
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
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
    print("============== is acive $isActivePage");
    fAliplayer?.prepare();
    if (data.reportedStatus == 'BLURRED') {
    } else {
      if (isActivePage) {
        print("=====prepare=====");

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

        final isViewed = dataSelected?.isViewed ?? true;

        final ref = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
        ref.tempAdsData = null;
        if (!isViewed) {
          ref.hasShowedAds = false;
          ref.getAdsVideo(Routing.navigatorKey.currentContext ?? context, _videoDuration).whenComplete(() {
            // (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().setIsViewed(widget.index!);
          });
        }
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

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      // setState(() {});
    });
  }

  Future<VideoIndicator> navigateTo(VideoNotifier notifier, int changevalue, int index) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    return await navigator.push(
      CupertinoPageRoute(
          builder: (_) => VideoFullLandingscreenPage(
              enableWakelock: true,
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
          settings: const RouteSettings()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<PreviewVidNotifier>();
    // final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    // final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Consumer3<PreviewVidNotifier, TranslateNotifierV2, HomeNotifier>(
      builder: (context, vidNotifier, translateNotifier, homeNotifier, widget) => TapRegion(
        behavior: HitTestBehavior.opaque,
        onTapInside: (event) => _initializeTimer(),
        // onPanDown: (details) {
        //   print("dari builder");
        //   _initializeTimer();
        // },
        child: SizedBox(
          child: Column(
            children: [
              (vidNotifier.vidData != null)
                  ? (vidNotifier.vidData?.isEmpty ?? true)
                      ? const NoResultFound()
                      : Expanded(
                          child: NotificationListener<UserScrollNotification>(
                            onNotification: (notification) {
                              final ScrollDirection direction = notification.direction;
                              setState(() {
                                print("-===========scrollll==========");
                                if (direction == ScrollDirection.reverse) {
                                  //down
                                  setState(() {
                                    scroolUp = false;
                                    homeClick = false;
                                  });

                                  print("-===========reverse ${homeClick}==========");
                                  print("-===========reverse==========");
                                } else if (direction == ScrollDirection.forward) {
                                  //up
                                  setState(() {
                                    scroolUp = true;
                                  });
                                  print("-===========forward==========");
                                }
                              });
                              return true;
                            },
                            child: ListView.builder(
                              // child: ScrollablePositionedList.builder(
                              // controller: vidNotifier.pageController,
                              // onPageChanged: (index) async {
                              //   print('HyppePreviewVid index : $index');
                              //   if (index == (vidNotifier.itemCount - 1)) {
                              //     final values = await vidNotifier.contentsQuery.loadNext(context, isLandingPage: true);
                              //     if (values.isNotEmpty) {
                              //       vidNotifier.vidData = [...(vidNotifier.vidData ?? [] as List<ContentData>)] + values;
                              //     }
                              //   }
                              //   // context.read<PreviewVidNotifier>().nextVideo = false;
                              //   // context.read<PreviewVidNotifier>().initializeVideo = false;
                              // },
                              physics: NeverScrollableScrollPhysics(),
                              // itemScrollController: itemScrollController,
                              // itemPositionsListener: itemPositionsListener,
                              // scrollOffsetController: scrollOffsetController,
                              shrinkWrap: true,
                              // itemCount: vidNotifier.itemCount,
                              itemCount: vidNotifier.vidData?.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (vidNotifier.vidData == null || homeNotifier.isLoadingVid) {
                                  "=============== pause 8".logger();
                                  vidNotifier.vidData?[index].fAliplayer?.pause();
                                  // _lastCurIndex = -1;
                                  return CustomShimmer(
                                    margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
                                    height: context.getHeight() / 8,
                                    width: double.infinity,
                                  );
                                } else if (index == vidNotifier.vidData?.length && vidNotifier.hasNext) {
                                  return const CustomLoading(size: 5);
                                }
                                // if (_curIdx == 0 && vidNotifier.vidData?[0].reportedStatus == 'BLURRED') {
                                //   isPlay = false;
                                //   vidNotifier.vidData?[index].fAliplayer?.stop();
                                // }
                                final vidData = vidNotifier.vidData?[index];
                                // return afterUploading && index == 0 ? CustomLoading() : itemVid(context, vidData ?? ContentData(), vidNotifier, index, homeNotifier);
                                return itemVid(context, vidData ?? ContentData(), vidNotifier, index, homeNotifier);
                              },
                            ),
                          ),
                        )
                  : ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return CustomShimmer(
                          margin: const EdgeInsets.only(bottom: 30, right: 16, left: 16),
                          height: context.getHeight() / 8,
                          width: double.infinity,
                        );
                      }),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemVid(BuildContext context, ContentData vidData, PreviewVidNotifier notifier, int index, HomeNotifier homeNotifier) {
    final videoNot = context.read<VideoNotifier>();
    var map = {
      DataSourceRelated.vidKey: vidData.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };

    final isAds = vidData.inBetweenAds != null && vidData.postID == null;
    return vidData.isContentLoading ?? false
        ? Builder(builder: (context) {
            Future.delayed(Duration(seconds: 1), () {
              setState(() {
                vidData.isContentLoading = false;
              });
            });
            return Container();
          })
        : WidgetSize(
            onChange: (Size size) {
              if (mounted) {
                setState(() {
                  notifier.vidData?[index].height = size.height;
                });
              }
            },
            child:

                ///ADS IN BETWEEN === Hariyanto Lukman ===
                isAds
                    ? VisibilityDetector(
                        key: Key(vidData.postID ?? index.toString()),
                        onVisibilityChanged: (info) async {
                          //fAliplayer stoped === Irfan ====
                          fAliplayer?.pause();
                          setState(() {
                            isPlay = false;
                            _showLoading = false;
                          });
                          if (info.visibleFraction >= 0.8) {
                            _videoDuration = 0;
                            setState(() {
                              isPlayAds = false;
                            });
                            if (!isShowingDialog) {
                              globalAdsPopUp?.pause();
                            }
                            globalAdsInContent?.setLoop(true);
                            globalAdsInContent?.play();
                            _curIdx = index;
                            // _curPostId = vidData.inBetweenAds?.adsId ?? index.toString();
                            _curPostId = vidData.postID ?? index.toString();

                            final indexList = notifier.vidData?.indexWhere((element) => element.postID == _curPostId);
                            final latIndexList = notifier.vidData?.indexWhere((element) => element.postID == _lastCurPostId);

                            final ads = context.read<VideoNotifier>();
                            ads.adsAliplayer?.pause();
                            dataSelected = notifier.vidData?[index];
                            if (_lastCurPostId != _curPostId) {
                              if (notifier.vidData?[_curIdx].fAliplayer != null) {
                                notifier.vidData?[_curIdx].fAliplayer?.pause();
                              } else {
                                dataAli[notifier.vidData?[_curIdx].postID]?.pause();
                              }
                              videoNot.setMapAdsContent(notifier.vidData?[_curIdx].postID ?? '', null);
                            }
                            try {
                              Future.delayed(const Duration(milliseconds: 400), () {
                                if (mounted) {
                                  setState(() {
                                    postIdVisibility = notifier.vidData?[_curIdx].inBetweenAds?.adsId ?? '';
                                    postIdVisibilityTemp = notifier.vidData?[_curIdx].inBetweenAds?.adsId ?? '';
                                  });
                                } else {
                                  postIdVisibility = notifier.vidData?[_curIdx].inBetweenAds?.adsId ?? '';
                                  postIdVisibilityTemp = notifier.vidData?[_curIdx].inBetweenAds?.adsId ?? '';
                                }
                              });
                            } catch (e) {
                              print("hahahha $e");
                            }
                            if (indexList == (notifier.vidData?.length ?? 0) - 1) {
                              Future.delayed(const Duration(milliseconds: 2000), () async {
                                await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                                  notifier.getTemp(indexList, latIndexList, indexList);
                                });
                              });
                            } else {
                              Future.delayed(const Duration(milliseconds: 2000), () {
                                notifier.getTemp(indexList, latIndexList, indexList);
                              });
                            }
                            // _lastCurIndex = _curIdx;
                            _lastCurPostId = _curPostId;
                          } else {
                            setState(() {
                              isPlayAds = true;
                            });
                          }
                        },
                        child: Stack(
                          children: [
                            context.getAdsInBetween(notifier.vidData, index, (info) {}, () {
                              notifier.setInBetweenAds(index, null);
                            }, (player, id) {
                              setState(() {
                                dataAli[id] = player;
                              });
                            }, isVideo: true, isStopPlay: isPlayAds),
                            Positioned.fill(
                              top: kToolbarHeight * 1.5,
                              left: kToolbarHeight * .6,
                              right: kToolbarHeight * .6,
                              bottom: kToolbarHeight * 2.5,
                              child: GestureDetector(
                                onTap: () {
                                  //Click Ads === Irfan ===
                                  Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
                                      builder: (_) => VideoFullLandingscreenPage(
                                            enableWakelock: true,
                                            onClose: () {},
                                            isLanding: true,
                                            videoIndicator: VideoIndicator(videoDuration: 0, seekValue: 0, positionText: 0, isMute: isMute),
                                            thumbnail: '',
                                            index: index,
                                          )));
                                },
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          VisibilityDetector(
                            key: Key(vidData.postID ?? index.toString()),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction >= 1) {
                                print(index);
                                _curIdx = index;
                                print(_curIdx);
                              }
                              if (info.visibleFraction >= 0.8) {
                                if (!notifier.loadAds) {
                                  if ((notifier.vidData?.length ?? 0) > notifier.nextAdsShowed) {
                                    notifier.loadAds = true;
                                    context.getInBetweenAds().then(
                                      (value) {
                                        if (value != null) {
                                          notifier.setInBetweenAds(index, value);
                                        } else {
                                          notifier.loadAds = false;
                                        }
                                      },
                                    );
                                  }
                                }

                                if (!isShowingDialog) {
                                  globalAdsPopUp?.pause();
                                }
                                globalAdsInBetween?.pause();
                                _curIdx = index;
                                _curPostId = vidData.postID ?? index.toString();

                                final indexList = notifier.vidData?.indexWhere((element) => element.postID == _curPostId);
                                final latIndexList = notifier.vidData?.indexWhere((element) => element.postID == _lastCurPostId);

                                if (_lastCurPostId != _curPostId) {
                                  setState(() {
                                    _currentPosition = 0;
                                  });
                                  Future.delayed(const Duration(milliseconds: 400), () {
                                    try {
                                      if (_curIdx != -1) {
                                        if (notifier.vidData?[_curIdx].fAliplayer != null) {
                                          "=============== pause 9".logger();
                                          // notifier.vidData?[_curIdx].fAliplayer?.pause();
                                        } else {
                                          "=============== pause 10".logger();
                                          dataAli[notifier.vidData?[_curIdx].postID]?.pause();
                                        }
                                        start(Routing.navigatorKey.currentContext ?? context, notifier.vidData?[_curIdx] ?? ContentData());
                                        System().increaseViewCount2(context, notifier.vidData?[_curIdx] ?? ContentData()).whenComplete(() async {});
                                        videoNot.setMapAdsContent(notifier.vidData?[_curIdx].postID ?? '', null);
                                        // Wakelock.disable();
                                        // notifier.vidData?[_curIdx].fAliplayerAds?.pause();
                                        // setState(() {
                                        //   _curIdx = -1;
                                        // });
                                      }
                                    } catch (e) {
                                      e.logger();
                                    }
                                    // System().increaseViewCount2(context, vidData);
                                  });
                                  if (vidData.certified ?? false) {
                                    System().block(context);
                                  } else {
                                    System().disposeBlock();
                                  }

                                  try {
                                    Future.delayed(const Duration(milliseconds: 400), () {
                                      if (mounted) {
                                        setState(() {
                                          postIdVisibility = notifier.vidData?[_curIdx].postID ?? '';
                                          postIdVisibilityTemp = notifier.vidData?[_curIdx].postID ?? '';
                                        });
                                      } else {
                                        postIdVisibility = notifier.vidData?[_curIdx].postID ?? '';
                                        postIdVisibilityTemp = notifier.vidData?[_curIdx].postID ?? '';
                                      }

                                      // VidPlayerPageState().playVideo();

                                      // notifier.vidData?[_curIdx].fAliplayer?.prepare().then(
                                      //       (value) => notifier.vidData?[_curIdx].fAliplayer?.play().then((value) {
                                      //         notifier.vidData?[_curIdx].isPlay = true;
                                      //       }),
                                      //     );

                                      // vidPlayerState.currentState!.playTest(notifier.vidData?[_curIdx].postID ?? '');

                                      // setState(() {

                                      // });
                                    });
                                    // if (_lastCurIndex > -1) {
                                    //   if (notifier.vidData?[_lastCurIndex].fAliplayer != null) {
                                    //     // notifier.vidData?[_lastCurIndex].isPlay = false;
                                    //     notifier.vidData?[_lastCurIndex].fAliplayer?.stop();
                                    //   }
                                    // }
                                  } catch (e) {
                                    print("hahahha $e");
                                  }
                                  if (indexList == (notifier.vidData?.length ?? 0) - 1) {
                                    Future.delayed(const Duration(milliseconds: 2000), () async {
                                      await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                                        notifier.getTemp(indexList, latIndexList, indexList);
                                      });
                                    });
                                  } else {
                                    Future.delayed(const Duration(milliseconds: 2000), () {
                                      notifier.getTemp(indexList, latIndexList, indexList);
                                    });
                                  }
                                }

                                // if (_curIdx != index) {
                                //   print('Vid Landing Page: stop pause $_curIdx ${notifier.vidData?[_lastCurIndex].fAliplayer} ${dataAli[_curIdx]}');
                                //   if (notifier.vidData?[_lastCurIndex].fAliplayer != null) {
                                //     notifier.vidData?[_lastCurIndex].fAliplayer?.stop();
                                //   } else {
                                //     final player = dataAli[_lastCurIndex];
                                //     if (player != null) {
                                //       // notifier.vidData?[_curIdx].fAliplayer = player;
                                //       player.stop();
                                //     }
                                //   }
                                //   // notifier.vidData?[_curIdx].fAliplayerAds?.stop();
                                // }
                                // _lastCurIndex = _curIdx;
                                _lastCurPostId = _curPostId;
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("${videoNot.tempAdsData}"),
                                  // Text("${videoNot.tempAdsData?.adsId}"),
                                  // Text("${videoNot.mapInContentAds[vidData.postID ?? ''] != null}"),

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
                                          username: vidData.username,
                                          featureType: FeatureType.other,
                                          // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                                          isCelebrity: false,
                                          imageUrl: '${System().showUserPicture(vidData.avatar?.mediaEndpoint)}',
                                          onTapOnProfileImage: () => System().navigateToProfile(context, vidData.email ?? ''),
                                          createdAt: '2022-02-02',
                                          musicName: vidData.music?.musicTitle ?? '',
                                          location: vidData.location ?? '',
                                          isIdVerified: vidData.privacy?.isIdVerified,
                                          badge: vidData.urluserBadge,
                                        ),
                                      ),
                                      if (vidData.email != email && (vidData.isNewFollowing ?? false))
                                        Consumer<PreviewPicNotifier>(
                                          builder: (context, picNot, child) => Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                context.handleActionIsGuest(() {
                                                  if (vidData.insight?.isloadingFollow != true) {
                                                    picNot.followUser(context, vidData, isUnFollow: vidData.following, isloading: vidData.insight!.isloadingFollow ?? false);
                                                  }
                                                });
                                              },
                                              child: vidData.insight?.isloadingFollow ?? false
                                                  ? Container(
                                                      height: 40,
                                                      width: 30,
                                                      child: const Align(
                                                        alignment: Alignment.bottomRight,
                                                        child: CustomLoading(),
                                                      ),
                                                    )
                                                  : Text(
                                                      (vidData.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                                      style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () {
                                          context.handleActionIsGuest(() {
                                            if (vidData.email != email) {
                                              // FlutterAliplayer? fAliplayer
                                              context.read<PreviewPicNotifier>().reportContent(context, vidData, fAliplayer: vidData.fAliplayer, onCompleted: () async {
                                                imageCache.clear();
                                                imageCache.clearLiveImages();
                                                await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                              });
                                            } else {
                                              if (_curIdx != -1) {
                                                "=============== pause 11".logger();
                                                notifier.vidData?[_curIdx].fAliplayer?.pause();
                                              }

                                              ShowBottomSheet().onShowOptionContent(
                                                context,
                                                contentData: vidData,
                                                captionTitle: hyppeVid,
                                                onDetail: false,
                                                isShare: vidData.isShared,
                                                onUpdate: () {
                                                  (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                                },
                                                fAliplayer: vidData.fAliplayer,
                                              );
                                            }
                                          });
                                        },
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: kHyppeTextLightPrimary,
                                        ),
                                      ),
                                    ],
                                  ), // Text("${postIdVisibility}"),
                                  tenPx,
                                  // Text("${postIdVisibility != vidData.postID}"),
                                  globalInternetConnection
                                      ? vidData.reportedStatus == 'BLURRED'
                                          ? blurContentWidget(context, vidData)
                                          : postIdVisibility != vidData.postID
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      postIdVisibility = vidData.postID ?? '';
                                                    });
                                                    var vidNotifier = context.read<PreviewVidNotifier>();
                                                    double position = 0.0;
                                                    for (var i = 0; i < index; i++) {
                                                      position += vidNotifier.vidData?[i].height ?? 0.0;
                                                    }
                                                    widget.scrollController?.animateTo(
                                                      position,
                                                      duration: const Duration(milliseconds: 700),
                                                      curve: Curves.easeOut,
                                                    );
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
                                                          videoData: vidData,
                                                          onDetail: false,
                                                          fn: () {},
                                                          withMargin: true,
                                                        ),
                                                      ),
                                                      // postIdVisibility == ''
                                                      //     ? Center(
                                                      //         child: Align(
                                                      //         alignment: Alignment.center,
                                                      //         child: SizedBox(
                                                      //           height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                                      //           width: MediaQuery.of(context).size.width,
                                                      //           child: const CustomIconWidget(
                                                      //             defaultColor: false,
                                                      //             width: 40,
                                                      //             iconData: '${AssetPath.vectorPath}pause2.svg',
                                                      //             // color: kHyppeLightButtonText,
                                                      //           ),
                                                      //         ),
                                                      //       ))
                                                      //     : Container(),
                                                    ],
                                                  ),
                                                )
                                              : videoPlayerWidget(notifier, vidData, index)
                                      : GestureDetector(
                                          onTap: () async {
                                            globalInternetConnection = await System().checkConnections();
                                            // _networklHasErrorNotifier.value++;
                                            // reloadImage(index);
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                              width: SizeConfig.screenWidth,
                                              height: 250,
                                              margin: const EdgeInsets.only(bottom: 16),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.all(32.0),
                                                child: CustomTextWidget(
                                                  textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                                  maxLines: 4,
                                                ),
                                              )),
                                        ),
                                  if (vidData.adsData != null)
                                    AdsCTALayout(
                                      adsData: vidData.adsData!,
                                      onClose: () {
                                        fAliplayer?.pause();
                                        notifier.setAdsData(index, null, context);
                                      },
                                      postId: notifier.vidData?[index].postID ?? '',
                                    ),
                                  twelvePx,
                                  SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                                          (vidData.boosted.isEmpty) &&
                                          (vidData.reportedStatus != 'OWNED' && vidData.reportedStatus != 'BLURRED' && vidData.reportedStatus2 != 'BLURRED') &&
                                          vidData.email == email
                                      ? Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          child: ButtonBoost(
                                            onDetail: false,
                                            marginBool: true,
                                            contentData: vidData,
                                            startState: () {
                                              SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                            },
                                            afterState: () {
                                              SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                            },
                                          ),
                                        )
                                      : Container(),
                                  if (vidData.email == email && (vidData.boostCount ?? 0) >= 0 && (vidData.boosted.isNotEmpty))
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
                                              "${vidData.boostJangkauan ?? '0'} ${lang?.reach}",
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
                                                child: vidData.insight?.isloading ?? false
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
                                                          color: (vidData.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                                          iconData: '${AssetPath.vectorPath}${(vidData.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                          height: 28,
                                                        ),
                                                        onTap: () {
                                                          likeNotifier.likePost(context, vidData);
                                                        },
                                                      ),
                                              ),
                                            ),
                                            if (vidData.allowComments ?? false)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 21.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: vidData.postID ?? '', fromFront: true, data: vidData));
                                                  },
                                                  child: const CustomIconWidget(
                                                    defaultColor: false,
                                                    color: kHyppeTextLightPrimary,
                                                    iconData: '${AssetPath.vectorPath}comment2.svg',
                                                    height: 24,
                                                  ),
                                                ),
                                              ),
                                            if ((vidData.isShared ?? false))
                                              Padding(
                                                padding: EdgeInsets.only(left: 21.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    context.read<VidDetailNotifier>().createdDynamicLink(context, data: vidData);
                                                  },
                                                  child: CustomIconWidget(
                                                    defaultColor: false,
                                                    color: kHyppeTextLightPrimary,
                                                    iconData: '${AssetPath.vectorPath}share2.svg',
                                                    height: 24,
                                                  ),
                                                ),
                                              ),
                                            if ((vidData.saleAmount ?? 0) > 0 && email != vidData.email)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    "=============== pause 4".logger();
                                                    context.handleActionIsGuest(() async {
                                                      vidData.fAliplayer?.pause();
                                                      fAliplayer!.pause();
                                                      setState(() {
                                                        isPause = !isPause;
                                                      });
                                                      await ShowBottomSheet.onBuyContent(context, data: vidData, fAliplayer: vidData.fAliplayer);
                                                      // fAliplayer?.play();
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
                                              text: "${vidData.insight?.likes} ${lang!.like}",
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) => ViewLiked(
                                                              postId: vidData.postID ?? '',
                                                              eventType: 'LIKE',
                                                            ))),
                                              style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                            ),
                                            const TextSpan(
                                              text: " • ",
                                              style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                                            ),
                                            TextSpan(
                                              text: "${vidData.insight!.views?.getCountShort()} ${lang!.views}",
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) => ViewLiked(
                                                              postId: vidData.postID ?? '',
                                                              eventType: 'VIEW',
                                                            ))),
                                              style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                            ),
                                          ]),
                                        ),
                                        // Text(
                                        //   "${vidData.insight?.likes}  ${lang?.like}",
                                        //   style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  twelvePx,
                                  CustomNewDescContent(
                                    // desc: "${data?.description}",
                                    email: vidData.email ?? '',
                                    username: vidData.username ?? '',
                                    desc: "${vidData.description}",
                                    trimLines: 3,
                                    textAlign: TextAlign.start,
                                    seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                                    seeMore: '  ${lang?.more}', //${notifier2.translate.seeMoreContent}',
                                    normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                    hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                    expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: vidData.postID ?? '', fromFront: true, data: vidData));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        "${lang?.seeAll} ${vidData.comments} ${lang?.comment}",
                                        style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                                      ),
                                    ),
                                  ),
                                  (vidData.comment?.length ?? 0) > 0
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 0.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: (vidData.comment?.length ?? 0) >= 2 ? 2 : 1,
                                            itemBuilder: (context, indexComment) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 6.0),
                                                child: CustomNewDescContent(
                                                  // desc: "${vidData?.description}",
                                                  email: vidData.comment?[indexComment].sender ?? '',
                                                  username: vidData.comment?[indexComment].userComment?.username ?? '',
                                                  desc: vidData.comment?[indexComment].txtMessages ?? '',
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
                                  // Padding(
                                  //   padding: EdgeInsets.symmetric(vertical: 4.0),
                                  //   child: Text(
                                  //     "${System().readTimestamp(
                                  //       DateTime.parse(System().dateTimeRemoveT(vidData.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                                  //       context,
                                  //       fullCaption: true,
                                  //     )}",
                                  //     style: TextStyle(fontSize: 12, color: kHyppeBurem),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          homeNotifier.isLoadingLoadmore && notifier.vidData?[index] == notifier.vidData?.last
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 32),
                                  child: Center(child: CustomLoading()),
                                )
                              : Container(),
                        ],
                      ),
          );
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
                context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID);
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

  Widget videoPlayerWidget(PreviewVidNotifier vidNotifier, ContentData data, int index) {
    VideoNotifier notifier = context.read<VideoNotifier>();

    if (notifier.mapInContentAds[data.postID ?? ''] != null) {
      adsPlayerPage = AdsPlayerPage(
        dataSourceMap: {
          DataSourceRelated.vidKey: notifier.mapInContentAds[data.postID ?? '']?.videoId,
          DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
        },
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        thumbnail: (data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : '${data?.fullThumbPath}',
        data: notifier.mapInContentAds[data.postID ?? ''],
        functionFullTriger: () {},
        getPlayer: (player) {},
        onStop: () {
          notifier.setMapAdsContent(data.postID ?? '', null);
          vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
        },
        fromFullScreen: false,
        onFullscreen: () async {
          fAliplayer?.pause();
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
          // notifier.firstIndex = index;
          int changevalue;
          changevalue = _currentPosition + 1000;
          if (changevalue > _videoDuration) {
            changevalue = _videoDuration;
          }
          notifier.adsAliplayer?.pause();
          notifier.isShowingAds = notifier.mapInContentAds[data.postID ?? ''] != null;
          VideoIndicator value = await navigateTo(notifier, changevalue, index);
          notifier.setMapAdsContent(data.postID ?? '', null);
          vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
          if (mounted) {
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
        },
        onClose: () {
          if (mounted) {
            notifier.setMapAdsContent(data.postID ?? '', null);
            print("====ini iklan ${notifier.mapInContentAds} =====");
            setState(() {
              isPlay = true;
              // vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
              isloading = false;
              data.adsData = null;
            });
          } else {
            isPlay = true;
            notifier.setMapAdsContent(data.postID ?? '', null);
            // vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
            isloading = false;
            data.adsData = null;
          }

          if (!notifier.isFullScreen) {
            Future.delayed(const Duration(milliseconds: 500), () {
              fAliplayer?.play();
              setState(() {
                isPause = false;
                _showTipsWidget = false;
              });
            });
          }
        },
        orientation: Orientation.portrait,
      );
    }

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

        if (notifier.mapInContentAds[data.postID ?? ''] == null) {
          "=============== pause 3".logger();
          // fAliplayer?.pause();
          // setState(() {
          //   isloading = true;
          // });
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
          notifier.firstIndex = index;
          fAliplayer?.pause();
          VideoIndicator value = await navigateTo(notifier, changevalue, index);

          fAliplayer?.play();
          var temp1 = vidNotifier.vidData?[_curIdx];
          var temp2 = vidNotifier.vidData?[vidNotifier.currentIndex];
          print("======index back $index -- ${vidNotifier.currentIndex}");
          if (index < vidNotifier.currentIndex) {
            print("======index22222222}");
            if (!mounted) return;
            setState(() {
              index = 0;
              // pn.diaryData!.removeRange(_curIdx, pn.currentIndex);
              vidNotifier.vidData?.removeRange(0, vidNotifier.currentIndex);
              _curIdx = 0;
            });
            widget.scrollController?.animateTo(0, duration: const Duration(milliseconds: 50), curve: Curves.ease);
          } else if (index > vidNotifier.currentIndex) {
            print("======index44444444}");
            if (!mounted) return;
            setState(() {
              vidNotifier.vidData?[_curIdx] = temp2 ?? ContentData();
              vidNotifier.vidData?[vidNotifier.currentIndex] = temp1 ?? ContentData();
            });
          }
          print(value.seekValue);
          print(value.positionText);

          if (mounted) {
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

          fAliplayer?.pause();
          fAliplayer?.seekTo(_currentPosition, 1);

          // int changevalue;
          // changevalue = _currentPosition + 1000;
          // if (changevalue > _videoDuration) {
          //   changevalue = _videoDuration;
          // }
          notifier.isLoading = true;
          Future.delayed(const Duration(seconds: 6), () {
            notifier.isLoading = false;
          });
        }
      },
      onDoubleTap: () {
        if (notifier.tempAdsData == null) {
          final likeNotifier = context.read<LikeNotifier>();
          likeNotifier.likePost(context, data);
        }
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
                  // aliPlayerViewType: AliPlayerViewTypeForAndroid.textureview,
                ),
                // if (isloading)
                //   Container(
                //     decoration: BoxDecoration(
                //       color: Colors.black,
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //     height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                //     width: MediaQuery.of(context).size.width,
                //     child: VideoThumbnail(
                //       videoData: data,
                //       onDetail: false,
                //       fn: () {},
                //       withMargin: true,
                //     ),
                //   ),
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
                if (isPlay)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildController(Colors.transparent, Colors.white, 120, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.8),
                    ),
                  ),
                if (notifier.mapInContentAds[data.postID ?? ''] != null && isPlay)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                      child: Container(color: Colors.black, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: adsPlayerPage),
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
            opacity: onTapCtrl || isPause ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            onEnd: _onPlayerHide,
            child: SafeArea(
                child: _currentPosition <= 0
                    ? Container()
                    : Padding(
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
                            Align(
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

  Widget _buildController(Color backgroundColor, Color iconColor, double barHeight, double width, double height) {
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
            _buildPlayPause(iconColor, barHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPause(
    Color iconColor,
    double barHeight,
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
          context.read<VideoNotifier>().isShowingAds = false;
          context.read<VideoNotifier>().hasShowedAds = true;
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

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 19 / 10,
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
                  onTap: () async {
                    setState(() {
                      data.reportedStatus = '';
                    });

                    fAliplayer?.prepare();
                    fAliplayer?.play();

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
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Spacer(),
    //       const CustomIconWidget(
    //         iconData: "${AssetPath.vectorPath}eye-off.svg",
    //         defaultColor: false,
    //         height: 30,
    //       ),
    //       Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    //       Text("HyppeVid ${transnot.translate.contentContainsSensitiveMaterial}",
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(
    //             color: Colors.white,
    //             fontSize: 13,
    //           )),
    //       // data.email == SharedPreference().readStorage(SpKeys.email)
    //       //     ? GestureDetector(
    //       //         onTap: () => Routing().move(Routes.appeal, argument: data),
    //       //         child: Container(
    //       //             padding: const EdgeInsets.all(8),
    //       //             margin: const EdgeInsets.all(18),
    //       //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
    //       //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
    //       //       )
    //       //     : const SizedBox(),
    //       const Spacer(),
    //       GestureDetector(
    //         onTap: () {
    //           data.reportedStatus = '';
    //           // start(data);
    //           // context.read<ReportNotifier>().seeContent(context, data, hyppeVid);
    //           data.fAliplayer?.prepare();
    //           data.fAliplayer?.play();
    //         },
    //         child: Container(
    //           padding: const EdgeInsets.only(top: 8),
    //           margin: const EdgeInsets.only(bottom: 20, right: 8, left: 8),
    //           width: SizeConfig.screenWidth,
    //           decoration: const BoxDecoration(
    //             border: Border(
    //               top: BorderSide(
    //                 color: Colors.white,
    //                 width: 1,
    //               ),
    //             ),
    //           ),
    //           child: Text(
    //             "${transnot.translate.see} HyppeVid",
    //             style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  var loadingAction = false;
  var loadLaunch = false;
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
