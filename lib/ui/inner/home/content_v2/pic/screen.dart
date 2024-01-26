import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/widget/view_like.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../ux/path.dart';
import '../../../../constant/entities/report/notifier.dart';
// import 'fullscreen/pic_fullscreen_page.dart';

class HyppePreviewPic extends StatefulWidget {
  final ScrollController? scrollController;
  final Function? onScaleStart;
  final Function? onScaleStop;
  final bool? appbarSeen;

  const HyppePreviewPic({
    Key? key,
    this.scrollController,
    this.onScaleStart,
    this.onScaleStop,
    this.appbarSeen,
  }) : super(key: key);

  @override
  _HyppePreviewPicState createState() => _HyppePreviewPicState();
}

class _HyppePreviewPicState extends State<HyppePreviewPic> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  FlutterAliplayer? fAliplayer;
  // TransformationController _transformationController = TransformationController();
  ScrollController innerScrollController = ScrollController();

  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  // bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;

  // int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;
  String _curPostId = '';
  String _lastCurPostId = '';

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  // bool isMute = true;
  String email = '';
  // String statusKyc = '';
  bool isInPage = true;
  // bool _scroolEnabled = true;
  double itemHeight = 0;
  ScrollController controller = ScrollController();
  ScrollPhysics scrollPhysic = const NeverScrollableScrollPhysics();
  double lastOffset = 0;
  bool scroolUp = false;
  GlobalKey? keyOwnership;
  MainNotifier? mn;
  bool isShowShowcase = false;
  int indexKeySell = 0;
  int indexKeyProtection = 0;
  int itemIndex = 0;
  bool isActivePage = true;

  @override
  void initState() {
    print('data screen pic');
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewPic');
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    mn = Provider.of<MainNotifier>(context, listen: false);
    notifier.initAdsCounter();
    // notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    lastOffset = -10;

    // _primaryScrollController = widget.scrollController!;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addObserver(this);
      print("===============init ali player ===========");
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPic');
      initAlipayer();
      print("===============init ali player ${fAliplayer?.playerId} ===========");

      //scroll
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          print("=========== global key prirnt ${widget.scrollController} ");
          widget.scrollController?.addListener(() async {
            double offset = widget.scrollController?.position.pixels ?? 0;
            if (mounted) await toPosition(offset, notifier);
          });
        });
      }
    });
    context.read<HomeNotifier>().removeWakelock();
    super.initState();
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

  initAlipayer() {
    globalAliPlayer = fAliplayer;
    vidConfig();
    fAliplayer?.pause();
    fAliplayer?.setAutoPlay(true);
    fAliplayer?.setLoop(true);

    //Turn on mix mode
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(true);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
    }

    //set player
    fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
    fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    _initListener(notifier);
  }

  _initListener(PreviewPicNotifier notifier) {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      if (SharedPreference().readStorage(SpKeys.isShowPopAds)) {
        notifier.isMute = true;
        fAliplayer?.pause();
      }

      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        setState(() {
          isPrepare = true;
        });
      });
      isPlay = true;
      dataSelected?.isDiaryPlay = true;
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      // _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          setState(() {
            // _showLoading = false;
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
      setState(() {
        // _showLoading = false;
      });
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
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      // _showLoading = false;

      isPause = true;

      setState(() {
        // _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      print("============init ali player error $errorCode - $errorExtra - $errorMsg - $playerId");

      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if ((info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });
    fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

    fAliplayer?.setOnThumbnailGetListener(
        onThumbnailGetSuccess: (bitmap, range, playerId) {
          // _thumbnailBitmap = bitmap;
          var provider = MemoryImage(bitmap);
          precacheImage(provider, context).then((_) {
            setState(() {});
          });
        },
        onThumbnailGetFail: (playerId) {});

    fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future toPosition(double offset, PreviewPicNotifier notifier) async {
    double totItemHeight = 0;
    double totItemHeightParam = 0;
    print("======== to position ${offset}---====");
    if (offset < 10) {
      itemIndex = 0;
    }

    // if (offset >= lastOffset) {
    print("============== to position");
    if (!scroolUp) {
      print("============== $scroolUp");
      for (var i = 0; i <= itemIndex; i++) {
        if (i == itemIndex) {
          totItemHeightParam += (notifier.pic?[i].height ?? 0.0) * 30 / 100;
        } else {
          totItemHeightParam += notifier.pic?[i].height ?? 0.0;
        }
        totItemHeight += notifier.pic?[i].height ?? 0.0;
      }

      var sizeMax = (SizeConfig.screenHeight ?? 0) + (SizeConfig.screenHeight ?? 0) * 0.633;
      if ((notifier.pic?.length ?? 0) > (_curIdx + 1)) {
        print("====erpppppp");
        print("====offset $offset");
        print("====totItemHeightParam $totItemHeightParam");
        print("====totItemHeightParam $sizeMax");

        if (offset >= totItemHeightParam && (notifier.pic?[itemIndex + 1].height ?? 0) <= sizeMax) {
          var position = totItemHeight;
          // if (notifier.pic?[_curIdx + 1].height >= sizeMax) {
          //   position += notifier.pic?[_curIdx + 1].height;
          // }
          if (!homeClick) {
            print("====erpppppp");
            try {
              widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
              itemIndex++;
            } catch (e) {
              print("====erroorrroooo $e");
            }
          }
        }
      } else {}
      // }
      // for (var i = 0; i <= _curIdx; i++) {
      //   if (i == _curIdx) {
      //     totItemHeightParam += (notifier.pic?[i].height ?? 0.0) * 30 / 100;
      //   } else {
      //     totItemHeightParam += notifier.pic?[i].height ?? 0.0;
      //   }
      //   totItemHeight += notifier.pic?[i].height ?? 0.0;
      // }

      // var sizeMax = (SizeConfig.screenHeight ?? 0) + (SizeConfig.screenHeight ?? 0) * 0.633;
      // if (offset >= totItemHeightParam && (notifier.pic?[_curIdx + 1].height ?? 0) <= sizeMax) {
      //   var position = totItemHeight;
      //   // if (notifier.pic?[_curIdx + 1].height >= sizeMax) {
      //   //   position += notifier.pic?[_curIdx + 1].height;
      //   // }
      //   if (mounted) {
      //     widget.scrollController?.animateTo(position, duration: Duration(milliseconds: 200), curve: Curves.ease);
      //     itemIndex++;
      //   }
      // } else {}
    } else {
      if (!homeClick) {
        // print("==== _curIdx ${_curIdx}");

        for (var i = 0; i < itemIndex; i++) {
          if (i == itemIndex - 1) {
            totItemHeightParam += (notifier.pic?[i].height ?? 0.0) * 75 / 100;
          } else if (i == itemIndex) {
          } else {
            totItemHeightParam += notifier.pic?[i].height ?? 0.0;
          }
          totItemHeight += notifier.pic?[i].height ?? 0.0;
        }
        if (itemIndex > 0) {
          totItemHeight -= notifier.pic?[itemIndex - 1].height ?? 0.0;
        }
        // print("==== totItemHeight ${totItemHeight}");
        var sizeMax = (SizeConfig.screenHeight ?? 0) + (SizeConfig.screenHeight ?? 0) * 0.633;
        if (offset <= totItemHeightParam && offset > 0) {
          if (itemIndex > 0 && (notifier.pic?[itemIndex - 1].height ?? 0) >= sizeMax) {
            return;
          }
          var position = totItemHeight;
          if (mounted) {
            widget.scrollController?.animateTo(position, duration: Duration(milliseconds: 200), curve: Curves.ease);
            itemIndex--;
          }
        }

        // for (var i = 0; i < _curIdx; i++) {
        //   if (i == _curIdx - 1) {
        //     totItemHeightParam += (notifier.pic?[i].height ?? 0.0) * 75 / 100;
        //   } else if (i == _curIdx) {
        //   } else {
        //     totItemHeightParam += notifier.pic?[i].height ?? 0.0;
        //   }
        //   totItemHeight += notifier.pic?[i].height ?? 0.0;
        // }
        // if (_curIdx > 0) {
        //   totItemHeight -= notifier.pic?[_curIdx - 1].height ?? 0.0;
        // }
        // print("==== totItemHeight ${totItemHeight}");
        // var sizeMax = (SizeConfig.screenHeight ?? 0) + (SizeConfig.screenHeight ?? 0) * 0.633;
        // if (offset <= totItemHeightParam && offset > 0) {
        //   if (_curIdx > 0 && (notifier.pic?[_curIdx - 1].height ?? 0) >= sizeMax) {
        //     return;
        //   }
        //   var position = totItemHeight;
        //   if (mounted) widget.scrollController?.animateTo(position, duration: Duration(milliseconds: 200), curve: Curves.ease);
        // }
      }
    }

    Timer(Duration(milliseconds: 300), () {
      lastOffset = offset;
    });

    Timer(Duration(milliseconds: 300), () {
      if (lastOffset != offset) {
        lastOffset = offset;
      }
    });
  }

  void start(BuildContext context, ContentData data, PreviewPicNotifier notifier) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    print("===-=-=-=-=-start--0-0-0-");
    fAliplayer?.stop();
    dataSelected = data;

    isPlay = false;
    dataSelected?.isDiaryPlay = false;

    // fAliplayer?.setVidAuth(
    //   vid: "c7d74ee240dd4fe288b1a897a7f8b0ab",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNWJGQ2NuR3I3RlkvWVNDTm4vRm8yc3ZRZXBrM291Zm9UejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGFZcHlhV2lqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFTUHlvYjNkZ1lCTUtXZ25DRVVRMXVJY09TSG90ekJHWWVPdUhERGhMYVN2OTBuQmFQNHYzWDIzbFpXNU5rYnlqbFJWQlJCRTVaVVpJbXBLcjNtVzZUdU9TWWY0Y2RKaTR6bHU2NkplWHNJM1AyQTlLWm9VVjhjOHlJV3RrSUYwdjVpaEFRTk53aCtmN2pLZnNSenQ0bkVuOGhqZFNmcTBYM0NmZ3NyQjBqMUdJQUE9IiwiQXV0aEluZm8iOiJ7XCJDSVwiOlwieVBacGpLVERNbVgrMXVhSDUwTGVuclRlZEs4YzBpdDNtZDhjWGdaQWhmUFR2MkxNeGY4NllVRCsyS3lJNkJoclBLVmMvS0N4YnlMMWR1aEF1aXpCQWV4VmU0VS9GNGlHdjByVVJwaU1KMk09XCIsXCJDYWxsZXJcIjpcIlE0cTdKSE5sUlYwRVNKZjdWaHFKVEZNakVRQUdGaG10U1hGR0N3eU9WYkE9XCIsXCJFeHBpcmVUaW1lXCI6XCIyMDI0LTAxLTIzVDA3OjQ3OjQwWlwiLFwiTWVkaWFJZFwiOlwiYzdkNzRlZTI0MGRkNGZlMjg4YjFhODk3YTdmOGIwYWJcIixcIlBsYXlEb21haW5cIjpcInZvZC5oeXBwZS5jbG91ZFwiLFwiU2lnbmF0dXJlXCI6XCJLbTNmbGZMRHZNOGJWWW1DRTJKN3FaTlVvWUk9XCJ9IiwiVmlkZW9NZXRhIjp7IlN0YXR1cyI6Ik5vcm1hbCIsIlZpZGVvSWQiOiJjN2Q3NGVlMjQwZGQ0ZmUyODhiMWE4OTdhN2Y4YjBhYiIsIlRpdGxlIjoiMzU3Njc3YjYtZjRkYi0yM2RkLTBmMWYtNGU0MTJjZDE1OWJjIiwiQ292ZXJVUkwiOiJodHRwczovL3ZvZC5oeXBwZS5jbG91ZC9jN2Q3NGVlMjQwZGQ0ZmUyODhiMWE4OTdhN2Y4YjBhYi9zbmFwc2hvdHMvNTM3YTliNmVmOWFmNDk0NWFiY2IwNDk2ZWY3NDZiMWYtMDAwMDQuanBnIiwiRHVyYXRpb24iOjU4LjMzMzN9LCJBY2Nlc3NLZXlJZCI6IlNUUy5OVXBCc3JCbnlKRmk0WXRHa3pNZUgxTjRDIiwiUGxheURvbWFpbiI6InZvZC5oeXBwZS5jbG91ZCIsIkFjY2Vzc0tleVNlY3JldCI6IjZMZDI5NlN6WVVaWWI5dkhmSG5YSm1GWlhQeUtuY1d0ZXJOTGlHSGVVcExRIiwiUmVnaW9uIjoiYXAtc291dGhlYXN0LTUiLCJDdXN0b21lcklkIjo1NDU0NzUzMjA1MjgwNTQ5fQ==",
    //   definitionList: [DataSourceRelated.definitionList],
    // );

    // _playMode = ModeTypeAliPLayer.auth;
    // await getAuth(data.music?.apsaraMusic ?? '');
    if (data.reportedStatus != 'BLURRED') {
      // _playMode = ModeTypeAliPLayer.auth;
      await getAuth(context, data.music?.apsaraMusic ?? '');
    }

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
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
    // Configure the application.
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
    print("====---- ---==== ali ${fAliplayer?.getPlayerName()}");

    try {
      print("===============init ali player ${fAliplayer?.playerId} ===========");
      fAliplayer?.prepare().then((value) {
        print("===============init ali player 22 ${fAliplayer?.playerId} ===========");
      });
    } catch (e) {
      print(e);
    }

    if (notifier.isMute) {
      fAliplayer?.setMuted(true);
    }
  }

  Future getAuth(BuildContext context, String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final fixContext = Routing.navigatorKey.currentContext;
      final notifier = PostsBloc();
      await notifier.getAuthApsara(fixContext ?? context, apsaraId: apsaraId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: [DataSourceRelated.definitionList],
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
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId);
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

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("---=-=-=-=--===-=-=-=-DiSPOSE--=-=-=-=-=-=-=-=-=-=-=----==-=");
    // fAliplayer?.destroy();

    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate ");
    fAliplayer?.stop();
    System().disposeBlock();
    if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
      // fAliplayer?.destroy();
    }
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop ");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext");
    isInPage = true;
    fAliplayer?.play();
    isActivePage = true;
    // System().disposeBlock();
    super.didPopNext();
  }

  @override
  void didPush() {
    print("========= didPush");
    super.didPush();
  }

  @override
  void didPushNext() {
    print("========= didPushNext");
    fAliplayer?.pause();
    isActivePage = false;
    System().disposeBlock();
    isInPage = false;
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        print("========= inactive");
        break;
      case AppLifecycleState.resumed:
        print("========= resumed");
        if (context.read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds) && isActivePage) {
          fAliplayer?.play();
        }
        break;
      case AppLifecycleState.paused:
        print("========= paused");
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        print("========= detached");
        break;
      default:
        break;
    }
  }

  @override
  void didUpdateWidget(covariant HyppePreviewPic oldWidget) {
    // If you want to react only to changes you could check
    // oldWidget.selectedIndex != widget.selectedIndex
    // if (oldWidget.data != widget.data)ç
    if (!(oldWidget.appbarSeen ?? false)) {
      setState(() {
        scrollPhysic = const ScrollPhysics();
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  List heightItem = [600, 400, 400];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    context.select((ErrorService value) => value.getError(ErrorType.pic));
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return Consumer2<PreviewPicNotifier, HomeNotifier>(
      builder: (_, notifier, home, __) => Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (notifier.pic == null || home.isLoadingPict)
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return CustomShimmer(
                          width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                          height: 168,
                          radius: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                        );
                      },
                      itemCount: 5,
                    )
                  : notifier.itemCount == 0
                      ? const NoResultFound()
                      : NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: NotificationListener<UserScrollNotification>(
                            onNotification: (notification) {
                              final ScrollDirection direction = notification.direction;
                              setState(() {
                                // print("-===========scrollll==========");
                                if (direction == ScrollDirection.reverse) {
                                  //down
                                  setState(() {
                                    scroolUp = false;
                                    homeClick = false;
                                  });
                                  // print("-===========reverse ${homeClick}==========");
                                  // print("-===========reverse==========");
                                } else if (direction == ScrollDirection.forward) {
                                  //up
                                  setState(() {
                                    homeClick = false;
                                    scroolUp = true;
                                  });
                                  // print("-===========forward==========");
                                }
                              });
                              return true;
                            },
                            child: ListView.builder(
                              // scrollDirection: Axis.horizontal,
                              // controller: innerScrollController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: notifier.pic?.length,
                              padding: const EdgeInsets.symmetric(horizontal: 11.5),
                              // child: ScrollSnapList(
                              //   listController: controller,
                              //   listViewPadding: EdgeInsets.zero,
                              //   dynamicItemSize: false,
                              //   itemCount: notifier.pic?.length ?? 0,
                              //   // itemCount: heightItem.length,
                              //   onItemFocus: (p0) {
                              //     print("focuss----- $p0");
                              //     setState(() {
                              //       itemHeight = notifier.picTemp?[p0].height ?? 0;
                              //     });
                              //   },
                              //   // itemSize: itemHeight,
                              //   itemSize: 722,
                              //   scrollDirection: Axis.vertical,
                              //   allowAnotherDirection: false,
                              //   clipBehavior: Clip.antiAlias,
                              //   scrollPhysics: scrollPhysic,
                              //   // scrollPhysics: NeverScrollableScrollPhysics(),
                              //   dispatchScrollNotifications: false,
                              //   endOfListTolerance: SizeConfig.screenHeight,
                              // child: SnappyListView(
                              //   reverse: false,
                              //   // controller: controller,
                              //   itemCount: notifier.picTemp?.length ?? 0,
                              //   itemSnapping: true,
                              //   allowItemSizes: true,
                              //   onPageChange: (index, size) {
                              //     print(index);
                              //     print(size);
                              //   },
                              //   // physics: NeverScrollableScrollPhysics(),
                              //   // physics: const CustomPageViewScrollPhysics(),
                              //   // overscrollPhysics: const PageOverscrollPhysics(velocityPerOverscroll: 100),
                              //   snapAlignment: SnapAlignment.moveAcross(),
                              //   snapOnItemAlignment: SnapAlignment.moveAcross(),
                              //   // visualisation: ListVisualisation.perspective(),
                              //   scrollBehavior: ScrollBehavior(),
                              itemBuilder: (context, index) {
                                if (notifier.pic == null || home.isLoadingPict) {
                                  fAliplayer?.pause();
                                  // _lastCurIndex = -1;
                                  _lastCurPostId = '';
                                  // return Container(
                                  //   alignment: Alignment.center,
                                  //   child: Text('Test'),
                                  // );
                                  return CustomShimmer(
                                    width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                                    height: 168,
                                    radius: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                                  );
                                } else if (index == notifier.pic?.length && notifier.hasNext) {
                                  return UnconstrainedBox(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 80 * SizeConfig.scaleDiagonal,
                                      height: 80 * SizeConfig.scaleDiagonal,
                                      child: const CustomLoading(),
                                    ),
                                  );
                                }

                                // return Container(
                                //   width: SizeConfig.screenWidth,
                                //   height: heightItem[index].toDouble(),
                                //   color: Colors.red,
                                //   margin: EdgeInsets.only(bottom: 20),
                                //   child: Text(index.toString()),
                                // );

                                return Visibility(
                                  // visible: (_curIdx - 1) == index || _curIdx == index || (_curIdx + 1) == index,
                                  visible: true,
                                  child: itemPict(context, notifier, index, home),
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  var initialControllerValue;
  ValueNotifier<int> _networklHasErrorNotifier = ValueNotifier(0);

  final Map cacheDesc = {};
  List tempHeight = [];

  Widget itemPict(BuildContext context, PreviewPicNotifier notifier, int index, HomeNotifier homeNotifier) {
    var picData = notifier.pic?[index];
    final isAds = picData?.inBetweenAds != null && picData?.postID == null;

    return picData?.isContentLoading ?? false
        ? Builder(builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                picData?.isContentLoading = false;
              });
            });
            return Container();
          })
        : WidgetSize(
            onChange: (Size size) {
              picData?.height = size.height;
            },
            child:

                /// ADS IN BETWEEN === Hariyanto Lukman ===
                isAds
                    ? VisibilityDetector(
                        key: Key(index.toString()),
                        onVisibilityChanged: (info) async {
                          if (info.visibleFraction >= 0.8) {
                            _curIdx = index;
                            _curPostId = picData?.inBetweenAds?.adsId ?? index.toString();
                            if (_lastCurIndex > _curIdx) {
                              // fAliplayer?.destroy();
                              // double position = 0.0;
                              // for (var i = 0; i < _curIdx; i++) {
                              //   position += notifier.pic?[i].height ?? 0.0;
                              //   // position = position - (notifier.pic?[_curIdx].height);
                              // }
                              // context.read<MainNotifier>().globalKey.currentState?.innerController.jumpTo(position);
                            }

                            // if (_lastCurIndex != _curIdx) {
                            if (_lastCurPostId != _curPostId) {
                              if (mounted) {
                                setState(() {
                                  isShowShowcase = false;
                                });
                              }
                              final indexList = notifier.pic?.indexWhere((element) => element.inBetweenAds?.adsId == _curPostId);

                              if (indexList == (notifier.pic?.length ?? 0) - 1) {
                                context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {});
                              }
                              fAliplayer?.stop();

                              Future.delayed(const Duration(milliseconds: 500), () {
                                System().increaseViewCount2(context, picData ?? ContentData(), check: false);
                                if ((picData?.saleAmount ?? 0) > 0 || ((picData?.certified ?? false) && (picData?.saleAmount ?? 0) == 0)) {
                                  if (mounted) {
                                    setState(() {
                                      isShowShowcase = true;
                                      // keyOwnership = picData?.keyGlobal;
                                    });
                                  }
                                  // ShowCaseWidget.of(context).startShowCase([picData?.keyGlobal ?? GlobalKey()]);
                                }
                              });
                              setState(() {
                                Future.delayed(const Duration(milliseconds: 400), () {
                                  itemHeight = notifier.pic?[indexList ?? 0].height ?? 0;
                                });
                              });
                            }
                            _lastCurIndex = _curIdx;
                            _lastCurPostId = _curPostId;
                          }
                        },
                        child: context.getAdsInBetween(notifier.pic?[index].inBetweenAds, (info) {}, () {
                          notifier.setAdsData(index, null);
                        }, (player, id) {}),
                      )
                    : Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SelectableText(((picData?.isApsara ?? false) ? (picData?.mediaThumbEndPoint ?? "") : "${picData?.fullThumbPath}") + "&key=${cacheDesc[index]}"),

                                // Text("mn?.status own ${mn?.tutorialData[indexKeyProtection].status}"),
                                // Text("mn?.status sell ${mn?.tutorialData[indexKeySell].status}"),
                                // Text("global ${picData?.keyGlobalOwn}"),
                                // Text("global ${picData?.keyGlobalSell}"),
                                // Text("itemHeight $itemHeight"),
                                // Text("height ${picData?.imageHeightTemp}"),
                                // Text("$_lastCurIndex"),
                                // Text("$index"),
                                // Text("${picData?.height}"),
                                // GestureDetector(
                                //   onScaleStart: (details) {
                                //     widget.functionZoomTriger();
                                //     print("***************** dua jari ***************");
                                //     print(details.pointerCount);
                                //   },
                                //   onScaleEnd: (details) {
                                //     print("***************** satu jari ***************");
                                //   },

                                //   child: Container(
                                //     width: 500,
                                //     height: 200,
                                //     color: Colors.red,
                                //   ),
                                // ),
                                // GestureDetector(
                                //   onTap: () {
                                //     Routing().move(Routes.testImage);
                                //   },
                                //   child: Text('hahahah'),
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ProfileLandingPage(
                                        show: true,
                                        // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
                                        onFollow: () {},
                                        following: true,
                                        haveStory: false,
                                        textColor: kHyppeTextLightPrimary,
                                        username: picData?.username,
                                        featureType: FeatureType.other,
                                        // isCelebrity: vidpicData?.privacy?.isCelebrity,
                                        isCelebrity: false,
                                        imageUrl: picData?.avatar == null ? '' : '${System().showUserPicture(picData?.avatar?.mediaEndpoint)}',
                                        onTapOnProfileImage: () => System().navigateToProfile(context, picData?.email ?? ''),
                                        createdAt: '2022-02-02',
                                        musicName: picData?.music?.musicTitle ?? '',
                                        location: picData?.location ?? '',
                                        isIdVerified: picData?.privacy?.isIdVerified,
                                        badge: picData?.urluserBadge,
                                      ),
                                    ),
                                    if (picData?.email != email && (picData?.isNewFollowing ?? false))
                                      Consumer<PreviewPicNotifier>(
                                        builder: (context, picNot, child) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              context.handleActionIsGuest(() {
                                                if (picData?.insight?.isloadingFollow != true) {
                                                  picNot.followUser(context, picData ?? ContentData(), isUnFollow: picData?.following, isloading: picData?.insight!.isloadingFollow ?? false);
                                                }
                                              });
                                            },
                                            child: picData?.insight?.isloadingFollow ?? false
                                                ? Container(
                                                    height: 40,
                                                    width: 30,
                                                    child: const Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: CustomLoading(),
                                                    ),
                                                  )
                                                : Text(
                                                    (picData?.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                                    style: const TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () {
                                        // fAliplayer?.pause();
                                        context.handleActionIsGuest(() {
                                          if (picData?.email != email) {
                                            context.read<PreviewPicNotifier>().reportContent(context, picData ?? ContentData(), fAliplayer: fAliplayer, onCompleted: () async {
                                              imageCache.clear();
                                              imageCache.clearLiveImages();
                                              await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 0);
                                            });
                                          } else {
                                            fAliplayer?.setMuted(true);
                                            fAliplayer?.pause();
                                            ShowBottomSheet().onShowOptionContent(
                                              context,
                                              contentData: picData ?? ContentData(),
                                              captionTitle: hyppePic,
                                              onDetail: false,
                                              isShare: picData?.isShared,
                                              onUpdate: () {
                                                (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 0);
                                              },
                                              fAliplayer: fAliplayer,
                                            );
                                          }
                                        });
                                      },
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: kHyppeTextLightPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                tenPx,

                                VisibilityDetector(
                                  key: Key(index.toString()),
                                  // key: Key(picData?.postID ?? index.toString()),
                                  onVisibilityChanged: (info) {
                                    if (info.visibleFraction == 1) {
                                      if (!isShowingDialog) {
                                        globalAdsPopUp?.pause();
                                      }
                                    }
                                    if (info.visibleFraction == 1 || info.visibleFraction >= 0.6) {
                                      _curIdx = index;
                                      _curPostId = picData?.postID ?? index.toString();
                                      if (_lastCurIndex > _curIdx) {
                                        // fAliplayer?.destroy();
                                        // double position = 0.0;
                                        // for (var i = 0; i < _curIdx; i++) {
                                        //   position += notifier.pic?[i].height ?? 0.0;
                                        //   // position = position - (notifier.pic?[_curIdx].height);
                                        // }
                                        // context.read<MainNotifier>().globalKey.currentState?.innerController.jumpTo(position);
                                      }

                                      // if (_lastCurIndex != _curIdx) {
                                      if (_lastCurPostId != _curPostId) {
                                        if (mounted) {
                                          setState(() {
                                            isShowShowcase = false;
                                          });
                                        }
                                        final indexList = notifier.pic?.indexWhere((element) => element.postID == _curPostId);
                                        // final latIndexList = notifier.pic?.indexWhere((element) => element.postID == _lastCurPostId);

                                        if (indexList == (notifier.pic?.length ?? 0) - 1) {
                                          context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {});
                                        }

                                        if (picData?.music != null) {
                                          print("ada musiknya ${picData?.music}");
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            start(context, picData ?? ContentData(), notifier);
                                          });
                                        } else {
                                          fAliplayer?.stop();
                                        }

                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          if (mn?.tutorialData.isNotEmpty ?? [].isEmpty) {
                                            indexKeySell = mn?.tutorialData.indexWhere((element) => element.key == 'sell') ?? 0;
                                            indexKeyProtection = mn?.tutorialData.indexWhere((element) => element.key == 'protection') ?? 0;
                                            // print("==============global challehg $globalChallengePopUp");
                                            // print("==============global challehg ${mn?.tutorialData[indexKeySell].status == false && !globalChallengePopUp}");
                                            if ((picData?.saleAmount ?? 0) > 0) {
                                              if (mn?.tutorialData[indexKeySell].status == false && !globalChallengePopUp) {
                                                ShowCaseWidget.of(context).startShowCase([picData?.keyGlobalSell ?? GlobalKey()]);
                                              }
                                            }
                                            if (((picData?.certified ?? false) && (picData?.saleAmount ?? 0) == 0)) {
                                              if (mn?.tutorialData[indexKeyProtection].status == false && !globalChallengePopUp) {
                                                ShowCaseWidget.of(context).startShowCase([picData?.keyGlobalOwn ?? GlobalKey()]);
                                              }
                                            }
                                          }
                                        });

                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          System().increaseViewCount2(context, picData ?? ContentData(), check: false);
                                        });

                                        if (picData?.certified ?? false) {
                                          System().block(context);
                                        } else {
                                          System().disposeBlock();
                                        }
                                        setState(() {
                                          Future.delayed(Duration(milliseconds: 400), () {
                                            itemHeight = notifier.pic?[indexList ?? 0].height ?? 0;
                                          });
                                        });
                                        // Future.delayed(const Duration(milliseconds: 500), () async {
                                        //   if (indexList == (notifier.pic?.length ?? 0) - 1) {
                                        //     await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                                        //       notifier.getTemp(indexList, latIndexList, indexList);
                                        //     });
                                        //   } else {
                                        //     notifier.getTemp(indexList, latIndexList, indexList);
                                        //   }
                                        // });

                                        ///ADS IN BETWEEN === Hariyanto Lukman ===
                                        if (!notifier.loadAds) {
                                          if ((notifier.pic?.length ?? 0) > notifier.nextAdsShowed) {
                                            notifier.loadAds = true;
                                            context.getInBetweenAds().then((value) {
                                              if (value != null) {
                                                notifier.setAdsData(index, value);
                                              } else {
                                                notifier.loadAds = false;
                                              }
                                            });
                                          }
                                        }
                                      }

                                      _lastCurIndex = _curIdx;
                                      _lastCurPostId = _curPostId;
                                    }
                                  },
                                  child: Container(
                                    // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    width: SizeConfig.screenWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.white,
                                      ),
                                      child: Stack(
                                        children: [
                                          // Center(
                                          //   child: CustomBaseCacheImage(
                                          //     memCacheWidth: 100,
                                          //     memCacheHeight: 100,
                                          //     widthPlaceHolder: 80,
                                          //     heightPlaceHolder: 80,
                                          //     imageUrl: (picData?.isApsara ?? false) ? (picData?.mediaThumbEndPoint ?? "") : "${picData?.fullThumbPath}",
                                          //     imageBuilder: (context, imageProvider) => ClipRRect(
                                          //       borderRadius: BorderRadius.circular(20), // Image border
                                          //       child: picData?.reportedStatus == 'BLURRED'
                                          //           ? ImageFiltered(
                                          //               imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                          //               child: Image(
                                          //                 image: imageProvider,
                                          //                 fit: BoxFit.fitHeight,
                                          //                 width: SizeConfig.screenWidth,
                                          //               ),
                                          //             )
                                          //           : Image(
                                          //               image: imageProvider,
                                          //               fit: BoxFit.fitHeight,
                                          //               width: SizeConfig.screenWidth,
                                          //             ),
                                          //     ),
                                          //     errorWidget: (context, url, error) {
                                          //       return Container(
                                          //         // const EdgeInsets.symmetric(horizontal: 4.5),
                                          //         // height: 500,
                                          //         decoration: BoxDecoration(
                                          //           image: const DecorationImage(
                                          //             image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                          //             fit: BoxFit.cover,
                                          //           ),
                                          //           borderRadius: BorderRadius.circular(8.0),
                                          //         ),
                                          //       );
                                          //     },
                                          //     emptyWidget: Container(
                                          //       // const EdgeInsets.symmetric(horizontal: 4.5),

                                          //       // height: 500,
                                          //       decoration: BoxDecoration(
                                          //         image: const DecorationImage(
                                          //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                          //           fit: BoxFit.cover,
                                          //         ),
                                          //         borderRadius: BorderRadius.circular(8.0),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),

                                          GestureDetector(
                                            onTap: () async {
                                              // if (picData?.reportedStatus != 'BLURRED') {
                                              //   // fAliplayer?.play();
                                              //   setState(() {
                                              //     notifier.isMute = true;
                                              //   });
                                              //   fAliplayer?.setMuted(notifier.isMute);
                                              // }

                                              // fAliplayer?.pause();
                                              var res = await Routing().move(Routes.picFullScreenDetail, argument: PicFullscreenArgument(picData: notifier.pic!, index: index, scrollPic: false));
                                              if (res != null || res == null) {
                                                fAliplayer?.play();
                                                fAliplayer?.setMuted(notifier.isMute);
                                                var temp1 = notifier.pic![_curIdx];
                                                var temp2 = notifier.pic![notifier.currentIndex];
                                                if (index < notifier.currentIndex) {
                                                  setState(() {
                                                    index = notifier.currentIndex;
                                                    notifier.pic!.removeRange(_curIdx, notifier.currentIndex);
                                                  });
                                                } else if (index > notifier.currentIndex) {
                                                  setState(() {
                                                    notifier.pic![_curIdx] = temp2;
                                                    notifier.pic![notifier.currentIndex] = temp1;
                                                  });
                                                }
                                              }
                                            },
                                            onDoubleTap: () {
                                              final _likeNotifier = context.read<LikeNotifier>();
                                              if (picData != null) {
                                                _likeNotifier.likePost(context, notifier.pic![index]);
                                              }
                                            },
                                            child: Center(
                                              child: Container(
                                                color: Colors.transparent,
                                                // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,

                                                // width: SizeConfig.screenWidth,
                                                // height: picData?.imageHeightTemp,
                                                child: ZoomableImage(
                                                  enable: homeNotifier.connectionError ? false : true,
                                                  onScaleStart: () {
                                                    print("================masuk zoom============");
                                                    widget.onScaleStart?.call();
                                                  }, // optional
                                                  onScaleStop: () {
                                                    widget.onScaleStop?.call();
                                                  }, // opt
                                                  child: ValueListenableBuilder(
                                                      valueListenable: _networklHasErrorNotifier,
                                                      builder: (BuildContext context, int count, _) {
                                                        return CustomBaseCacheImage(
                                                          // cacheKey: "${picData?.postID}-${cacheDesc[index]}",
                                                          memCacheWidth: 100,
                                                          memCacheHeight: 100,
                                                          widthPlaceHolder: 80,
                                                          heightPlaceHolder: 80,
                                                          imageUrl: (picData?.isApsara ?? false)
                                                              ? ("${picData?.mediaEndpoint}?key=${picData?.valueCache}")
                                                              : ("${picData?.fullThumbPath}&key=${picData?.valueCache}"),
                                                          imageBuilder: (context, imageProvider) {
                                                            return ClipRRect(
                                                              borderRadius: BorderRadius.circular(20), // Image border
                                                              child: ImageSize(
                                                                onChange: (Size size) {
                                                                  if ((picData?.imageHeightTemp ?? 0) == 0) {
                                                                    setState(() {
                                                                      picData?.imageHeightTemp = size.height;
                                                                    });
                                                                  }
                                                                },
                                                                child: picData?.reportedStatus == 'BLURRED'
                                                                    ? ImageFiltered(
                                                                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                                        child: Image(
                                                                          image: imageProvider,
                                                                          fit: BoxFit.fitHeight,
                                                                          width: SizeConfig.screenWidth,
                                                                          // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,
                                                                        ),
                                                                      )
                                                                    : Image(
                                                                        image: imageProvider,
                                                                        fit: BoxFit.fitHeight,
                                                                        width: SizeConfig.screenWidth,
                                                                        // height: picData?.imageHeightTemp == 0 || (picData?.imageHeightTemp ?? 0) <= 100 ? null : picData?.imageHeightTemp,
                                                                      ),
                                                              ),
                                                            );
                                                          },
                                                          emptyWidget: GestureDetector(
                                                            onTap: () {
                                                              _networklHasErrorNotifier.value++;
                                                              Random random = new Random();
                                                              int randomNumber = random.nextInt(100); // from 0 upto 99 included

                                                              picData?.valueCache = randomNumber.toString();
                                                              setState(() {});
                                                              // reloadImage(index);
                                                            },
                                                            child: Container(
                                                                decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                                                width: SizeConfig.screenWidth,
                                                                height: 250,
                                                                padding: EdgeInsets.all(20),
                                                                alignment: Alignment.center,
                                                                child: CustomTextWidget(
                                                                  textToDisplay: lang?.couldntLoadImage ?? 'Error',
                                                                  maxLines: 3,
                                                                )),
                                                          ),
                                                          errorWidget: (context, url, error) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                Random random = new Random();
                                                                int randomNumber = random.nextInt(100); // from 0 upto 99 included
                                                                _networklHasErrorNotifier.value++;
                                                                picData?.valueCache = randomNumber.toString();
                                                                setState(() {});
                                                                // reloadImage(index);
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                                                  width: SizeConfig.screenWidth,
                                                                  height: 250,
                                                                  padding: const EdgeInsets.all(20),
                                                                  alignment: Alignment.center,
                                                                  child: CustomTextWidget(
                                                                    textToDisplay: lang?.couldntLoadImage ?? 'Error',
                                                                    maxLines: 3,
                                                                  )),
                                                            );
                                                          },
                                                        );
                                                      }),
                                                ),
                                              ),
                                            ),
                                          ),
                                          _buildBody(context, SizeConfig.screenWidth, picData ?? ContentData(), notifier),
                                          blurContentWidget(context, picData ?? ContentData()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                                        (picData?.boosted.isEmpty ?? [].isEmpty) &&
                                        (picData?.reportedStatus != 'OWNED' && picData?.reportedStatus != 'BLURRED' && picData?.reportedStatus2 != 'BLURRED') &&
                                        picData?.email == email
                                    ? Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: ButtonBoost(
                                          onDetail: false,
                                          marginBool: true,
                                          contentData: picData,
                                          startState: () {
                                            SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                          },
                                          afterState: () {
                                            SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                          },
                                        ),
                                      )
                                    : Container(),
                                if (picData?.email == email && (picData?.boostCount ?? 0) >= 0 && (picData?.boosted.isNotEmpty ?? [].isEmpty))
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: kHyppeGreyLight,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const CustomIconWidget(
                                          iconData: "${AssetPath.vectorPath}reach.svg",
                                          defaultColor: false,
                                          height: 24,
                                          color: kHyppeTextLightPrimary,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 13),
                                          child: CustomTextWidget(
                                            textToDisplay: "${picData?.boostJangkauan ?? '0'} ${lang?.reach}",
                                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                Consumer<LikeNotifier>(
                                  builder: (context, likeNotifier, child) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: picData?.insight?.isloading ?? false
                                                  ? const SizedBox(
                                                      height: 28,
                                                      width: 28,
                                                      child: CircularProgressIndicator(
                                                        color: kHyppePrimary,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : InkWell(
                                                      child: CustomIconWidget(
                                                        defaultColor: false,
                                                        color: (picData?.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                                        iconData: '${AssetPath.vectorPath}${(picData?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                        height: 28,
                                                      ),
                                                      onTap: () {
                                                        if (picData != null) {
                                                          likeNotifier.likePost(context, notifier.pic![index]);
                                                        }
                                                      },
                                                    ),
                                            ),
                                          ),
                                          if (picData?.allowComments ?? true)
                                            Padding(
                                              padding: EdgeInsets.only(left: 21.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: picData?.postID ?? '', fromFront: true, data: picData ?? ContentData()));
                                                  // ShowBottomSheet.onShowCommentV2(context, postID: picData?.postID);
                                                },
                                                child: const CustomIconWidget(
                                                  defaultColor: false,
                                                  color: kHyppeTextLightPrimary,
                                                  iconData: '${AssetPath.vectorPath}comment2.svg',
                                                  height: 24,
                                                ),
                                              ),
                                            ),
                                          if ((picData?.isShared ?? false))
                                            GestureDetector(
                                              onTap: () {
                                                context.read<PicDetailNotifier>().createdDynamicLink(context, data: picData);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 21.0),
                                                child: CustomIconWidget(
                                                  defaultColor: false,
                                                  color: kHyppeTextLightPrimary,
                                                  iconData: '${AssetPath.vectorPath}share2.svg',
                                                  height: 24,
                                                ),
                                              ),
                                            ),
                                          if ((picData?.saleAmount ?? 0) > 0 && email != picData?.email)
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  context.handleActionIsGuest(() async {
                                                    fAliplayer?.pause();
                                                    await ShowBottomSheet.onBuyContent(context, data: picData, fAliplayer: fAliplayer);
                                                  });
                                                },
                                                child: const Align(
                                                  alignment: Alignment.centerRight,
                                                  child: CustomIconWidget(
                                                    defaultColor: false,
                                                    color: kHyppeTextLightPrimary,
                                                    iconData: '${AssetPath.vectorPath}cart.svg',
                                                    height: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      twelvePx,
                                      RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: "${picData?.insight?.likes} ${notifier.language.like}",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      builder: (context) => ViewLiked(
                                                            postId: picData?.postID ?? '',
                                                            eventType: 'LIKE',
                                                          ))),
                                            style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                          const TextSpan(
                                            text: " . ",
                                            style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 22),
                                          ),
                                          TextSpan(
                                            text: "${picData?.insight!.views?.getCountShort()} ${notifier.language.views}",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      builder: (context) => ViewLiked(
                                                            postId: picData?.postID ?? '',
                                                            eventType: 'VIEW',
                                                          ))),
                                            style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                        ]),
                                      ),
                                      // Text(
                                      //   "${picData?.insight?.likes}  ${notifier.language.like}",
                                      //   style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                      // ),
                                    ],
                                  ),
                                ),
                                fourPx,
                                CustomNewDescContent(
                                  // desc: "${data?.description}",
                                  username: picData?.username ?? '',
                                  desc: "${picData?.description}",
                                  trimLines: 3,
                                  textAlign: TextAlign.start,
                                  seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                                  seeMore: '  ${lang?.more}', //${notifier2.translate.seeMoreContent}',
                                  normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                  hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary, fontSize: 12),
                                  expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                if (picData?.allowComments ?? false)
                                  GestureDetector(
                                    onTap: () {
                                      Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: picData?.postID ?? '', fromFront: true, data: picData ?? ContentData()));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        "${lang?.seeAll} ${picData?.comments} ${lang?.comment}",
                                        style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                                      ),
                                    ),
                                  ),
                                (picData?.comment?.length ?? 0) > 0
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: (picData?.comment?.length ?? 0) >= 2 ? 2 : 1,
                                          itemBuilder: (context, indexComment) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 6.0),
                                              child: CustomNewDescContent(
                                                // desc: "${picData??.description}",
                                                username: picData?.comment?[indexComment].userComment?.username ?? '',
                                                desc: picData?.comment?[indexComment].txtMessages ?? '',
                                                trimLines: 2,
                                                textAlign: TextAlign.start,
                                                seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
                                                seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
                                                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                                expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    "${System().readTimestamp(
                                      DateTime.parse(System().dateTimeRemoveT(picData?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                                      context,
                                      fullCaption: true,
                                    )}",
                                    style: TextStyle(fontSize: 12, color: kHyppeBurem),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          homeNotifier.isLoadingLoadmore && picData == notifier.pic?.last
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 32),
                                  child: Center(child: CustomLoading()),
                                )
                              : Container(),
                        ],
                      ),
          );
  }

  Widget _buildBody(BuildContext context, width, ContentData data, PreviewPicNotifier notifier) {
    // final indexKeySell = mn?.tutorialData.indexWhere((element) => element.key == 'sell') ?? 0;
    // final indexKey = mn?.tutorialData.indexWhere((element) => element.key == 'protection') ?? 0;

    // String descCase = "";
    // if ((data.saleAmount ?? 0) > 0) {
    //   descCase = lang?.localeDatetime == 'id' ? mn?.tutorialData[indexKeySell].textID ?? '' : mn?.tutorialData[indexKeySell].textEn ?? '';
    // }
    // if ((data.certified ?? false) && (data.saleAmount ?? 0) == 0) {
    //   descCase = lang?.localeDatetime == 'id' ? mn?.tutorialData[indexKey].textID ?? '' : mn?.tutorialData[indexKey].textEn ?? '';
    // }

    return Positioned.fill(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PicTopItem(
              data: data,
              isShow: isShowShowcase,
              globalKey: (data.saleAmount ?? 0) > 0
                  ? data.keyGlobalSell
                  : ((data.certified ?? false) && (data.saleAmount ?? 0) == 0)
                      ? data.keyGlobalOwn
                      : GlobalKey(),
              postId: _curPostId,
            ),
          ),
          if (data.tagPeople?.isNotEmpty ?? false)
            Positioned(
              bottom: 18,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  fAliplayer?.pause();
                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, fAliplayer: fAliplayer, title: lang!.inthisphoto);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          if (data.music != null)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    notifier.isMute = !notifier.isMute;
                  });
                  print("muteeee----------------- ${notifier.isMute}");
                  fAliplayer?.setMuted(notifier.isMute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomIconWidget(
                    iconData: notifier.isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                    defaultColor: false,
                    height: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return data.reportedStatus == 'BLURRED'
        ? Positioned.fill(
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppePic ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      // data.email == SharedPreference().readStorage(SpKeys.email)
                      //     ? GestureDetector(
                      //         onTap: () => Routing().move(Routes.appeal, argument: data),
                      //         child: Container(
                      //             padding: const EdgeInsets.all(8),
                      //             margin: const EdgeInsets.all(18),
                      //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                      //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      //       )
                      //     : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          System().increaseViewCount2(context, data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppePic);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
                          margin: const EdgeInsets.only(bottom: 20, right: 8, left: 8),
                          width: SizeConfig.screenWidth,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            "${transnot.translate.see} HyppePic",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }
}

class ImageSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const ImageSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  State<ImageSize> createState() => _ImageSizeState();
}

class _ImageSizeState extends State<ImageSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);

    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
