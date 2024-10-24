import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LandingDiaryPageTest extends StatefulWidget {
  final ScrollController? scrollController;
  const LandingDiaryPageTest({Key? key, this.scrollController}) : super(key: key);

  @override
  _LandingDiaryPageTestState createState() => _LandingDiaryPageTestState();
}

class _LandingDiaryPageTestState extends State<LandingDiaryPageTest> with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  // FlutterAliplayer? fAliplayer;
  FlutterAliListPlayer? fAliListPlayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;

  int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  // int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  // int _lastCurIndex = -1;
  String _curPostId = '';
  String _lastCurPostId = '';

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  String email = '';
  String statusKyc = '';
  double itemHeight = 0;
  double lastOffset = -10;
  bool isEmptyData = true;

  List videos = [
    {
      "id": '1111',
      "description":
          "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
      "subtitle": "By Blender Foundation",
      "thumb": "images/BigBuckBunny.jpg",
      "title": "Big Buck Bunny"
    },
    {
      "id": '2222',
      "description": "The first Blender Open Movie from 2006",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"],
      "subtitle": "By Blender Foundation",
      "thumb": "images/ElephantsDream.jpg",
      "title": "Elephant Dream"
    },
    {
      "id": '3333',
      "description":
          "HBO GO now works with Chromecast -- the easiest way to enjoy online video on your TV. For when you want to settle into your Iron Throne to watch the latest episodes. For 35.\nLearn how to use Chromecast with HBO GO and more at google.com/chromecast.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
      "subtitle": "By Google",
      "thumb": "images/ForBiggerBlazes.jpg",
      "title": "For Bigger Blazes"
    },
    {
      "id": '44444',
      "description":
          "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when Batman's escapes aren't quite big enough. For 35. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"],
      "subtitle": "By Google",
      "thumb": "images/ForBiggerEscapes.jpg",
      "title": "For Bigger Escape"
    },
    {
      "id": '55555',
      "description": "Introducing Chromecast. The easiest way to enjoy online video and music on your TV. For 35.  Find out more at google.com/chromecast.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"],
      "subtitle": "By Google",
      "thumb": "images/ForBiggerFun.jpg",
      "title": "For Bigger Fun"
    },
    {
      "description":
          "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for the times that call for bigger joyrides. For 35. Learn how to use Chromecast with YouTube and more at google.com/chromecast.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"],
      "subtitle": "By Google",
      "thumb": "images/ForBiggerJoyrides.jpg",
      "title": "For Bigger Joyrides"
    },
    {
      "id": '66666',
      "description":
          "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when you want to make Buster's big meltdowns even bigger. For 35. Learn how to use Chromecast with Netflix and more at google.com/chromecast.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"],
      "subtitle": "By Google",
      "thumb": "images/ForBiggerMeltdowns.jpg",
      "title": "For Bigger Meltdowns"
    },
    {
      "id": '777777',
      "description":
          "Sintel is an independently produced short film, initiated by the Blender Foundation as a means to further improve and validate the free/open source 3D creation suite Blender. With initial funding provided by 1000s of donations via the internet community, it has again proven to be a viable development model for both open 3D technology as for independent animation film.\nThis 15 minute film has been realized in the studio of the Amsterdam Blender Institute, by an international team of artists and developers. In addition to that, several crucial technical and creative targets have been realized online, by developers and artists and teams all over the world.\nwww.sintel.org",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"],
      "subtitle": "By Blender Foundation",
      "thumb": "images/Sintel.jpg",
      "title": "Sintel"
    },
    {
      "id": '888888',
      "description":
          "Smoking Tire takes the all-new Subaru Outback to the highest point we can find in hopes our customer-appreciation Balloon Launch will get some free T-shirts into the hands of our viewers.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4"],
      "subtitle": "By Garage419",
      "thumb": "images/SubaruOutbackOnStreetAndDirt.jpg",
      "title": "Subaru Outback On Street And Dirt"
    },
    {
      "id": '999999',
      "description":
          "Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender. Target was to improve and test a complete open and free pipeline for visual effects in film - and to make a compelling sci-fi film in Amsterdam, the Netherlands.  The film itself, and all raw material used for making it, have been released under the Creatieve Commons 3.0 Attribution license. Visit the tearsofsteel.org website to find out more about this, or to purchase the 4-DVD box with a lot of extras.  (CC) Blender Foundation - http://www.tearsofsteel.org",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"],
      "subtitle": "By Blender Foundation",
      "thumb": "images/TearsOfSteel.jpg",
      "title": "Tears of Steel"
    },
    {
      "id": '1212121',
      "description":
          "The Smoking Tire heads out to Adams Motorsports Park in Riverside, CA to test the most requested car of 2010, the Volkswagen GTI. Will it beat the Mazdaspeed3's standard-setting lap time? Watch and see...",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4"],
      "subtitle": "By Garage419",
      "thumb": "images/VolkswagenGTIReview.jpg",
      "title": "Volkswagen GTI Review"
    },
    {
      "id": '1313131',
      "description":
          "The Smoking Tire is going on the 2010 Bullrun Live Rally in a 2011 Shelby GT500, and posting a video from the road every single day! The only place to watch them is by subscribing to The Smoking Tire or watching at BlackMagicShine.com",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"],
      "subtitle": "By Garage419",
      "thumb": "images/WeAreGoingOnBullrun.jpg",
      "title": "We Are Going On Bullrun"
    },
    {
      "id": '14141414',
      "description":
          "The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far 1,000 can go when looking for a car.The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far 1,000 can go when looking for a car.",
      "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"],
      "subtitle": "By Garage419",
      "thumb": "images/WhatCarCanYouGetForAGrand.jpg",
      "title": "What care can you get for a grand?"
    }
  ];

  @override
  void initState() {
    super.initState();
    "++++++++++++++ initState".logger();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LandingDiaryPage2');
    // final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    // notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    lastOffset = -10;

    // stopwatch = new Stopwatch()..start();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    WidgetsBinding.instance.addObserver(this);
    initAliplayerList();
    // initAlipayer();

    //scroll
    if (mounted) {
      var notifierMain = Routing.navigatorKey.currentState?.overlay?.context.read<MainNotifier>();
      notifierMain?.globalKey?.currentState?.innerController.addListener(() {
        var offset = notifierMain.globalKey?.currentState?.innerController.position.pixels ?? 0;
        if (mounted) {
          toPosition(offset);
        }
      });
    }
    // });

    _initializeTimer();
  }

  initAliplayerList() {
    fAliListPlayer = FlutterAliPlayerFactory.createAliListPlayer(playerId: 'aliListPlayer');
    fAliListPlayer?.setAutoPlay(true);
    // fAliListPlayer?.pause();
    fAliListPlayer?.setLoop(true);
    var configMap = {
      'mClearFrameWhenStop': true,
    };
    fAliListPlayer?.setConfig(configMap);
    fAliListPlayer?.setOnRenderingStart((playerId) {
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
      // _isFirstRenderShow = true;
    });

    fAliListPlayer?.setOnStateChanged((newState, playerId) {
      // _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          try {
            _showLoading = false;
            isPause = false;
            if (mounted) {
              setState(() {});
            }
          } catch (e) {
            e.logger();
          }
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          if (mounted) setState(() {});
          break;
        default:
      }
    });
    fAliListPlayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      try {
        _showLoading = false;
        setState(() {});
      } catch (e) {
        print("eroor aplikasi aplikasi");
        e.logger();
      }
    });
    _getData();
  }

  _getData() async {
    final notifier = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    print("ininttt intintintitnt");
    // if (notifier.diaryData != null && (notifier.diaryData?.isNotEmpty ?? [].isEmpty)) {
    print("ininttt 23123123123123123");
    print(notifier.diaryData?.length);
    try {
      for (var element in videos) {
        fAliListPlayer?.addUrlSource(url: element['sources'][0], uid: element['id']);
      }
      // notifier.diaryData?.forEach((element) {
      //   if (element.isApsara ?? false) {
      //     fAliListPlayer?.addVidSource(vid: element.apsaraId, uid: element.apsaraId);
      //   } else {
      //     fAliListPlayer?.addVidSource(vid: element.postID, uid: element.postID);
      //   }
      // });
    } catch (e) {
      print(e);
    }

    isEmptyData = false;
    // }
    setState(() {});
  }

  initAlipayer() {
    // fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'DiaryLandingpage');
    // fAliplayer?.pause();
    // fAliplayer?.setAutoPlay(true);
    vidConfig();
    // fAliplayer?.setLoop(true);

    //Turn on mix mode
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(true);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
    }

    //set player
    // fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
    // fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    // _initListener();
  }

  // _initListener() {
  //   fAliplayer?.setOnEventReportParams((params, playerId) {
  //     print("EventReportParams=${params}");
  //   });
  //   fAliplayer?.setOnPrepared((playerId) {
  //     // Fluttertoast.showToast(msg: "OnPrepared ");
  //     fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
  //     fAliplayer?.getMediaInfo().then((value) {
  //       try {
  //         isPrepare = true;
  //         _showLoading = false;
  //         if (mounted) {}
  //       } catch (e) {
  //         e.logger();
  //       }
  //     });
  //     isPlay = true;
  //     dataSelected?.isDiaryPlay = true;
  //     // _initAds(context);
  //   });
  //   fAliplayer?.setOnRenderingStart((playerId) {
  //     // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
  //   });
  //   fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
  //   fAliplayer?.setOnStateChanged((newState, playerId) {
  //     _currentPlayerState = newState;
  //     print("aliyun : onStateChanged $newState");
  //     switch (newState) {
  //       case FlutterAvpdef.AVPStatus_AVPStatusStarted:
  //         try {
  //           _showLoading = false;
  //           isPause = false;
  //           if (mounted) {
  //             setState(() {});
  //           }
  //         } catch (e) {
  //           e.logger();
  //         }

  //         break;
  //       case FlutterAvpdef.AVPStatus_AVPStatusPaused:
  //         isPause = true;
  //         if (mounted) setState(() {});
  //         break;
  //       default:
  //     }
  //   });
  //   fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
  //     try {
  //       _loadingPercent = 0;
  //       _showLoading = true;
  //       if (mounted) {
  //         setState(() {});
  //       }
  //     } catch (e) {
  //       e.logger();
  //     }
  //   }, loadingProgress: (percent, netSpeed, playerId) {
  //     try {
  //       _loadingPercent = percent;
  //       if (percent == 100) {
  //         _showLoading = false;
  //       }
  //       if (mounted) {
  //         setState(() {});
  //       }
  //     } catch (e) {
  //       e.logger();
  //     }
  //   }, loadingEnd: (playerId) {
  //     try {
  //       _showLoading = false;
  //       if (mounted) {
  //         setState(() {});
  //       }
  //     } catch (e) {
  //       e.logger();
  //     }
  //   });
  //   fAliplayer?.setOnSeekComplete((playerId) {
  //     _inSeek = false;
  //   });
  //   fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
  //     if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
  //       if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
  //         _currentPosition = extraValue ?? 0;
  //       }
  //       // if (!_inSeek) {
  //       //   setState(() {
  //       //     _currentPositionText = extraValue ?? 0;
  //       //   });
  //       // }
  //     } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
  //       _bufferPosition = extraValue ?? 0;
  //       // if (mounted) {
  //       //   setState(() {});
  //       // }
  //     } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
  //       // Fluttertoast.showToast(msg: "AutoPlay");
  //     } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
  //     } else if (infoCode == FlutterAvpdef.CACHEERROR) {
  //     } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
  //       // Fluttertoast.showToast(msg: "Looping Start");
  //     } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
  //       // Fluttertoast.showToast(msg: "change to soft ware decoder");
  //       // mOptionsFragment.switchHardwareDecoder();
  //     }
  //   });
  //   fAliplayer?.setOnCompletion((playerId) {
  //     final notifier = context.read<PreviewDiaryNotifier>();
  //     try {
  //       _showLoading = false;

  //       isPause = true;

  //       _currentPosition = _videoDuration;
  //       double position = 0.0;
  //       for (var i = 0; i <= _curIdx; i++) {
  //         position += notifier.diaryData?[i].height ?? 0.0;
  //       }
  //       if (notifier.diaryData?[_curIdx] != notifier.diaryData?.last) {
  //         context.read<MainNotifier>().globalKey?.currentState?.innerController.animateTo(
  //               position,
  //               duration: const Duration(milliseconds: 400),
  //               curve: Curves.easeOut,
  //             );
  //       }
  //       if (mounted) {
  //         setState(() {});
  //       }
  //     } catch (e) {
  //       e.logger();
  //     }
  //   });

  //   fAliplayer?.setOnSnapShot((path, playerId) {
  //     print("aliyun : snapShotPath = $path");
  //     // Fluttertoast.showToast(msg: "SnapShot Save : $path");
  //   });
  //   fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
  //     try {
  //       _showLoading = false;

  //       setState(() {});
  //     } catch (e) {
  //       e.logger();
  //     }
  //   });

  //   fAliplayer?.setOnTrackChanged((value, playerId) {
  //     AVPTrackInfo info = AVPTrackInfo.fromJson(value);
  //     if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
  //       // trackFragmentKey.currentState.onTrackChanged(info);
  //       // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
  //     }
  //   });
  //   fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

  //   fAliplayer?.setOnThumbnailGetListener(
  //       onThumbnailGetSuccess: (bitmap, range, playerId) {
  //         // _thumbnailBitmap = bitmap;
  //         var provider = MemoryImage(bitmap);
  //         precacheImage(provider, context).then((_) {
  //           setState(() {});
  //         });
  //       },
  //       onThumbnailGetFail: (playerId) {});

  //   fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });

  //   fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

  void toPosition(offset) async {
    _initializeTimer();
    double totItemHeight = 0;
    double totItemHeightParam = 0;
    final notifier = context.read<PreviewDiaryNotifier>();
    print("kkkkkkkkkk");
    print(lastOffset);
    if (offset > lastOffset) {
      homeClick = false;
      for (var i = 0; i <= _curIdx; i++) {
        if (i == _curIdx) {
          totItemHeightParam += (notifier.diaryData?[i].height ?? 0.0) * 30 / 100;
        } else {
          totItemHeightParam += notifier.diaryData?[i].height ?? 0.0;
        }
        totItemHeight += notifier.diaryData?[i].height ?? 0.0;
      }
      if (offset >= totItemHeightParam) {
        var position = totItemHeight;
        if (mounted) widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    } else {
      if (!homeClick) {
        for (var i = 0; i < _curIdx; i++) {
          if (i == _curIdx - 1) {
            totItemHeightParam += (notifier.diaryData?[i].height ?? 0.0) * 75 / 100;
          } else if (i == _curIdx) {
          } else {
            totItemHeightParam += notifier.diaryData?[i].height ?? 0.0;
          }
          totItemHeight += notifier.diaryData?[i].height ?? 0.0;
        }
        if (_curIdx > 0) {
          totItemHeight -= notifier.diaryData?[_curIdx - 1].height ?? 0.0;
        }

        if (offset <= totItemHeightParam) {
          var position = totItemHeight;
          if (mounted) widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
        }
      }
    }
    lastOffset = offset;
  }

  void vidConfig() {
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
    //
    //   /// The maximum space that can be occupied by the cache directory.
    //   "mMaxDurationS": GlobalSettings.mMaxDurationSController,
    //
    //   /// The maximum cache duration of a single file.
    //   "mDir": GlobalSettings.mDirController,
    //
    //   /// The cache directory.
    //   "mEnable": GlobalSettings.mEnableCacheConfig
    //
    //   /// Specify whether to enable the cache feature.
    // };
    // fAliplayer?.setCacheConfig(map);
  }

  void start(BuildContext context, ContentData data) async {
    print("-==-=-=-=-=-=- ${data.apsaraId}");

    setState(() {
      isPause = false;
      isPlay = true;
    });
    dataSelected = data;
    print(dataSelected?.postID);
    print(data.postID);
    print(dataSelected?.postID == data.postID && isPlay);
    // fAliListPlayer?.stop();
    try {
      print(videos[_curIdx]['id']);
      fAliListPlayer!.moveTo(uid: videos[_curIdx]['id']).whenComplete(() => print("completeeee"));
      print(videos[_curIdx]['id']);
    } catch (e) {
      print("sdasdasdasdasd $e");
    }

    // if (data.isApsara ?? false) {
    //   final notifier = PostsBloc();
    //   final fixContext = Routing.navigatorKey.currentContext;
    //   await notifier.getAuthApsara(fixContext ?? context, apsaraId: data.apsaraId ?? '', check: false);
    //   final fetch = notifier.postsFetch;
    //   if (fetch.postsState == PostsState.videoApsaraSuccess) {
    //     Map jsonMap = json.decode(fetch.data.toString());
    //     print("111111");
    //     try {
    //       print("22222");
    //       fAliListPlayer?.moveTo(
    //         // uid: "ded4cdff72874c49b535f12150886884",
    //         uid: data.apsaraId,
    //         accId: "LTAI5tP2FZeBukPgRq3McSpM",
    //         accKey: "Q5hRgEciIYI2g265zbWsh2kc7meBjI",
    //         token: jsonMap['PlayAuth'],
    //         region: DataSourceRelated.defaultRegion,
    //         // region: "cn-shanghai",
    //       );
    //     } catch (e) {
    //       print("video error wkkwkww $e");
    //     }

    //     // print("ASJDHKSJDHF KSF");
    //     // print(data.apsaraId);
    //     // print(jsonMap["data"]["accessKeyId"]);
    //     // print(jsonMap["data"]["accessKeySecret"]);
    //     // print(jsonMap["data"]["securityToken"]);
    //   }
    // } else {
    //   await getOldVideoUrl(data.postID ?? '').then((value) => null);
    // }
    if (mounted) {
      setState(() {
        isPause = false;
        // _isFirstRenderShow = false;
      });
    }
    // fAliListPlayer?.prepare();
    fAliListPlayer?.play();
  }

  // void start(BuildContext context, ContentData data) async {
  //   // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

  //   // fAliplayer?.stop();
  //   dataSelected = data;

  //   isPlay = false;
  //   dataSelected?.isDiaryPlay = false;
  //   // fAliplayer?.setVidAuth(
  //   //   vid: "c1b24d30b2c671edbfcb542280e90102",
  //   //   region: DataSourceRelated.defaultRegion,
  //   //   playAuth:
  //   //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
  //   // );
  //   if (data.reportedStatus != 'BLURRED') {
  //     if (data.isApsara ?? false) {
  //       _playMode = ModeTypeAliPLayer.auth;
  //       await getAuth(context, data.apsaraId ?? '');
  //     } else {
  //       _playMode = ModeTypeAliPLayer.url;
  //       await getOldVideoUrl(data.postID ?? '');
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {
  //       isPause = false;
  //       // _isFirstRenderShow = false;
  //     });
  //   }

  //   if (data.reportedStatus == 'BLURRED') {
  //   } else {
  //     print("=====prepare=====");
  //     fAliplayer?.prepare();
  //   }
  //   // this syntax below to prevent video play after changing video
  //   Future.delayed(const Duration(seconds: 1), () {
  //     if (context.read<MainNotifier>().isInactiveState) {
  //       fAliplayer?.pause();
  //     }
  //   });

  //   // fAliplayer?.play();
  // }

  // Future getAuth(BuildContext context, String apsaraId) async {
  //   try {
  //     final fixContext = Routing.navigatorKey.currentContext;
  //     isloading = true;
  //     _showLoading = true;
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     final notifier = PostsBloc();
  //     await notifier.getAuthApsara(fixContext ?? context, apsaraId: apsaraId, check: false);
  //     final fetch = notifier.postsFetch;
  //     if (fetch.postsState == PostsState.videoApsaraSuccess) {
  //       Map jsonMap = json.decode(fetch.data.toString());
  //       auth = jsonMap['PlayAuth'];

  //       fAliplayer?.setVidAuth(
  //         vid: apsaraId,
  //         region: DataSourceRelated.defaultRegion,
  //         playAuth: auth,
  //         definitionList: [DataSourceRelated.definitionList],
  //       );

  //       isloading = false;
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
  //     }
  //   } catch (e) {
  //     isloading = false;
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     // 'Failed to fetch ads data $e'.logger();
  //   }
  // }

  Future getOldVideoUrl(String postId) async {
    if (mounted) {
      setState(() {
        isloading = true;
      });
    }
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        // fAliplayer?.setUrl(jsonMap['data']['url']);
        fAliListPlayer?.moveTo(uid: jsonMap['data']['url']);
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliListPlayer?.setPlayerView(viewId);
    // _generatePlayConfigGen();
    // FlutterAliplayer.generatePlayerConfig().then((value) {
    //   fAliplayer?.setVidAuth(
    //       vid: "51b4d7a0adb771edbfb7442380ea0102",
    //       region: DataSourceRelated.regionKey,
    //       playAuth:
    //           "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNWJiSTg3d25xd1RocmFSYjBmVzAyb0ZkdVpicmJ6RXNqejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5MnZwaGxlU2lqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFVR3JNU3g0TXhQZ3dGc0ZMYkpNaUdnWG56dWM5UHFEc2lsenVodnpxK0VmNzdsdjFzZzRKcGx1NWhkdCtvR3FwNGQ1QUlWbDFDRTRBaVc3bFZZZGFGS2dpTml6US9TNGdMeGJaUW5vZ2lHUGdLUHJBSTZoeTVibFNvVWRxV0VOcnhqYUxnbEF3b2ttaStBNERLemJhY1ZKdVh1SmFlcEhSZFpJQWhuWXZMMzMiLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJENytSWlo1ek9xYUczMUZxczFjZVpjaVVVWXdhZWZMWHBsQ3dPYTY1b2xxRlVCTkVCQkpHQnJqKzJvQVNraHhXZFk5RlQ3UGF1S3RiUjIxZ3Z5dFFOd2lpdm1Vdlowbzl0K3ZoZHA5dmVTTT1cIixcIkNhbGxlclwiOlwiK3dSWk1ObW55NEhZR205ZTNqNVp5c2F0enZPRU10aGRadWx2czZKd3Nzdz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDctMDdUMDQ6NTU6MjNaXCIsXCJNZWRpYUlkXCI6XCI1MWI0ZDdhMGFkYjc3MWVkYmZiNzQ0MjM4MGVhMDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcInRvdEhOY1VqUTF5eHVtakVsZEZXbkJ1VUxoaz1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6IjUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyIiwiVGl0bGUiOiJlZDcyNDk5NC02Y2EzLTM0NGYtYmFlZi02N2Q4NTY1ZDNmMzQiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkLzUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyL3NuYXBzaG90cy83ZGI1YWQxMWQ5ZGI0MjEwYmJjZGZiODBhZGU0ZDIwYy0wMDAwMi5qcGciLCJEdXJhdGlvbiI6MjUuNDAzfSwiQWNjZXNzS2V5SWQiOiJTVFMuTlVuaHREc3MyMXR6bWFnN2pQeml3QnlvUCIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiI5R0xuV1BaZG50YTVOeDV1aTNaTGJkdVlpdDNkVUt3ckEyQUR4ZEFmaXMxWiIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    //       // definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
    //       playConfig: value);
    // });
  }

  // _generatePlayConfigGen() {
  //   FlutterAliplayer.createVidPlayerConfigGenerator();
  //   FlutterAliplayer.setPreviewTime(0);
  // }

  _initAds(BuildContext context) async {
    //for ads
    // getCountVid();
    // await _newInitAds(true);
    context.incrementAdsCount();
    final adsNotifier = context.read<PreviewDiaryNotifier>();
    if (context.getAdsCount() == 2) {
      try {
        context.read<PreviewDiaryNotifier>().getAdsVideo(context, false);
      } catch (e) {
        'Failed to fetch ads data 0 : $e'.logger();
      }
    }
    if (context.getAdsCount() == 3 && adsNotifier.adsData != null) {
      // fAliplayer?.pause();
      _pauseScreen();
      System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
        // fAliplayer?.play();
        _initializeTimer();
      });
    }
  }

  _pauseScreen() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
  }

  void _initializeTimer() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initWakelockTimer(onShowInactivityWarning: _handleInactivity);
  }

  void _handleInactivity() {
    context.read<MainNotifier>().isInactiveState = true;
    fAliListPlayer?.pause();
    // fAliplayer?.pause();
    _pauseScreen();
    ShowBottomSheet().onShowColouredSheet(
      context,
      context.read<TranslateNotifierV2>().translate.warningInavtivityDiary,
      maxLines: 2,
      color: kHyppeLightBackground,
      textColor: kHyppeTextLightPrimary,
      textButtonColor: kHyppePrimary,
      iconSvg: 'close.svg',
      textButton: context.read<TranslateNotifierV2>().translate.stringContinue ?? '',
      onClose: () {
        context.read<MainNotifier>().isInactiveState = false;
        fAliListPlayer?.play();
        // fAliplayer?.play();
        _initializeTimer();
      },
    );
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    // fAliplayer?.stop();
    // fAliplayer?.destroy();
    fAliListPlayer?.stop();
    fAliListPlayer?.destroy();

    _pauseScreen();
    // if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
    //   fAliplayer?.destroy();
    // }
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary");

    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext dari diary");
    // fAliplayer?.play();
    fAliListPlayer?.play();

    _initializeTimer();
    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    // fAliplayer?.pause();
    fAliListPlayer?.pause();
    _pauseScreen();
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // fAliplayer?.pause();
        fAliListPlayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.resumed:
        if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
          // fAliplayer?.play();
          fAliListPlayer?.play();
          _initializeTimer();
        }
        break;
      case AppLifecycleState.paused:
        // fAliplayer?.pause();
        fAliListPlayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.detached:
        // fAliplayer?.pause();
        fAliListPlayer?.pause();
        _pauseScreen();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmptyData) _getData();
    SizeConfig().init(context);
    context.select((ErrorService value) => value.getError(ErrorType.pic));
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return Consumer2<PreviewDiaryNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
      return Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: (notifier.diaryData == null || home.isLoadingDiary)
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
                  : notifier.diaryData != null && (notifier.diaryData?.isEmpty ?? true)
                      ? const NoResultFound()
                      : NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return false;
                          },
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            // controller: notifier.scrollController,
                            // scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: notifier.diaryData?.length,
                            padding: const EdgeInsets.symmetric(horizontal: 11.5),
                            itemBuilder: (context, index) {
                              if (notifier.diaryData == null || home.isLoadingDiary) {
                                // fAliplayer?.pause();
                                fAliListPlayer?.pause();

                                // _lastCurIndex = -1;
                                _lastCurPostId = '';
                                return CustomShimmer(
                                  width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                                  height: 168,
                                  radius: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                                );
                              } else if (index == notifier.diaryData?.length && notifier.hasNext) {
                                return UnconstrainedBox(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 80 * SizeConfig.scaleDiagonal,
                                    height: 80 * SizeConfig.scaleDiagonal,
                                    child: const CustomLoading(),
                                  ),
                                );
                              }
                              // if (_curIdx == 0 && notifier.diaryData?[0].reportedStatus == 'BLURRED') {
                              if (notifier.diaryData?[0].reportedStatus == 'BLURRED') {
                                isPlay = false;
                                // fAliplayer?.stop();
                                fAliListPlayer?.stop();
                              }

                              return itemDiary(context, notifier, index, home);
                            },
                          ),
                        ),
            ),
          ],
        ),
      );
    });
  }

  Widget itemDiary(BuildContext context, PreviewDiaryNotifier notifier, int index, HomeNotifier homeNotifier) {
    var data = notifier.diaryData?[index];
    return WidgetSize(
      onChange: (Size size) {
        data?.height = size.height;
      },
      child: Column(
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
                // Text("itemHeight $itemHeight"),
                // SelectableText("isApsara : ${data?.isApsara}"),
                // SelectableText("post id : ${data?.postID})"),
                // sixteenPx,
                // SelectableText((data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? "") : "${data?.fullThumbPath}"),
                // sixteenPx,
                // SelectableText((data?.isApsara ?? false) ? (data?.apsaraId ?? "") : "${UrlConstants.oldVideo + notifier.diaryData![index].postID!}"),
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
                        username: data?.username,
                        featureType: FeatureType.other,
                        // isCelebrity: viddata?.privacy?.isCelebrity,
                        isCelebrity: false,
                        imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                        onTapOnProfileImage: () => System().navigateToProfile(context, data?.email ?? ''),
                        createdAt: '2022-02-02',
                        musicName: data?.music?.musicTitle ?? '',
                        location: data?.location ?? '',
                        isIdVerified: data?.privacy?.isIdVerified,
                        badge: data?.urluserBadge,
                      ),
                    ),
                    if (data?.email != email && (data?.isNewFollowing ?? false))
                      Consumer<PreviewPicNotifier>(
                        builder: (context, picNot, child) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              context.handleActionIsGuest(()  {
                                if (data?.insight?.isloadingFollow != true) {
                                  picNot.followUser(context, data ?? ContentData(), isUnFollow: data?.following, isloading: data?.insight?.isloadingFollow ?? false);
                                }
                              });

                            },
                            child: data?.insight?.isloadingFollow ?? false
                                ? Container(
                                    height: 40,
                                    width: 30,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CustomLoading(),
                                    ),
                                  )
                                : Text(
                                    (data?.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                    style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                  ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        fAliListPlayer?.setMuted(true);
                        fAliListPlayer?.pause();
                        await context.handleActionIsGuest(() async  {
                          if (data?.email != email) {
                            // FlutterAliplayer? fAliplayer
                            context.read<PreviewPicNotifier>().reportContent(context, data ?? ContentData(), fAliplayer: fAliListPlayer, onCompleted: () async {
                              imageCache.clear();
                              imageCache.clearLiveImages();
                              await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 1);
                            });
                          } else {


                            // fAliplayer?.setMuted(true);
                            // fAliplayer?.pause();
                            ShowBottomSheet().onShowOptionContent(
                              context,
                              contentData: data ?? ContentData(),
                              captionTitle: hyppeDiary,
                              onDetail: false,
                              isShare: data?.isShared,
                              onUpdate: () {
                                (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 1);
                              },
                              fAliplayer: fAliListPlayer,
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
                  // key: Key(index.toString()),
                  key: Key(data?.postID ?? index.toString()),
                  onVisibilityChanged: (info) {
                    // if (info.visibleFraction == 1.0) {
                    //   Wakelock.enable();
                    // }
                    if (info.visibleFraction >= 0.6) {
                      _curIdx = index;

                      _curPostId = data?.postID ?? index.toString();
                      // if (_lastCurIndex != _curIdx) {
                      final indexList = notifier.diaryData?.indexWhere((element) => element.postID == _curPostId);
                      // final latIndexList = notifier.diaryData?.indexWhere((element) => element.postID == _lastCurPostId);
                      if (_lastCurPostId != _curPostId) {
                        if (mounted) {
                          setState(() {
                            Future.delayed(Duration(milliseconds: 400), () {
                              itemHeight = notifier.diaryData?[indexList ?? 0].height ?? 0;
                            });
                          });
                        }
                        Future.delayed(const Duration(milliseconds: 700), () {
                          start(Routing.navigatorKey.currentContext ?? context, data ?? ContentData());
                          System().increaseViewCount2(Routing.navigatorKey.currentContext ?? context, data ?? ContentData(), check: false);
                        });
                        if (data?.certified ?? false) {
                          System().block(Routing.navigatorKey.currentContext ?? context);
                        } else {
                          System().disposeBlock();
                        }

                        if (indexList == (notifier.diaryData?.length ?? 0) - 1) {
                          Future.delayed(const Duration(milliseconds: 1000), () async {
                            await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                              // notifier.getTemp(indexList, latIndexList, indexList);
                            });
                          });
                        } else {
                          Future.delayed(const Duration(milliseconds: 2000), () {
                            // notifier.getTemp(indexList, latIndexList, indexList);
                          });
                        }
                      }
                      // _lastCurIndex = _curIdx;
                      _lastCurPostId = _curPostId;
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    // width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.width * 16.0 / 10.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      // color: Colors.yellow,
                    ),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Stack(
                        children: [
                          // _curIdx == index
                          _curPostId == (data?.postID ?? index.toString())
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                  child: AliPlayerView(
                                    onCreated: onViewPlayerCreated,
                                    x: 0,
                                    y: 0,
                                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                    width: MediaQuery.of(context).size.width,
                                    aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
                                  ),
                                )
                              : Container(),
                          // _buildProgressBar(SizeConfig.screenWidth!, 500),
                          !notifier.connectionError
                              ? Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      fAliListPlayer?.play();
                                      if (mounted) {
                                        setState(() {
                                          isMute = !isMute;
                                        });
                                      }
                                      fAliListPlayer?.setMuted(isMute);
                                    },
                                    onDoubleTap: () {
                                      final _likeNotifier = context.read<LikeNotifier>();
                                      if (data != null) {
                                        _likeNotifier.likePost(context, data);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: SizeConfig.screenWidth,
                                      height: SizeConfig.screenHeight,
                                    ),
                                  ),
                                )
                              : Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      homeNotifier.checkConnection();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                      width: SizeConfig.screenWidth,
                                      height: SizeConfig.screenHeight,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(20),
                                      child: data?.reportedStatus == 'BLURRED'
                                          ? Container()
                                          : CustomTextWidget(
                                              textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                              maxLines: 3,
                                            ),
                                    ),
                                  ),
                                ),
                          dataSelected?.postID == data?.postID && isPlay
                              ? Container()
                              : CustomBaseCacheImage(
                                  memCacheWidth: 100,
                                  memCacheHeight: 100,
                                  widthPlaceHolder: 80,
                                  heightPlaceHolder: 80,
                                  placeHolderWidget: Container(),
                                  imageUrl: (data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? "") : data?.fullThumbPath ?? '',
                                  imageBuilder: (context, imageProvider) => data?.reportedStatus == 'BLURRED'
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
                                        homeNotifier.checkConnection();
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                          width: SizeConfig.screenWidth,
                                          height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          child: CustomTextWidget(
                                            textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                            maxLines: 3,
                                          )),
                                    );
                                  },
                                  emptyWidget: GestureDetector(
                                    onTap: () {
                                      homeNotifier.checkConnection();
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                        width: SizeConfig.screenWidth,
                                        height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(20),
                                        child: CustomTextWidget(
                                          textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                          maxLines: 3,
                                        )),
                                  ),
                                ),
                          _showLoading && !homeNotifier.connectionError
                              ? const Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          _buildBody(context, SizeConfig.screenWidth, data ?? ContentData()),
                          blurContentWidget(context, data ?? ContentData()),
                        ],
                      ),
                    ),
                  ),
                ),
                SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                        (data?.boosted.isEmpty ?? [].isEmpty) &&
                        (data?.reportedStatus != 'OWNED' && data?.reportedStatus != 'BLURRED' && data?.reportedStatus2 != 'BLURRED') &&
                        data?.email == email
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ButtonBoost(
                          onDetail: false,
                          marginBool: true,
                          contentData: data,
                          startState: () {
                            SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                          },
                          afterState: () {
                            SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                          },
                        ),
                      )
                    : Container(),
                if (data?.email == email && (data?.boostCount ?? 0) >= 0 && (data?.boosted.isNotEmpty ?? [].isEmpty))
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
                          child: Text(
                            "${data?.boostJangkauan ?? '0'} ${lang?.reach}",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                            child: Consumer<LikeNotifier>(
                              builder: (context, likeNotifier, child) => Align(
                                alignment: Alignment.bottomRight,
                                child: data?.insight?.isloading ?? false
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
                                          color: (data?.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                          iconData: '${AssetPath.vectorPath}${(data?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                          height: 28,
                                        ),
                                        onTap: () {
                                          if (data != null) {
                                            likeNotifier.likePost(context, data);
                                          }
                                        },
                                      ),
                              ),
                            ),
                          ),
                          if (data?.allowComments ?? false)
                            Padding(
                              padding: const EdgeInsets.only(left: 21.0),
                              child: GestureDetector(
                                onTap: () {
                                  Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: data?.postID ?? '', fromFront: true, data: data ?? ContentData()));
                                },
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  color: kHyppeTextLightPrimary,
                                  iconData: '${AssetPath.vectorPath}comment2.svg',
                                  height: 24,
                                ),
                              ),
                            ),
                          if ((data?.isShared ?? false))
                            Padding(
                              padding: EdgeInsets.only(left: 21.0),
                              child: GestureDetector(
                                onTap: () {
                                  context.read<DiariesPlaylistNotifier>().createdDynamicLink(context, data: data);
                                },
                                child: CustomIconWidget(
                                  defaultColor: false,
                                  color: kHyppeTextLightPrimary,
                                  iconData: '${AssetPath.vectorPath}share2.svg',
                                  height: 24,
                                ),
                              ),
                            ),
                          if ((data?.saleAmount ?? 0) > 0 && email != data?.email)
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await context.handleActionIsGuest(() async  {
                                    fAliListPlayer?.pause();
                                    await ShowBottomSheet.onBuyContent(context, data: data, fAliplayer: fAliListPlayer);
                                  });

                                  // fAliplayer?.play();
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
                      Text(
                        "${data?.insight?.likes}  ${lang?.like}",
                        style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                twelvePx,
                CustomNewDescContent(
                  // desc: "${data?.description}",
                  email: data?.email??'',
                  username: data?.username ?? '',
                  desc: "${data?.description}",
                  trimLines: 3,
                  textAlign: TextAlign.start,
                  seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                  seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                  normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                  hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                  expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: () {
                    Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: data?.postID ?? '', fromFront: true, data: data ?? ContentData()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${lang?.seeAll} ${data?.comments} ${lang?.comment}",
                      style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                    ),
                  ),
                ),
                (data?.comment?.length ?? 0) > 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (data?.comment?.length ?? 0) >= 2 ? 2 : 1,
                          itemBuilder: (context, indexComment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: CustomNewDescContent(
                                // desc: "${data??.description}",
                                email: data?.comment?[indexComment].sender,
                                username: data?.comment?[indexComment].userComment?.username ?? '',
                                desc: data?.comment?[indexComment].txtMessages ?? '',
                                trimLines: 3,
                                textAlign: TextAlign.start,
                                seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                                seeMore: ' ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                      DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                      context,
                      fullCaption: true,
                    )}",
                    style: TextStyle(fontSize: 12, color: kHyppeBurem),
                  ),
                ),
              ],
            ),
          ),
          homeNotifier.isLoadingLoadmore && data == notifier.diaryData?.last
              ? const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Center(child: CustomLoading()),
                )
              : Container(),
        ],
      ),
    );
  }

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

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned.fill(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PicTopItem(data: data),
          ),
          if (data.tagPeople?.isNotEmpty ?? false)
            Positioned(
              bottom: 18,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  fAliListPlayer?.pause();
                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, fAliplayer: fAliListPlayer);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    isMute = !isMute;
                  });
                }
                fAliListPlayer?.setMuted(isMute);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomIconWidget(
                  iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
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
                      Text("HyppeDiary ${transnot.translate.contentContainsSensitiveMaterial}",
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
                          data.reportedStatus = '';
                          start(context, data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppeDiary);
                          fAliListPlayer?.prepare();
                          fAliListPlayer?.play();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
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
                            "${transnot.translate.see} HyppeDiary",
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
