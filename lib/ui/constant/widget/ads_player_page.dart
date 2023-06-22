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
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../../../../../app.dart';

class AdsPlayerPage extends StatefulWidget {
  final ModeTypeAliPLayer playMode;
  final Map<String, dynamic> dataSourceMap;
  final ContentData? data;
  double? height;
  double? width;
  final Function functionFullTriger;
  final Function(FlutterAliplayer)? getPlayer;
  final Function(ContentData)? onPlay;
  final Orientation orientation;

  AdsPlayerPage({
    Key? key,
    required this.playMode,
    required this.dataSourceMap,
    required this.data,
    this.height,
    this.width,
    required this.functionFullTriger,
    this.onPlay,
    this.getPlayer,
    required this.orientation,
  }) : super(key: key);

  @override
  State<AdsPlayerPage> createState() => _AdsPlayerPageState();
}

class _AdsPlayerPageState extends State<AdsPlayerPage> with WidgetsBindingObserver {
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

  String auth = '';

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  AdsVideo? adsData;
  var secondsSkip = 0;
  var skipAdsCurent = 0;
  bool isActiveAds = false;
  bool isCompleteAds = false;
  AliPlayerView? aliPlayerView;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDSuccess');
    super.initState();
    adsData = context.read<VidDetailNotifier>().adsData;
    print("ini iklan ${adsData?.data?.videoId}");
    print("ini iklan ${adsData?.data?.apsaraAuth}");
    _playMode = widget.playMode;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: widget.data?.postID ?? 'video_player_landing');

        final getPlayers = widget.getPlayer;

        if (getPlayers != null) {
          print('Vid Player1: getPlayer ${fAliplayer}');
          if (fAliplayer != null) {
            getPlayers(fAliplayer!);
          }
        }

        WidgetsBinding.instance.addObserver(this);
        bottomIndex = 0;

        _dataSourceMap = widget.dataSourceMap;
        _dataSourceAdsMap = {};
        setState(() {});

        //Turn on mix mode
        if (Platform.isIOS) {
          FlutterAliplayer.enableMix(true);
        }

        configAliplayer();
      } catch (e) {
        'Error Initialize Ali Player: $e'.logger();
      } finally {}
    });

    globalAliPlayer = fAliplayer;
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
      fAliplayer?.setOnRenderingStart((playerId) {
        // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
      });
      fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {
        print('video size changed');
      });
      fAliplayer?.setOnStateChanged((newState, playerId) {
        _currentPlayerState = newState;
        print("aliyun : onStateChanged $newState");
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            Wakelock.enable();
            try {
              setState(() {
                _showTipsWidget = false;
                _showLoading = false;
                isPause = false;
              });
            } catch (e) {
              print('error AVPStatus_AVPStatusStarted: $e');
            }

            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPaused:
            isPause = true;
            Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusStopped:
            isPlay = false;
            _showLoading = false;
            try {
              Wakelock.disable();
            } catch (e) {
              e.logger();
            }

            setState(() {});
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
            Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            Wakelock.disable();
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
        if (info != null && (info.trackDefinition?.length ?? 0) > 0) {}
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
      print(widget.data?.isApsara);
      print(widget.data?.postID);
      if (widget.data != null) {
        start(widget.data!);
      }

      // if (widget.data!.isApsara ?? false) {
      //   getAuth();
      // } else {
      //   getOldVideoUrl();
      // }
    } catch (e) {
      rethrow;
    }
  }

  void start(ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();

    isPlay = false;
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
    //// Configure the application.
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
    if (data.reportedStatus == 'BLURRED') {
    } else {
      fAliplayer?.prepare();
    }

    // fAliplayer?.play();
  }

  @override
  void deactivate() {
    print('deactive player_page');
    super.deactivate();
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
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
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
  void dispose() {
    Wakelock.disable();
    globalAliPlayer = null;
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
    }

    fAliplayer?.stop();
    fAliplayer?.destroy();

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

    if (isloading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(child: SizedBox(width: 40, height: 40, child: CustomLoading())),
      );
    } else {
      aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: widget.width, height: widget.height);

      return GestureDetector(
        onTap: () {
          onTapCtrl = true;
          setState(() {});
        },
        child: Stack(
          children: [
            if (adsData == null || adsData != null)
              widget.data!.isLoading
                  ? Container(color: Colors.black, width: widget.width, height: widget.height)
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                      child: Container(color: Colors.black, width: widget.width, height: widget.height, child: isPlay ? aliPlayerView : const SizedBox.shrink())),
            if (isPlay)
              SizedBox(
                width: widget.width,
                height: widget.height,
                // padding: EdgeInsets.only(bottom: 25.0),
                child: Offstage(offstage: _isLock, child: _buildContentWidget(context, widget.orientation)),
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
            if (!isPlay && !_showLoading)
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
                  },
                  child: Visibility(
                    visible: (widget.data?.reportedStatus != "BLURRED"),
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: const CustomIconWidget(
                        defaultColor: false,
                        iconData: '${AssetPath.vectorPath}pause.svg',
                        color: kHyppeLightButtonText,
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
            if (isPlay)
              Align(
                alignment: Alignment.topCenter,
                child: _buildController(
                  Colors.transparent,
                  Colors.white,
                  100,
                  widget.width ?? 0,
                  widget.height ?? 0,
                ),
              ),
          ],
        ),
      );
    }
  }

  void onViewPlayerCreated(viewId) async {
    await fAliplayer?.setPlayerView(viewId);
    final getPlayers = widget.getPlayer;
    if (getPlayers != null) {
      print('Vid Player1: getPlayer ${fAliplayer}');
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
            vid: _dataSourceMap?[DataSourceRelated.vidKey],
            region: _dataSourceMap?[DataSourceRelated.regionKey],
            playAuth: _dataSourceMap?[DataSourceRelated.playAuth],
            definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
            previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);
        break;
    }
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
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

  ///Loading
  _buildProgressBar(double width, double height) {
    if (_showLoading) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 3.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "$_loadingPercent%",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
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
                                fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                              },
                              onChanged: (value) {
                                print('on change');
                                if (_thumbnailSuccess) {
                                  fAliplayer?.requestBitmapAtPosition(value.ceil());
                                }
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
                          int changevalue;
                          changevalue = _currentPosition + 1000;
                          if (changevalue > _videoDuration) {
                            changevalue = _videoDuration;
                          }
                          if (widget.orientation == Orientation.portrait) {
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
                                      slider: _buildContentWidget(context, widget.orientation),
                                      videoIndicator: VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentAdsPositionText, isMute: isMute),
                                    ),
                                settings: const RouteSettings()));
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
                          } else {
                            Navigator.pop(context, changevalue);
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
    _showTipsWidget = true;
    _showLoading = false;
    _tipsContent = "Play Again";
    isPause = true;
    setState(() {
      _currentAdsPosition = _videoAdsDuration;
      print("========== $isCompleteAds || $isActiveAds");
      isPlay = true;
    });
    fAliplayer?.prepare().whenComplete(() => _showLoading = false);
    fAliplayer?.isAutoPlay();
    fAliplayer?.play();

    isActiveAds = false;
    adsData = null;
    context.read<VidDetailNotifier>().adsData = null;
    setState(() {});
  }
}