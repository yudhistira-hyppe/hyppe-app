import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import '../../../../../app.dart';
import '../../../../../core/arguments/other_profile_argument.dart';
import '../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../core/bloc/ads_video/state.dart';
import '../../../../../core/config/ali_config.dart';
import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../core/constants/utils.dart';
import '../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../core/models/collection/advertising/view_ads_request.dart';
import '../../../../../core/services/shared_preference.dart';
import '../../../../../core/services/system.dart';
import '../../../../../ux/path.dart';
import '../../../widget/custom_base_cache_image.dart';
import '../../../widget/custom_icon_widget.dart';
import '../../../widget/custom_loading.dart';
import '../../bottom_sheet/show_bottom_sheet.dart';
import '../show_general_dialog.dart';

class AdsPopupVideoDialog extends StatefulWidget {
  final AdsData data;
  final String auth;
  const AdsPopupVideoDialog({Key? key, required this.data, required this.auth}) : super(key: key);

  @override
  State<AdsPopupVideoDialog> createState() => _AdsPopupVideoDialogState();
}

class _AdsPopupVideoDialogState extends State<AdsPopupVideoDialog> with WidgetsBindingObserver, TickerProviderStateMixin {
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

  var loadLaunch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
      secondsSkip = widget.data.adsSkip ?? 0;
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

      _initListener();
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
      _currentPlayerState = newState;
      try{
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            Wakelock.enable();
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
            Wakelock.disable();
            _animationController?.stop();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusStopped:
            Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
            Wakelock.disable();
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            Wakelock.disable();
            break;
          default:
        }
      }catch(e){
        e.logger();
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
      _animationController?.forward();
      setState(() {
        _showLoading = false;
      });
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      _inSeek = false;
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
    adsGlobalAliPlayer = fAliplayer;
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
    }
  }

  Future adsView(AdsData data, int time, {bool isClick = false}) async {
    try {
      setState(() {
        loadingAction = true;
      });


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
    Wakelock.disable();
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
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
    fAliplayer?.setPlayerView(viewId);
    fAliplayer?.setVidAuth(
        vid: widget.data.videoId,
        region: DataSourceRelated.defaultRegion,
        playAuth: widget.auth,
        definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
        previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final language = context.read<TranslateNotifierV2>().translate;
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CustomBaseCacheImage(
                                    imageUrl: widget.data.avatar?.fullLinkURL,
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
                                    errorWidget: (_, __, ___) {
                                      return Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(18)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage('${AssetPath.pngPath}content-error.png'),
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
                                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  twelvePx,
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextWidget(textToDisplay: widget.data.fullName ?? '', textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700, ),),
                                      CustomTextWidget(textToDisplay: language.sponsored ?? 'Bersponsor', textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, ),)
                                    ],
                                  ),),
                                  twelvePx,
                                  GestureDetector(
                                    onTap: () {
                                      ShowBottomSheet().onReportContent(
                                        context,
                                        adsData: widget.data,
                                        type: adsPopUp,
                                        postData: null,
                                        onUpdate: () {
                                          setState(() {
                                            widget.data.isReport = true;
                                          });
                                        },
                                      );
                                    },
                                    child: const CustomIconWidget(
                                      defaultColor: false,
                                      iconData: '${AssetPath.vectorPath}more.svg',
                                      color: kHyppeTextLightPrimary,
                                    ),
                                  ),
                                  tenPx,
                                  secondsSkip > 0 ? Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.grey),
                                    child: Text(
                                      '$secondsSkip',
                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ) : InkWell(
                                    onTap: (){
                                      Routing().moveBack();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: CustomIconWidget(
                                        defaultColor: false,
                                        iconData: "${AssetPath.vectorPath}close_ads.svg",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16/9,
                                      child: ClipRRect(
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(16.0)),
                                        child: AliPlayerView(
                                          onCreated: onViewPlayerCreated,
                                          x: 0,
                                          y: 0,
                                          height:
                                          MediaQuery.of(context).size.width * 16/9,
                                          width: MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                    ),
                                    // Image.asset('${AssetPath.pngPath}avatar_ads_exp.png', width: double.infinity, fit: BoxFit.cover,),
                                    // Container(
                                    //   width: double.infinity,
                                    //   decoration: BoxDecoration(
                                    //     image: const DecorationImage(
                                    //       image: AssetImage('${AssetPath.pngPath}avatar_ads_exp.png'),
                                    //       fit: BoxFit.fitWidth,
                                    //     ),
                                    //     borderRadius: BorderRadius.circular(12.0),
                                    //   ),
                                    // ),
                                    sixteenPx,
                                    if(widget.data.adsDescription != null)
                                    CustomTextWidget(
                                      maxLines: 10,
                                      textAlign: TextAlign.justify,
                                      textToDisplay: widget.data.adsDescription ?? '',
                                      textStyle: context.getTextTheme().bodyText1,),
                                    sixteenPx,
                                    InkWell(
                                      onTap: () async {
                                        final data = widget.data;
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
                                            // adsView(widget.data, secondsVideo, isClick: true).whenComplete(() {
                                            //   Navigator.pop(context);
                                            //   Future.delayed(const Duration(milliseconds: 800), () {
                                            //     Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                            //   });
                                            // });
                                          } else {
                                            try {
                                              final uri = Uri.parse(data.adsUrlLink ?? '');
                                              print('bottomAdsLayout ${data.adsUrlLink}');
                                              if (await canLaunchUrl(uri)) {
                                                setState(() {
                                                  loadLaunch = true;
                                                });
                                                print('second close ads: $secondsVideo');
                                                // Navigator.pop(context);
                                                // await launchUrl(
                                                //   uri,
                                                //   mode: LaunchMode.externalApplication,
                                                // );
                                                // adsView(widget.data, secondsVideo, isClick: true).whenComplete(() async {
                                                //   Navigator.pop(context);
                                                //   await launchUrl(
                                                //     uri,
                                                //     mode: LaunchMode.externalApplication,
                                                //   );
                                                // });
                                              } else {
                                                throw "Could not launch $uri";
                                              }
                                              // can't launch url, there is some error
                                            } catch (e) {
                                              setState(() {
                                                loadLaunch = true;
                                              });
                                              print('second close ads: $secondsVideo');
                                              System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                              // adsView(widget.data, secondsVideo, isClick: true).whenComplete(() {
                                              //   System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                              // });
                                            }
                                          }
                                        }
                                      },
                                      child: Builder(builder: (context) {
                                        final notifier = context.read<TranslateNotifierV2>();
                                        final learnMore = secondsSkip < 1 ? (notifier.translate.learnMore ?? 'Learn More') : "${notifier.translate.learnMore ?? 'Learn More'}($secondsSkip)";
                                        return Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: secondsSkip < 1 ? KHyppeButtonAds : context.getColorScheme().secondary),
                                          child: loadLaunch ? const SizedBox(width: 40, height: 20, child: CustomLoading()) : Text(
                                            learnMore,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void start() async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    _animationController?.reset();
    fAliplayer?.stop();
    isPlay = false;

    setState(() {
      _isPause = false;
      _isFirstRenderShow = false;
    });

    fAliplayer?.prepare();
    // fAliplayer?.play();
  }
}
