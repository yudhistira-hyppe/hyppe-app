import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/beauty/live_beauty.dart';
import 'package:flutter_livepush_plugin/live_base.dart';
import 'package:flutter_livepush_plugin/live_push_def.dart';
import 'package:flutter_livepush_plugin/live_pusher.dart';

/// Import a header file.
import 'package:flutter_livepush_plugin/live_push_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/item.dart';
import 'package:permission_handler/permission_handler.dart';

class StreamerNotifier with ChangeNotifier {
  int livePushMode = 0;
  int timeReady = 3;

  late AlivcBase _alivcBase;
  late AlivcLivePusher _alivcLivePusher;
  late AlivcLiveBeautyManager _beautyManager;

  bool isloading = false;
  bool mute = false;

  FocusNode titleFocusNode = FocusNode();
  TextEditingController titleLiveCtrl = TextEditingController();

  String _titleLive = '';
  String get titleLive => _titleLive;
  String pushURL = "rtmp://ingest.hyppe.cloud/Hyppe/hdstream?auth_key=1700732018-0-0-580e7fb4d21585a87315470a335513c1";
  //Status => Offline - Prepare - StandBy - Ready - Online
  String statusLive = 'Offline';

  List<Item> _items = <Item>[];
  List<Item> get items => _items;

  set titleLive(String val) {
    _titleLive = val;
    notifyListeners();
  }

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

    /// Listener for the stream ingest status
    /// Configure the callback for preview start.
    _alivcLivePusher.setOnPreviewStarted(() {});

    /// Configure the callback for preview stop.
    _alivcLivePusher.setOnPreviewStoped(() {});

    /// Configure the callback for first frame rendering.
    _alivcLivePusher.setOnFirstFramePreviewed(() {});

    /// Configure the callback for start of stream ingest.
    _alivcLivePusher.setOnPushStarted(() {
      statusLive = 'StandBy';
      notifyListeners();
      countDown();
    });

    /// Configure the callback for pause of stream ingest from the camera.
    _alivcLivePusher.setOnPushPaused(() {});

    /// Configure the callback for resume of stream ingest from the camera.
    _alivcLivePusher.setOnPushResumed(() {});

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

  Future<void> clickPushAction() async {
    statusLive = 'Prepare';
    notifyListeners();
    _alivcLivePusher.startPushWithURL(pushURL);
  }

  Future<void> destoryPusher() async {
    statusLive = 'Offline';
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
        statusLive = 'Ready';
        notifyListeners();
        Future.delayed(Duration(seconds: 2), () {
          statusLive = 'Online';
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
    print(mute);
    notifyListeners();
  }

  Future<void> pauseLive() async {
    try {
      print("hahahahahha");
    } catch (e) {
      print("hahahahahha");
    }

    // _alivcLivePusher.pause();
  }
}
