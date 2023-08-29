import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/advertising/view_ads_request.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../../../../../app.dart';

class VidPlayerPage extends StatefulWidget {
  final bool? fromFullScreen;
  final ModeTypeAliPLayer playMode;
  final Map<String, dynamic> dataSourceMap;
  final ContentData? data;
  double? height;
  double? width;
  final bool inLanding;
  final bool fromDeeplink;
  final Function functionFullTriger;
  final Function(FlutterAliplayer)? getPlayer;
  final Function(FlutterAliplayer)? getAdsPlayer;
  final Function(ContentData)? onPlay;
  final Orientation orientation;
  final List<ContentData>? vidData;
  final int? index;
  final Function()? loadMoreFunction;
  final Function()? clearPostId; //netral player
  final bool? isPlaying;
  final bool clearing;
  final bool? isAutoPlay;
  final Function()? autoScroll; //netral player

  // FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;

  VidPlayerPage({
    Key? key,
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
    required this.orientation,
    this.vidData,
    this.fromFullScreen,
    this.index,
    this.loadMoreFunction,
    this.isPlaying,
    this.clearPostId,
    this.clearing = false,
    this.isAutoPlay = false,
    this.autoScroll,

    // this.fAliplayer,
    // this.fAliplayerAds
  }) : super(key: key);

  @override
  State<VidPlayerPage> createState() => VidPlayerPageState();
}

class VidPlayerPageState extends State<VidPlayerPage> with WidgetsBindingObserver {
  FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  Map<String, dynamic>? _dataSourceAdsMap;
  String urlVid = '';
  String _savePath = '';
  bool isMute = false;
  bool isPotraitFull = false;
  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  bool _mEnablePlayBack = false;

  //当前播放进度
  int _currentPosition = 0;
  int _currentAdsPosition = 0;

  //当前播放时间，用于Text展示
  int _currentPositionText = 0;
  int _currentAdsPositionText = 0;

  //当前buffer进度
  int _bufferPosition = 0;

  //是否展示loading
  bool _showLoading = false;

  //loading进度
  int _loadingPercent = 0;

  //视频时长
  int _videoDuration = 1;
  int _videoAdsDuration = 1;

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
  ImageProvider? _imageProvider;

  //当前网络状态
  // ConnectivityResult? _currentConnectivityResult;

  ///seek中
  bool _inSeek = false;

  bool _isLock = false;

  //网络状态
  bool _isShowMobileNetWork = false;

  //当前播放器状态
  int _currentPlayerState = 0;

  String extSubTitleText = '';

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  AdsVideo? adsData;
  var secondsSkip = 0;
  var skipAdsCurent = 0;
  bool isActiveAds = false;
  bool isCompleteAds = false;
  AliPlayerView? aliPlayerView;
  AdsVideo? _newClipData;
  int newIndex = 0;

  String vidId = "";
  String vidAuth = "";

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDSuccess');
    super.initState();
    // if (widget.playMode == ModeTypeAliPLayer.auth) {
    //   getAuth();
    // } else {
    //   getOldVideoUrl();
    // }
    //cek ikaln
    // adsData = context.read<VidDetailNotifier>().adsData;
    print("ini iklan ${adsData?.data?.videoId}");
    print("ini iklan ${adsData?.data?.apsaraAuth}");
    if (widget.inLanding) {
      getAdsVideo(false);
    }
    if (widget.clearing) {
      widget.clearPostId?.call();
    }

    bool autoPlay = widget.isAutoPlay ?? false;

