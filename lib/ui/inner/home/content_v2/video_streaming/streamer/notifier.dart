import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/beauty/live_beauty.dart';
import 'package:flutter_livepush_plugin/live_base.dart';
import 'package:flutter_livepush_plugin/live_push_def.dart';
import 'package:flutter_livepush_plugin/live_pusher.dart';

/// Import a header file.
import 'package:flutter_livepush_plugin/live_push_config.dart';
import 'package:hyppe/core/bloc/live_stream/bloc.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/item.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class StreamerNotifier with ChangeNotifier {
  static const String eventComment = 'COMMENT_STREAM_SINGLE';
  static const String eventViewStream = 'VIEW_STREAM';
  static const String eventLikeStream = 'LIKE_STREAM';
  static const String eventCommentDisable = 'COMMENT_STREAM_DISABLED';

  final _socketService = SocketService();

  int livePushMode = 0;
  int timeReady = 3;
  int totLikes = 0;
  int totViews = 0;

  LinkStreamModel dataStream = LinkStreamModel();

  late AlivcBase _alivcBase;
  late AlivcLivePusher _alivcLivePusher;
  late AlivcLiveBeautyManager _beautyManager;

  bool isloadingPreview = true;
  bool isloading = false;
  bool mute = false;
  bool isPause = false;
  bool isCommentDisable = false;

  FocusNode titleFocusNode = FocusNode();
  TextEditingController titleLiveCtrl = TextEditingController();

  String _titleLive = '';
  String get titleLive => _titleLive;
  String pushURL = "rtmp://ingest.hyppe.cloud/Hyppe/hdstream?auth_key=1700732018-0-0-580e7fb4d21585a87315470a335513c1";
  //Status => Offline - Prepare - StandBy - Ready - Online
  StatusStream statusLive = StatusStream.offline;

  List<Item> _items = <Item>[];
  List<Item> get items => _items;

  List<CommentLiveModel> comment = [];

  set titleLive(String val) {
    _titleLive = val;
    notifyListeners();
  }

  LocalizationModelV2? tn;

  Future<void> init(BuildContext context) async {
    // final isGranted = await System().requestPermission(context, permissions: [Permission.camera, Permission.microphone]);
    isloading = true;
    notifyListeners();
    // _setPageOrientation(action, ctx);
    _alivcBase = AlivcBase.init();
    await _alivcBase.registerSDK();
    await _alivcBase.setObserver();
    _alivcBase.setOnLicenceCheck((result, reason) {
      print("======== belum ada lisensi $reason ========");
      if (result != AlivcLiveLicenseCheckResultCode.success) {
        print("======== belum ada lisensi $reason ========");
      }
    });
    await _setLivePusher();
    await _onListen();
    isloading = false;
    notifyListeners();
    tn = context.read<TranslateNotifierV2>().translate;
  }

  Future requestPermission(BuildContext context) async {
    final isGranted = await System().requestPermission(context, permissions: [Permission.camera, Permission.microphone]);
    if (isGranted) {
      return;
    } else {
      await System().requestPermission(context, permissions: [Permission.camera, Permission.microphone]);
    }
  }

  Future<void> _onListen() async {
    /// Listener for stream ingest errors
    /// Configure the callback for SDK errors.
    _alivcBase.setOnLicenceCheck((result, reason) {
      if (result != AlivcLiveLicenseCheckResultCode.success) {
        print("======== belum ada lisensi $reason ========");
      }
    });

    /// Configure the callback for system errors.
    _alivcLivePusher.setOnSDKError((errorCode, errorDescription) {
      print("========  setOnSDKError $errorDescription ========");
      // Fluttertoast.showToast(
      //   msg: AppLocalizations.of(ctx.context)!.camerapush_sdk_error,
      //   gravity: ToastGravity.CENTER,
      // );
    });

    /// 系统错误回调
    _alivcLivePusher.setOnSystemError((errorCode, errorDescription) {
      print("========  setOnSystemError $errorDescription ========");
      // Fluttertoast.showToast(
      //   msg: AppLocalizations.of(ctx.context)!.camerapush_system_error,
      //   gravity: ToastGravity.CENTER,
      // );
    });

    /// Listener for the stream ingest status`
    /// Configure the callback for preview start.
    _alivcLivePusher.setOnPreviewStarted(() {
      isloadingPreview = false;
      notifyListeners();
    });

    /// Configure the callback for preview stop.
    _alivcLivePusher.setOnPreviewStoped(() {});

    /// Configure the callback for first frame rendering.
    _alivcLivePusher.setOnFirstFramePreviewed(() {});

    /// Configure the callback for start of stream ingest.
    _alivcLivePusher.setOnPushStarted(() {
      statusLive = StatusStream.standBy;
      notifyListeners();
      countDown();
    });

    /// Configure the callback for pause of stream ingest from the camera.
    _alivcLivePusher.setOnPushPaused(() {
      isPause = true;
      notifyListeners();
    });

    /// Configure the callback for resume of stream ingest from the camera.
    _alivcLivePusher.setOnPushResumed(() {
      isPause = false;
      notifyListeners();
    });

    /// Configure the callback for restart of stream ingest.
    _alivcLivePusher.setOnPushRestart(() {});

    /// Configure the callback for end of stream ingest.
    _alivcLivePusher.setOnPushStoped(() {});

    /// Listener for the network status during stream ingest
    /// Configure the callback for failed connection of stream ingest.
    _alivcLivePusher.setOnConnectFail((errorCode, errorDescription) {});

    /// Configure the callback for network recovery.
    _alivcLivePusher.setOnConnectRecovery(() {});

    /// Configure the callback for disconnection.
    _alivcLivePusher.setOnConnectionLost(() {});

    /// Configure the callback for poor network.
    _alivcLivePusher.setOnNetworkPoor(() {});

    /// Configure the callback for failed reconnection.
    _alivcLivePusher.setOnReconnectError((errorCode, errorDescription) {});

    /// Configure the callback for reconnection start.
    _alivcLivePusher.setOnReconnectStart(() {});

    /// Configure the callback for successful reconnection.
    _alivcLivePusher.setOnReconnectSuccess(() {});

    /// Send data timeout
    _alivcLivePusher.setOnSendDataTimeout(() {});

    /// Configure the callback for complete playback of background music.
    _alivcLivePusher.setOnBGMCompleted(() {});

    /// Configure the callback for timeout of the download of background music.
    _alivcLivePusher.setOnBGMDownloadTimeout(() {});

    /// Configure the callback for failed playback of background music.
    _alivcLivePusher.setOnBGMOpenFailed(() {});

    /// Configure the callback for paused playback of background music.
    _alivcLivePusher.setOnBGMPaused(() {});

    /// Configure the callback for playback progress.
    _alivcLivePusher.setOnBGMProgress((progress, duration) {
      // ctx.dispatch(CameraPushActionCreator.onUpdateBGMProgress(progress));
      // ctx.dispatch(CameraPushActionCreator.onUpdateBGMDuration(duration));
    });

    /// Configure the callback for resumed playback of background music.
    _alivcLivePusher.setOnBGMResumed(() {
      // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_resume_log));
    });

    /// Configure the callback for start of playback of background music.
    _alivcLivePusher.setOnBGMStarted(() {
      // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_start_log));
    });

    /// Configure the callback for stop of playback of background music.
    _alivcLivePusher.setOnBGMStoped(() {
      // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_stop_log));
      // ctx.dispatch(CameraPushActionCreator.onUpdateBGMProgress(0));
      // ctx.dispatch(CameraPushActionCreator.onUpdateBGMDuration(0));
    });

    /// Configure callbacks related to snapshot capture.
    _alivcLivePusher.setOnSnapshot((saveResult, savePath, {dirTypeForIOS}) {
      // if (saveResult == true) {
      //   String tip = AppLocalizations.of(ctx.context)!.camerapush_snapshot_tip;
      //   if (Platform.isIOS) {
      //     DirType saveDirType = DirType.document;
      //     if (dirTypeForIOS == AlivcLiveSnapshotDirType.document) {
      //       saveDirType = DirType.document;
      //     } else {
      //       saveDirType = DirType.library;
      //     }
      //     CommomUtils.getSaveDir(saveDirType, savePath).then((value) {
      //       Fluttertoast.showToast(msg: tip + value.path, gravity: ToastGravity.CENTER);
      //     });
      //   } else {
      //     Fluttertoast.showToast(msg: tip + savePath, gravity: ToastGravity.CENTER);
      //   }
      // }
    });
  }

  Future<void> _setLivePusher() async {
    AlivcLivePusherConfig pusherConfig = AlivcLivePusherConfig.init();
    pusherConfig.setCameraType(AlivcLivePushCameraType.front);

    /// Set the resolution to 540p.
    pusherConfig.setResolution(AlivcLivePushResolution.resolution_540P);

    /// Specify the frame rate. We recommend that you set the frame rate to 20 frames per second (FPS).
    pusherConfig.setFps(AlivcLivePushFPS.fps_20);

    /// Enable adaptive bitrate streaming. The default value is true.
    pusherConfig.setEnableAutoBitrate(true);

    /// Specify the group of pictures (GOP) size. A larger value indicates a higher latency. We recommend that you set the value to a number from 1 to 2.
    pusherConfig.setVideoEncodeGop(AlivcLivePushVideoEncodeGOP.gop_2);

    /// Specify the reconnection duration. The value cannot be less than 1000. Unit: milliseconds. We recommend that you use the default value.
    pusherConfig.setConnectRetryInterval(2000);

    /// Disable the mirroring mode for preview.
    pusherConfig.setPreviewMirror(false);

    /// Set the stream ingest orientation to portrait.
    pusherConfig.setOrientation(AlivcLivePushOrientation.portrait);

    pusherConfig.setPreviewDisplayMode(AlivcPusherPreviewDisplayMode.preview_aspect_fill);

    _alivcLivePusher = AlivcLivePusher.init();
    _alivcLivePusher.initLivePusher();
    _alivcLivePusher.createConfig();
    _alivcLivePusher.setErrorDelegate();
    _alivcLivePusher.setInfoDelegate();
    _alivcLivePusher.setNetworkDelegate();
    _alivcLivePusher.setCustomFilterDelegate();
    _alivcLivePusher.setCustomDetectorDelegate();
    _alivcLivePusher.setBGMDelegate();
  }

  Future<void> _clickSnapShot() async {
    if (Platform.isIOS) {
      /// dir parameter: On iOS, the path is a relative path. A custom directory is automatically generated in the system sandbox. If you set this parameter to "", snapshots are stored in the root directory of the system sandbox.
      /// dirTypeForIOS parameter: Optional. If you do not specify this parameter, snapshots are stored in the [document] directory of the system sandbox.
      _alivcLivePusher.snapshot(1, 0, "snapshot", dirTypeForIOS: AlivcLiveSnapshotDirType.document);
    } else {
      // CommomUtils.getSystemPath(DirType.externalFile).then((value) {
      //   _alivcLivePusher.snapshot(1, 0, value);
      // });
    }

    /// Set the listener for snapshot capture.
    _alivcLivePusher.setSnapshotDelegate();
  }

  Future<void> previewCreated() async {
    _alivcLivePusher.startPreview().then((value) {
      print("===== start preview ====");
    });
    // _beautyManager.setupBeauty();
    // ctx.dispatch(CameraPushActionCreator.onClickPreview(CameraPushPagePreviewState.startPreview));
  }

