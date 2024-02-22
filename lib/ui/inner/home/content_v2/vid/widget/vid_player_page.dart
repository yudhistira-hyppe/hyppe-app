import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_appbar.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/widget/vidscroll_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';
import '../../../../../constant/widget/ads/ads_player_page.dart';
import '../../../../../constant/widget/custom_desc_content_widget.dart';
import '../playlist/comments_detail/screen.dart';
import 'fullscreen/notifier.dart';
import 'fullscreen/video_fullscreen_page.dart';
import 'dart:math' as math;

class VidPlayerPage extends StatefulWidget {
  final bool? isVidFormProfile;
  final bool fromFullScreen;
  final ModeTypeAliPLayer playMode;
  final Map<String, dynamic> dataSourceMap;
  final ContentData? data;
  final double? height;
  final double? width;
  final bool inLanding;
  final bool fromDeeplink;
  final Function functionFullTriger;
  final Function(FlutterAliplayer, String id)? getPlayer;
  final Function(FlutterAliplayer)? getAdsPlayer;
  final Function(ContentData)? onPlay;
  final Function(AdsData?)? onShowAds;
  final Orientation orientation;
  final List<ContentData>? vidData;
  final int? index;
  final Function()? loadMoreFunction;
  final Function()? clearPostId; //netral player
  final bool? isPlaying;
  final bool clearing;
  final bool? isAutoPlay;
  final Function()? autoScroll; //netral player
  final bool enableWakelock;
  final Function()? prevScroll;
  final int currentPosition;

  // FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;

  const VidPlayerPage({
    Key? key,
    this.isVidFormProfile = false,
    required this.playMode,
    required this.dataSourceMap,
    required this.data,
    this.height,
    this.width,
    this.inLanding = false,
    this.fromDeeplink = false,
    required this.functionFullTriger,
    this.onPlay,
    this.getPlayer,
    this.getAdsPlayer,
    this.onShowAds,
    required this.orientation,
    this.vidData,
    this.fromFullScreen = false,
    this.index,
    this.loadMoreFunction,
    this.isPlaying,
    this.clearPostId,
    this.clearing = false,
    this.isAutoPlay = false,
    this.autoScroll,
    this.enableWakelock = true,
    this.prevScroll,
    this.currentPosition = 0,

    // this.fAliplayer,
    // this.fAliplayerAds
  }) : super(key: key);

  @override
  State<VidPlayerPage> createState() => VidPlayerPageState();
}

