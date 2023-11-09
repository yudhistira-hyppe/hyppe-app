import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/transitions/line_indicator_transation.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/link_copied_widget.dart';
import 'package:hyppe/ui/constant/widget/sticker_overlay.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_bottom_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_top_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../../app.dart';

class StoryPlayerPage extends StatefulWidget {
  final StoryDetailScreenArgument argument;

  const StoryPlayerPage({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  State<StoryPlayerPage> createState() => _StoryPlayerPageState();
}

class _StoryPlayerPageState extends State<StoryPlayerPage> with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  FlutterAliplayer? fAliplayer;
  late AnimationController animationController;
  late AnimationController emojiController;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  // ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  String auth = '';
  List shown = [];

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
  int _loadingPercent = 0;

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

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  AnimationController? _animationController;

  // PageController? _pageController;


  List<StoriesGroup>? _groupUserStories;

  PageController _pageController = PageController();

  int _curIdx = 0;
  int _curChildIdx = 0;
  int _lastCurIndex = -1;
  // bool _isPause = false;
  double _playerY = 0;
  // bool _isFirstRenderShow = false;
  // bool _isBackgroundMode = false;
  int loadImage = 0;

  bool isOnPageTurning = false;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'StoryPlayerPage');
    print("======================ke initstate");

    super.initState();