//   rtmp://ingest.hyppe.cloud/Hyppe/hdstream?auth_key=1700732018-0-0-580e7fb4d21585a87315470a335513c1

// Stream URL (download stream dari user yang nnton)
// rtmp://live.hyppe.cloud/Hyppe/hdstream_hd-v?auth_key=1700732018-0-0-8e221f09856a236e9f2454e8dfddfae1

  Future<void> clickPushAction(BuildContext context, mounted) async {
    if (titleLive == '') {
      titleLive = context.read<SelfProfileNotifier>().user.profile?.fullName ?? '';
    }
    statusLive = StatusStream.prepare;
    notifyListeners();
    var init = await initLiveStream(context, mounted);
    if (init) {
      Future.delayed(Duration(seconds: 1));
      _alivcLivePusher.startPushWithURL(dataStream.urlIngest ?? '');
      _connectAndListenToSocket(eventComment);
      _connectAndListenToSocket(eventLikeStream);
      _connectAndListenToSocket(eventViewStream);

      // _alivcLivePusher.startPushWithURL(pushURL);
    } else {
      statusLive = StatusStream.offline;
      notifyListeners();
    }
  }

  Future<void> destoryPusher() async {
    WakelockPlus.disable();
    statusLive = StatusStream.offline;
    _alivcLivePusher.stopPush();
    _alivcLivePusher.stopPreview();
    _alivcLivePusher.destroy();
  }

  void flipCamera() {
    _alivcLivePusher.switchCamera();
  }

  void countDown() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {
      timeReady--;
      notifyListeners();
      if (timeReady > 0) {
        countDown();
      } else {
        statusLive = StatusStream.ready;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          statusLive = StatusStream.online;
          initTimer();
          notifyListeners();
        });
      }
    });
  }

  List<Widget> loveStreamer(AnimationController animationController) {
    // print('isPreventedEmoji: $isPreventedEmoji');
    final animatedOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.linear));
    return items.map((item) {
      var tween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: const Offset(0, -1.7),
      ).chain(CurveTween(curve: Curves.linear));
      return SlideTransition(
        position: animationController.drive(tween),
        child: AnimatedAlign(
            alignment: item.alignment,
            duration: const Duration(seconds: 10),
            child: FadeTransition(
              opacity: animatedOpacity,
              child: Material(color: Colors.transparent, child: Icon(Icons.heart_broken)),
            )),
      );
    }).toList();
  }

  void makeItems(AnimationController animationController) {
    items.clear();
    for (int i = 0; i < 1; i++) {
      items.add(Item());
      // notifyListeners();
    }

    print("ini print $items");

    // notifyListeners();
    animationController.reset();
    animationController.forward().whenComplete(() {});
  }

  void soundMute() {
    mute = !mute;
    _alivcLivePusher.setMute(mute);
    debugPrint(mute.toString());
    notifyListeners();
  }

  Future<void> pauseLive() async {
    mute = true;
    _alivcLivePusher.pause();
    notifyListeners();
  }

  Future<void> resumeLive() async {
    mute = false;
    _alivcLivePusher.resume();
    notifyListeners();
  }

  int x = 0;
  void addCommentDummy() {
    // comment.insert(0, 'hahaha ${x++}');
    notifyListeners();
  }

  void initTimer() async {
    // adding delay to prevent if there's another that not disposed yet
    Future.delayed(const Duration(milliseconds: 2000), () {
      WakelockPlus.enable();

      Timer(const Duration(seconds: 10), () {
        ShowGeneralDialog.generalDialog(
          Routing.navigatorKey.currentContext,
          titleText: tn?.liveBroadcastRemaining5Minutes ?? '',
          bodyText: tn?.youOnlyHave5MinutesLeftinTheLiveBroadcast ?? 'Waktumu tinggal 5 menit dalam siaran LIVE',
          maxLineTitle: 1,
          maxLineBody: 4,
          functionPrimary: () async {
            Routing().moveBack();
          },
          titleButtonPrimary: tn?.understand ?? '',
          barrierDismissible: true,
          isHorizontal: false,
          fillColor: false,
        );
      });
    });
  }

  Future initLiveStream(BuildContext context, mounted) async {
    bool returnNext = false;
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'title': titleLive};

        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.getLinkStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          dataStream = LinkStreamModel.fromJson(fetch.data);
          returnNext = true;
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          initLiveStream(context, mounted);
        });
      }
    }
    return returnNext;
  }

  Future disableComment(BuildContext context, mounted) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"_id": dataStream.sId, "commentDisabled": !isCommentDisable, "type": "COMMENT_DISABLED"};
        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          isCommentDisable = !isCommentDisable;
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          initLiveStream(context, mounted);
        });
      }
    }
  }

  void _connectAndListenToSocket(String events) async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);

    // if (_socketService.isRunning) {
    //   _socketService.closeSocket();
    // }

    _socketService.connectToSocket(
      () {
        _socketService.events(
          events,
          (message) {
            try {
              handleSocket(message, events);
              print('ini message dari socket $events ----- ${message}');
            } catch (e) {
              e.toString().logger();
            }
          },
        );
      },
      host: Env.data.baseUrl,
      options: OptionBuilder()
          .setAuth({
            "x-auth-user": "$email",
            "x-auth-token": "$token",
          })
          .setTransports(
            ['websocket'],
          )
          .setPath('${Env.data.versionApi}/socket.io')
          .disableAutoConnect()
          .build(),
    );
  }

  void handleSocket(message, event) {
    if (event == eventComment) {
      var messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        comment.insert(0, messages);
      }
    } else if (event == eventLikeStream) {
      var messages = CountLikeLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        totLikes += messages.likeCount ?? 0;
      }
    } else if (event == eventViewStream) {
      var messages = CountViewLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        totViews = messages.viewCount ?? 0;
      }
    }
    notifyListeners();
  }
}
