import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/player/player_full_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  final ModeTypeAliPLayer playMode;
  final Map<String, dynamic> dataSourceMap;
  final ContentData? data;

  double? height;
  double? width;

  PlayerPage({
    Key? key,
    required this.playMode,
    required this.dataSourceMap,
    required this.data,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  FlutterAliplayer? fAliplayer;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;

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
  bool _showLoading = true;

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
  ConnectivityResult? _currentConnectivityResult;

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

  @override
  void initState() {
    super.initState();
    getAuth();
    fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
    fAliplayer?.setAutoPlay(false);

    WidgetsBinding.instance.addObserver(this);
    bottomIndex = 0;
    _playMode = widget.playMode;
    _dataSourceMap = widget.dataSourceMap;
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
  }

  Future getAuth() async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: widget.data?.apsaraId ?? '');
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        print(fetch.data);
        Map jsonMap = json.decode(fetch.data.toString());
        _dataSourceMap?[DataSourceRelated.playAuth] = jsonMap['PlayAuth'] ?? '';
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      // 'Failed to fetch ads data $e'.logger();
    }
    setState(() {
      isloading = false;
    });
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
        setState(() {
          isPrepare = true;
        });
      });
    });
    fAliplayer?.setOnRenderingStart((playerId) {
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
        if (!_inSeek) {
          setState(() {
            _currentPositionText = extraValue ?? 0;
          });
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
      _tipsContent = "Play完成";
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

    _setNetworkChangedListener();
  }

  _setNetworkChangedListener() {
    _networkSubscriptiion = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        fAliplayer?.pause();
        setState(() {
          _isShowMobileNetWork = true;
        });
      } else if (result == ConnectivityResult.wifi) {
        //从4G网络或者无网络切换到wifi
        if (_currentConnectivityResult == ConnectivityResult.mobile || _currentConnectivityResult == ConnectivityResult.none) {
          fAliplayer?.play();
        }
        setState(() {
          _isShowMobileNetWork = false;
        });
      }
      _currentConnectivityResult = result;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        _setNetworkChangedListener();
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
    isPlay = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;

    var height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    if (isloading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        // padding: EdgeInsets.only(bottom: 25.0),
        // child: _buildThumbnail(width, height),
      );
    } else {
      AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: widget.width, height: widget.height);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isPrepare) fAliplayer?.prepare();
      });
      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) => GestureDetector(
          onTap: () {
            onTapCtrl = true;
            setState(() {});
          },
          child: Stack(
            children: [
              Container(color: Colors.black, width: width, height: height, child: aliPlayerView),

              // /====slide dan tombol fullscreen
              if (isPlay)
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  // padding: EdgeInsets.only(bottom: 25.0),
                  child: Offstage(offstage: _isLock, child: _buildContentWidget(orientation)),
                ),

              if (!isPlay)
                SizedBox(
                  height: height,
                  width: width,
                  child: VideoThumbnail(
                    videoData: widget.data,
                    onDetail: false,
                    fn: () {},
                  ),
                ),
              if (!isPlay)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      print("ini play");
                      isPlay = true;
                      fAliplayer?.prepare();
                      fAliplayer?.play();
                      setState(() {});
                    },
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

              _buildProgressBar(widget.width ?? 0, widget.height ?? 0),
              _buildTipsWidget(widget.width ?? 0, widget.height ?? 0),

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

              // Positioned(
              //   left: 30,
              //   top: height / 2,
              //   child: Offstage(
              //       offstage: orientation == Orientation.portrait,
              //       child: InkWell(
              //         onTap: () {
              //           setState(() {
              //             _isLock = !_isLock;
              //           });
              //         },
              //         child: Container(
              //           width: 40,
              //           height: 40,
              //           decoration: BoxDecoration(color: Colors.black.withAlpha(150), borderRadius: BorderRadius.circular(20)),
              //           child: Icon(
              //             _isLock ? Icons.lock : Icons.lock_open,
              //             color: Colors.white,
              //           ),
              //         ),
              //       )),
              // )
            ],
          ),
        ),
      );
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
    switch (_playMode) {
      case ModeTypeAliPLayer.url:
        fAliplayer?.setUrl(_dataSourceMap?[DataSourceRelated.urlKey]);
        break;
      case ModeTypeAliPLayer.sts:
        fAliplayer?.setVidSts(
            vid: _dataSourceMap?[DataSourceRelated.vidKey],
            region: _dataSourceMap?[DataSourceRelated.regionKey],
            accessKeyId: _dataSourceMap?[DataSourceRelated.accessKeyId],
            accessKeySecret: _dataSourceMap?[DataSourceRelated.accessKeySecret],
            securityToken: _dataSourceMap?[DataSourceRelated.securityToken],
            definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
            previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);
        break;
      case ModeTypeAliPLayer.auth:
        fAliplayer?.setVidAuth(
            vid: _dataSourceMap?[DataSourceRelated.vidKey],
            region: _dataSourceMap?[DataSourceRelated.regionKey],
            playAuth: _dataSourceMap?[DataSourceRelated.playAuth],
            definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
            previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);

        break;
      case ModeTypeAliPLayer.mps:
        fAliplayer?.setVidMps(_dataSourceMap!);
        break;
      default:
    }
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      setState(() {});
    });
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSkipBack(iconColor, barHeight),
            _buildPlayPause(iconColor, barHeight),
            _buildSkipForward(iconColor, barHeight),
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
          fAliplayer?.play();
          isPause = false;
          setState(() {});
        } else {
          fAliplayer?.pause();
          isPause = true;
          setState(() {});
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

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {},
      child: CustomIconWidget(
        iconData: "${AssetPath.vectorPath}replay10.svg",
        defaultColor: false,
      ),
      // Icon(
      //   Icons.replay_10_outlined,
      //   color: iconColor,
      //   size: barHeight * 0.4,
      // ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      // onTap: skipForward,
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}forward10.svg",
        defaultColor: false,
      ),
      //  Icon(
      //   Icons.forward_10_outlined,
      //   color: iconColor,
      //   size: barHeight * 0.4,
      // ),
    );
  }

  ///缩略图
  _buildThumbnail(double width, double height) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          widget.data?.mediaThumbEndPoint == '' ? Container() : Container(width: width, height: height, child: Image.network(widget.data?.mediaThumbEndPoint ?? '')),
        ],
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
                fAliplayer?.prepare();
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
      return Positioned(
        left: width / 2 - 20,
        top: height / 2 - 20,
        child: Column(
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
      );
    } else {
      return SizedBox();
    }
  }

  ///播放进度和buffer
  _buildContentWidget(Orientation orientation) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              sixPx,
              Text(
                System.getTimeformatByMs(_currentPositionText),
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
                      max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                      value: _currentPosition.toDouble(),
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
                        fAliplayer?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
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
              ),
              GestureDetector(
                onTap: () {
                  print('sentuh aku $orientation');

                  if (orientation == Orientation.portrait) {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

                    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                    // context.read<VidDetailNotifier>().orientation = Orientation.landscape;
                    // context.read<VidDetailNotifier>().onUpdate();
                  } else {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                    // widget.function!(Orientation.landscape);

                    // context.read<VidDetailNotifier>().orientation = Orientation.landscape;
                    // context.read<VidDetailNotifier>().onUpdate();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(19.0),
                  child: Icon(
                    orientation == Orientation.portrait ? Icons.fullscreen : Icons.fullscreen_exit,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