    context.read<StoriesPlaylistNotifier>().setLoadReaction(false);
    _pageController = PageController(initialPage: widget.argument.peopleIndex);
    _pageController.addListener(() {
      final _notifier = context.read<StoriesPlaylistNotifier>();
      if (isOnPageTurning && _pageController.page == _pageController.page?.roundToDouble()) {
        _notifier.pageIndex = _pageController.page?.toInt() ?? 0;
        setState(() {
          // current = _controller.page.toInt();
          isOnPageTurning = false;
        });
      } else if (!isOnPageTurning && _notifier.currentPage?.toDouble() != _pageController.page) {
        if (((_notifier.pageIndex.toDouble()) - (_pageController.page ?? 0)).abs() > 0.1) {
          setState(() {
            isOnPageTurning = true;
          });
        }
      }
    });

    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    emojiController = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController = AnimationController(
        vsync: this,
      )
        // ..addListener(() { setState(() {});})
        ..addStatusListener(
          (AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image') {
                storyComplete(notifier);
              }
            }
            if (status == AnimationStatus.forward) {
              if (mounted) {
                setState(() {});
              }
            }
          },
        );
      _curChildIdx = 0;
      _curIdx = widget.argument.peopleIndex.toInt();
      _lastCurIndex = widget.argument.peopleIndex.toInt();

      print("initial index ${widget.argument.peopleIndex}");
      // _pageController.addListener(() => notifier.currentPage = _pageController.page);
      initStory();

      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'storyPlayer');
      var configMap = {
        'mClearFrameWhenStop': true,
      };
      fAliplayer?.setConfig(configMap);

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);
      // _playMode = ModeTypeAliPLayer.auth;
      isPlay = false;
      isPrepare = false;
      if (mounted) {
        setState(() {});
      }

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

      _initListener();
    });
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    super.didChangeMetrics();
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print("iyyiyiyiyiyi $jsonMap");

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
        // widget.videoData?.fullContent = jsonMap['PlayUrl'];
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
        if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image') {
          _animationController?.duration = Duration(milliseconds: _videoDuration > 5000 ? 15000 : 8000);
        } else {
          _animationController?.duration = Duration(milliseconds: _videoDuration);
        }
        setState(() {
          isPrepare = true;
        });
      });
      final fixContext = Routing.navigatorKey.currentContext;
      System().increaseViewCount(fixContext ?? context, _groupUserStories![_curIdx].story?[_curChildIdx] ?? ContentData()).whenComplete(() {
        // _showAds(Routing.navigatorKey.currentContext ?? context);
      });
      isPlay = true;
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      _animationController?.forward();

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
          _animationController?.forward();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          WakelockPlus.disable();
          "================ disable wakelock 12".logger();
          _animationController?.stop();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusStopped:
          WakelockPlus.disable();
          "================ disable wakelock 11".logger();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
          WakelockPlus.disable();
          "================ disable wakelock 10".logger();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusError:
          WakelockPlus.disable();
          "================ disable wakelock 13".logger();
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      _animationController?.stop();
      _loadingPercent = 0;
      _showLoading = true;
      if (mounted) {
        setState(() {});
      }
    }, loadingProgress: (percent, netSpeed, playerId) {
      _loadingPercent = percent;
      if (percent == 100) {
        _showLoading = false;
      }
      if (mounted) {
        setState(() {});
      }
    }, loadingEnd: (playerId) {
      // _animationController?.forward();
      _showLoading = false;
      if (mounted) {
        setState(() {});
      }
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
        // Fluttertoast.showToast(msg: "Cache Success");
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
        // Fluttertoast.showToast(msg: "Cache Error $extraMsg");
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // _animationController?.reset();
        // _animationController?.forward();
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      } else if (infoCode == FlutterAvpdef.AVPStatus_AVPStatusCompletion) {}
    });
    fAliplayer?.setOnCompletion((playerId) {
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "Play Again";
      isPause = true;
      _animationController?.reset();
      storyComplete(notifier);
      // _currentPosition = _videoDuration;
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "$errorCode \n $errorMsg";
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if ((info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });

    globalAliPlayer = fAliplayer;
  }

  ///ADS IN BETWEEN === Hariyanto Lukman ===
  _showAds(BuildContext context) async {
    //for ads
    // getCountVid();
    // await _newInitAds(true);
    final count = context.getAdsCount();
    if (count == 5) {
      final adsData = await context.getInBetweenAds();
      if (adsData != null) {
        final auth = await context.getAuth(context, videoId: adsData.videoId ?? '');
        pause();
        System().adsPopUp(context, adsData, auth).whenComplete(() {
          play();
        });
      }
    }
    context.incrementAdsCount();
  }

  void storyComplete(StoriesPlaylistNotifier not) {
    not.isPreventedEmoji = true;
    if (_curChildIdx == ((_groupUserStories![_curIdx].story?.length ?? 0) - 1)) {
      shown = [];
      if (_curIdx == (_groupUserStories!.length - 1)) {
        Routing().moveBack();
      } else {
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
        _curChildIdx = 0;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image') {
        _animationController?.duration = const Duration(milliseconds: 8000);
      }
      shown.add(_groupUserStories![_curIdx].story?[_curChildIdx].postID);
      print(shown);
      _curChildIdx++;
      if (mounted) {
        setState(() {});
      }
      start();
    }
  }

  void storyPrev(StoriesPlaylistNotifier not) {
    not.isPreventedEmoji = true;
    if (_curChildIdx > 0) {
      _curChildIdx--;
      print("story kurang ${shown.length}");
      shown.removeAt(shown.length - 1);
      print("story setelah kurang ${shown.length}");
      if (mounted) {
        setState(() {});
      }
      start();
    } else {
      if (_curIdx > 0) {
        shown = [];
        _pageController.previousPage(duration: const Duration(milliseconds: 900), curve: Curves.ease);
        _curChildIdx = 0;
        if (mounted) {
          setState(() {});
        }
      }
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
          setState(() => isPause = true);
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
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    globalAliPlayer = null;
    WakelockPlus.disable();
    "================ disable wakelock 9".logger();
    _animationController?.dispose();
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    print('dispose StoryPlayerPage');
    fAliplayer?.stop();
    fAliplayer?.destroy();
    super.dispose();
    emojiController.reset();
    emojiController.dispose();
    animationController.reset();
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (_networkSubscriptiion != null) {
      _networkSubscriptiion?.cancel();
    }
  }

  @override
  void deactivate() {
    print("====== deactivate ");

    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari story ");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext dari story");
    fAliplayer?.play();
    setState(() => isPause = false);
    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari story");
    pause();
    super.didPushNext();
  }

  void play() {
    setState(() => isPause = false);
    fAliplayer?.play();
    _animationController?.forward();
  }

  void pause() {
    print('pause pause');
    setState(() => isPause = true);
    fAliplayer?.pause();
    _animationController?.stop();
  }

  void onViewPlayerCreated(viewId, bool isImage) async {
    print('onViewPlayerCreated===');

    fAliplayer?.setPlayerView(viewId);
  }

  final notifier = StoriesPlaylistNotifier();

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<StoriesPlaylistNotifier>(
    //   create: (context) {

    //   },
    //   child: ,
    // );

    return Consumer2<StoriesPlaylistNotifier, PreviewStoriesNotifier>(builder: (context, value, storyNot, child) {
      if (MediaQuery.of(context).viewInsets.bottom > 0.0 || value.textEditingController.text.isNotEmpty) {
        value.setIsKeyboardActive(true);
      } else {
        value.setIsKeyboardActive(false);
      }
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.argument.myStories != null ? 1 : storyNot.storiesGroups?.length,
          onPageChanged: (index) async {
            shown = [];
            _curIdx = index;
            if (mounted) {
              setState(() {});
            }
            if (_lastCurIndex != _curIdx) {
              // notifier.isPreventedEmoji = true;
              _curChildIdx = 0;
              start();
            }
            _lastCurIndex = _curIdx;
          },
          itemBuilder: (context, index) {
            // final player = AliPlayerView(
            //   onCreated: (id) {
            //     final isImage = _groupUserStories?[index].story?[_curChildIdx].mediaType == 'image';
            //     onViewPlayerCreated(id, isImage);
            //   },
            //   x: 0,
            //   y: _playerY,
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            // );
            return Stack(
              children: [
                // Text("${_groupUserStories?[_curIdx].story?[_curChildIdx].music?.apsaraMusic != null || _groupUserStories?[_curIdx].story?[_curChildIdx].mediaType != 'image'}"),
                // _groupUserStories?[_curIdx].story?[_curChildIdx].music?.apsaraMusic != null || _groupUserStories?[_curIdx].story?[_curChildIdx].mediaType != 'image'
                //     ? AliPlayerView(
                //         onCreated: onViewPlayerCreated,
                //         x: 0,
                //         y: _playerY,
                //         width: MediaQuery.of(context).size.width,
                //         height: MediaQuery.of(context).size.height,
                //       )
                //     : Container(),
                Positioned.fill(
                    child: Container(
                  color: Colors.black,
                )),
                Builder(builder: (context) {
                  return !isOnPageTurning
                      // ? AliPlayerView(
                      //     onCreated: (id) {
                      //       final isImage = _groupUserStories?[index].story?[_curChildIdx].mediaType == 'image';
                      //       onViewPlayerCreated(id, isImage);
                      //     },
                      //     x: 0,
                      //     y: _playerY,
                      //     width: MediaQuery.of(context).size.width,
                      //     height: MediaQuery.of(context).size.height,
                      //   )
                      ? FutureBuilder(
                          future: Future.wait([
                            for (StickerModel sticker in _groupUserStories?[index].story?[_curChildIdx].stickers ?? []) precacheImage(NetworkImage(sticker.image ?? ''), context),
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              Container();
                            }
                            return Center(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width * (16 / 9),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: AliPlayerView(
                                        onCreated: (id) {
                                          final isImage = _groupUserStories?[index].story?[_curChildIdx].mediaType == 'image';
                                          onViewPlayerCreated(id, isImage);
                                        },
                                        x: 0,
                                        y: _playerY,
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.width * (16 / 9),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Visibility(
                                      visible: isPlay,
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: StickerOverlay(
                                          stickers: _groupUserStories?[index].story?[_curChildIdx].stickers,
                                          fullscreen: true,
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.width * (16 / 9),
                                          isPause: isPause || _showLoading,
                                          canPause: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                      : Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                  // ? (value.onChangingVid
                  //     ? Container(
                  //         color: Colors.black,
                  //         alignment: Alignment.center,
                  //         child: const CircularProgressIndicator(),
                  //       )
                  //     : player)
                  // : Container(
                  //     color: Colors.black,
                  //     alignment: Alignment.center,
                  //     child: const CircularProgressIndicator(),
                  //   );
                }),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  // padding: EdgeInsets.only(bottom: 25.0),
                  child: _buildFillStory(value, index),
                ),

                _buildSingleScreen(index, value),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildFillStory(StoriesPlaylistNotifier not, int index) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Row(
              children: (_groupUserStories?[index].story ?? []).map((it) {
                print('seconds: ${_animationController?.value}');
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5, right: _groupUserStories![index].story!.last == it ? 0 : 4),
                    height: 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: it.postID == _groupUserStories![index].story?[_curChildIdx].postID
                          ? LineIndicatorTransition(
                              value: Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(parent: _animationController ?? animationController, curve: Curves.easeIn)),
                              color: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
                              backgroundColor: kHyppeLightButtonText.withOpacity(0.4))
                          : LinearProgressIndicator(
                              value: (shown.contains(it.postID) ? 1 : 0),
                              backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
                              valueColor: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
                            ),
                    ),
                  ),
                );
                // return Expanded(
                //   child: Container(
                //     padding: EdgeInsets.only(top: 5, right: _groupUserStories![index].story!.last == it ? 0 : 4),
                //     height: 9,
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(40.0),
                //       child: TweenAnimationBuilder<double>(
                //         duration: const Duration(milliseconds: 250),
                //         tween: Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeIn)),
                //         builder: (context, value, _) {
                //           return LinearProgressIndicator(
                //             value: it.postID == _groupUserStories![index].story?[_curChildIdx].postID ? value : (shown.contains(it.postID) ? 1 : 0),
                //             backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
                //             valueColor: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
                //           );
                //         }
                //       ),
                //     ),
                //   ),
                // );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // storyPrev(not);
                    if (isPause) {
                      print('StoryPlayer pause1');
                      play();
                    } else {
                      print('StoryPlayer page1');
                      storyPrev(not);
                    }
                  },
                  onLongPressEnd: (value) => play(),
                  onLongPressStart: (value) => pause(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    // padding: EdgeInsets.only(bottom: 25.0),
                    color: Colors.transparent,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // storyComplete(not);
                    if (isPause) {
                      print('StoryPlayer pause2');
                      play();
                    } else {
                      print('StoryPlayer page2');
                      storyComplete(not);
                    }
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
          if (_groupUserStories?[index].story?[_curChildIdx] != null)
            BuildTopView(
              when: System().readTimestamp(
                    DateTime.parse(_groupUserStories?[index].story?[_curChildIdx].createdAt ?? '').millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  ) ??
                  '',
              data: _groupUserStories?[index].story?[_curChildIdx],
              // storyController: _storyController,
            ),
          (_groupUserStories?[index].story?[_curChildIdx].isReport ?? false)
              ? Container()
              : Form(
                  child: BuildBottomView(
                    data: _groupUserStories?[index].story?[_curChildIdx],
                    // storyController: _storyController,
                    currentStory: _groupUserStories?[index].story?.indexOf(_groupUserStories![index].story?[_curChildIdx] ?? ContentData()),
                    animationController: emojiController,
                    currentIndex: _curChildIdx,
                    pause: pause,
                    play: play,
                    // play: play,
                  ),
                ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) {
              animation = CurvedAnimation(parent: animation, curve: Curves.bounceOut);
              return ScaleTransition(
                scale: animation,
                alignment: Alignment.center,
                child: child,
              );
            },
            child: not.linkCopied
                ? const Center(
                    child: LinkCopied(),
                  )
                : const SizedBox.shrink(),
          ),
          // BuildReplayCaption(data: _groupUserStories![_curIdx].story?[_curChildIdx]),
          // Stack(children: [...not.buildItems(emojiController)])
          Stack(children: [...not.buildItems(emojiController)])
        ],
      ),
    );
  }

  Widget _buildSingleScreen(int index, StoriesPlaylistNotifier not) {
    // VideoModel model = _dataList[index];
    // if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image' && loadImage == 1) {
    //   _animationController?.forward();
    // }
    return !isPlay || (_groupUserStories?[index].story?[_curChildIdx].mediaType == 'image' && _groupUserStories?[index].story?[_curChildIdx].music?.apsaraMusic != null)
        ? Stack(
            children: [
              _groupUserStories?[index].story?[_curChildIdx].mediaType == 'image'
                  ? FutureBuilder(
                      future: Future.wait([
                        for (StickerModel sticker in _groupUserStories?[index].story?[_curChildIdx].stickers ?? []) precacheImage(NetworkImage(sticker.image ?? ''), context),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          Container();
                        }
                        return Container(
                          color: Colors.black,
                          child: CustomBaseCacheImage(
                            widthPlaceHolder: 112,
                            heightPlaceHolder: 40,
                            imageUrl: (_groupUserStories?[index].story?[_curChildIdx].isApsara ?? false)
                                ? (_groupUserStories?[index].story?[_curChildIdx].media) == null
                                    ? "${_groupUserStories?[index].story?[_curChildIdx].mediaUri}"
                                    : "${_groupUserStories?[index].story?[_curChildIdx].media?.imageInfo?[0].url}"
                                : "${_groupUserStories?[index].story?[_curChildIdx].fullContent}",
                            imageBuilder: (context, imageProvider) {
                              if (_groupUserStories?[index].story?[_curChildIdx].mediaType == 'image') {
                                loadImage++;
                              }
                              return Center(
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        width: double.infinity,
                                        // height: double.infinity,
                                        height: MediaQuery.of(context).size.width * (16 / 9),
                                        // margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: StickerOverlay(
                                          stickers: _groupUserStories?[index].story?[_curChildIdx].stickers,
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.width * (16 / 9),
                                          fullscreen: true,
                                          isPause: isPause,
                                          canPause: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            placeHolderWidget: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.transparent,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        strokeWidth: 3.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // child: _buildBody(index),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              // child: _buildBody(index),
                            ),
                            emptyWidget: Container(
                              width: double.infinity,
                              height: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              // child: _buildBody(index),
                            ),
                          ),
                        );
                      })
                  : Center(
                      child: const CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                      ),
                    ),
              _buildFillStory(not, index),
            ],
          )
        : Container();
  }

  void initStory() async {
    // final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
    notifier.initStateGroup(context, widget.argument);
    _groupUserStories = notifier.groupUserStories;

    start();
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    _animationController?.reset();
    final fixContext = Routing.navigatorKey.currentContext;
    final storyRef = (Routing.navigatorKey.currentContext ?? context).read<PreviewStoriesNotifier>();
    (Routing.navigatorKey.currentContext ?? context).read<StoriesPlaylistNotifier>().textEditingController.clear();
    emojiController.reset();
    System().increaseViewCount(fixContext ?? context, _groupUserStories![_curIdx].story?[_curChildIdx] ?? ContentData()).whenComplete(() {
      // _showAds(Routing.navigatorKey.currentContext ?? context);
      storyRef.setViewed(_curIdx, _curChildIdx);
    });
    fAliplayer?.stop();
    isPlay = false;
    print("ini index1 $_curIdx");
    print("ini index2 $_curChildIdx");

    if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'video') {
      await getAuth(_groupUserStories?[_curIdx].story?[_curChildIdx].apsaraId ?? '');
      print("startsttt==========");
      // _isPause = false;
      // _isFirstRenderShow = false;
      if (mounted) {
        setState(() {});
      }
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
      // // Configure the application.
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
      fAliplayer?.prepare();
    } else {
      print("animasi start");
      if (_groupUserStories?[_curIdx].story?[_curChildIdx].music?.apsaraMusic != null) {
        print("================== gambar music ${[_curChildIdx]}");
        print("================== gambar music ${_groupUserStories?[_curIdx].story?[_curChildIdx].music?.apsaraMusic}");
        await getAuth(_groupUserStories?[_curIdx].story?[_curChildIdx].music?.apsaraMusic ?? '');
        fAliplayer?.prepare();
      } else {
        _animationController?.duration = const Duration(milliseconds: 8000);
        _animationController?.forward();
      }
    }
  }

  ///Loading
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
}