class VidPlayerPageState extends State<VidPlayerPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = true;
  int? bottomIndex;
  List<Widget>? mFramePage;
  // ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  // Map<String, dynamic>? _dataSourceAdsMap;
  String urlVid = '';
  String _savePath = '';
  bool isMute = false;
  bool isPotraitFull = false;
  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  final bool _mEnablePlayBack = false;

  LocalizationModelV2? lang;

  //当前播放进度
  int _currentPosition = 0;
  int _currentAdsPosition = 0;

  //当前播放时间，用于Text展示
  int _currentPositionText = 0;
  final int _currentAdsPositionText = 0;

  //当前buffer进度
  // int _bufferPosition = 0;

  //是否展示loading
  bool _showLoading = false;

  bool isShowMore = false;

  //loading进度
  int _loadingPercent = 0;

  //视频时长
  int _videoDuration = 1;
  final int _videoAdsDuration = 1;

  //截图保存路径
  String _snapShotPath = '';

  //提示内容
  String _tipsContent = '';

  //是否展示提示内容
  bool _showTipsWidget = false;

  //是否有缩略图
  bool _thumbnailSuccess = false;

  //缩略图
  // Uint8List _thumbnailBitmap;
  // ImageProvider? _imageProvider;

  //当前网络状态
  // ConnectivityResult? _currentConnectivityResult;

  ///seek中
  bool _inSeek = false;

  final bool _isLock = false;

  //网络状态
  bool _isShowMobileNetWork = false;

  //当前播放器状态
  int _currentPlayerState = 0;

  String extSubTitleText = '';

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  // AdsData? adsData;
  var secondsSkip = 0;
  var skipAdsCurent = 0;
  bool isActiveAds = false;
  bool isCompleteAds = false;
  AliPlayerView? aliPlayerView;
  AdsPlayerPage? adsPlayerPage;
  AdsVideo? _newClipData;
  int newIndex = 0;

  String vidId = "";
  String vidAuth = "";
  String email = '';

  String playerNameId() {
    switch (widget.isVidFormProfile ?? false) {
      case true:
        if (widget.fromFullScreen) {
          return 'full_profile_${widget.data?.postID}';
        } else {
          return 'profile_${widget.data?.postID}';
        }
      default:
        return widget.data?.postID ?? 'video_player_landing';
    }
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDSuccess');
    super.initState();
    "================= enable wakelock ${widget.enableWakelock}".logger();
    // if (widget.playMode == ModeTypeAliPLayer.auth) {
    //   getAuth();
    // } else {
    //   getOldVideoUrl();
    // }
    //cek ikaln
    // adsData = context.read<VidDetailNotifier>().adsData;
    // if (widget.inLanding) {
    //   getAdsVideo(false);
    // }
    email = SharedPreference().readStorage(SpKeys.email);
    lang = context.read<TranslateNotifierV2>().translate;
    if (widget.clearing) {
      widget.clearPostId?.call();
    }

    bool autoPlay = widget.isAutoPlay ?? false;
    // _playMode = widget.playMode;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: playerNameId());
        // globalAliPlayer = fAliplayer;
        fAliplayer?.setAutoPlay(autoPlay);
        if (autoPlay) {
          print("================== vid player index ${widget.index}");
          "===================== isPlaying ${widget.isPlaying}".logger();
          // Wakelock.enable();
          setState(() {
            isloading = false;
          });
        }

        final getPlayers = widget.getPlayer;

        if (getPlayers != null) {
          print('Vid Player1: getPlayer $fAliplayer');
          if (fAliplayer != null) {
            getPlayers(fAliplayer!, widget.data?.postID ?? '');
          }
        }

        WidgetsBinding.instance.addObserver(this);
        bottomIndex = 0;

        // fAliplayer?.setAutoPlay(widget.fromDeeplink);
        // if (widget.fromDeeplink) {
        //   isPlay = true;
        // }

        _dataSourceMap = widget.dataSourceMap;
        // _dataSourceAdsMap = {};
        // isPlay = false;
        // isPrepare = false;
        setState(() {});

        //Turn on mix mode
        if (Platform.isIOS) {
          FlutterAliplayer.enableMix(true);
          // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
        }

        configAliplayer();
        vidConfig();

        if (widget.currentPosition != 0) {
          fAliplayer?.seekTo(widget.currentPosition, FlutterAvpdef.ACCURATE);
        }
      } catch (e) {
        'Error Initialize Ali Player: $e'.logger();
      } finally {}
    });
  }

  Future getAdsVideo(bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        _newClipData = fetch.data;
        'videoId : ${_newClipData?.data?.videoId}'.logger();
        secondsSkip = _newClipData?.data?.adsSkip ?? 0;
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }

  void configAliplayer() {
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
              if (widget.isAutoPlay ?? false) {
                System().increaseViewCount2(context, widget.data ?? ContentData()).whenComplete(() async {
                  // final count = context.getAdsCount();
                  // if(count == 5){
                  //   final adsData = await context.getInBetweenAds();
                  //   widget.betweenAds(adsData);
                  // }
                  // if(!(widget.data?.isViewed ?? true)){
                  //   context.incrementAdsCount();
                  // }
                  // (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().setIsViewed(widget.index ?? 0);
                });
              }
              setState(() {
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
            if (widget.isAutoPlay ?? false) {
              widget.autoScroll?.call();
            }
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            // Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPrepared:
            // Wakelock.enable();
            if (widget.isAutoPlay ?? false) {
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
            // print("===detik $detik");
            if (!(widget.isVidFormProfile ?? false)) {
              if (notifier.adsTime == detik) {
                if (notifier.tempAdsData != null) {
                  fAliplayer?.pause();
                  final tempAds = notifier.tempAdsData;
                  if (tempAds != null) {
                    notifier.setMapAdsContent(widget.data?.postID ?? '', tempAds);
                    final fixAds = notifier.mapInContentAds[widget.data?.postID ?? ''];

                    if (widget.onShowAds != null && fixAds != null) {
                      widget.onShowAds!(fixAds);
                    }
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
        widget.functionFullTriger();
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
            extSubTitleText = '';
          });
        }
      });

      fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
        if (mounted) {
          setState(() {
            extSubTitleText = subtitle;
          });
        }
      });
      print("!=1=1=1==================================================1=1=1");
      print(widget.playMode);
      print(widget.data!.isApsara);
      print(widget.data?.postID);
      if (widget.data!.isApsara ?? false) {
        getAuth();
      } else {
        getOldVideoUrl();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void deactivate() {
    print('deactive player_page');
    super.deactivate();
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

  Future getAuth({String videoId = ''}) async {
    // setState(() {
    //   isloading = true;
    // });
    try {
      final notifier = PostsBloc();
      String apsaraId = '';
      if (videoId != '') {
        apsaraId = videoId;
      } else {
        apsaraId = widget.data?.apsaraId ?? '';
      }
      globalInternetConnection = await System().checkConnections();
      await notifier.getAuthApsara(context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        print(fetch.data);
        Map jsonMap = json.decode(fetch.data.toString());
        if (videoId != '') {
          print("-======= auth iklan ${jsonMap['PlayAuth']}");
          // _dataSourceAdsMap?[DataSourceRelated.playAuth] = jsonMap['PlayAuth'] ?? '';
        } else {
          // _dataSourceMap?[DataSourceRelated.playAuth] = jsonMap['PlayAuth'] ?? '';
          print("-======= auth konten ${jsonMap['PlayAuth']}");
          print("-======= auth konten ${_dataSourceMap?[DataSourceRelated.vidKey]}");
          fAliplayer?.setVidAuth(
            vid: apsaraId,
            region: _dataSourceMap?[DataSourceRelated.regionKey],
            playAuth: jsonMap['PlayAuth'],
            definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
            // previewTime: _dataSourceMap?[DataSourceRelated.previewTime]
          );
          setState(() {
            vidAuth = jsonMap['PlayAuth'] ?? '';
            vidId = apsaraId;
          });

          fAliplayer?.prepare().then((value) {
            // try {
            //   if (mounted) {
            //     setState(() {
            //       isloading = false;
            //     });
            //   } else {
            //     isloading = false;
            //   }
            // } catch (e) {
            //   isloading = false;
            // }
          });
          final isViewed = widget.data?.isViewed ?? true;
          print('isViewed Setting: ${widget.index} | ${widget.data?.isViewed} | $isViewed');
          final ref = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
          ref.tempAdsData = null;
          if (widget.inLanding && !isViewed) {
            ref.hasShowedAds = false;
            ref.getAdsVideo(Routing.navigatorKey.currentContext ?? context, _videoDuration).whenComplete(() {
              if (widget.index != null) {
                (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().setIsViewed(widget.index!);
              }
            });
          }
          // fAliplayer?.play();
          print('=2=2=2=2=2=2=2prepare done');
        }
      }
    } catch (e) {
      // 'Failed to fetch ads data $e'.logger();
    }
    if (mounted) {
      setState(() {
        isloading = false;
      });
    } else {
      isloading = false;
    }
  }

  Future getOldVideoUrl() async {
    setState(() {
      isloading = true;
    });
    try {
      globalInternetConnection = await System().checkConnections();
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: widget.data?.postID ?? '', check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        setState(() {
          urlVid = jsonMap['data']['url'];
          fAliplayer?.setUrl(urlVid);
          isloading = false;
        });
        fAliplayer?.prepare().then((value) {
          setState(() {
            isloading = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  // _initAds(BuildContext context) async {
  //   //for ads
  //   // getCountVid();
  //   await _newInitAds(context, true);
  //   // if (context.getAdsCount() == null) {
  //   //   context.setAdsCount(0);
  //   // } else {
  //   //   if (context.getAdsCount() == 5) {
  //   //     await _newInitAds(context, true);
  //   //   } else if (context.getAdsCount() == 2) {
  //   //     // await _newInitAds(false);
  //   //   }
  //   // }
  // }
  //
  // Future _newInitAds(BuildContext context, bool isContent) async {
  //   if (isContent) {
  //     context.setAdsCount(0);
  //   }
  //   try {
  //     if (notifier.mapInContentAds[widget.data?.postID ?? ''] == null) {
  //       context.read<VidDetailNotifier>().getAdsVideo(context, isContent);
  //     }
  //   } catch (e) {
  //     'Failed to fetch ads data 0 : $e'.logger();
  //   }
  // }

  void playVideo(VideoNotifier notifier) async {
    if (mounted) {
      globalAliPlayer = widget.data?.fAliplayer;
      print("ini play");
      print("=========================================");
      print(urlVid);
      print(widget.data?.description);
      print(widget.data?.postID);

      if (widget.onPlay != null) {
        widget.onPlay!(widget.data ?? ContentData());
      }

      // if (widget.inLanding) {
      // _initAds(context);
      //   context.incrementAdsCount();
      // }
      setState(() {
        isPlay = true;
        _showLoading = true;
      });
      fAliplayer?.setMuted(isMute);
      fAliplayer?.play();
      await fAliplayer?.prepare().whenComplete(() {}).onError((error, stackTrace) => print('Error Loading video: $error'));

      // Future.delayed(const Duration(seconds: 1), () {
      //   if (isPlay) {
      //     fAliplayer?.play();
      //     setState(() {
      //       isPlay = true;
      //       // _showLoading = false;
      //     });
      //   }
      // });

      System().increaseViewCount2(context, widget.data ?? ContentData()).whenComplete(() {});
    }
  }

  void playTest(String postId) {
    print('someMethod is called');
    print(postId);
    print(widget.data?.postID);
    if (postId == (widget.data?.postID ?? '')) {
      setState(() {
        isPlay = true;
        // _showLoading = false;
      });
    }
  }

  void someMethod() {
    print('someMethod is called');
  }

  // Future initAdsVideo() async {
  //   try {
  //     // print('data : ${fetch.data.toString()}');
  //     fAliplayerAds = FlutterAliPlayerFactory.createAliPlayer(playerId: 'iklanVideo ${adsData?.data?.videoId}');
  //     fAliplayerAds?.setAutoPlay(true);
  //     '("========== videoId : ${adsData?.data?.videoId}'.logger();
  //     secondsSkip = adsData?.data?.adsSkip ?? 0;
  //     skipAdsCurent = secondsSkip;
  //     print("========== get source ads 1 ${_dataSourceAdsMap?[DataSourceRelated.vidKey]}");
  //     fAliplayerAds?.setVidAuth(
  //         vid: adsData?.data?.videoId,
  //         region: 'ap-southeast-5',
  //         playAuth: adsData?.data?.apsaraAuth,
  //         definitionList: _dataSourceAdsMap?[DataSourceRelated.definitionList],
  //         previewTime: _dataSourceAdsMap?[DataSourceRelated.previewTime]);
  //     fAliplayerAds?.setPreferPlayerName(GlobalSettings.mPlayerName);
  //     fAliplayerAds?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
  //     fAliplayerAds?.setOnPrepared((playerId) {
  //       // Fluttertoast.showToast(msg: "OnPrepared ");
  //       fAliplayerAds?.getPlayerName().then((value) => print("getPlayerName==${value}"));
  //       fAliplayerAds?.getMediaInfo().then((value) {
  //         _videoAdsDuration = value['duration'];
  //         setState(() {
  //           isPrepare = true;
  //         });
  //       });
  //     });
  //     fAliplayerAds?.setOnRenderingStart((playerId) {
  //       // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
  //     });
  //     fAliplayerAds?.setOnLoadingStatusListener(loadingBegin: (playerId) {
  //       setState(() {
  //         _loadingPercent = 0;
  //         _showLoading = true;
  //       });
  //     }, loadingProgress: (percent, netSpeed, playerId) {
  //       _loadingPercent = percent;
  //       if (percent == 100) {
  //         _showLoading = false;
  //       }
  //       setState(() {});
  //     }, loadingEnd: (playerId) {
  //       setState(() {
  //         _showLoading = false;
  //       });
  //     });
  //     fAliplayerAds?.setOnSeekComplete((playerId) {
  //       _inSeek = false;
  //     });
  //     fAliplayerAds?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
  //       if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
  //         if (_videoAdsDuration != 0 && (extraValue ?? 0) <= _videoAdsDuration) {
  //           _currentAdsPosition = extraValue ?? 0;
  //         }
  //         if (!_inSeek) {
  //           setState(() {
  //             _currentAdsPositionText = extraValue ?? 0;
  //             if (skipAdsCurent > 0) {
  //               skipAdsCurent = (secondsSkip - (_currentAdsPositionText / 1000)).round();
  //             }
  //             print("============= $_currentAdsPosition");
  //           });
  //         }
  //       } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
  //         _bufferPosition = extraValue ?? 0;
  //         if (mounted) {
  //           setState(() {});
  //         }
  //       } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
  //         // Fluttertoast.showToast(msg: "AutoPlay");
  //       } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
  //         // Fluttertoast.showToast(msg: "Cache Success");
  //       } else if (infoCode == FlutterAvpdef.CACHEERROR) {
  //         // Fluttertoast.showToast(msg: "Cache Error $extraMsg");
  //       } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
  //         // Fluttertoast.showToast(msg: "Looping Start");
  //       } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
  //         // Fluttertoast.showToast(msg: "change to soft ware decoder");
  //         // mOptionsFragment.switchHardwareDecoder();
  //       }
  //     });
  //     fAliplayerAds?.setOnCompletion((playerId) {
  //       _showTipsWidget = true;
  //       _showLoading = false;
  //       _tipsContent = "Play Again";
  //       isPause = true;
  //       setState(() {
  //         // isCompleteAds = true;
  //         // isActiveAds = false;
  //         _currentAdsPosition = _videoAdsDuration;
  //         print("========== $isCompleteAds || $isActiveAds");
  //         // adsData = null;
  //         isPlay = true;
  //       });
  //       // fAliplayerAds?.stop();
  //       // fAliplayerAds?.destroy();
  //       fAliplayer?.prepare().whenComplete(() => _showLoading = false);
  //       fAliplayer?.isAutoPlay();
  //       fAliplayer?.play();
  //       // fAliplayer!.play();
  //     });
  //
  //     // await getAdsVideoApsara(adsData?.data?.videoId ?? '');
  //   } catch (e) {
  //     'Failed to fetch ads data $e'.logger();
  //   } finally {
  //     if (widget.getAdsPlayer != null && fAliplayerAds != null) {
  //       widget.getAdsPlayer!(fAliplayerAds!);
  //     }
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        // _setNetworkChangedListener();
        break;
      case AppLifecycleState.paused:
        if (!_mEnablePlayBack) {
          "=============== pause 4".logger();
          fAliplayer?.pause();
        }
        if (_networkSubscriptiion != null) {
          _networkSubscriptiion?.cancel();
        }
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }

  @override
  void didUpdateWidget(covariant VidPlayerPage oldWidget) {
    // If you want to react only to changes you could check
    // oldWidget.selectedIndex != widget.selectedIndex
    if (mounted) {
      if (oldWidget.isPlaying != widget.isPlaying) {
        "===================== isPlaying ${widget.isPlaying}".logger();
        if (widget.isPlaying ?? true) {
          fAliplayer?.setMuted(isMute);
          fAliplayer?.play();
        } else {
          "=============== pause 0".logger();
          fAliplayer?.pause();
        }
        // this syntax below to prevent video play after changing video
        Future.delayed(const Duration(seconds: 1), () {
          if (context.read<MainNotifier>().isInactiveState) {
            "=============== pause 1".logger();
            fAliplayer?.pause();
          }
        });
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    print("-=-=-=-=-=-=disepose vid");
    fAliplayer?.stop();
    fAliplayer?.destroy();
    // animatedController.dispose();
    // Wakelock.disable();
    globalAliPlayer = null;
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    // fAliplayer?.stop();
    // fAliplayer?.destroy();
    // if (adsData != null) {
    //   fAliplayerAds?.stop();
    //   fAliplayerAds?.destroy();
    // }

    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (_networkSubscriptiion != null) {
      _networkSubscriptiion?.cancel();
    }
  }

  void changeStatusBlur() {
    setState(() {
      widget.data?.reportedStatus = "";
    });
  }

  Future<VideoIndicator> navigateTo(VideoNotifier notifier, int changevalue) async {
    print('page fullscreen ${widget.isVidFormProfile ?? false}');
    if (widget.isVidFormProfile ?? false) {
      // if (isPause)
      return await Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
            builder: (_) => VidScrollFullScreenPage(
                enableWakelock: widget.enableWakelock,
                aliPlayerView: aliPlayerView!,
                isVidFormProfile: widget.isVidFormProfile ?? false,
                thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                fAliplayer: fAliplayer,
                data: widget.data ?? ContentData(),
                onClose: () {
                  setState(() {
                    isPlay = true;
                  });
                },
                slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation),
                videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                vidData: widget.vidData,
                index: widget.index,
                clearPostId: widget.clearPostId,
                loadMoreFunction: () {
                  widget.loadMoreFunction?.call();
                },
                isAutoPlay: false,
                isLanding: widget.inLanding),
            settings: const RouteSettings()),
      );
    } else {
      return await Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
            builder: (_) => VideoFullscreenPage(
                enableWakelock: widget.enableWakelock,
                aliPlayerView: aliPlayerView!,
                thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                fAliplayer: fAliplayer,
                data: widget.data ?? ContentData(),
                onClose: () {
                  setState(() {
                    isPlay = true;
                  });
                },
                slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation),
                videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                vidData: widget.vidData,
                index: widget.index,
                clearPostId: widget.clearPostId,
                loadMoreFunction: () {
                  // widget.loadMoreFunction?.call();
                },
                isAutoPlay: widget.isAutoPlay,
                isLanding: widget.inLanding),
            settings: const RouteSettings()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data!.isLoading) {
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          widget.data!.isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 50), () {
          widget.data!.isLoading = true;
          Future.delayed(const Duration(milliseconds: 50), () {
            widget.data!.isLoading = false;
          });
        });
      });
    }
    return Consumer<VideoNotifier>(builder: (context, notifier, _) {
      if (isloading) {
        return Stack(
          key: ValueKey<bool>(isloading),
          children: [
            Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(widget.fromFullScreen ? 0 : 16),
              ),
              child: VideoThumbnail(
                videoData: widget.data,
                onDetail: false,
                fn: () {},
                withMargin: true,
              ),
            ),
            const Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: kHyppePrimary,
                ),
              ),
            )
          ],
        );
      } else {
        // print("onViewPlayerCreated ${onViewPlayerCreated}");
        aliPlayerView = AliPlayerView(
          onCreated: onViewPlayerCreated,
          x: 0.0,
          y: 0.0,
          width: widget.width,
          height: widget.height,
          aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
        );
        // AliPlayerView aliPlayerAdsView = AliPlayerView(onCreated: onViewPlayerAdsCreated, x: 0.0, y: 0.0, width: widget.width, height: widget.height);
        if (notifier.mapInContentAds[widget.data?.postID ?? ''] != null) {
          adsPlayerPage = AdsPlayerPage(
            dataSourceMap: {
              DataSourceRelated.vidKey: notifier.mapInContentAds[widget.data?.postID ?? '']?.videoId,
              DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
            },
            width: widget.width,
            height: widget.height,
            thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
            data: notifier.mapInContentAds[widget.data?.postID ?? ''],
            functionFullTriger: () {},
            getPlayer: (player) {},
            onStop: () {
              notifier.setMapAdsContent(widget.data?.postID ?? '', null);
              if (widget.onShowAds != null) {
                widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
              }
            },
            fromFullScreen: widget.fromFullScreen,
            onFullscreen: () {
              print('onFullScreen VideoPlayer: ${notifier.isShowingAds} ${widget.fromFullScreen}');
              if (widget.fromFullScreen) {
                Routing().moveBack();
              } else {
                onFullscreen(notifier);
              }
            },
            onClose: () {
              if (mounted) {
                notifier.setMapAdsContent(widget.data?.postID ?? '', null);
                setState(() {
                  isPlay = true;

                  if (widget.onShowAds != null) {
                    widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                  }
                  isloading = false;
                });
              } else {
                isPlay = true;

                notifier.setMapAdsContent(widget.data?.postID ?? '', null);
                if (widget.onShowAds != null) {
                  widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                }
                isloading = false;
              }

              if (!notifier.isFullScreen) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  fAliplayer?.play();
                  setState(() {
                    isPause = false;
                    _showTipsWidget = false;
                  });
                });
              } else if (widget.fromFullScreen) {
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
        return AnimatedSwitcher(
          duration: const Duration(),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: Builder(
              key: ValueKey<bool>(isloading),
              builder: (context) {
                if (notifier.isPlay) {
                  isPlay = true;
                }
                if (widget.data!.reportedStatus == 'BLURRED' && widget.fromFullScreen) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    fAliplayer!.pause();
                    isPlay = false;
                  });
                }

                return (widget.data!.reportedStatus == 'BLURRED' && widget.fromFullScreen)
                    ? blurContentWidget(context, widget.data!)
                    : GestureDetector(
                        onTap: () async {
                          if (isPlay) print('page fullscreen $isPause $isPlay');
                          setState(() {
                            onTapCtrl = true;
                          });
                          if (!widget.fromFullScreen && (widget.isVidFormProfile ?? false) && !isPlay) {
                            fAliplayer?.play();
                            setState(() {
                              isPause = false;
                            });
                          } else {
                            print('data Fullscreen ${widget.fromFullScreen}');
                            if (!widget.fromFullScreen) {
                              int changevalue;
                              changevalue = _currentPosition + 1000;
                              if (changevalue > _videoDuration) {
                                changevalue = _videoDuration;
                              }

                              print("========= aaaa ${notifier.mapInContentAds[widget.data?.postID ?? ''] != null}");
                              if (notifier.mapInContentAds[widget.data?.postID ?? ''] == null && !isPause) {
                                if (widget.orientation == Orientation.portrait) {
                                  "=============== pause 3".logger();
                                  // fAliplayer?.pause();
                                  // setState(() {
                                  //   isloading = true;
                                  // });
                                  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                                  if ((widget.data?.metadata?.height ?? 0) < (widget.data?.metadata?.width ?? 0)) {
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
                                  notifier.firstIndex = widget.index ?? 0;
                                  VideoIndicator value = await navigateTo(notifier, changevalue);
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

                                  // int changevalue;
                                  // changevalue = _currentPosition + 1000;
                                  // if (changevalue > _videoDuration) {
                                  //   changevalue = _videoDuration;
                                  // }

                                  notifier.isLoading = true;
                                  Future.delayed(const Duration(seconds: 6), () {
                                    notifier.isLoading = false;
                                  });

                                  if (widget.isVidFormProfile ?? false) {
                                    var notifScroll = context.read<ScrollVidNotifier>();
                                    notifScroll.itemScrollController.jumpTo(index: notifScroll.lastScrollIndex);
                                    // if (widget.index != notifScroll.lastScrollIndex){

                                    //   fAliplayer?.prepare();
                                    // }
                                  }
                                  fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
                                    if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
                                      if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
                                        _currentPosition = extraValue ?? 0;
                                      }
                                      if (!_inSeek) {
                                        try {
                                          setState(() {
                                            _currentPositionText = extraValue ?? 0;
                                          });
                                        } catch (e) {
                                          print(e);
                                        }
                                      }
                                    } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
                                      // _bufferPosition = extraValue ?? 0;
                                      if (mounted) {
                                        setState(() {});
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
                                }
                              } else {
                                Navigator.pop(context, changevalue);
                              }
                            }
                          }
                        },
                        onDoubleTap: () {
                          if (notifier.tempAdsData == null) {
                            final likeNotifier = context.read<LikeNotifier>();
                            if (widget.data != null) {
                              likeNotifier.likePost(context, widget.data!);
                            }
                          }
                        },
                        child: Stack(
                          children: [
                            if (notifier.mapInContentAds[widget.data?.postID ?? ''] == null || (notifier.mapInContentAds[widget.data?.postID ?? ''] != null && !widget.inLanding))
                              widget.data!.isLoading
                                  ? Container(color: Colors.black, width: widget.width, height: widget.height)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(widget.fromFullScreen ? 0 : 16),
                                      ),
                                      child: Container(color: Colors.black, width: widget.width, height: widget.height, child: isPlay ? aliPlayerView : const SizedBox.shrink())),
                            if (widget.fromFullScreen)
                              GestureDetector(
                                onTap: () {
                                  //// fungsi tap dimana saja
                                  onTapCtrl = true;
                                  setState(() {});
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  height: SizeConfig.screenHeight,
                                  width: SizeConfig.screenWidth,
                                ),
                              ),
                            // Text("${adsData == null}"),
                            // Text("${SharedPreference().readStorage(SpKeys.countAds)}"),
                            // /====slide dan tombol fullscreen

                            if (isPlay)
                              SizedBox(
                                  width: widget.width,
                                  height: widget.height,
                                  child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation))),

                            if (widget.fromFullScreen)
                              AnimatedOpacity(
                                opacity: onTapCtrl || isPause ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                onEnd: _onPlayerHide,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      child: Container(
                                        height: widget.orientation == Orientation.portrait ? kToolbarHeight * 2 : kToolbarHeight * 1.4,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18.0),
                                        child: CustomAppBar(
                                            isVidFormProfile: widget.isVidFormProfile ?? false,
                                            orientation: widget.orientation,
                                            data: widget.data ?? ContentData(),
                                            currentPosition: _currentPosition,
                                            currentPositionText: _currentPositionText,
                                            showTipsWidget: _showTipsWidget,
                                            videoDuration: _videoDuration,
                                            email: email,
                                            lang: lang!,
                                            isMute: isMute,
                                            onTapOnProfileImage: () async {
                                              var res = await System().navigateToProfile(context, widget.data?.email ?? '');
                                              fAliplayer?.pause();
                                              isPause = true;
                                              setState(() {});
                                              print('data result $res');
                                              if (res != null && res == true) {
                                                if ((widget.data?.metadata?.height ?? 0) < (widget.data?.metadata?.width ?? 0)) {
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
                                              }
                                            },
                                            onTap: () {
                                              context.handleActionIsGuest(() async {
                                                if (widget.data?.email != email) {
                                                  context.read<PreviewPicNotifier>().reportContent(context, widget.data!, fAliplayer: widget.data!.fAliplayer, onCompleted: () async {
                                                    imageCache.clear();
                                                    imageCache.clearLiveImages();
                                                    await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                                  });
                                                  isPause = true;
                                                  setState(() {});
                                                } else {
                                                  // if (_curIdx != -1) {
                                                  //   "=============== pause 11".logger();
                                                  //   notifier.vidData?[_curIdx].fAliplayer?.pause();
                                                  // }
                                                  ShowBottomSheet().onShowOptionContent(
                                                    context,
                                                    contentData: widget.data!,
                                                    captionTitle: hyppeVid,
                                                    onDetail: false,
                                                    orientation: widget.orientation,
                                                    isShare: widget.data!.isShared,
                                                    onUpdate: () {
                                                      Routing().moveBack();
                                                      Routing().moveBack();
                                                      Routing().moveBack();

                                                      (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                                    },
                                                    fAliplayer: widget.data!.fAliplayer,
                                                  ).then((value) => print('disini datas popup'));
                                                  widget.data!.fAliplayer?.pause();
                                                  isPause = true;
                                                  setState(() {});
                                                }
                                              });
                                            }),
                                      ),
                                    ),
                                    _buttomBodyRight(),
                                  ],
                                ),
                              ),
                            if (!isPlay && !widget.fromFullScreen)
                              SizedBox(
                                height: widget.height,
                                width: widget.width,
                                child: VideoThumbnail(
                                  videoData: widget.data,
                                  onDetail: false,
                                  fn: () {},
                                  withMargin: true,
                                ),
                              ),
                            // Text("${SharedPreference().readStorage(SpKeys.countAds)}"),
                            // if (isPlay && adsData != null) skipAds(),
                            if (!isPlay && !_showLoading & !(widget.isAutoPlay ?? false))
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    globalAliPlayer = widget.data?.fAliplayer;
                                    print("ini play");
                                    print("=========================================");
                                    print(urlVid);
                                    print(widget.data?.description);
                                    print(widget.data?.postID);

                                    if (widget.onPlay != null) {
                                      widget.onPlay!(widget.data ?? ContentData());
                                    }

                                    // if (widget.inLanding) {
                                    // _initAds(context);
                                    //   context.incrementAdsCount();
                                    // }
                                    setState(() {
                                      isPlay = true;
                                      _showLoading = true;
                                    });
                                    notifier.hasShowedAds = false;
                                    fAliplayer?.play();
                                    await fAliplayer?.prepare().whenComplete(() {}).onError((error, stackTrace) => print('Error Loading video: $error'));
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (isPlay) {
                                        fAliplayer?.play();
                                        setState(() {
                                          isPlay = true;
                                          // _showLoading = false;
                                        });
                                      }
                                    });

                                    System().increaseViewCount2(context, widget.data ?? ContentData()).whenComplete(() async {
                                      // final count = context.getAdsCount();
                                      // if(count == 5){
                                      //   final adsData = await context.getInBetweenAds();
                                      //   widget.betweenAds(adsData);
                                      // }
                                      // context.incrementAdsCount();
                                    });
                                    // if (adsData != null && widget.inLanding) {
                                    //   fAliplayerAds?.prepare().whenComplete(() {
                                    //     setState(() {
                                    //       _showLoading = false;
                                    //     });
                                    //   }).onError((error, stackTrace) => print('Error Loading video: $error'));
                                    //   fAliplayerAds?.play();
                                    //   setState(() {
                                    //     isActiveAds = true;
                                    //   });
                                    // } else {
                                    //   fAliplayer?.prepare().whenComplete(() {
                                    //     setState(() {
                                    //       _showLoading = false;
                                    //     });
                                    //   }).onError((error, stackTrace) => print('Error Loading video: $error'));
                                    //   fAliplayer?.play();
                                    //   System().increaseViewCount2(context, widget.data ?? ContentData());
                                    // }
                                  },
                                  child: Visibility(
                                    visible: (widget.data?.reportedStatus != "BLURRED"),
                                    child: SizedBox(
                                      width: widget.width,
                                      height: widget.height,
                                      child: const CustomIconWidget(
                                        defaultColor: false,
                                        width: 40,
                                        iconData: '${AssetPath.vectorPath}pause2.svg',
                                        // color: kHyppeLightButtonText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!isPlay && (widget.data?.tagPeople?.isNotEmpty ?? false))
                              Positioned(
                                bottom: 18,
                                left: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<PicDetailNotifier>().showUserTag(context, widget.data?.tagPeople, widget.data?.postID, title: lang!.inThisVideo);
                                  },
                                  child: const CustomIconWidget(
                                    iconData: '${AssetPath.vectorPath}tag_people.svg',
                                    defaultColor: false,
                                    height: 24,
                                  ),
                                ),
                              ),

                            _buildProgressBar(widget.width ?? 0, widget.height ?? 0),
                            // _buildTipsWidget(widget.width ?? 0, widget.height ?? 0),
                            if (isPlay)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: _buildController(Colors.transparent, Colors.white, 120, widget.width!, widget.height! * 0.8, widget.orientation),
                                ),
                              ),
                            if (notifier.mapInContentAds[widget.data?.postID ?? ''] != null && isPlay && !(widget.isVidFormProfile ?? false))
                              Positioned.fill(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(widget.fromFullScreen ? 0 : 16),
                                      ),
                                      child: Container(color: Colors.black, width: widget.width, height: widget.height, child: adsPlayerPage))),
                          ],
                        ),
                      );
              }),
        );
      }
    });
  }

  void onViewPlayerCreated(viewId) async {
    await fAliplayer?.setPlayerView(viewId);
    final getPlayers = widget.getPlayer;
    if (getPlayers != null) {
      if (fAliplayer != null) {
        getPlayers(fAliplayer!, widget.data?.postID ?? '');
      }
    }
    switch (widget.data?.apsara) {
      case false:
        fAliplayer?.setUrl(urlVid);
        break;
      case true:
        fAliplayer?.setVidAuth(
          vid: vidId,
          playAuth: vidAuth,
          region: _dataSourceMap?[DataSourceRelated.regionKey],
          definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
          // previewTime: _dataSourceMap?[DataSourceRelated.previewTime]
        );
        break;
    }
  }

  // void onViewPlayerAdsCreated(viewId) async {
  //   fAliplayerAds?.setPlayerView(viewId);
  // }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      // setState(() {});
    });
  }

  Widget skipAds() {
    return Positioned.fill(
      bottom: 40,
      child: Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: () {
              if (skipAdsCurent == 0) {
                adsComleteOrSkip();
              }
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    width: skipAdsCurent == 0 ? null : 100,
                    child: Text(
                      skipAdsCurent > 0 ? " Your video will begin in $skipAdsCurent" : " SkipdAds",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  skipAdsCurent == 0
                      ? const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        )
                      : Container(),
                  Container(
                      child: Image.network(
                    (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                  )),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildController(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double width,
    double height,
    Orientation orientation,
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      onEnd: _onPlayerHide,
      child: Container(
        width: orientation == Orientation.landscape ? width * .35 : width * .8,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.fromFullScreen) Expanded(child: _buildSkipPrev(iconColor, height)),
            if (widget.fromFullScreen) Expanded(child: _buildSkipBack(iconColor, height)),
            _buildPlayPause(iconColor, barHeight),
            if (widget.fromFullScreen) Expanded(child: _buildSkipForward(iconColor, height)),
            if (widget.fromFullScreen) Expanded(child: _buildSkipNext(iconColor, height)),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildSkipPrev(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        // if (!onTapCtrl) return;
        // previousPage();
        widget.prevScroll?.call();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}previous.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipNext(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        widget.autoScroll?.call();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}next.svg",
        defaultColor: false,
      ),
    );
  }

  Widget _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (context.read<VideoNotifier>().mapInContentAds[widget.data?.postID ?? ''] == null) {
          if (isPause) {
            // if (_showTipsWidget) fAliplayer?.prepare();
            if ((widget.isVidFormProfile ?? false) && _currentPosition == _videoDuration) {
              _currentPosition = 0;
              _inSeek = false;
              setState(() {
                if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
                  setState(() {
                    _showTipsWidget = false;
                  });
                }
              });
              fAliplayer?.seekTo(_currentPosition.ceil(), FlutterAvpdef.ACCURATE);
            }
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
        }
      },
      child: CustomIconWidget(
        iconData: isPause
            ? widget.fromFullScreen
                ? '${AssetPath.vectorPath}play3.svg'
                : '${AssetPath.vectorPath}pause2.svg'
            : "${AssetPath.vectorPath}pause3.svg",
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

  Widget _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        // if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }

        changevalue = _currentPosition - value;
        if (changevalue < 0) {
          changevalue = 0;
        }
        print("currSeek: $value, changeSeek: $changevalue");
        fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: Container(
        // color: Colors.blue,
        padding: const EdgeInsets.all(8.0),
        child: const CustomIconWidget(
          iconData: "${AssetPath.vectorPath}replay10.svg",
          defaultColor: false,
        ),
      ),
    );
  }

  Widget _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        // if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }
        changevalue = _currentPosition + value;
        if (changevalue > _videoDuration) {
          changevalue = _videoDuration;
        }
        print("currSeek: $value, changeSeek: $changevalue");
        fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: Container(
        // color: Colors.red,
        padding: const EdgeInsets.all(8.0),
        child: const CustomIconWidget(
          iconData: "${AssetPath.vectorPath}forward10.svg",
          defaultColor: false,
        ),
      ),
    );
  }

  ///提示Widget
  _buildTipsWidget(double width, double height) {
    if (_showTipsWidget) {
      return Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_tipsContent, maxLines: 3, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(
              height: 5.0,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: BeveledRectangleBorder(
                  side: const BorderSide(
                    style: BorderStyle.solid,
                    color: Colors.blue,
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text("Replay", style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _showTipsWidget = false;
                });
                // fAliplayer?.prepare();
                fAliplayer?.play();
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  //网络提示Widget
  _buildNetWorkTipsWidget(double widgetWidth, double widgetHeight) {
    return Offstage(
      offstage: !_isShowMobileNetWork,
      child: Container(
        alignment: Alignment.center,
        width: widgetWidth,
        height: widgetHeight,
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text("Currently mobile web", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(
              height: 30.0,
            ),
            Wrap(
              direction: Axis.horizontal,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: BeveledRectangleBorder(
                      side: const BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blue,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text("keep playing", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _isShowMobileNetWork = false;
                    });
                    fAliplayer?.play();
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: BeveledRectangleBorder(
                      side: const BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blue,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text("quit playing", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _isShowMobileNetWork = false;
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///Loading
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
    } else {
      return const SizedBox();
    }
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
    switch (widget.fromFullScreen) {
      case true:
        return AnimatedOpacity(
          opacity: onTapCtrl || isPause ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          onEnd: _onPlayerHide,
          child: SafeArea(
              child: _currentPosition <= 0
                  ? Container()
                  : Container(
                      decoration: orientation == Orientation.portrait
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                end: const Alignment(0.0, -1),
                                begin: const Alignment(0.0, 1),
                                colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
                              ),
                            )
                          : null,
                      child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(children: [
                            Positioned(
                              bottom: widget.orientation == Orientation.portrait ? 28 : 0,
                              left: 0,
                              right: !widget.fromFullScreen
                                  ? 0
                                  : orientation == Orientation.landscape
                                      ? SizeConfig.screenHeight! * .2
                                      : SizeConfig.screenHeight! * .08,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        Visibility(
                                          visible: widget.data?.tagPeople?.isNotEmpty ?? false,
                                          child: Container(
                                            decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                            margin: const EdgeInsets.only(right: 12.0),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  fAliplayer?.pause();
                                                  context
                                                      .read<PicDetailNotifier>()
                                                      .showUserTag(context, widget.data?.tagPeople, widget.data?.postID, title: lang!.inThisVideo, fAliplayer: fAliplayer, orientation: orientation);
                                                },
                                                child: Row(
                                                  children: [
                                                    const CustomIconWidget(
                                                      iconData: '${AssetPath.vectorPath}tag-people-light.svg',
                                                      defaultColor: false,
                                                      height: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 4.0,
                                                    ),
                                                    Text(
                                                      '${widget.data?.tagPeople!.length} ${lang!.people}',
                                                      style: const TextStyle(color: kHyppeTextPrimary),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.data?.location != '',
                                          child: Container(
                                            decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                ),
                                                child: location()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: SizeConfig.screenWidth! * .7,
                                      maxHeight: widget.data!.description!.length > 24
                                          ? isShowMore
                                              ? 54
                                              : SizeConfig.screenHeight! * .1
                                          : 54),
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                    padding: const EdgeInsets.only(left: 8.0, top: 20),
                                    child: SingleChildScrollView(
                                      child: CustomDescContent(
                                        desc: widget.data?.description ?? '',
                                        trimLines: 2,
                                        textAlign: TextAlign.start,
                                        callbackIsMore: (val) {
                                          setState(() {
                                            isShowMore = val;
                                          });
                                        },
                                        seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                                        seeMore: ' ${lang?.more}', //${notifier2.translate.seeMoreContent}',
                                        normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                                        hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                        expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                                          (widget.data!.boosted.isEmpty) &&
                                          (widget.data!.reportedStatus != 'OWNED' && widget.data!.reportedStatus != 'BLURRED' && widget.data!.reportedStatus2 != 'BLURRED') &&
                                          widget.data!.email == SharedPreference().readStorage(SpKeys.email)
                                      ? Container(
                                          width: orientation == Orientation.landscape ? SizeConfig.screenWidth! * .28 : SizeConfig.screenWidth!,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.only(top: 12, left: 8.0, right: 8.0),
                                          child: ButtonBoost(
                                            onDetail: false,
                                            marginBool: true,
                                            contentData: widget.data ?? ContentData(),
                                            startState: () {
                                              SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                            },
                                            afterState: () {
                                              SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                            },
                                          ),
                                        )
                                      : Container(),
                                  if (widget.data!.email == email && (widget.data!.boostCount ?? 0) >= 0 && (widget.data!.boosted.isNotEmpty))
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 10, left: 18.0),
                                      width: MediaQuery.of(context).size.width * .18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: kHyppeGreyLight.withOpacity(.9),
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
                                            child: CustomTextWidget(
                                              textToDisplay: "${widget.data?.boostJangkauan ?? '0'} ${lang?.reach}",
                                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            "${System.getTimeformatByMs(_currentPositionText)}/${System.getTimeformatByMs(_videoDuration)}",
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SliderTheme(
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
                                                  max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                                                  value: _currentPosition.toDouble(),
                                                  activeColor: Colors.purple,
                                                  thumbColor: Colors.purple,
                                                  onChangeStart: (value) {
                                                    _inSeek = true;
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
                                                    fAliplayer?.requestBitmapAtPosition(value.ceil());

                                                    setState(() {
                                                      _currentPosition = value.ceil();
                                                    });
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (widget.data!.music?.musicTitle != '' && widget.data!.music?.musicTitle != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: CustomIconWidget(
                                                  iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                                  defaultColor: false,
                                                  color: kHyppeLightBackground,
                                                  height: 18,
                                                ),
                                              ),
                                              Expanded(
                                                child: _textSize(widget.data?.music?.musicTitle ?? '', const TextStyle(fontWeight: FontWeight.bold)).width > SizeConfig.screenWidth! * .56
                                                    ? SizedBox(
                                                        width: SizeConfig.screenWidth! * .56,
                                                        height: kTextTabBarHeight,
                                                        child: Marquee(
                                                          text: '  ${widget.data?.music?.musicTitle ?? ''}',
                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                                        ),
                                                      )
                                                    : CustomTextWidget(
                                                        textToDisplay: " ${widget.data!.music?.musicTitle ?? ''}",
                                                        maxLines: 1,
                                                        textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                                        textAlign: TextAlign.left,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: kHyppeSurface.withOpacity(.9),
                                            child: CustomBaseCacheImage(
                                              imageUrl: widget.data!.music?.apsaraThumnailUrl ?? '',
                                              imageBuilder: (_, imageProvider) {
                                                return Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: kDefaultIconDarkColor,
                                                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: imageProvider,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorWidget: (_, __, ___) {
                                                return const CustomIconWidget(
                                                  iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                                  defaultColor: false,
                                                  color: kHyppeLightBackground,
                                                  height: 18,
                                                );
                                              },
                                              emptyWidget: AnimatedBuilder(
                                                animation: animatedController,
                                                builder: (_, child) {
                                                  return Transform.rotate(
                                                    angle: animatedController.value * 2 * -math.pi,
                                                    child: child,
                                                  );
                                                },
                                                child: const CustomIconWidget(
                                                  iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                                  defaultColor: false,
                                                  color: kHyppeLightBackground,
                                                  height: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ])))),
        );

      default:
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
                                  if (widget.data?.tagPeople?.isNotEmpty ?? false)
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 12.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              fAliplayer?.pause();
                                              context.read<PicDetailNotifier>().showUserTag(context, widget.data?.tagPeople, widget.data?.postID, title: lang!.inThisVideo, fAliplayer: fAliplayer);
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
                          decoration: orientation == Orientation.portrait
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    end: const Alignment(0.0, -1),
                                    begin: const Alignment(0.0, 1),
                                    colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
                                  ),
                                )
                              : null,
                          child: Stack(
                            children: [
                              if (!widget.fromFullScreen)
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
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    return Stack(
      children: [
        Positioned.fill(
          child: VideoThumbnail(
            videoData: data,
            onDetail: false,
            fn: () {},
            withMargin: true,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: kHyppeBackground.withOpacity(.8),
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(lang!.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeVid ${lang!.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
                                  margin: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                                  child: Text(lang?.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          System().increaseViewCount2(context, data);
                          setState(() {
                            widget.data!.reportedStatus = '';
                          });
                          fAliplayer!.play();
                          isPlay = true;
                          // context.read<ReportNotifier>().seeContent(context, data, hyppePic);
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
                            "${lang!.see} HyppeVid",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Future onFullscreen(VideoNotifier notifier) async {
    int changeValue;
    changeValue = _currentPosition;
    if (changeValue > _videoDuration) {
      changeValue = _videoDuration;
    }
    print('change Value : $changeValue');
    if (widget.orientation == Orientation.portrait) {
      print('pause here 1');
      fAliplayer?.pause();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if ((widget.data?.metadata?.height ?? 0) < (widget.data?.metadata?.width ?? 0)) {
        print('Landscape VidPlayerPage');
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        print('Portrait VidPlayerPage');
      }
      setState(() {
        notifier.isFullScreen = true;
      });
      notifier.isShowingAds = notifier.mapInContentAds[widget.data?.postID ?? ''] != null;

      VideoIndicator value = await Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
          builder: (_) => VideoFullscreenPage(
                aliPlayerView: aliPlayerView!,
                thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                // adsPlayer: adsPlayerPage!,
                fAliplayer: fAliplayer,
                data: widget.data ?? ContentData(),
                onClose: () {
                  isPlay = true;

                  notifier.setMapAdsContent(widget.data?.postID ?? '', null);
                  if (widget.onShowAds != null) {
                    widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                  }
                  notifier.hasShowedAds = true;
                  notifier.tempAdsData = null;
                  notifier.isShowingAds = false;
                  // Routing().moveBack();
                },
                slider: _buildContentWidget(context, widget.orientation),
                videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changeValue, positionText: _currentAdsPositionText, isMute: isMute),
                vidData: widget.vidData,
                index: widget.index,
                clearPostId: widget.clearPostId,
                loadMoreFunction: () {
                  print("loadmore function vidplayer");
                  widget.loadMoreFunction?.call();
                },
                isAutoPlay: widget.isAutoPlay,
                isLanding: widget.inLanding,
              ),
          settings: const RouteSettings()));
      notifier.isShowingAds = notifier.mapInContentAds[widget.data?.postID ?? ''] != null;
      notifier.isLoading = true;
      Future.delayed(const Duration(seconds: 1), () {
        notifier.isLoading = false;
      });

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
      notifier.isFullScreen = false;

      fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
        if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
          if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
            _currentPosition = extraValue ?? 0;
            final detik = (_currentPosition / 1000).round();
            if (notifier.adsTime == detik) {
              if (notifier.tempAdsData != null) {
                print('pause here 2');
                fAliplayer?.pause();
                notifier.setMapAdsContent(widget.data?.postID ?? '', notifier.tempAdsData);
                if (widget.onShowAds != null) {
                  widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                }
              }
            }
          }
          if (!_inSeek) {
            try {
              setState(() {
                _currentPositionText = extraValue ?? 0;
              });
            } catch (e) {
              print(e);
            }
          }
        } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
          // _bufferPosition = extraValue ?? 0;
          if (mounted) {
            setState(() {});
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
    } else {
      Navigator.pop(context, changeValue);
    }
  }

  void adsComleteOrSkip() {
    // adsView(adsData?.data ?? AdsData(), _currentAdsPosition);

    /////
    _showTipsWidget = true;
    _showLoading = false;
    _tipsContent = "Play Again";
    isPause = true;
    setState(() {
      // isCompleteAds = true;
      // isActiveAds = false;
      _currentAdsPosition = _videoAdsDuration;
      print("========== $isCompleteAds || $isActiveAds");
      // adsData = null;
      isPlay = true;
    });
    // fAliplayerAds?.stop();
    // fAliplayerAds?.destroy();
    fAliplayer?.prepare().whenComplete(() => _showLoading = false);
    fAliplayer?.isAutoPlay();
    fAliplayer?.play();

    ///
    // fAliplayerAds?.stop();
    isActiveAds = false;

    (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>().setMapAdsContent(widget.data?.postID ?? '', null);
    (Routing.navigatorKey.currentContext ?? context).read<VidDetailNotifier>().adsData = null;
    setState(() {});
  }

  Widget buttonVideoRight({Function()? onFunctionTap, required String iconData, required String value, bool liked = false}) {
    return InkResponse(
      onTap: onFunctionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: onFunctionTap,
              child: CustomIconWidget(
                defaultColor: false,
                color: liked ? kHyppeRed : kHyppePrimaryTransparent,
                iconData: iconData,
                height: liked ? 24 : 38,
                width: 38,
              ),
            ),
            if (liked)
              const SizedBox(
                height: 10.0,
              ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              child: Text(
                value,
                style: const TextStyle(shadows: [
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Colors.black54),
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 8.0, color: Colors.black54),
                ], color: kHyppePrimaryTransparent, fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttomBodyRight() {
    return Positioned(
      right: 18,
      bottom: 0,
      child: Column(
        children: [
          Consumer<LikeNotifier>(
              builder: (context, likeNotifier, child) => buttonVideoRight(
                  onFunctionTap: () {
                    likeNotifier.likePost(context, widget.data!);
                  },
                  iconData: '${AssetPath.vectorPath}${(widget.data?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                  value: widget.data!.insight!.likes! > 0 ? '${widget.data?.insight?.likes}' : '${lang?.like}',
                  liked: widget.data?.insight?.isPostLiked ?? false)),
          if (widget.data!.allowComments ?? false)
            buttonVideoRight(
              onFunctionTap: () {
                Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: widget.data?.postID ?? '', fromFront: true, data: widget.data!, pageDetail: widget.fromFullScreen));
              },
              iconData: '${AssetPath.vectorPath}comment-shadow.svg',
              value: widget.data!.comments! > 0 ? widget.data!.comments.toString() : lang?.comments ?? '',
            ),
          if (widget.data?.isShared ?? false)
            buttonVideoRight(
                onFunctionTap: () {
                  fAliplayer?.pause();
                  context.read<VidDetailNotifier>().createdDynamicLink(context, data: widget.data);
                },
                iconData: '${AssetPath.vectorPath}share-shadow.svg',
                value: lang!.share ?? 'Share'),
          if ((widget.data?.saleAmount ?? 0) > 0 && email != widget.data?.email)
            buttonVideoRight(
                onFunctionTap: () async {
                  fAliplayer?.pause();
                  await ShowBottomSheet.onBuyContent(context, data: widget.data, fAliplayer: widget.data?.fAliplayer);
                },
                iconData: '${AssetPath.vectorPath}cart-shadow.svg',
                value: lang!.buy ?? 'Buy'),
        ],
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget location() {
    switch (widget.orientation) {
      case Orientation.portrait:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: widget.data?.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .4 : SizeConfig.screenWidth! * .65,
              child: Text(
                '${widget.data?.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: widget.data?.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .13 : SizeConfig.screenWidth! * .22,
              child: Text(
                '${widget.data?.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }
}