    _playMode = widget.playMode;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: widget.data?.postID ?? 'video_player_landing');
        fAliplayer?.setAutoPlay(autoPlay);
        if (autoPlay) {
          print("================== vid player index ${widget.index}");
          "===================== isPlaying ${widget.isPlaying}".logger();
          // Wakelock.enable();
          setState(() {
            isloading = true;
          });
        }

        final getPlayers = widget.getPlayer;

        if (getPlayers != null) {
          print('Vid Player1: getPlayer ${fAliplayer}');
          if (fAliplayer != null) {
            getPlayers(fAliplayer!);
          }
        }

        WidgetsBinding.instance.addObserver(this);
        bottomIndex = 0;

        // fAliplayer?.setAutoPlay(widget.fromDeeplink);
        // if (widget.fromDeeplink) {
        //   isPlay = true;
        // }

        _dataSourceMap = widget.dataSourceMap;
        _dataSourceAdsMap = {};
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
      } catch (e) {
        'Error Initialize Ali Player: $e'.logger();
      } finally {}
    });

    globalAliPlayer = fAliplayer;
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
          if (value?.length != 0) {
            _savePath = value![0].path + "/localCache/";
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
        print("EventReportParams=${params}");
      });
      fAliplayer?.setOnPrepared((playerId) {
        // Fluttertoast.showToast(msg: "OnPrepared ");
        fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
        fAliplayer?.getMediaInfo().then((value) {
          print("getMediaInfo==${value}");
          _videoDuration = value['duration'];
          setState(() {
            isPrepare = true;
          });
        });
        // isPlay = true;
        // isPause = false;
      });
      fAliplayer?.setOnRenderingStart((playerId) {});
      fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {
        print('video size changed');
      });
      fAliplayer?.setOnStateChanged((newState, playerId) {
        _currentPlayerState = newState;
        print("aliyun : onStateChanged $newState");
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            // Wakelock.enable();
            try {
              if (widget.isAutoPlay ?? false) {
                System().increaseViewCount2(context, widget.data ?? ContentData());
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
            } catch (e) {
              e.logger();
            }
            setState(() {});
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
          _bufferPosition = extraValue ?? 0;
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
        if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
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
                _imageProvider = provider;
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
      var vidNotifier = context.read<PreviewVidNotifier>();
      double position = 0.0;
      for (var i = 0; i < (widget.index ?? 0); i++) {
        position += vidNotifier.vidData?[i].height ?? 0.0;
      }
      context.read<MainNotifier>().globalKey.currentState?.innerController.animateTo(
        position,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
      );
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
            setState(() {
              isloading = false;
            });
          });
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

  _initAds(BuildContext context) async {
    //for ads
    // getCountVid();
    await _newInitAds(context, true);
    // if (context.getAdsCount() == null) {
    //   context.setAdsCount(0);
    // } else {
    //   if (context.getAdsCount() == 5) {
    //     await _newInitAds(context, true);
    //   } else if (context.getAdsCount() == 2) {
    //     // await _newInitAds(false);
    //   }
    // }
  }

  Future _newInitAds(BuildContext context, bool isContent) async {
    if (isContent) {
      context.setAdsCount(0);
    }
    try {
      if (adsData == null) {
        context.read<VidDetailNotifier>().getAdsVideo(context, isContent);
      }
    } catch (e) {
      'Failed to fetch ads data 0 : $e'.logger();
    }
  }

  void playVideo() async {
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

      System().increaseViewCount2(context, widget.data ?? ContentData());
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

  Future adsView(AdsData data, int time) async {
    try {
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(watchingTime: time, adsId: data.adsId, useradsId: data.useradsId);
      await notifier.viewAdsBloc(context, request);
      final fetch = notifier.adsDataFetch;
      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print("ini hasil ${fetch.data['rewards']}");
        if (fetch.data['rewards'] == true) {
          print("ini hasil ${mounted}");
          if (mounted) {
            ShowGeneralDialog.adsRewardPop(context);
            Timer(const Duration(milliseconds: 800), () {
              Routing().moveBack();
              // Timer(const Duration(milliseconds: 800), () {
              //   Routing().moveBack();
              // });
            });
          }
        }
      }
    } catch (e) {
      'Failed hit view ads ${e}'.logger();
    }
  }

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
    }
  }

  @override
  void didUpdateWidget(covariant VidPlayerPage oldWidget) {
    // If you want to react only to changes you could check
    // oldWidget.selectedIndex != widget.selectedIndex
    if (oldWidget.isPlaying != widget.isPlaying) {
      "===================== isPlaying ${widget.isPlaying}".logger();
      if (widget.isPlaying ?? true) {
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

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Wakelock.disable();
    globalAliPlayer = null;
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }

    fAliplayer?.stop();
    fAliplayer?.destroy();
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

  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    var width = MediaQuery.of(context).size.width;

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

    return AnimatedSwitcher(
      duration: const Duration(),
      transitionBuilder: (child, animation) => FadeTransition(child: child, opacity: animation),
      child: isloading
          ? Stack(
              key: ValueKey<bool>(isloading),
              children: [
                Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(widget.fromFullScreen ?? false ? 0 : 16),
                  ),
                  child: VideoThumbnail(
                    videoData: widget.data,
                    onDetail: false,
                    fn: () {},
                    withMargin: true,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: kHyppePrimary,
                    ),
                  ),
                )
              ],
            )
          : Builder(
              key: ValueKey<bool>(isloading),
              builder: (context) {
                aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: widget.width, height: widget.height);
                return GestureDetector(
                  onTap: () {
                    onTapCtrl = true;
                    setState(() {});
                  },
                  // onDoubleTap: (){
                  //   final _likeNotifier = context.read<LikeNotifier>();
                  //   if (widget.data != null) {
                  //     _likeNotifier.likePost(context, widget.data!);
                  //   }
                  // },
                  child: Stack(
                    children: [
                      // Text("${(adsData != null && !widget.inLanding)}"),
                      // if (adsData != null && !isCompleteAds && widget.inLanding)
                      //   Builder(
                      //     builder: (context) {
                      //       print('show content ads');
                      //       return ClipRRect(
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(16),
                      //           ),
                      //           child: Container(color: Colors.black, width: widget.width, height: widget.height, child: aliPlayerAdsView));
                      //     }
                      //   ),
                      if (adsData == null || (adsData != null && !widget.inLanding))
                        widget.data!.isLoading
                            ? Container(color: Colors.black, width: widget.width, height: widget.height)
                            : ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(widget.fromFullScreen ?? false ? 0 : 16),
                                ),
                                child: Container(color: Colors.black, width: widget.width, height: widget.height, child: isPlay ? aliPlayerView : const SizedBox.shrink())),

                      // Text("${adsData == null}"),
                      // Text("${SharedPreference().readStorage(SpKeys.countAds)}"),
                      // /====slide dan tombol fullscreen
                      if (isPlay)
                        SizedBox(
                          width: widget.width,
                          height: widget.height,
                          // padding: EdgeInsets.only(bottom: 25.0),
                          child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation)),
                        ),
                      if (!isPlay)
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
                      (widget.data?.reportedStatus == "BLURRED")
                          ? Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: VideoThumbnailReport(
                                  videoData: widget.data,
                                  function: () {
                                    changeStatusBlur();
                                  },
                                ),
                              ),
                            )
                          : Container(),
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

                              System().increaseViewCount2(context, widget.data ?? ContentData());
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
                              context.read<PicDetailNotifier>().showUserTag(context, widget.data?.tagPeople, widget.data?.postID);
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
                            child: _buildController(
                              Colors.transparent,
                              Colors.white,
                              100,
                              widget.width ?? 0,
                              widget.height ?? 0,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
    );
  }

  void onViewPlayerCreated(viewId) async {
    await fAliplayer?.setPlayerView(viewId);
    final getPlayers = widget.getPlayer;
    if (getPlayers != null) {
      if (fAliplayer != null) {
        getPlayers(fAliplayer!);
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
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    width: skipAdsCurent == 0 ? null : 100,
                    child: Text(
                      skipAdsCurent > 0 ? " Your video will begin in $skipAdsCurent" : " SkipdAds",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  skipAdsCurent == 0
                      ? Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        )
                      : Container(),
                  Container(
                      child: Image.network(
                    (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                  ))
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
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: _onPlayerHide,
      child: Container(
        height: height * 0.8,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildSkipBack(iconColor, height)),
            _buildPlayPause(iconColor, barHeight),
            Expanded(child: _buildSkipForward(iconColor, height)),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (isPause) {
          // if (_showTipsWidget) fAliplayer?.prepare();
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
      },
      child: CustomIconWidget(
        iconData: isPause ? "${AssetPath.vectorPath}pause.svg" : "${AssetPath.vectorPath}play.svg",
        defaultColor: false,
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
        print("currSeek: " + value.toString() + ", changeSeek: " + changevalue.toString());
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
        padding: const EdgeInsets.all(20.0),
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
        print("currSeek: " + value.toString() + ", changeSeek: " + changevalue.toString());
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
        padding: const EdgeInsets.all(20.0),
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
            Text("Currently mobile web", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            SizedBox(
              height: 30.0,
            ),
            Wrap(
              direction: Axis.horizontal,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: BeveledRectangleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blue,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("keep playing", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _isShowMobileNetWork = false;
                    });
                    fAliplayer?.play();
                  },
                ),
                SizedBox(
                  width: 10.0,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: BeveledRectangleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blue,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("quit playing", style: TextStyle(color: Colors.white)),
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
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
    // print('ORIENTATION: CHANGING ORIENTATION');
    return SafeArea(
      child: _currentPosition <= 0
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      sixPx,
                      Text(
                        System.getTimeformatByMs(isActiveAds ? _currentAdsPositionText : _currentPositionText),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      sixPx,
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            overlayShape: SliderComponentShape.noThumb,
                            activeTrackColor: const Color(0xAA7d7d7d),
                            inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                            // trackShape: RectangularSliderTrackShape(),
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
                              // trackColor: Color(0xAA7d7d7d),
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
                                // isActiveAds
                                //     ? fAliplayerAds?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE)
                                //     : fAliplayer?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
                                // isActiveAds ? fAliplayerAds?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE) : fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                                fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                              },
                              onChanged: (value) {
                                print('on change');
                                if (_thumbnailSuccess) {
                                  // isActiveAds ? fAliplayerAds?.requestBitmapAtPosition(value.ceil()) : fAliplayer?.requestBitmapAtPosition(value.ceil());
                                  fAliplayer?.requestBitmapAtPosition(value.ceil());
                                }
                                // setState(() {
                                //   isActiveAds ? _currentAdsPosition = value.ceil() : _currentPosition = value.ceil();
                                // });
                                setState(() {
                                  _currentPosition = value.ceil();
                                  ;
                                });
                              }),
                        ),
                      ),
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
                      GestureDetector(
                        onTap: () async {
                          if (widget.fromFullScreen ?? false) {
                            Routing().moveBack();
                          } else {
                            int changevalue;
                            changevalue = _currentPosition + 1000;
                            if (changevalue > _videoDuration) {
                              changevalue = _videoDuration;
                            }
                            if (widget.orientation == Orientation.portrait) {
                              "=============== pause 3".logger();
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
                              VideoIndicator value = await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                                  builder: (_) => VideoFullscreenPage(
                                        aliPlayerView: aliPlayerView!,
                                        fAliplayer: fAliplayer,
                                        data: widget.data ?? ContentData(),
                                        onClose: () {
                                          // Routing().moveBack();
                                        },
                                        slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation),
                                        videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                                        vidData: widget.vidData,
                                        index: widget.index,
                                        clearPostId: widget.clearPostId,
                                        loadMoreFunction: () {
                                          print("loadmore function vidplayer");
                                          widget.loadMoreFunction?.call();
                                        },
                                        isAutoPlay: widget.isAutoPlay,
                                      ),
                                  settings: const RouteSettings()));
                              // VideoIndicator value = await showDialog(
                              //     context: context,
                              //     builder: (context) {
                              //       return VideoFullscreenPage(
                              //         aliPlayerView: aliPlayerView!,
                              //         fAliplayer: fAliplayer,
                              //         data: widget.data ?? ContentData(),
                              //         onClose: () {
                              //           // Routing().moveBack();
                              //         },
                              //         slider: _buildContentWidget(context, widget.orientation),
                              //         videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                              //       );
                              //     });
                              if (mounted) {
                                setState(() {
                                  _videoDuration = value.videoDuration;
                                  _currentPosition = value.seekValue;
                                  _currentPositionText = value.positionText;
                                  _showTipsWidget = value.showTipsWidget;
                                  isMute = value.isMute;
                                  isPlay = !_showTipsWidget;
                                });
                              } else {
                                _videoDuration = value.videoDuration;
                                _currentPosition = value.seekValue;
                                _currentPositionText = value.positionText;
                                _showTipsWidget = value.showTipsWidget;
                                isMute = value.isMute;
                                isPlay = !_showTipsWidget;
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
                                  _bufferPosition = extraValue ?? 0;
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
                              // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                              // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

                              // fAliplayer?.requestBitmapAtPosition(value);
                              // fAliplayer?.seekTo(value, FlutterAvpdef.ACCURATE);
                              // fAliplayer?.play();
                            } else {
                              Navigator.pop(context, changevalue);
                            }
                            // isPotraitFull = !isPotraitFull;
                            // print('ORIENTATION: TRIGGER $orientation');
                            // //pause
                            // fAliplayer?.pause();
                            // if ((widget.data?.metadata?.height ?? 0) > (widget.data?.metadata?.width ?? 0)) {
                            //   if (isPotraitFull) {
                            //     if (Platform.isIOS) {
                            //       SystemChrome.setEnabledSystemUIOverlays([]);
                            //     }
                            //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                            //   } else {
                            //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                            //   }
                            //   widget.functionFullTriger(_currentPosition);
                            // } else {
                            //   if (orientation == Orientation.portrait) {
                            //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                            //     SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                            //   } else {
                            //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                            //     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                            //   }
                            // }
                            // print("+++++++kesini 1 ++++++++");
                            //
                            // // try to seek
                            // int changevalue;
                            // changevalue = _currentPosition + 1000;
                            // if (changevalue > _videoDuration) {
                            //   changevalue = _videoDuration;
                            // }
                            // print("currSeek: " + _currentPosition.toString() + ", changeSeek: " + changevalue.toString());
                            // fAliplayer?.requestBitmapAtPosition(changevalue);
                            // setState(() {
                            //   _currentPosition = changevalue;
                            // });
                            // _inSeek = false;
                            // setState(() {
                            //   if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
                            //     setState(() {
                            //       _showTipsWidget = false;
                            //     });
                            //   }
                            // });
                            // // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
                            // fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
                            //
                            // //play again
                            // fAliplayer?.play();
                            // print('ORIENTATION: DONE $orientation');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            orientation == Orientation.portrait ? Icons.fullscreen : Icons.fullscreen_exit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
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
    adsData = null;
    context.read<VidDetailNotifier>().adsData = null;
    setState(() {});
  }
}
