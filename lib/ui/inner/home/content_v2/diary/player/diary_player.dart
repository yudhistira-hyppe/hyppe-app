import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/diary_sensitive.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../../app.dart';
import '../../../../../constant/entities/like/notifier.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

class DiaryPlayerPage extends StatefulWidget {
  final DiaryDetailScreenArgument argument;

  const DiaryPlayerPage({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  State<DiaryPlayerPage> createState() => _DiaryPlayerPageState();
}

class _DiaryPlayerPageState extends State<DiaryPlayerPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  FlutterAliplayer? fAliplayer;

  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  String auth = '';
  double opacityLevel = 0.0;

  ContentData? dataSelected;

  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  bool _mEnablePlayBack = false;

  //当前播放进度
  // int _currentPosition = 0;

  //当前播放时间，用于Text展示
  // int _currentPositionText = 0;

  //当前buffer进度
  // int _bufferPosition = 0;

  //是否展示loading
  bool _showLoading = false;

  //loading进度
  // int _loadingPercent = 0;

  //视频时长
  int _videoDuration = 1;

  //截图保存路径
  String _snapShotPath = '';

  //提示内容
  // String _tipsContent = '';

  //是否展示提示内容
  // bool _showTipsWidget = false;

  //是否有缩略图
  // bool _thumbnailSuccess = false;

  //缩略图
  // Uint8List _thumbnailBitmap;
  // ImageProvider? _imageProvider;

  //当前网络状态
  // ConnectivityResult? _currentConnectivityResult;

  ///seek中
  // bool _inSeek = false;

  // bool _isLock = false;

  //网络状态
  // bool _isShowMobileNetWork = false;

  //当前播放器状态
  // int _currentPlayerState = 0;

  String extSubTitleText = '';
  Stopwatch stopwatch = new Stopwatch()..start();
  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  AnimationController? _animationController;

  // PageController? _pageController;

  // RefreshController _videoListRefreshController = RefreshController(initialRefresh: false);

  List<ContentData>? _listData;

  late PageController _pageController;

  @override
  void initState() {
    print("init init init init");
    // stopwatch = new Stopwatch()..start();

    FirebaseCrashlytics.instance.setCustomKey('layout', 'DiaryPlayerPage');
    super.initState();
    _pageController = PageController(initialPage: widget.argument.index.toInt());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ));
      _curIdx = widget.argument.index.toInt();
      _lastCurIndex = widget.argument.index.toInt();
      // _pageController.addListener(() => notifier.currentPage = _pageController.page);
      initDiary();
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: "${Random().nextInt(60).toDouble()}");

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);
      if (widget.argument.diaryData?[_curIdx].certified ?? false) {
        System().block(context);
      } else {
        System().disposeBlock();
      }

      _animationController = AnimationController(
        /// [AnimationController]s can be created with `vsync: this` because of
        /// [TickerProviderStateMixin].
        vsync: this,
        // duration: Duration(milliseconds: _videoDuration),
      )..addListener(() {
          setState(() {});
        });

      // if (widget.data?.apsaraId != '') {
      // } else {
      //   _playMode = ModeTypeAliPLayer.url;
      // }
      isPlay = false;
      isPrepare = false;
      setState(() {});

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
        // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
      }

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
      }

      // mOptionsFragment = OptionsFragment(fAliplayer);
      // mFramePage = [
      //   mOptionsFragment,
      //   PlayConfigFragment(fAliplayer),
      //   FilterFragment(fAliplayer),
      //   CacheConfigFragment(fAliplayer),
      //   TrackFragment(trackFragmentKey, fAliplayer),
      // ];

      // mOptionsFragment.setOnEnablePlayBackChanged((mEnablePlayBack) {
      //   this._mEnablePlayBack = mEnablePlayBack;
      // });

      _initListener();
      print("[DIARY_PLAYER] addPostFrameCallback() ended. " + stopwatch.elapsed.toString());
    });
    print("[DIARY_PLAYER] initState() ended. " + stopwatch.elapsed.toString());
  }

  Future getAuth(String apsaraId) async {
    print("[DIARY_PLAYER] getAuth() started. " + stopwatch.elapsed.toString());
    setState(() {
      _showLoading = true;
      // isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];
        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
          // previewTime: _dataSourceMap?[DataSourceRelated.previewTime]
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

  Future getOldVideoUrl() async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: widget.argument.diaryData?[_curIdx].postID ?? '');
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

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        _videoDuration = value['duration'];
        _animationController?.duration = Duration(milliseconds: _videoDuration);
        setState(() {
          isPrepare = true;
        });
      });
      isPlay = true;
      print("[DIARY_PLAYER] setOnPrepared() ended. " + stopwatch.elapsed.toString());
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      print("[DIARY_PLAYER] _animationController.forward(). " + stopwatch.elapsed.toString());
      _animationController?.forward();
      print("[DIARY_PLAYER] setOnRenderingStart(). " + stopwatch.elapsed.toString());
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      // _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          WakelockPlus.enable();
          setState(() {
            // _showTipsWidget = false;
            _showLoading = false;
            isPause = false;
          });
          _animationController?.reset();
          _animationController?.forward();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          WakelockPlus.disable();
          "================ disable wakelock 53".logger();
          _animationController?.stop();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusStopped:
          WakelockPlus.disable();
          "================ disable wakelock 85".logger();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
          WakelockPlus.disable();
          "================ disable wakelock 96".logger();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusError:
          WakelockPlus.disable();
          "================ disable wakelock 00".logger();
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      print("[DIARY_PLAYER] setOnLoadingStatusListener() started. " + stopwatch.elapsed.toString());
      _animationController?.stop();
      setState(() {
        // _loadingPercent = 0;
        _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      // _loadingPercent = percent;
      if (percent == 100) {
        _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      _animationController?.forward();
      setState(() {
        _showLoading = false;
      });
      print("[DIARY_PLAYER] setOnLoadingStatusListener() ended. " + stopwatch.elapsed.toString());
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      // _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          // _currentPosition = extraValue ?? 0;
        }
        // if (!_inSeek) {
        //   setState(() {
        //     _currentPositionText = extraValue ?? 0;
        //   });
        // }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        // _bufferPosition = extraValue ?? 0;
        if (mounted) {
          setState(() {});
        }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
        print("[DIARY_PLAYER] Cache Succeed. " + stopwatch.elapsed.toString());
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
        print("[DIARY_PLAYER] Cache Error. " + stopwatch.elapsed.toString());
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        _animationController?.reset();
        _animationController?.forward();
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "Play Again";
      isPause = true;
      _animationController?.reset();
      setState(() {
        // _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "$errorCode \n $errorMsg";
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
      // _thumbnailSuccess = true;
    }, preparedFail: (playerId) {
      // _thumbnailSuccess = false;
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

    globalAliPlayer = fAliplayer;
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
      default:
        break;
    }
  }

  @override
  void dispose() {
    globalAliPlayer = null;
    WakelockPlus.disable();
    "================ disable wakelock 63".logger();
    _animationController?.dispose();
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }

    fAliplayer?.stop();
    fAliplayer?.destroy();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (_networkSubscriptiion != null) {
      _networkSubscriptiion?.cancel();
    }
  }

  int _curIdx = 0;
  int _lastCurIndex = -1;
  bool _isPause = false;
  double _playerY = 0;
  // bool _isFirstRenderShow = false;
  // bool _isBackgroundMode = false;

  void onViewPlayerCreated(viewId) async {
    print('onViewPlayerCreated===');
    fAliplayer?.setPlayerView(viewId);
  }

  void play() {
    isPause = false;
    fAliplayer?.play();
    _animationController?.forward();
  }

  void pause() {
    print('pause pause');
    isPause = true;
    fAliplayer?.pause();
    _animationController?.stop();
  }

  void changeStatusBlur() {
    setState(() {
      _listData?[_curIdx].reportedStatus = "";
    });
  }

  bool loadTitle = false;
  @override
  Widget build(BuildContext context) {
    var lang = context.read<TranslateNotifierV2>().translate;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Consumer2<PreviewDiaryNotifier, HomeNotifier>(
        builder: (_, notifier, home, __) => Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _listData?.length ?? 0,
            onPageChanged: (index) async {
              _curIdx = index;
              loadTitle = true;
              setState(() {});
              if (_lastCurIndex != _curIdx) {
                if (_listData?[_curIdx].isApsara ?? false) {
                  _playMode = ModeTypeAliPLayer.auth;
                } else {
                  _playMode = ModeTypeAliPLayer.url;
                }
                // initDiary();
                start();
                if (widget.argument.diaryData?[_curIdx].certified ?? false) {
                  System().block(context);
                } else {
                  System().disposeBlock();
                }
                // ======getLoadmore
                if ((_listData?.length ?? 0) - 1 == _curIdx) {}
              }
              _lastCurIndex = _curIdx;
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {},
                onDoubleTap: () {
                  final _likeNotifier = context.read<LikeNotifier>();
                  final data = _listData?[_curIdx];
                  if (data != null) {
                    _likeNotifier.likePost(context, data);
                  }
                },
                onLongPress: () {
                  setState(() {
                    _isPause = !_isPause;
                  });
                  if (_isPause) {
                    fAliplayer?.pause();
                  } else {
                    fAliplayer?.play();
                  }
                },
                child: Stack(
                  children: [
                    _curIdx == index
                        ? AliPlayerView(
                            onCreated: onViewPlayerCreated,
                            x: 0,
                            y: 0,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          )
                        : Container(),
                    _showLoading
                        ? const Positioned.fill(
                            child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ))
                        : Container(),
                    Align(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        opacity: opacityLevel,
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Opacity(
                            opacity: 0.4,
                            child: Icon(
                              isPause ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text('${dataSelected?.postID}'),

                    dataSelected?.postID == _listData?[index].postID
                        ? Container()
                        : CustomBaseCacheImage(
                            memCacheWidth: 100,
                            memCacheHeight: 100,
                            widthPlaceHolder: 80,
                            heightPlaceHolder: 80,
                            placeHolderWidget: Container(),
                            imageUrl: (_listData?[index].isApsara ?? false) ? (_listData?[index].mediaThumbEndPoint ?? "") : _listData?[index].fullThumbPath ?? '',
                            imageBuilder: (context, imageProvider) => _listData?[_curIdx].reportedStatus == 'BLURRED'
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
                                  context.read<HomeNotifier>().checkConnection();
                                },
                                child: Container(
                                    decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                    width: SizeConfig.screenWidth,
                                    height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    child: CustomTextWidget(
                                      textToDisplay: lang.couldntLoadVideo ?? 'Error',
                                      maxLines: 3,
                                    )),
                              );
                            },
                            emptyWidget: GestureDetector(
                              onTap: () {
                                context.read<HomeNotifier>().checkConnection();
                              },
                              child: Container(
                                  decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                  width: SizeConfig.screenWidth,
                                  height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(20),
                                  child: CustomTextWidget(
                                    textToDisplay: lang.couldntLoadVideo ?? 'Error',
                                    maxLines: 3,
                                  )),
                            ),
                          ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      // padding: EdgeInsets.only(bottom: 25.0),
                      child: _buildFillDiary(),
                    ),
                    // _buildSingleScreen(index),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFillDiary() {
    // print("[DIARY_PLAYER] _buildFillDiary() started. "+stopwatch.elapsed.toString());
    return SafeArea(
      child: Stack(
        children: [
          // Container(
          //   padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5),
          //   height: 9,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(40.0),
          //     child: LinearProgressIndicator(
          //       value: _animationController?.value,
          //       backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
          //       valueColor: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
          //     ),
          //   ),
          // ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // storyComplete(not);
                    if (isPause) {
                      play();
                      print('DiaryPlayer pause');
                    } else {
                      pause();
                      print('DiaryPlayer play');
                    }
                    setState(() {
                      opacityLevel = 1.0;
                    });

                    Future.delayed(const Duration(seconds: 1), () {
                      opacityLevel = 0.0;
                      setState(() {});
                    });
                  },
                  onLongPressEnd: (value) => play(),
                  onLongPressStart: (value) => pause(),
                  // onLongPress: () => pause(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    // padding: EdgeInsets.only(bottom: 25.0),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          _listData?[_curIdx].reportedStatus == "BLURRED"
              ? CustomBackgroundLayer(
                  sigmaX: 30,
                  sigmaY: 30,
                  // thumbnail: picData!.content[arguments].contentUrl,
                  thumbnail: (_listData?[_curIdx].isApsara ?? false) ? (_listData?[_curIdx].mediaThumbEndPoint ?? '') : (_listData?[_curIdx].fullThumbPath ?? ''),
                )
              : Container(),
          (_listData?[_curIdx].reportedStatus == "BLURRED")
              ? DiarySensitive(
                  data: _listData?[_curIdx],
                  function: () {
                    changeStatusBlur();
                  },
                )
              : Container(),
          _listData?[_curIdx].reportedStatus == "BLURRED"
              ? Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CustomTextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.only(left: 0.0),
                        ),
                      ),
                      onPressed: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
                      child: const DecoratedIconWidget(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : loadTitle
                  ? Container()
                  : TitlePlaylistDiaries(
                      data: _listData?[_curIdx],
                      // storyController: _storyController,
                    ),

          // Text(_listData![_curIdx].username!),
          _listData?[_curIdx].reportedStatus == "BLURRED"
              ? Container()
              : RightItems(
                  data: _listData?[_curIdx] ?? ContentData(),
                ),
          _listData?[_curIdx].reportedStatus == "BLURRED"
              ? Container()
              : LeftItems(
                  aliPlayer: fAliplayer,
                  description: _listData?[_curIdx].description,
                  // tags: _listData?[_curIdx].tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" "),
                  music: _listData?[_curIdx].music,
                  authorName: _listData?[_curIdx].username,
                  userName: _listData?[_curIdx].username,
                  location: _listData?[_curIdx].location,
                  postID: _listData?[_curIdx].postID,
                  // storyController: _storyController,
                  tagPeople: _listData?[_curIdx].tagPeople,
                  animatedController: _animationController,
                  data: _listData?[_curIdx]),
          Align(
            alignment: Alignment.bottomCenter,
            child: _listData?[_curIdx].email == SharedPreference().readStorage(SpKeys.email) && (_listData?[_curIdx].reportedStatus == 'OWNED')
                ? SizedBox(height: 58, child: ContentViolationWidget(data: _listData?[_curIdx] ?? ContentData()))
                : Container(),
          ),
        ],
      ),
    );
  }

  // Widget _buildSingleScreen(int index) {
  //   // print("[DIARY_PLAYER] _buildSingleScreen() started. "+stopwatch.elapsed.toString());
  //   // VideoModel model = _dataList[index];
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _isPause = !_isPause;
  //       });
  //       if (_isPause) {
  //         fAliplayer?.pause();
  //       } else {
  //         fAliplayer?.play();
  //       }
  //     },
  //     onDoubleTap: () {
  //       final _likeNotifier = context.read<LikeNotifier>();
  //       final data = _listData?[_curIdx];
  //       if (data != null) {
  //         _likeNotifier.likePost(context, data);
  //       }
  //     },
  //     child: !isPlay
  //         ? Stack(
  //             children: [
  //               Container(
  //                 width: double.infinity,
  //                 height: double.infinity,
  //                 child: Center(child: SizedBox(width: 40, height: 40, child: CustomLoading())),
  //               ),
  //               // Container(
  //               //   color: Colors.black,
  //               //   child: CustomBaseCacheImage(
  //               //     widthPlaceHolder: 112,
  //               //     heightPlaceHolder: 40,
  //               //     imageUrl: (_listData?[index].isApsara ?? false) ? "${_listData?[index].mediaThumbEndPoint}" : "${_listData?[index].fullThumbPath}",
  //               //     imageBuilder: (context, imageProvider) => Container(
  //               //       clipBehavior: Clip.hardEdge,
  //               //       width: double.infinity,
  //               //       height: double.infinity,
  //               //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
  //               //       decoration: BoxDecoration(
  //               //         borderRadius: BorderRadius.circular(8.0),
  //               //         image: DecorationImage(
  //               //           image: imageProvider,
  //               //           fit: BoxFit.contain,
  //               //         ),
  //               //       ),
  //               //       // child: _buildBody(index),
  //               //     ),
  //               //     errorWidget: (context, url, error) => Container(
  //               //       width: double.infinity,
  //               //       height: double.infinity,
  //               //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
  //               //       decoration: BoxDecoration(
  //               //         image: const DecorationImage(
  //               //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
  //               //           fit: BoxFit.cover,
  //               //         ),
  //               //         borderRadius: BorderRadius.circular(8.0),
  //               //       ),
  //               //       // child: _buildBody(index),
  //               //     ),
  //               //     emptyWidget: Container(
  //               //       width: double.infinity,
  //               //       height: double.infinity,
  //               //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
  //               //       decoration: BoxDecoration(
  //               //         image: const DecorationImage(
  //               //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
  //               //           fit: BoxFit.cover,
  //               //         ),
  //               //         borderRadius: BorderRadius.circular(8.0),
  //               //       ),
  //               //       // child: _buildBody(index),
  //               //     ),
  //               //   ),
  //               // ),
  //               _buildFillDiary()
  //             ],
  //           )
  //         : Container(),
  //   );
  // }

  void initDiary() async {
    print("=-=-=-=-=-=-=-=-init diary");
    var notifier = context.read<DiariesPlaylistNotifier>();
    setState(() {
      _showLoading = true;
    });
    await notifier.initState(context, widget.argument);
    _listData = notifier.listData;
    if (_listData?[_curIdx].isApsara ?? false) {
      _playMode = ModeTypeAliPLayer.auth;
    } else {
      _playMode = ModeTypeAliPLayer.url;
    }
    start();
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    _animationController?.reset();
    fAliplayer?.stop();
    isPlay = false;
    dataSelected = _listData?[_curIdx];
    if (_playMode == ModeTypeAliPLayer.auth) {
      await getAuth(_listData?[_curIdx].apsaraId ?? '');
    } else {
      await getOldVideoUrl();
    }

    setState(() {
      _isPause = false;
      // _isFirstRenderShow = false;
      loadTitle = false;
    });
    var configMap = {
      'mStartBufferDuration': GlobalSettings.mStartBufferDuration, // The buffer duration before playback. Unit: milliseconds.
      'mHighBufferDuration': GlobalSettings.mHighBufferDuration, // The duration of high buffer. Unit: milliseconds.
      'mMaxBufferDuration': GlobalSettings.mMaxBufferDuration, // The maximum buffer duration. Unit: milliseconds.
      'mMaxDelayTime': GlobalSettings.mMaxDelayTime, // The maximum latency of live streaming. Unit: milliseconds. You can specify the latency only for live streams.
      'mNetworkTimeout': GlobalSettings.mNetworkTimeout, // The network timeout period. Unit: milliseconds.
      'mNetworkRetryCount': GlobalSettings.mNetworkRetryCount, // The number of retires after a network timeout. Unit: milliseconds.
      // 'mEnableLocalCache': GlobalSettings.mEnableCacheConfig,
      'mLocalCacheDir': GlobalSettings.mDirController,
      'mClearFrameWhenStop': true
    };
    // Configure the application.
    fAliplayer?.setConfig(configMap);
    var map = {
      // "mMaxSizeMB": GlobalSettings.mMaxSizeMBController,

      /// The maximum space that can be occupied by the cache directory.
      // "mMaxDurationS": GlobalSettings.mMaxDurationSController,

      /// The maximum cache duration of a single file.
      // "mDir": GlobalSettings.mDirController,

      /// The cache directory.
      // "mEnable": GlobalSettings.mEnableCacheConfig

      /// Specify whether to enable the cache feature.
    };
    fAliplayer?.setCacheConfig(map);
    if (_listData?[_curIdx].reportedStatus != "BLURRED") {
      fAliplayer?.prepare();
    }

    // fAliplayer?.play();
    print("[DIARY_PLAYER] start() ended. " + stopwatch.elapsed.toString());
  }

  // void _onPlayerHide() {
  //   Future.delayed(const Duration(seconds: 4), () {
  //     onTapCtrl = false;
  //     setState(() {});
  //   });
  // }
  //
  // ///Loading
  // _buildProgressBar(double width, double height) {
  //   print("[DIARY_PLAYER] _buildProgressBar() started. " + stopwatch.elapsed.toString());
  //   if (_showLoading) {
  //     return Positioned(
  //       left: width / 2 - 20,
  //       top: height / 2 - 20,
  //       child: Column(
  //         children: const [
  //           CircularProgressIndicator(
  //             backgroundColor: Colors.white,
  //             strokeWidth: 3.0,
  //           ),
  //           SizedBox(
  //             height: 10.0,
  //           ),
  //           // Text(
  //           //   "$_loadingPercent%",
  //           //   style: const TextStyle(color: Colors.white),
  //           // ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return const SizedBox();
  //   }
  // }
}
