import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/link_copied_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_bottom_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_replay_caption.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_top_view.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

class StoryPlayerPage extends StatefulWidget {
  final StoryDetailScreenArgument argument;

  const StoryPlayerPage({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  State<StoryPlayerPage> createState() => _StoryPlayerPageState();
}

class _StoryPlayerPageState extends State<StoryPlayerPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  FlutterAliplayer? fAliplayer;

  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  String auth = '';
  List shown = [];

  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  bool _mEnablePlayBack = false;

  //当前播放进度
  int _currentPosition = 0;

  //当前播放时间，用于Text展示
  int _currentPositionText = 0;

  //当前buffer进度
  int _bufferPosition = 0;

  //是否展示loading
  bool _showLoading = false;

  //loading进度
  int _loadingPercent = 0;

  //视频时长
  int _videoDuration = 1;

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
  AnimationController? _animationController;

  // PageController? _pageController;

  RefreshController _videoListRefreshController = RefreshController(initialRefresh: false);

  List<StoriesGroup>? _groupUserStories;

  late PageController _pageController;

  int _curIdx = 0;
  int _curChildIdx = 0;
  int _lastCurIndex = -1;
  bool _isPause = false;
  double _playerY = 0;
  bool _isFirstRenderShow = false;
  bool _isBackgroundMode = false;
  int loadImage = 0;

  @override
  void initState() {
    print("======================ke initstate");

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        print("=========== ${widget.argument.peopleIndex}");
        _pageController = PageController(initialPage: widget.argument.peopleIndex);
      });
      _animationController = AnimationController(
        vsync: this,
      )
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener(
          (AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              storyComplete();
            }
          },
        );
      _curChildIdx = 0;
      _curIdx = widget.argument.peopleIndex.toInt();
      _lastCurIndex = widget.argument.peopleIndex.toInt();

      print("initial index ${widget.argument.peopleIndex}");
      // _pageController.addListener(() => notifier.currentPage = _pageController.page);
      initStory();

      fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
      var configMap = {
        'mClearFrameWhenStop': true,
      };
      fAliplayer?.setConfig(configMap);

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);
      _playMode = ModeTypeAliPLayer.auth;
      isPlay = false;
      isPrepare = false;
      setState(() {});

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
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
            previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);
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
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      _animationController?.forward();

      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          setState(() {
            _showTipsWidget = false;
            _showLoading = false;
            isPause = false;
          });
          _animationController?.forward();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          _animationController?.stop();
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      _animationController?.stop();
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
      // _animationController?.forward();
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
      _showTipsWidget = true;
      _showLoading = false;
      _tipsContent = "Play Again";
      isPause = true;
      _animationController?.reset();
      storyComplete();
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
      if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });
  }

  void storyComplete() {
    if (_curChildIdx == ((_groupUserStories![_curIdx].story?.length ?? 0) - 1)) {
      shown = [];
      if (_curIdx == (_groupUserStories!.length - 1)) {
        Routing().moveBack();
      } else {
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
        _curChildIdx = 0;
        setState(() {});
      }
    } else {
      setState(() {
        if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image') {
          _animationController?.duration = const Duration(milliseconds: 5000);
        }
        shown.add(_groupUserStories![_curIdx].story?[_curChildIdx].postID);
        print(shown);
        _curChildIdx++;
      });
      start();
    }
  }

  void storyPrev() {
    if (_curChildIdx > 0) {
      _curChildIdx--;
      setState(() {});
      start();
    } else {
      if (_curIdx > 0) {
        shown = [];
        _pageController.previousPage(duration: const Duration(milliseconds: 900), curve: Curves.ease);
        _curChildIdx = 0;
        setState(() {});
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
          // fAliplayer?.pause();
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
    _animationController?.dispose();
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

  void play() {
    fAliplayer?.play();
  }

  void pause() {
    print('pause pause');
    fAliplayer?.pause();
    _animationController?.stop();
  }

  void onViewPlayerCreated(viewId) async {
    print('onViewPlayerCreated===');
    fAliplayer?.setPlayerView(viewId);
  }

  final notifier = StoriesPlaylistNotifier();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoriesPlaylistNotifier>(
      create: (context) => notifier,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: _groupUserStories?.length ?? 0,
        onPageChanged: (index) async {
          _curIdx = index;
          setState(() {});
          if (_lastCurIndex != _curIdx) {
            _curChildIdx = 0;
            start();
          }
          _lastCurIndex = _curIdx;
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              AliPlayerView(
                onCreated: onViewPlayerCreated,
                x: 0,
                y: _playerY,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                // padding: EdgeInsets.only(bottom: 25.0),
                child: _buildFillStory(),
              ),
              _buildSingleScreen(index),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFillStory() {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Row(
              children: _groupUserStories![_curIdx].story!.map((it) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5, right: _groupUserStories![_curIdx].story!.last == it ? 0 : 4),
                    height: 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: LinearProgressIndicator(
                        value: it.postID == _groupUserStories![_curIdx].story?[_curChildIdx].postID ? _animationController?.value : (shown.contains(it.postID) ? 1 : 0),
                        backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    storyPrev();
                  },
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
                    storyComplete();
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    // padding: EdgeInsets.only(bottom: 25.0),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          BuildTopView(
            when: System().readTimestamp(
                  DateTime.parse(_groupUserStories![_curIdx].story?[_curChildIdx].createdAt ?? '').millisecondsSinceEpoch,
                  context,
                  fullCaption: true,
                ) ??
                '',
            data: _groupUserStories![_curIdx].story?[_curChildIdx],
            // storyController: _storyController,
          ),
          (_groupUserStories![_curIdx].story?[_curChildIdx].isReport ?? false)
              ? Container()
              : Form(
                  child: BuildBottomView(
                    data: _groupUserStories![_curIdx].story?[_curChildIdx],
                    // storyController: _storyController,
                    currentStory: _groupUserStories![_curIdx].story?.indexOf(_groupUserStories![_curIdx].story?[_curChildIdx] ?? ContentData()),
                    // animationController: animationController,
                    currentIndex: _curChildIdx,
                    pause: pause,
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
            child: notifier.linkCopied
                ? const Center(
                    child: LinkCopied(),
                  )
                : const SizedBox.shrink(),
          ),
          BuildReplayCaption(data: _groupUserStories![_curIdx].story?[_curChildIdx]),
          ...notifier.buildItems(_animationController!)
        ],
      ),
    );
  }

  Widget _buildSingleScreen(int index) {
    // VideoModel model = _dataList[index];
    if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image' && loadImage == 1) {
      _animationController?.forward();
    }
    return !isPlay
        ? Stack(
            children: [
              _groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image'
                  ? Container(
                      color: Colors.black,
                      child: CustomBaseCacheImage(
                        widthPlaceHolder: 112,
                        heightPlaceHolder: 40,
                        imageUrl: (_groupUserStories?[_curIdx].story?[_curChildIdx].isApsara ?? false)
                            ? (_groupUserStories?[_curIdx].story?[_curChildIdx].media) == null
                                ? "${_groupUserStories?[_curIdx].story?[_curChildIdx].mediaUri}"
                                : "${_groupUserStories?[_curIdx].story?[_curChildIdx].media?.imageInfo?[0].url}"
                            : "${_groupUserStories?[_curIdx].story?[_curChildIdx].fullThumbPath}",
                        imageBuilder: (context, imageProvider) {
                          if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'image') {
                            loadImage++;
                          }
                          return Container(
                            clipBehavior: Clip.hardEdge,
                            width: double.infinity,
                            height: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
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
                    )
                  : Center(
                      child: const CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                      ),
                    ),
              _buildFillStory()
            ],
          )
        : Container();
  }

  void initStory() async {
    // final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
    notifier.initStateGroup(context, widget.argument);
    _groupUserStories = notifier.groupUserStories;
    print(_groupUserStories);
    start();
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    _animationController?.reset();
    fAliplayer?.stop();
    isPlay = false;
    print("ini index1 $_curIdx");
    print("ini index2 $_curChildIdx");

    if (_groupUserStories?[_curIdx].story?[_curChildIdx].mediaType == 'video') {
      await getAuth(_groupUserStories?[_curIdx].story?[_curChildIdx].apsaraId ?? '');
      print("startsttt==========");
      setState(() {
        _isPause = false;
        _isFirstRenderShow = false;
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
      _animationController?.duration = const Duration(milliseconds: 5000);
      _animationController?.forward();
    }

    // fAliplayer?.play();
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      setState(() {});
    });
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