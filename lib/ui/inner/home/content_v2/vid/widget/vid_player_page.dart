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
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';
import '../../../../../constant/widget/ads/ads_player_page.dart';
import 'fullscreen/notifier.dart';
import 'fullscreen/video_fullscreen_page.dart';

class VidPlayerPage extends StatefulWidget {
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

  // FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;

  const VidPlayerPage({
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
    lang = context.read<TranslateNotifierV2>().translate;
    if (widget.clearing) {
      widget.clearPostId?.call();
    }

    bool autoPlay = widget.isAutoPlay ?? false;

    // _playMode = widget.playMode;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: widget.data?.postID ?? 'video_player_landing');
        // globalAliPlayer = fAliplayer;
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
      });
      fAliplayer?.setOnStateChanged((newState, playerId) {
        _currentPlayerState = newState;
        print("aliyun : onStateChanged $newState");
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
            if (notifier.adsTime == detik) {
              if (notifier.tempAdsData != null) {
                print('pause here 2');
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
            try {
              if (mounted) {
                setState(() {
                  isloading = false;
                });
              } else {
                isloading = false;
              }
            } catch (e) {
              isloading = false;
            }
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
        aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: widget.width, height: widget.height);
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
                return GestureDetector(
                  onTap: () async {
                    onTapCtrl = true;
                    setState(() {});

                    if (widget.fromFullScreen){
                      Routing().moveBack();
                    }else{
                      int changevalue;
                      changevalue = _currentPosition + 1000;
                      if (changevalue > _videoDuration) {
                        changevalue = _videoDuration;
                      }
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
                        }
                        VideoIndicator value = await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                            builder: (_) => VideoFullscreenPage(
                                enableWakelock: widget.enableWakelock,
                                aliPlayerView: aliPlayerView!,
                                thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                                fAliplayer: fAliplayer,
                                data: widget.data ?? ContentData(),
                                onClose: () {
                                  notifier.setMapAdsContent(widget.data?.postID ?? '', null);
                                  setState(() {
                                    isPlay = true;
                                    if (widget.onShowAds != null) {
                                      widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                                    }
                                  });
                                  notifier.hasShowedAds = true;
                                  notifier.tempAdsData = null;
                                  notifier.isShowingAds = false;
                                  // Routing().moveBack();
                                },
                                slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation, notifier),
                                videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                                vidData: widget.vidData,
                                index: widget.index,
                                clearPostId: widget.clearPostId,
                                loadMoreFunction: () {
                                  print("loadmore function vidplayer");
                                  widget.loadMoreFunction?.call();
                                },
                                isAutoPlay: widget.isAutoPlay,
                                isLanding: widget.inLanding),
                            settings: const RouteSettings()));
                        notifier.isLoading = true;
                        Future.delayed(const Duration(seconds: 6), () {
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
                      } else {
                        Navigator.pop(context, changevalue);
                      }
                      // if (mounted) {
                      //   setState(() {
                      //     isloading = false;
                      //   });
                      // } else {
                      //   isloading = false;
                      // }
                    }
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
                      if (notifier.mapInContentAds[widget.data?.postID ?? ''] == null || (notifier.mapInContentAds[widget.data?.postID ?? ''] != null && !widget.inLanding))
                        widget.data!.isLoading
                            ? Container(color: Colors.black, width: widget.width, height: widget.height)
                            : ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(widget.fromFullScreen ? 0 : 16),
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
                          child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation, notifier)),
                        ),
                        
                      if (widget.fromFullScreen && Platform.isIOS)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                Routing().moveBack();
                              },
                              padding:
                                  widget.orientation == Orientation.portrait
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 42.0)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 46.0, vertical: 8.0),
                              icon: const CustomIconWidget(
                                  iconData: "${AssetPath.vectorPath}close.svg",
                                  defaultColor: false),
                            ),
                          ),
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
                      if (notifier.mapInContentAds[widget.data?.postID ?? ''] != null && isPlay)
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

  Widget _buildPlayPause(
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

  _buildContentWidget(BuildContext context, Orientation orientation, VideoNotifier notifier) {
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
                          if (widget.fromFullScreen) {
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
                              setState(() {
                                isloading = true;
                              });
                              await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
                                      enableWakelock: widget.enableWakelock,
                                      aliPlayerView: aliPlayerView!,
                                      thumbnail: (widget.data?.isApsara ?? false) ? (widget.data?.mediaThumbEndPoint ?? '') : '${widget.data?.fullThumbPath}',
                                      fAliplayer: fAliplayer,
                                      data: widget.data ?? ContentData(),
                                      onClose: () {
                                        notifier.setMapAdsContent(widget.data?.postID ?? '', null);
                                        setState(() {
                                          isPlay = true;
                                          if (widget.onShowAds != null) {
                                            widget.onShowAds!(notifier.mapInContentAds[widget.data?.postID ?? '']);
                                          }
                                        });
                                        notifier.hasShowedAds = true;
                                        notifier.tempAdsData = null;
                                        notifier.isShowingAds = false;
                                        // Routing().moveBack();
                                      },
                                      slider: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, widget.orientation, notifier),
                                      videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                                      vidData: widget.vidData,
                                      index: widget.index,
                                      clearPostId: widget.clearPostId,
                                      loadMoreFunction: () {
                                        print("loadmore function vidplayer");
                                        widget.loadMoreFunction?.call();
                                      },
                                      isAutoPlay: widget.isAutoPlay,
                                      isLanding: widget.inLanding),
                                  settings: const RouteSettings()));
                              notifier.isLoading = true;
                              Future.delayed(const Duration(seconds: 6), () {
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
                              // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                              // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

                              // fAliplayer?.requestBitmapAtPosition(value);
                              // fAliplayer?.seekTo(value, FlutterAvpdef.ACCURATE);
                              // fAliplayer?.play();
                            } else {
                              Navigator.pop(context, changevalue);
                            }
                            if (mounted) {
                              setState(() {
                                isloading = false;
                              });
                            } else {
                              isloading = false;
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

      VideoIndicator value = await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
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
                slider: _buildContentWidget(context, widget.orientation, notifier),
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

  Widget buttonVideoRight({Function()? onTap, required String iconData, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              
            },
            child:  CustomIconWidget(
              defaultColor: false,
              color: kHyppePrimaryTransparent,
              iconData: iconData,
              height: 24,
            ),
          ),
          const SizedBox(height: 8.0,),
          Text(
            value,
            style: const TextStyle(color: kHyppePrimaryTransparent, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
