import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_item_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_user_tag.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/top_item_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

  PageController? _pageController;

  RefreshController _videoListRefreshController = RefreshController(initialRefresh: false);

  List<ContentData>? _listData;
  @override
  void initState() {
    print("======================ke initstate");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _curIdx = widget.argument.index.toInt();
      _lastCurIndex = widget.argument.index.toInt();
      _pageController = PageController(initialPage: _curIdx);
      initDiary();

      fAliplayer = FlutterAliPlayerFactory.createAliPlayer();

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);
      var configMap = {
        'mClearFrameWhenStop': true,
      };
      fAliplayer?.setConfig(configMap);

      print("Hahahaha $_videoDuration");

      _animationController = AnimationController(
        /// [AnimationController]s can be created with `vsync: this` because of
        /// [TickerProviderStateMixin].
        vsync: this,
        // duration: Duration(milliseconds: _videoDuration),
      )..addListener(() {
          setState(() {});
        });

      // _animationController?.repeat(reverse: false);

      _playMode = ModeTypeAliPLayer.auth;
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
    });
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      // isloading = true;
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

  int _curIdx = 0;
  int _lastCurIndex = -1;
  bool _isPause = false;
  double _playerY = 0;
  bool _isFirstRenderShow = false;
  bool _isBackgroundMode = false;

  void onViewPlayerCreated(viewId) async {
    print('onViewPlayerCreated===');
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isloading
          ? Container()
          : NotificationListener(
              onNotification: (ScrollNotification notification) {
                print("test test $_curIdx");
                if (notification.depth == 0 && notification is ScrollUpdateNotification) {
                  final PageMetrics metrics = notification.metrics as PageMetrics;
                  _playerY = metrics.pixels - _curIdx * MediaQuery.of(context).size.height;
                  print("selesai _curIdx $_curIdx");
                  setState(() {});
                } else if (notification is ScrollEndNotification) {
                  _playerY = 0.0;
                  PageMetrics metrics = notification.metrics as PageMetrics;
                  _curIdx = metrics.page!.round();
                  print("selesai _curIdx $_curIdx");
                  if (_lastCurIndex != _curIdx) {
                    start();
                  }
                  print("selesai _curIdx2 $_curIdx");
                  _lastCurIndex = _curIdx;
                  print("selesai _lastCurIndex $_lastCurIndex");
                }
                return false;
              },
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: _playerY,
                    child: Container(
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      // child: Center(
                      //     child: Text(
                      //   "${_lastCurIndex}",
                      //   style: TextStyle(color: Colors.white),
                      // )),
                      child: AliPlayerView(
                        onCreated: onViewPlayerCreated,
                        x: 0,
                        y: _playerY,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: LinearProgressIndicator(
                        value: _animationController?.value,
                        backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
                        valueColor: AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
                      ),
                    ),
                  ),
                  _buildProgressBar(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  SmartRefresher(
                    // scrollDirection: Axis.horizontal,
                    enablePullDown: true,
                    enablePullUp: true,
                    header: ClassicHeader(),
                    footer: ClassicFooter(
                      loadStyle: LoadStyle.ShowWhenLoading,
                    ),
                    controller: _videoListRefreshController,
                    // onRefresh: _onRefresh,
                    // onLoading: _onLoadMore,
                    child: CustomScrollView(
                      physics: const PageScrollPhysics(),
                      controller: _pageController,
                      slivers: <Widget>[
                        SliverFillViewport(
                            delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _buildSingleScreen(index);
                          },
                          childCount: _listData?.length,
                        ))
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // _exitScreenMode();
                    },
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSingleScreen(int index) {
    // VideoModel model = _dataList[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPause = !_isPause;
        });
        if (_isPause) {
          fAliplayer?.pause();
        } else {
          fAliplayer?.play();
        }
      },
      child: Container(
        // color: Colors.black,
        child: Stack(
          children: [
            _curIdx == index && _isFirstRenderShow
                ? Container(
                    color: Colors.black,
                    child: CustomBaseCacheImage(
                      widthPlaceHolder: 112,
                      heightPlaceHolder: 40,
                      imageUrl: (_listData?[index].isApsara ?? false) ? "${_listData?[index].mediaThumbEndPoint}" : "${_listData?[index].fullThumbPath}",
                      imageBuilder: (context, imageProvider) => Container(
                        clipBehavior: Clip.hardEdge,
                        width: double.infinity,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: _buildBody(index),
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
                        child: _buildBody(index),
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
                        child: _buildBody(index),
                      ),
                    ),
                  )
                : Container(),
            Container(
              color: Colors.black.withAlpha(0),
              alignment: Alignment.center,
              child: Offstage(
                offstage: _isPause == false || _isBackgroundMode == true,
                child: Icon(
                  Icons.play_circle_filled,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    final email = SharedPreference().readStorage(SpKeys.email);
    final isSale = _listData?[index].email != email;
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        if (isSale) Positioned(top: 0, right: 0, child: TopItemView(data: _listData?[index])),
        Positioned(
          bottom: 0,
          left: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BottomItemView(data: _listData?[index]),
              (_listData?[index].tagPeople?.isNotEmpty ?? false) ? BottomUserView(data: _listData?[index]) : const SizedBox(),
            ],
          ),
        ),
        _listData?[index].reportedStatus == 'BLURRED'
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 30.0,
                    sigmaY: 30.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}eye-off.svg",
                          defaultColor: false,
                          height: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void initDiary() async {
    var notifier = context.read<DiariesPlaylistNotifier>();
    notifier.initState(context, widget.argument);
    _listData = notifier.listData;
    start();
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    isPlay = false;
    await getAuth(_listData?[_curIdx].apsaraId ?? '');
    setState(() {
      _isPause = false;
      _isFirstRenderShow = false;
    });

    fAliplayer?.prepare();
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
