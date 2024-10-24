import 'dart:ui';

import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../core/arguments/other_profile_argument.dart';
import '../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../core/models/collection/advertising/view_ads_request.dart';
import '../../../../../core/services/shared_preference.dart';
import '../../../../../core/services/system.dart';
import '../../../../../ux/path.dart';
import '../../../../../ux/routing.dart';
import '../../../widget/custom_base_cache_image.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:path_provider/path_provider.dart';

class AdsPopUpDialog extends StatefulWidget {
  final AdsData data;
  final String auth;
  final bool isSponsored;

  const AdsPopUpDialog({Key? key, required this.data, required this.auth, required this.isSponsored}) : super(key: key);

  @override
  State<AdsPopUpDialog> createState() => _AdsPopUpDialogState();
}

class _AdsPopUpDialogState extends State<AdsPopUpDialog> with WidgetsBindingObserver, TickerProviderStateMixin {
  FlutterAliplayer? fAliplayer;
  // final _sharedPrefs = SharedPreference();
  var secondsSkip = 0;
  var secondsVideo = 0;
  bool loadingAction = false;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  // ModeTypeAliPLayer? _playMode;
  Map<String, dynamic>? _dataSourceMap;
  String auth = '';

  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  bool _mEnablePlayBack = false;

  //当前播放进度
  int _currentPosition = 0;

  //当前播放时间，用于Text展示
  // int _currentPositionText = 0;

  //当前buffer进度
  // int _bufferPosition = 0;

  //是否展示loading
  // bool _showLoading = false;

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

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  // GlobalKey<TrackFragmentState> trackFragmentKey = GlobalKey();
  AnimationController? _animationController;

  // PageController? _pageController;

  // RefreshController _videoListRefreshController = RefreshController(initialRefresh: false);
  //
  // List<ContentData>? _listData;
  //
  // late PageController _pageController;

  var loadLaunch = false;

  @override
  void initState() {
    print("======================ke initstate");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      secondsSkip = widget.data.adsSkip ?? 4;
      secondsImage = 0;
      if ((widget.data.mediaType?.toLowerCase() ?? '') == 'image') {
        startTimer();
      }
      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
      // _pageController.addListener(() => notifier.currentPage = _pageController.page);
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: "iklanPopUp");

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);

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

      // _playMode = ModeTypeAliPLayer.auth;
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

      _initListener();
    });
  }

  Timer? countdownTimer;
  var secondsImage = 0;

  void stopTime({bool isReset = false}) {
    setState(() => countdownTimer?.cancel());
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsSkip == 0) {
        countdownTimer?.cancel();
      } else {
        setState(() {
          secondsSkip -= 1;
          secondsImage += 1;
          if (((widget.data.adsSkip ?? 4) + 2) == secondsImage) {
            stopTime();
          }
        });
      }
    });
  }

  _initListener() {
    Future.delayed(const Duration(milliseconds: 500), () {
      fAliplayer?.prepare();
    });
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        _videoDuration = value['duration'];
        _animationController?.duration = Duration(milliseconds: _videoDuration);

        _animationController?.forward();
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
      // _currentPlayerState = newState;
      try {
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            WakelockPlus.enable();
            setState(() {
              // _showTipsWidget = false;
              // _showLoading = false;
              isPause = false;
            });
            _animationController?.forward();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPaused:
            isPause = true;
            setState(() {});
            WakelockPlus.disable();
            "================ disable wakelock 92".logger();
            _animationController?.stop();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusStopped:
            WakelockPlus.disable();
            "================ disable wakelock 75".logger();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
            WakelockPlus.disable();
            "================ disable wakelock 63".logger();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            WakelockPlus.disable();
            "================ disable wakelock 53".logger();
            break;
          default:
        }
      } catch (e) {
        e.logger();
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      _animationController?.stop();
      setState(() {
        // _loadingPercent = 0;
        // _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      // _loadingPercent = percent;
      if (percent == 100) {
        // _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      _animationController?.forward();
      setState(() {
        // _showLoading = false;
      });
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      // _inSeek = false;
    });
    var lastDetik = 0;
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
          var detik = (_currentPosition / 1000).round();
          print("*************detik $detik");
          secondsVideo = detik;
          print("*************last $lastDetik");
          print("*************last ${lastDetik != detik}");

          if (lastDetik != detik) {
            secondsSkip -= 1;
          }
          print("*************last ${secondsSkip}");
          lastDetik = detik;
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
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      // _showTipsWidget = true;
      // _showLoading = false;
      // _tipsContent = "Play Again";
      isPause = true;
      // adsView(widget.data, secondsVideo);
      setState(() {
        _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showTipsWidget = true;
      // _showLoading = false;
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        fAliplayer?.play();
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

  Future adsView(AdsData data, int time, {bool isClick = false}) async {
    try {
      setState(() {
        loadingAction = true;
      });

      context.read<PreviewDiaryNotifier>().adsData = null;

      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(
        watchingTime: time,
        adsId: data.adsId,
        useradsId: data.useradsId,
      );
      await notifier.viewAdsBloc(context, request, isClick: isClick);

      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print("ini hasil ${fetch.data['rewards']}");
        if (fetch.data['rewards'] == true) {
          print("ini hasil ${mounted}");
          if (mounted) {
            ShowGeneralDialog.adsRewardPop(context).whenComplete(() => null);
            Timer(const Duration(milliseconds: 800), () {
              Routing().moveBack();
              // Routing().moveBack();
              // Timer(const Duration(milliseconds: 800), () {
              //   Routing().moveBack();
              // });
            });
          }
        }
      }
    } catch (e) {
      'Failed hit view ads $e'.logger();
      setState(() {
        loadingAction = false;
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    "================ disable wakelock 434".logger();
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
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

  // int _curIdx = 0;
  // int _lastCurIndex = -1;
  // bool _isPause = false;
  double _playerY = 0;
  // bool _isFirstRenderShow = false;
  // bool _isBackgroundMode = false;

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
    fAliplayer?.setVidAuth(
      vid: widget.data.videoId,
      region: DataSourceRelated.defaultRegion,
      playAuth: widget.auth,
      definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
      // previewTime: _dataSourceMap?[DataSourceRelated.previewTime]
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return WillPopScope(
      onWillPop: () async {
        // if (!loadingAction && secondsSkip < 1 || widget.data.isReport == true) {
        //   adsView(widget.data, secondsVideo);
        //   return true;
        // } else {
        //   return false;
        // }
        // adsView(widget.data, secondsVideo);
        return true;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: (widget.data.mediaType?.toLowerCase() ?? '') == 'image'
                ? CustomBaseCacheImage(
                    memCacheWidth: 100,
                    memCacheHeight: 100,
                    widthPlaceHolder: 80,
                    heightPlaceHolder: 80,
                    imageUrl: widget.data.mediaUri,
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Image border
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.fitWidth,
                        width: context.getWidth(),
                      ),
                    ),
                    emptyWidget: Container(
                        decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                        width: context.getWidth(),
                        height: 250,
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: CustomTextWidget(
                          textToDisplay: language.couldntLoadImage ?? 'Error',
                          maxLines: 3,
                        )),
                    errorWidget: (context, url, error) {
                      return Container(
                          decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                          width: context.getWidth(),
                          height: 250,
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: CustomTextWidget(
                            textToDisplay: language.couldntLoadImage ?? 'Error',
                            maxLines: 3,
                          ));
                    },
                  )
                : AliPlayerView(
                    onCreated: onViewPlayerCreated,
                    x: 0,
                    y: _playerY,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // padding: EdgeInsets.only(bottom: 25.0),
            child: _buildFillDiary(),
          ),
          Positioned(left: 0, top: 50, right: 0, child: topAdsLayout(widget.data)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: (widget.data.isReport ?? false) ? Container() : bottomAdsLayout(widget.data),
          ),
          _buildSingleScreen(),
        ],
      ),
    );
  }

  Widget topAdsLayout(AdsData data) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 18, right: 18, top: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                loadingAction
                    ? Container(
                        // padding: const EdgeInsets.only(left: 8.0),
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: context.getColorScheme().primary, strokeWidth: 3.0))
                    : InkWell(
                        onTap: () async {
                          print('second close ads: $secondsVideo');
                          // await adsView(widget.data, secondsVideo);
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: CustomIconWidget(
                            defaultColor: false,
                            iconData: "${AssetPath.vectorPath}back-arrow.svg",
                          ),
                        ),
                      ),
                data.isReport ?? false
                    ? Container()
                    : Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: widget.data.email));
                              },
                              child: CustomBaseCacheImage(
                                imageUrl: data.avatar?.fullLinkURL,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                imageBuilder: (_, imageProvider) {
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: imageProvider,
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (_, url, ___) {
                                  if (url.isNotEmpty && url.withHttp()) {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.network(url, width: 36, height: 36, fit: BoxFit.cover, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                              ),
                                            ),
                                          );
                                        }, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
                                        }));
                                  }
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(18)),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                                      ),
                                    ),
                                  );
                                },
                                emptyWidget: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(18)),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            twelvePx,
                            Expanded(
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CustomIconWidget(
                                        defaultColor: false,
                                        iconData: "${AssetPath.vectorPath}ad_yellow_icon.svg",
                                      ),
                                      sixPx,
                                      Text(
                                        widget.isSponsored ? 'Sponsored' : '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                  sixPx,
                                  Expanded(
                                      child: Text(
                                    maxLines: 3,
                                    data.adsDescription ?? 'Nike',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                sixPx,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ShowBottomSheet().onReportContent(
                          context,
                          adsData: widget.data,
                          type: adsPopUp,
                          postData: null,
                          onUpdate: () {
                            setState(() {
                              data.isReport = true;
                            });
                          },
                        );
                      },
                      child: const CustomIconWidget(
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}more.svg",
                        color: kHyppeLightButtonText,
                      ),
                    ),
                  ],
                )
              ],
            ),
            // secondsSkip > 0 && widget.data.isReport != true
            //     ? Container(
            //         height: 30,
            //         width: 30,
            //         margin: EdgeInsets.only(top: 0),
            //         child: Text(
            //           '$secondsSkip',
            //           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //         ),
            //         alignment: Alignment.center,
            //         decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.grey),
            //       )
            //     : Container()
          ],
        ),
      ),
    );
  }

  Widget bottomAdsLayout(AdsData data) {
    return Material(
      color: Colors.transparent,
      child: Consumer<TranslateNotifierV2>(builder: (context, notifier, child) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
          child: InkWell(
            onTap: () async {
              if (!loadingAction) {
                if (secondsSkip < 1) {
                  if (data.adsUrlLink?.isEmail() ?? false) {
                    final email = data.adsUrlLink!.replaceAll('email:', '');
                    setState(() {
                      loadLaunch = true;
                    });

                    print('second close ads: $secondsVideo');
                    // Navigator.pop(context);
                    // Future.delayed(const Duration(milliseconds: 800), () {
                    //   Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                    // });
                    adsView(widget.data, secondsVideo, isClick: true).whenComplete(() {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 800), () {
                        Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                      });
                    });
                  } else {
                    final uri = Uri.parse(data.adsUrlLink ?? '');
                    if ((data.adsUrlLink ?? '').withHttp()) {
                      try {
                        print('bottomAdsLayout ${data.adsUrlLink}');

                        if (await canLaunchUrl(uri)) {
                          setState(() {
                            loadLaunch = true;
                          });
                          print('second close ads: $secondsVideo');
                          Navigator.pop(context);
                          // await launchUrl(
                          //   uri,
                          //   mode: LaunchMode.externalApplication,
                          // );
                          adsView(widget.data, secondsVideo, isClick: true).whenComplete(() async {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          });
                        } else {
                          throw "Could not launch $uri";
                        }
                        // can't launch url, there is some error
                      } catch (e) {
                        setState(() {
                          loadLaunch = true;
                        });
                        print('second close ads: $secondsVideo');
                        // System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                        adsView(widget.data, secondsVideo, isClick: true).whenComplete(() {
                          System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                        });
                      }
                    }
                  }
                }
              }
            },
            child: Builder(builder: (context) {
              final learnMore = secondsSkip < 1 ? (notifier.translate.learnMore ?? 'Learn More') : "${notifier.translate.learnMore ?? 'Learn More'}($secondsSkip)";
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: secondsSkip < 1 ? KHyppeButtonAds : context.getColorScheme().secondary),
                child: loadLaunch
                    ? const SizedBox(width: 40, height: 20, child: CustomLoading())
                    : Text(
                        learnMore,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildFillDiary() {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5),
            height: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: LinearProgressIndicator(
                value: _animationController?.value,
                backgroundColor: kHyppeLightButtonText.withOpacity(0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(kHyppeLightButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleScreen() {
    // VideoModel model = _dataList[index];
    return GestureDetector(
      onTap: () {},
      child: !isPlay
          ? Stack(
              children: [
                (widget.data.mediaType?.toLowerCase() ?? '') == 'image'
                    ? const SizedBox.shrink()
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(child: SizedBox(width: 40, height: 40, child: CustomLoading())),
                      ),
                // Container(
                //   color: Colors.black,
                //   child: CustomBaseCacheImage(
                //     widthPlaceHolder: 112,
                //     heightPlaceHolder: 40,
                //     imageUrl: (_listData?[index].isApsara ?? false) ? "${_listData?[index].mediaThumbEndPoint}" : "${_listData?[index].fullThumbPath}",
                //     imageBuilder: (context, imageProvider) => Container(
                //       clipBehavior: Clip.hardEdge,
                //       width: double.infinity,
                //       height: double.infinity,
                //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(8.0),
                //         image: DecorationImage(
                //           image: imageProvider,
                //           fit: BoxFit.contain,
                //         ),
                //       ),
                //       // child: _buildBody(index),
                //     ),
                //     errorWidget: (context, url, error) => Container(
                //       width: double.infinity,
                //       height: double.infinity,
                //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                //       decoration: BoxDecoration(
                //         image: const DecorationImage(
                //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: BorderRadius.circular(8.0),
                //       ),
                //       // child: _buildBody(index),
                //     ),
                //     emptyWidget: Container(
                //       width: double.infinity,
                //       height: double.infinity,
                //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                //       decoration: BoxDecoration(
                //         image: const DecorationImage(
                //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: BorderRadius.circular(8.0),
                //       ),
                //       // child: _buildBody(index),
                //     ),
                //   ),
                // ),
                _buildFillDiary()
              ],
            )
          : Container(),
    );
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    _animationController?.reset();
    fAliplayer?.stop();
    isPlay = false;

    // setState(() {
    //   _isPause = false;
    //   _isFirstRenderShow = false;
    // });

    fAliplayer?.prepare();
    // fAliplayer?.play();
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
  //   if (_showLoading) {
  //     return Positioned(
  //       left: width / 2 - 20,
  //       top: height / 2 - 20,
  //       child: Column(
  //         children: [
  //           const CircularProgressIndicator(
  //             backgroundColor: Colors.white,
  //             strokeWidth: 3.0,
  //           ),
  //           const SizedBox(
  //             height: 10.0,
  //           ),
  //           Text(
  //             "$_loadingPercent%",
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return const SizedBox();
  //   }
  // }
}

