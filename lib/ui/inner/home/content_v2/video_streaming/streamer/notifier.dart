import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/arguments/summary_live_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/bloc/live_stream/bloc.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/bloc/message_v2/state.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/live_stream/banned_stream_model.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
import 'package:hyppe/core/models/collection/live_stream/gift_live_model.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/models/collection/live_stream/list_user_gift_model.dart';
import 'package:hyppe/core/models/collection/live_stream/live_summary_model.dart';
import 'package:hyppe/core/models/collection/live_stream/viewers_live_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/query_request/users_data_query.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/socket_live_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/item.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:math' as math;
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';

class StreamerNotifier with ChangeNotifier, GeneralMixin {
  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  static const String eventComment = 'COMMENT_STREAM_SINGLE';
  static const String eventViewStream = 'VIEW_STREAM';
  static const String eventLikeStream = 'LIKE_STREAM';
  static const String eventStatusStream = 'STATUS_STREAM';

  final _socketService = SocketLiveService();

  int livePushMode = 0;
  int timeReady = 3;
  int totLikes = 0;
  int totViews = 0;
  int pageViewers = 0;
  int rowViewers = 10;
  int totPause = 0;
  int pageNumberUserShare = 0;
  int limitNumberUserShare = 15;

  Duration timeCountdownReported = const Duration(seconds: 30);

  BannedStreamModel? dataBanned;
  LinkStreamModel dataStream = LinkStreamModel();
  UserProfileModel audienceProfile = UserProfileModel();
  UserProfileModel audienceProfileViewer = UserProfileModel();
  StatusFollowing statusFollowing = StatusFollowing.none;

  StatusFollowing statusFollowingViewer = StatusFollowing.none;
  LiveSummaryModel dataSummary = LiveSummaryModel();

  List<GiftLiveModel> dataGift = [];
  List<GiftLiveModel> dataGiftDeluxe = [];
  GiftLiveModel? giftSelect;

  // late AlivcBase _alivcBase;
  // late AlivcLivePusher _alivcLivePusher;
  // late AlivcLiveBeautyManager _beautyManager;
  bool flipCameraVisible = true;

  bool isloadingPreview = true;
  bool isloading = false;
  bool isloadingViewers = false;
  bool isloadingViewersMore = false;
  bool isloadingProfile = false;
  bool isloadingProfileViewer = false;
  bool isCheckLoading = false;
  bool isloadingButton = false;
  bool isloadingUserShare = false;
  bool isloadingGift = false;
  bool mute = false;
  bool isPause = false;
  bool isCommentDisable = false;
  bool isCancel = false;
  bool isSendComment = false;
  bool isFirst = true;

  // Agora
  int? remoteUid;
  String? tempToken;
  String? channel;
  bool localUserJoined = false;

  // Engine Agora
  late RtcEngine engine;

  FocusNode titleFocusNode = FocusNode();
  TextEditingController titleUrlLiveCtrl = TextEditingController();
  TextEditingController titleLiveCtrl = TextEditingController();
  TextEditingController urlLiveCtrl = TextEditingController();
  TextEditingController commentCtrl = TextEditingController();
  TextEditingController searchUserCtrl = TextEditingController();
  TextEditingController messageShareCtrl = TextEditingController();

  Timer? inactivityTimer;
  DateTime dateTimeStart = DateTime.now();

  String userName = '';
  String _titleLive = '';
  String get titleLive => _titleLive;

  String _urlLink = '';
  String get urlLink => _urlLink;

  String _textUrl = '';
  String get textUrl => _textUrl;
  // String pushURL = "rtmp://ingest.hyppe.cloud/Hyppe/hdstream?auth_key=1700732018-0-0-580e7fb4d21585a87315470a335513c1";

  ///Status => Offline - Prepare - StandBy - Ready - Online
  StatusStream statusLive = StatusStream.offline;

  List<CommentLiveModel> giftBasic = [];
  List<CommentLiveModel> giftBasicTemp = [];
  List<CommentLiveModel> giftDelux = [];
  List<CommentLiveModel> giftDeluxTemp = [];
  List<Item> _items = <Item>[];
  List<Item> get items => _items;

  List<ViewersLiveModel> dataViewers = [];
  List<CommentLiveModel> comment = [];
  List<int> animationIndexes = [];
  List<SearchPeolpleData> listShareUser = [];
  List<SearchPeolpleData> shareUsers = [];
  List<ListGiftModel> dataUserGift = [];

  CommentLiveModel? pinComment;

  set titleLive(String val) {
    _titleLive = val;
    notifyListeners();
  }

  onUpdate() => notifyListeners();
  set urlLink(String val) {
    _urlLink = val;
    notifyListeners();
  }

  set textUrl(String val) {
    _textUrl = val;
    notifyListeners();
  }

  LocalizationModelV2? tn;
  double a = 0;
  // void zoom() {
  //   a++;
  //   _alivcLivePusher.setZoom(a);
  //   _alivcLivePusher.setResolution(AlivcLivePushResolution.resolution_1080P);
  //   print(a);
  // }

  Future<void> init(BuildContext context, mounted, {bool forConfig = false}) async {
    dataBanned = null;
    dataStream = LinkStreamModel();
    titleLive = '';
    userName = '';

    print("-------- init stream $forConfig ---------");
    isloading = true;

    isloadingPreview = true;
    notifyListeners();

    // _alivcBase = AlivcBase.init();

    // await _alivcBase.registerSDK();
    // await _alivcBase.setObserver();
    // if (!forConfig) {
    //   await setLiveConfig();
    //   await _setLivePusher();

    //   if (isFirst && mounted) {
    //     isFirst = false;
    //     await init(context, mounted);
    //   }
    //   await _onListen(context, mounted);
    // }

    await checkBeforeLive(context, mounted).then((value) async {
      if (dataBanned != null) {
        // statusLive = StatusStream.banned;
      }
      await initAgora();
    });

    // notifyListeners();

    if (!mounted) return;
    tn = context.read<TranslateNotifierV2>().translate;
  }

  void setDefaultExternalLink(BuildContext context) {
    urlLink = '';
    textUrl = '';
    notifyListeners();
  }

  Future<bool> requestPermission(BuildContext context) async {
    final isGranted = await System().requestPermission(context, permissions: [Permission.camera, Permission.storage, Permission.microphone]);
    if (isGranted) {
      return isGranted;
    } else {
      await System().requestPermission(context, permissions: [Permission.camera, Permission.storage, Permission.microphone]);
      return true;
    }
  }

  void addAnimation(int index) {
    animationIndexes.add(index);
    notifyListeners();
  }

  void removeAnimation(int index) {
    // animationIndexes.remove(index);
    notifyListeners();
    print("=== total ${animationIndexes.length}");
    print("=== skrng ${index} -- ${animationIndexes}");
  }

  Future<void> initAgora() async {
    // retrieve permissions
    // await [Permission.microphone, Permission.camera].request();

    //create the engine
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: UrlConstants.agoraId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    isloading = false;
    notifyListeners();

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onCameraReady: () {
          debugPrint("Camera Ready");
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          localUserJoined = true;
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          remoteUid = remoteUid;
          notifyListeners();
        },
        onLocalVideoStats: (source, stats) {
          debugPrint("onLocalVideo State $source stats $stats 2827318481");
        },
        onRemoteVideoStateChanged: ((connection, remoteUid, state, reason, elapsed) {
          debugPrint("connection $connection, remote user $remoteUid, state ${state.name}, resion $reason, $elapsed");
        }),
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUid = -1;
          statusLive = StatusStream.offline;
          notifyListeners();
        },
      ),
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await engine.enableAudio();
    await engine.enableVideo();
    await engine.startPreview();

    isloading = false;
    isloadingPreview = false;
    notifyListeners();
  }

  Future<void> disposeAgora() async {
    await engine.leaveChannel();
    await engine.release();
  }

  Future<void> startStreamer(BuildContext context, mounted) async {
    statusLive = StatusStream.standBy;
    notifyListeners();

    if (!mounted) return;
    countDown(context, mounted);
  }

  // Future<void> _onListen(BuildContext context, mounted) async {
  //   /// Listener for stream ingest errors
  //   /// Configure the callback for SDK errors.
  //   _alivcBase.setOnLicenceCheck((result, reason) {
  //     if (result != AlivcLiveLicenseCheckResultCode.success) {
  //       print("======== belum ada lisensi $reason ========");
  //     }
  //   });

  //   /// Configure the callback for system errors.
  //   _alivcLivePusher.setOnSDKError((errorCode, errorDescription) {
  //     print("========  setOnSDKError $errorDescription ========");
  //     // Fluttertoast.showToast(
  //     //   msg: AppLocalizations.of(ctx.context)!.camerapush_sdk_error,
  //     //   gravity: ToastGravity.CENTER,
  //     // );
  //   });

  //   /// 系统错误回调
  //   _alivcLivePusher.setOnSystemError((errorCode, errorDescription) {
  //     print("========  setOnSystemError $errorDescription ========");
  //     Fluttertoast.showToast(
  //       msg: 'Camera Stream Error, Please back and stream again',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Listener for the stream ingest status`
  //   /// Configure the callback for preview start.
  //   _alivcLivePusher.setOnPreviewStarted(() {
  //     isloadingPreview = false;
  //     notifyListeners();
  //   });

  //   /// Configure the callback for preview stop.
  //   _alivcLivePusher.setOnPreviewStoped(() {
  //     isloadingPreview = false;
  //     notifyListeners();
  //   });

  //   /// Configure the callback for first frame rendering.
  //   _alivcLivePusher.setOnFirstFramePreviewed(() {
  //     isloadingPreview = false;
  //     notifyListeners();
  //   });

  //   /// Configure the callback for start of stream ingest.
  //   _alivcLivePusher.setOnPushStarted(() {
  //     statusLive = StatusStream.standBy;
  //     notifyListeners();
  //     countDown(context, mounted);
  //   });

  //   /// Configure the callback for pause of stream ingest from the camera.
  //   _alivcLivePusher.setOnPushPaused(() {
  //     isPause = true;
  //     notifyListeners();
  //   });

  //   /// Configure the callback for resume of stream ingest from the camera.
  //   _alivcLivePusher.setOnPushResumed(() {
  //     isPause = false;
  //     notifyListeners();
  //   });

  //   /// Configure the callback for restart of stream ingest.
  //   _alivcLivePusher.setOnPushRestart(() {});

  //   /// Configure the callback for end of stream ingest.
  //   _alivcLivePusher.setOnPushStoped(() {});

  //   /// Listener for the network status during stream ingest
  //   /// Configure the callback for failed connection of stream ingest.
  //   _alivcLivePusher.setOnConnectFail((errorCode, errorDescription) {
  //     "Error Init Live Streaming : $errorDescription".logger();
  //   });

  //   /// Configure the callback for network recovery.
  //   _alivcLivePusher.setOnConnectRecovery(() {});

  //   /// Configure the callback for disconnection.
  //   _alivcLivePusher.setOnConnectionLost(() {
  //     Fluttertoast.showToast(
  //       msg: 'Error no connection lost',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Configure the callback for poor network.
  //   _alivcLivePusher.setOnNetworkPoor(() {
  //     ShowGeneralDialog.showToastAlert(Routing.navigatorKey.currentContext!, 'There was a bad network', () async {});
  //   });

  //   /// Configure the callback for failed reconnection.
  //   _alivcLivePusher.setOnReconnectError((errorCode, errorDescription) {
  //     Fluttertoast.showToast(
  //       msg: 'Failed Reconnection',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Configure the callback for reconnection start.
  //   _alivcLivePusher.setOnReconnectStart(() {
  //     Fluttertoast.showToast(
  //       msg: 'Reconnection start',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Configure the callback for successful reconnection.
  //   _alivcLivePusher.setOnReconnectSuccess(() {
  //     Fluttertoast.showToast(
  //       msg: 'Successful reconnection',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Send data timeout
  //   _alivcLivePusher.setOnSendDataTimeout(() {
  //     Fluttertoast.showToast(
  //       msg: 'Send data timeout',
  //       gravity: ToastGravity.CENTER,
  //     );
  //   });

  //   /// Configure the callback for complete playback of background music.
  //   _alivcLivePusher.setOnBGMCompleted(() {});

  //   /// Configure the callback for timeout of the download of background music.
  //   _alivcLivePusher.setOnBGMDownloadTimeout(() {});

  //   /// Configure the callback for failed playback of background music.
  //   _alivcLivePusher.setOnBGMOpenFailed(() {});

  //   /// Configure the callback for paused playback of background music.
  //   _alivcLivePusher.setOnBGMPaused(() {});

  //   /// Configure the callback for playback progress.
  //   _alivcLivePusher.setOnBGMProgress((progress, duration) {
  //     // ctx.dispatch(CameraPushActionCreator.onUpdateBGMProgress(progress));
  //     // ctx.dispatch(CameraPushActionCreator.onUpdateBGMDuration(duration));
  //   });

  //   /// Configure the callback for resumed playback of background music.
  //   _alivcLivePusher.setOnBGMResumed(() {
  //     // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_resume_log));
  //   });

  //   /// Configure the callback for start of playback of background music.
  //   _alivcLivePusher.setOnBGMStarted(() {
  //     // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_start_log));
  //   });

  //   /// Configure the callback for stop of playback of background music.
  //   _alivcLivePusher.setOnBGMStoped(() {
  //     // ctx.dispatch(CameraPushActionCreator.updatePushStatusTip(AppLocalizations.of(ctx.context)!.camerapush_bgm_stop_log));
  //     // ctx.dispatch(CameraPushActionCreator.onUpdateBGMProgress(0));
  //     // ctx.dispatch(CameraPushActionCreator.onUpdateBGMDuration(0));
  //   });

  //   /// Configure callbacks related to snapshot capture.
  //   _alivcLivePusher.setOnSnapshot((saveResult, savePath, {dirTypeForIOS}) {
  //     // if (saveResult == true) {
  //     //   String tip = AppLocalizations.of(ctx.context)!.camerapush_snapshot_tip;
  //     //   if (Platform.isIOS) {
  //     //     DirType saveDirType = DirType.document;
  //     //     if (dirTypeForIOS == AlivcLiveSnapshotDirType.document) {
  //     //       saveDirType = DirType.document;
  //     //     } else {
  //     //       saveDirType = DirType.library;
  //     //     }
  //     //     CommomUtils.getSaveDir(saveDirType, savePath).then((value) {
  //     //       Fluttertoast.showToast(msg: tip + value.path, gravity: ToastGravity.CENTER);
  //     //     });
  //     //   } else {
  //     //     Fluttertoast.showToast(msg: tip + savePath, gravity: ToastGravity.CENTER);
  //     //   }
  //     // }
  //   });
  // }

  // Future<void> setLiveConfig() async {
  //   AlivcLivePusherConfig pusherConfig = AlivcLivePusherConfig.init();
  //   pusherConfig.setCameraType(AlivcLivePushCameraType.front);

  //   /// Set the resolution to 540p.
  //   pusherConfig.setResolution(AlivcLivePushResolution.resolution_480P);

  //   /// Specify the frame rate. We recommend that you set the frame rate to 20 frames per second (FPS).
  //   pusherConfig.setFps(AlivcLivePushFPS.fps_20);

  //   /// Enable adaptive bitrate streaming. The default value is true.
  //   pusherConfig.setEnableAutoBitrate(true);

  //   /// Specify the group of pictures (GOP) size. A larger value indicates a higher latency. We recommend that you set the value to a number from 1 to 2.
  //   pusherConfig.setVideoEncodeGop(AlivcLivePushVideoEncodeGOP.gop_2);

  //   /// Specify the reconnection duration. The value cannot be less than 1000. Unit: milliseconds. We recommend that you use the default value.
  //   pusherConfig.setConnectRetryInterval(2000);

  //   /// Disable the mirroring mode for preview.
  //   pusherConfig.setPreviewMirror(false);

  //   pusherConfig.setPushMirror(true);

  //   /// Set the stream ingest orientation to portrait.
  //   pusherConfig.setOrientation(AlivcLivePushOrientation.portrait);

  //   pusherConfig.setPreviewDisplayMode(AlivcPusherPreviewDisplayMode.preview_aspect_fill);
  //   pusherConfig.setQualityMode(AlivcLivePushQualityMode.resolution_first);
  // }

  // Future<void> _setLivePusher() async {
  //   _alivcLivePusher = AlivcLivePusher.init();
  //   _alivcLivePusher.initLivePusher();
  //   _alivcLivePusher.createConfig();
  //   _alivcLivePusher.setErrorDelegate();
  //   _alivcLivePusher.setInfoDelegate();
  //   _alivcLivePusher.setNetworkDelegate();
  //   _alivcLivePusher.setCustomFilterDelegate();
  //   _alivcLivePusher.setCustomDetectorDelegate();
  //   _alivcLivePusher.setBGMDelegate();
  //   _alivcLivePusher.setResolution(AlivcLivePushResolution.resolution_540P);
  // }

  // Future<void> _clickSnapShot() async {
  //   if (Platform.isIOS) {
  //     /// dir parameter: On iOS, the path is a relative path. A custom directory is automatically generated in the system sandbox. If you set this parameter to "", snapshots are stored in the root directory of the system sandbox.
  //     /// dirTypeForIOS parameter: Optional. If you do not specify this parameter, snapshots are stored in the [document] directory of the system sandbox.
  //     _alivcLivePusher.snapshot(1, 0, "snapshot", dirTypeForIOS: AlivcLiveSnapshotDirType.document);
  //   } else {
  //     // CommomUtils.getSystemPath(DirType.externalFile).then((value) {
  //     //   _alivcLivePusher.snapshot(1, 0, value);
  //     // });
  //   }

  //   /// Set the listener for snapshot capture.
  //   _alivcLivePusher.setSnapshotDelegate();
  // }

  // Future<void> previewCreated() async {
  //   _alivcLivePusher.startPreview().then((value) {
  //     print("===== start preview ====");
  //   });
  //   // _beautyManager.setupBeauty();
  //   // ctx.dispatch(CameraPushActionCreator.onClickPreview(CameraPushPagePreviewState.startPreview));
  // }

//   rtmp://ingest.hyppe.cloud/Hyppe/hdstream?auth_key=1700732018-0-0-580e7fb4d21585a87315470a335513c1

// Stream URL (download stream dari user yang nnton)
// rtmp://live.hyppe.cloud/Hyppe/hdstream_hd-v?auth_key=1700732018-0-0-8e221f09856a236e9f2454e8dfddfae1

  Future<void> clickPushAction(BuildContext context, mounted) async {
    pinComment = null;
    isCancel = false;
    timeReady = 3;
    userName = context.read<SelfProfileNotifier>().user.profile?.username ?? '';
    dateTimeStart = DateTime.now();
    // if (titleLive == '') {
    //   titleLive = context.read<SelfProfileNotifier>().user.profile?.fullName ?? '';
    // }
    statusLive = StatusStream.prepare;
    notifyListeners();
    var init = await initLiveStream(context, mounted);
    if (init) {
      Future.delayed(const Duration(seconds: 1));

      // _alivcLivePusher.startPushWithURL(dataStream.urlIngest ?? '');
      if (!mounted) return;
      await startStreamer(context, mounted);

      if (_socketService.isRunning) {
        _socketService.closeSocket(eventComment);
        _socketService.closeSocket(eventLikeStream);
        _socketService.closeSocket(eventViewStream);
        _socketService.closeSocket(eventStatusStream);
      }
      _connectAndListenToSocket(eventComment);
      _connectAndListenToSocket(eventLikeStream);
      _connectAndListenToSocket(eventViewStream);
      _connectAndListenToSocket(eventStatusStream);

      // _alivcLivePusher.startPushWithURL(pushURL);
    } else {
      statusLive = StatusStream.offline;
      notifyListeners();
    }
  }

  Future<void> destoryPusher() async {
    _socketService.closeSocket(eventComment);
    _socketService.closeSocket(eventLikeStream);
    _socketService.closeSocket(eventViewStream);
    _socketService.closeSocket(eventStatusStream);
    // _alivcLivePusher.stopPush();
    // _alivcLivePusher.stopPreview();
    // _alivcLivePusher.destroy();
    disposeAgora();

    WakelockPlus.disable();
    statusLive = StatusStream.offline;
    livePushMode = 0;
    timeReady = 3;
    totLikes = 0;
    totViews = 0;
    totPause = 0;
    pageViewers = 0;
    rowViewers = 10;
    isloadingPreview = true;
    isloading = false;
    isloadingViewers = false;
    isloadingViewersMore = false;
    isloadingProfile = false;
    isloadingProfileViewer = false;
    isCheckLoading = false;
    mute = false;
    isPause = false;
    isCommentDisable = false;
    flipCameraVisible = true;
    titleLiveCtrl.clear();
    urlLink = '';
    textUrl = '';
    userName = '';
    _titleLive = '';
    statusLive = StatusStream.offline;
    _items = [];
    dataViewers = [];
    comment = [];
    animationIndexes = [];

    commentCtrl.clear();
    inactivityTimer?.cancel();
    inactivityTimer = null;
  }

  //Comment Empty or Witespase
  void sendComment() {
    isSendComment = commentCtrl.text.trim().isNotEmpty;
    notifyListeners();
  }

  void flipCamera() {
    engine.switchCamera();
    // _alivcLivePusher.switchCamera();
  }

  void countDown(BuildContext context, mounted) async {
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      timeReady--;
      notifyListeners();
      if (timeReady > 0) {
        countDown(context, mounted);
      } else {
        if (!isCancel) {
          statusLive = StatusStream.ready;
          notifyListeners();

          print('===TempToken $tempToken');
          print('===Channel $channel');
          // Agora
          await engine.joinChannel(
            token: tempToken ?? '',
            channelId: channel ?? '',
            uid: 0,
            options: const ChannelMediaOptions(),
          );

          Future.delayed(const Duration(seconds: 2), () {
            statusLive = StatusStream.online;
            initTimer(context, mounted);
            notifyListeners();
          });
        }
      }
    });
  }

  // Future<void> pauseStreamer() async {
  //   await engine.stopPreview();
  //   engine.muteLocalVideoStream(true);
  //   engine.muteLocalAudioStream(true);
  //   mute = true;
  //   flipCameraVisible = false;
  //   notifyListeners();
  // }

  Future<void> resumeStreamer(BuildContext context) async {
    pauseSendStatus(context);
    engine.startPreview();
    engine.muteLocalVideoStream(false);
    engine.muteLocalAudioStream(false);
    mute = false;
    flipCameraVisible = true;
    isPause = false;

    notifyListeners();
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
              child: const Material(color: Colors.transparent, child: Icon(Icons.heart_broken)),
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
    engine.muteLocalAudioStream(mute);
    // _alivcLivePusher.setMute(mute);
    debugPrint(mute.toString());
    notifyListeners();
  }

  DateTime? timePause;
  Future<void> pauseLive(BuildContext context, mounted) async {
    var pause = await pauseSendStatus(context);
    if (pause) {
      mute = true;
      flipCameraVisible = false;
      await engine.stopPreview();
      engine.muteLocalVideoStream(mute);
      engine.muteLocalAudioStream(mute);
      totPause++;
      isPause = true;
      timePause = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> resumeLive(BuildContext context) async {
    isloadingButton = true;
    notifyListeners();
    var pause = await pauseSendStatus(context);

    if (pause) {
      mute = false;
      flipCameraVisible = true;
      engine.startPreview();
      engine.muteLocalVideoStream(mute);
      engine.muteLocalAudioStream(mute);
      // _alivcLivePusher.resume();
      // _alivcLivePusher.setMute(false);
      isPause = false;
    }
    isloadingButton = false;
    notifyListeners();
  }

  Future<void> cancelLive(BuildContext context, mounted) async {
    isCancel = true;
    statusLive = StatusStream.offline;
    // _alivcLivePusher.stopPush();
    // engine.release();
    inactivityTimer?.cancel();
    stopStream(context, mounted);
  }

  int x = 0;
  void addCommentDummy() {
    // comment.insert(0, 'hahaha ${x++}');
    notifyListeners();
  }

  Future endLive(BuildContext context, mounted, {bool isBack = true, bool blockLive = false}) async {
    if (isBack) Routing().moveBack();
    var dateTimeFinish = DateTime.now();
    Duration duration = dateTimeFinish.difference(dateTimeStart);
    await destoryPusher();
    if (!mounted) return;
    await stopStream(context, mounted);
    Routing().moveReplacement(Routes.streamingFeedback, argument: SummaryLiveArgument(duration: duration, data: dataSummary, blockLive: blockLive));
  }

  int secondsEnd = 0;

  void initTimer(BuildContext context, mounted) async {
    // adding delay to prevent if there's another that not disposed yet
    Future.delayed(const Duration(milliseconds: 1000), () {
      WakelockPlus.enable();

      if (inactivityTimer != null) inactivityTimer?.cancel();
      inactivityTimer = Timer(const Duration(seconds: 3300), () {
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
        secondsEnd = 300;
        inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (secondsEnd <= 0) {
            inactivityTimer?.cancel();
            secondsEnd = 0;
            endLive(context, mounted, isBack: false);
          } else {
            secondsEnd--;
            notifyListeners();
          }
        });
        // inactivityTimer = Timer(const Duration(seconds: 300), () {
        //   endLive(context, mounted, isBack: false);
        // });
      });
    });
  }

  Future pauseSendStatus(BuildContext context) async {
    print("hahahahah -------==== = = =");
    bool returnNext = false;
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"_id": dataStream.sId, "type": "PAUSE"};

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
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
          pauseSendStatus(context);
        });
      }
    }
    return returnNext;
  }

  Future stopStream(BuildContext context, mounted) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"_id": dataStream.sId, "type": "STOP"};

        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          dataSummary = LiveSummaryModel.fromJson(fetch.data);
          notifyListeners();
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      // returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          initLiveStream(context, mounted);
        });
      }
    }
    // return returnNext;
  }

  Future kickUser(BuildContext context, bool mounted, String userId, String username) async {
    Map data = {"_id": dataStream.sId, "userId": userId, "type": "KICK"};
    await updateStream(context, mounted, data).then((value) {
      if (value == 'Update stream succesfully') {
        Routing().moveBack();
        // if (context.mounted) {
        tn = context.read<TranslateNotifierV2>().translate;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
            backgroundColor: kHyppeTextLightPrimary,
            content: Row(
              children: [
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}info-icon.svg",
                  defaultColor: false,
                  color: Colors.white,
                ),
                sixPx,
                Text("${tn?.infoKick1} $username ${tn?.infoKick2}", style: const TextStyle(color: Colors.white)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // }
      }
    });
  }

  Future updateStream(BuildContext context, mounted, Map data) async {
    var dataReturn;
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        print(data);
        final notifier = LiveStreamBloc();

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          dataReturn = fetch.data;
          dataReturn ??= 'Update stream succesfully';
          notifyListeners();
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      // returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          initLiveStream(context, mounted);
        });
      }
    }
    return dataReturn;
  }

  Future initLiveStream(BuildContext context, mounted) async {
    bool returnNext = false;
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'title': titleLive, 'url': urlLink, 'textUrl': textUrl};

        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.getLinkStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          if (fetch.statusStream) {
            dataStream = LinkStreamModel.fromJson(fetch.data);
            print('======= fetch.data');
            tempToken = dataStream.token;
            channel = dataStream.sId ?? '';
            returnNext = true;
          } else {
            returnNext = false;
          }
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
          Fluttertoast.showToast(msg: 'Please try again letter');
          initLiveStream(context, mounted);
        });
      }
    }
    return returnNext;
  }

  Future disableComment(BuildContext context, mounted) async {
    pinComment = null;
    comment = [];
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
          disableComment(context, mounted);
        });
      }
    }
  }

  Future getViewer(BuildContext context, mounted, {String? idStream, bool end = false, bool isMore = false}) async {
    if (pageViewers == 0) isloadingViewers = true;
    notifyListeners();
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        if (!isMore) {
          pageViewers = 0;
          dataViewers = [];
          notifyListeners();
        }

        Map data = {
          "_id": idStream ?? dataStream.sId,
          "page": pageViewers,
          "limit": rowViewers,
        };
        if (end == true) {
          data['type'] = "END";
        }
        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.viewrStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          fetch.data.forEach((v) => dataViewers.add(ViewersLiveModel.fromJson(v)));
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
    isloadingViewers = false;
    notifyListeners();
  }

  Future getMoreViewer(BuildContext context, mounted, idStream, ScrollController scrollController) async {
    if (!isloadingViewers && scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      isloadingViewersMore = true;
      notifyListeners();
      pageViewers++;
      await getViewer(context, mounted, idStream: idStream, isMore: true);
      isloadingViewersMore = false;
      notifyListeners();
    }
  }

  Future getProfileNCheck(BuildContext context, String email) async {
    isloadingProfile = true;
    notifyListeners();
    statusFollowing = StatusFollowing.none;
    await getProfile(context, email, withCheckFollow: false);
    isloadingProfile = false;
    notifyListeners();
  }

  Future getProfileNCheckViewer(BuildContext context, String email) async {
    int totLoading = 0;
    isloadingProfileViewer = true;
    // statusFollowingViewer = StatusFollowing.none;
    await checkFollowingToUserViewer(context, email).then((value) => totLoading++);
    await getProfileViewer(context, email).then((value) => totLoading++);
    isloadingProfileViewer = false;
    notifyListeners();
  }

  Future getProfile(BuildContext context, String email, {bool withCheckFollow = true}) async {
    final usersNotifier = UserBloc();
    print("========== withCheckFollow $withCheckFollow");
    if (withCheckFollow) {
      checkFollowingToUser(context, email);
    }

    await usersNotifier.getUserProfilesBloc(context, search: email, withAlertMessage: true);

    final usersFetch = usersNotifier.userFetch;

    if (usersFetch.userState == UserState.getUserProfilesSuccess) {
      audienceProfile = usersFetch.data;
      if (audienceProfile.following ?? false) {
        statusFollowing = StatusFollowing.following;
      } else {
        statusFollowing = StatusFollowing.none;
      }
    }
  }

  Future getProfileViewer(BuildContext context, String email) async {
    final usersNotifier = UserBloc();
    checkFollowingToUser(context, email);
    await usersNotifier.getUserProfilesBloc(context, search: email, withAlertMessage: true);

    final usersFetch = usersNotifier.userFetch;

    if (usersFetch.userState == UserState.getUserProfilesSuccess) {
      audienceProfileViewer = usersFetch.data;
    }
  }

  Future<bool> checkFollowingToUser(BuildContext context, String email) async {
    try {
      _usersFollowingQuery.senderOrReceiver = email;
      _usersFollowingQuery.limit = 200;
      print('reload contentsQuery : 11');
      final resFuture = _usersFollowingQuery.reload(context);
      final resRequest = await resFuture;

      if (resRequest.isNotEmpty) {
        if (resRequest.any((element) => element.event == InteractiveEvent.accept)) {
          statusFollowing = StatusFollowing.following;
        } else if (resRequest.any((element) => element.event == InteractiveEvent.initial)) {
          statusFollowing = StatusFollowing.requested;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      'load following request list: ERROR: $e'.logger();
      return false;
    }
  }

  Future<void> checkFollowingToUserViewer(BuildContext context, String email) async {
    try {
      _usersFollowingQuery.senderOrReceiver = email;
      _usersFollowingQuery.limit = 200;
      print('reload contentsQuery : 11');
      final resFuture = await _usersFollowingQuery.reload(context);
      final resRequest = resFuture;
      if (resRequest.isNotEmpty) {
        if (resRequest.any((element) => element.event == InteractiveEvent.accept)) {
          statusFollowingViewer = StatusFollowing.following;
          notifyListeners();
        } else if (resRequest.any((element) => element.event == InteractiveEvent.initial)) {
          statusFollowingViewer = StatusFollowing.requested;
          notifyListeners();
        }
      } else {
        statusFollowingViewer = StatusFollowing.none;
      }
    } catch (e) {
      'load following request list: ERROR: $e'.logger();
    }
    notifyListeners();
  }

  Future followUser(BuildContext context, email, {isUnFollow = false, String? idMediaStreaming}) async {
    try {
      // _system.actionReqiredIdCard(
      //   context,
      //   action: () async {
      // statusFollowing = StatusFollowing.requested;
      isCheckLoading = true;
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: email ?? '',
          eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
          idMediaStreaming: idMediaStreaming,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        if (isUnFollow) {
          statusFollowing = StatusFollowing.none;
        } else {
          statusFollowing = StatusFollowing.following;
        }
      } else if (statusFollowing != StatusFollowing.none && statusFollowing != StatusFollowing.following) {
        statusFollowing = StatusFollowing.none;
      }
      // else {
      //   statusFollowing = StatusFollowing.none;
      // }
      //   },
      //   uploadContentAction: false,
      // );
      isCheckLoading = false;
      notifyListeners();
    } catch (e) {
      'followUser error: $e'.logger();
      // statusFollowing = StatusFollowing.none;
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    }
  }

  Future followUserViewer(BuildContext context, email, {isUnFollow = false, String? idMediaStreaming}) async {
    try {
      // _system.actionReqiredIdCard(
      //   context,
      //   action: () async {
      // statusFollowingViewer = StatusFollowing.requested;
      isCheckLoading = true;
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: email ?? '',
          eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
          idMediaStreaming: idMediaStreaming,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        if (isUnFollow) {
          statusFollowingViewer = StatusFollowing.none;
        } else {
          statusFollowingViewer = StatusFollowing.following;
        }
      } else if (statusFollowingViewer != StatusFollowing.none && statusFollowingViewer != StatusFollowing.following) {
        statusFollowingViewer = StatusFollowing.none;
      }
      // else {
      //   statusFollowingViewer = StatusFollowing.none;
      // }
      //   },
      //   uploadContentAction: false,
      // );
      isCheckLoading = false;
      notifyListeners();
    } catch (e) {
      'followUser error: $e'.logger();
      // statusFollowingViewer = StatusFollowing.none;
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    }
  }

  Future sendMessage(BuildContext context, mounted) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();

        Map data = {"_id": dataStream.sId, "messages": commentCtrl.text, "type": "COMMENT", "commentType": "MESSAGGES"};
        commentCtrl.clear();
        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          notifyListeners();
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
    isloadingViewers = false;
    notifyListeners();
  }

  Future sendScoreLive(BuildContext context, mounted, {String? desc, int? score}) async {
    isloading = true;
    notifyListeners();
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "_id": dataStream.sId,
          "feedBack": score, //1,2,3
          "feedbackText": desc
        };
        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.feedbackStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          isloading = false;

          notifyListeners();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          initLiveStream(context, mounted);
        });
      }
    }
    isloading = false;
    notifyListeners();
  }

  void _connectAndListenToSocket(String events) async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);

    _socketService.connectToSocket(
      () {
        _socketService.events(
          events,
          (message) {
            try {
              handleSocket(message, events);
              print('ini message dari stremaer socket $events ----- ${message}');
            } catch (e) {
              e.toString().logger();
            }
          },
        );
      },
      host: Env.data.baseUrlSocket,
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

  void handleSocket(message, event) async {
    if (event == eventComment) {
      var messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        if (messages.commentType == 'MESSAGGES' || messages.commentType == 'JOIN') {
          comment.insert(0, messages);
        } else if (messages.commentType == 'GIFT') {
          if (messages.urlGift != null) {
            print("=====ada json");
            if (giftDelux.isEmpty) {
              // messages.urlGift = 'https://be-staging.oss-ap-southeast-5.aliyuncs.com/images/gift/66471897d975922b87c91578_3d.json';
              giftDelux.add(messages);
            } else {
              giftDeluxTemp.add(messages);
            }
            if (timerDeluxe?.isActive ?? false) {
            } else {
              startTimerDelux();
            }
          } else {
            if (giftBasic.length <= 2) {
              giftBasic.add(messages);
            } else {
              giftBasicTemp.add(messages);
            }
            if (timerBasic?.isActive ?? false) {
            } else {
              startTimerBasic();
            }
          }
        }
      }
    } else if (event == eventLikeStream) {
      var messages = CountLikeLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        // totLikes += messages.likeCount ?? 0;
        totLikes = messages.likeCountTotal ?? 0;
        // for (var i = 0; i < (messages.likeCount ?? 0); i++) {
        var run = getRandomDouble(1, 999999999999999);
        animationIndexes.add(run.toInt());

        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 700));
        // }
      }
    } else if (event == eventViewStream) {
      var messages = CountViewLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        totViews = messages.viewCount ?? 0;
      }
    } else if (event == eventStatusStream) {
      var data = json.decode('$message');
      if (data['data']['idStream'] == dataStream.sId && data['data']['status'] == false) {
        dataStream.status = false;
        timeCountdownReported = Duration(seconds: data['data']['countdown'] ?? 30);
        dataBanned = BannedStreamModel(
          streamBannedDate: data['data']['datePelanggaran'],
          streamBannedMax: data['data']['totalPelanggaran'],
          statusBanned: data['data']['statusBanned'],
          streamId: dataStream.sId,
        );
      }
    }
    notifyListeners();
  }

  double getRandomDouble(double min, double max) {
    // Membuat instance dari kelas Random
    final random = math.Random();

    // Menghasilkan angka acak antara min dan max
    // dengan presisi 4 digit di belakang koma
    double randomValue = min + random.nextDouble() * (max - min);

    // Membulatkan angka menjadi 4 digit di belakang koma
    randomValue = double.parse(randomValue.toStringAsFixed(4));

    return randomValue;
  }

  bool urlFalse = true;
  void urlValidation(String url) {
    if (Uri.tryParse(url)?.hasAbsolutePath ?? false) {
      urlFalse = true;
    } else {
      urlFalse = false;
    }
    notifyListeners();
  }

  void insertPinComment(BuildContext context, bool mounted, CommentLiveModel data) async {
    if (pinComment != null) {
      comment.insert(0, pinComment ?? CommentLiveModel());
    }
    pinComment = data;
    comment.removeWhere((element) => element.idComment == data.idComment);
    Map param = {
      "_id": dataStream.sId,
      "idComment": data.idComment,
      "pinned": true, //true/false
      "type": "COMMENT_PINNED"
    };
    updateStream(context, mounted, param).then((value) {});
    notifyListeners();
  }

  Future removePinComment(BuildContext context, bool mounted) async {
    comment.insert(0, pinComment ?? CommentLiveModel());
    Map param = {
      "_id": dataStream.sId,
      "idComment": pinComment?.idComment,
      "pinned": false, //true/false
      "type": "COMMENT_PINNED"
    };
    updateStream(context, mounted, param).then((value) {});
    pinComment = null;
    notifyListeners();
  }

  void removeComment(BuildContext context, bool mounted, String idComment) async {
    Map param = {"_id": dataStream.sId, "idComment": idComment, "type": "COMMENT_DELETE"};
    updateStream(context, mounted, param).then((value) {});
    comment.removeWhere((element) => element.idComment == idComment);
    notifyListeners();
    Routing().moveBack();
  }

  Future deletePinComment(BuildContext context, bool mounted) async {
    Map param = {
      "_id": dataStream.sId,
      "idComment": pinComment?.idComment,
      "pinned": false, //true/false
      "type": "COMMENT_PINNED"
    };
    await updateStream(context, mounted, param).then((value) {});
    Map param2 = {"_id": dataStream.sId, "idComment": pinComment?.idComment, "type": "COMMENT_DELETE"};
    // ignore: use_build_context_synchronously
    updateStream(context, mounted, param2).then((value) {});
    pinComment = null;
    notifyListeners();
    Routing().moveBack();
  }

  void sendGift(BuildContext context, bool mounted, String idGift, String urlGiftThumb, String title, {String? urlGift, String? idViewStream}) async {
    Map param = {
      "_id": dataStream.sId,
      "commentType": "GIFT",
      "type": "COMMENT",
      "idGift": idGift,
      "urlGiftThum": urlGiftThumb,
      "messages": title,
    };

    if (idViewStream != null) param['_id'] = idViewStream;

    if (urlGift != null) param['urlGift'] = urlGift;
    updateStream(context, mounted, param).then((value) {});
    Routing().moveBack();
  }

  Future getUserShare(BuildContext context, bool mounted, {bool isLoadmore = false}) async {
    if (!isLoadmore) {
      pageNumberUserShare = 0;
      isloadingUserShare = true;
    }

    notifyListeners();
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "pageNumber": pageNumberUserShare,
          "pageRow": limitNumberUserShare,
        };

        if (searchUserCtrl.text != '') {
          pageNumberUserShare = 0;
          data["username"] = searchUserCtrl.text;
          data["pageNumber"] = pageNumberUserShare;
        }

        if (mounted) await notifier.getLinkStream(context, data, UrlConstants.userShare);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          if (!isLoadmore) listShareUser = [];
          fetch.data.forEach((v) => listShareUser.add(SearchPeolpleData.fromJson(v)));
          if (shareUsers.isNotEmpty) {
            for (var e in listShareUser) {
              for (var f in shareUsers) {
                if (e.username == f.username) {
                  e.isSelected = true;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
        });
      }
    }
    isloadingUserShare = false;
    notifyListeners();
  }

  void loadMore(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      print('kebawah');
      pageNumberUserShare++;
      notifyListeners();
      await getUserShare(context, context.mounted, isLoadmore: true);
      notifyListeners();
    }
  }

  insertListShare(SearchPeolpleData data) {
    shareUsers.add(data);
    notifyListeners();
  }

  removeListShare(SearchPeolpleData data) {
    shareUsers.removeWhere((element) => element.username == data.username);
    notifyListeners();
  }

  //send share DM DIRECT MESSAGE
  Future sendShareMassage(BuildContext context, {bool isViewer = false}) async {
    Routing().moveBack();

    var message = messageShareCtrl.text;

    if (message == '') {
      var profile = context.read<SelfProfileNotifier>().user.profile;
      var translate = context.read<TranslateNotifierV2>().translate;
      message = '@${profile?.username} ${translate.localeDatetime == 'id' ? 'mengirim kamu LIVE' : 'send you a LIVE'}';
    }

    var idStream = isViewer ? context.read<ViewStreamingNotifier>().dataStreaming.sId : dataStream.sId;

    for (var i = 0; i < shareUsers.length; i++) {
      sendMessageDirect(context, idStream ?? '', shareUsers[i].email ?? '', isViewer, message);
    }
    shareCount(context, true, idStream ?? '', shareUsers.length);

    ScaffoldMessengerState().hideCurrentSnackBar();
    messageShareCtrl.clear();
    // if (context.mounted) {
    tn = context.read<TranslateNotifierV2>().translate;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
      backgroundColor: kHyppeTextLightPrimary,
      content: Text(tn?.sentSuccessfully ?? '', style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
    ));
    // }
  }

  Future sendMessageDirect(BuildContext context, String idStream, String recipientEmail, bool isViewer, String message) async {
    // if (messageShareCtrl.text.trim().isEmpty) return;

    try {
      final emailSender = SharedPreference().readStorage(SpKeys.email);

      final param = DiscussArgument(
        email: emailSender,
        receiverParty: recipientEmail,
      )
        ..txtMessages = message
        ..streamID = idStream;

      final notifier = MessageBlocV2();
      await notifier.createDiscussionBloc(context, disqusArgument: param);

      final fetch = notifier.messageFetch;

      if (fetch.chatState == MessageState.createDiscussionBlocSuccess) {}
      if (fetch.chatState == MessageState.createDiscussionBlocError) {}
    } catch (e) {
      e.toString().logger();
    }
  }

  Future createLinkStream(
    BuildContext context, {
    required bool copiedToClipboard,
    required String description,
  }) async {
    var profile = context.read<SelfProfileNotifier>().user.profile;

    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.viewStreaming,
        postID: dataStream.sId,
        fullName: "",
        description: '${profile?.fullName ?? profile?.username} (${profile?.username}) \n is LIVE ${dataStream.title}',
        // thumb: System().showUserPicture(profileImage),
        thumb: System().showUserPicture(profile?.avatar?.mediaEndpoint),
      ),
      copiedToClipboard: copiedToClipboard,
      afterShare: () {
        if (!copiedToClipboard) {
          shareCount(context, true, dataStream.sId ?? '', 1);
        }
      },
    ).then((value) {
      if (value) {
        if (copiedToClipboard && context.mounted) {
          shareCount(context, true, dataStream.sId ?? '', 1);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            margin: EdgeInsets.only(bottom: 60, left: 16, right: 16),
            backgroundColor: kHyppeTextLightPrimary,
            content: Text('Link Copied', style: TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    });
  }

  Timer? timerBasic;

  void startTimerBasic() {
    timerBasic = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (giftBasic.isNotEmpty) {
        comment.insert(0, giftBasic[0]);
        giftBasic.removeAt(0);
        if (giftBasicTemp.isNotEmpty && giftBasic.length <= 2) {
          giftBasic.add(giftBasicTemp[0]);
          giftBasicTemp.removeAt(0);
        }

        notifyListeners();
      } else {
        timerBasic?.cancel();
      }
    });
  }

  Timer? timerDeluxe;
  void startTimerDelux() {
    timerDeluxe = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (giftDelux.isNotEmpty) {
        comment.insert(0, giftDelux[0]); //masukin ke comment
        giftDelux.removeAt(0); //hapus gift deluxe
        if (giftDeluxTemp.isNotEmpty) {
          giftDelux.add(giftDeluxTemp[0]);
          giftDeluxTemp.removeAt(0);
        }

        notifyListeners();
      } else {
        timerDeluxe?.cancel();
      }
    });
  }

  Future getListGift(BuildContext context, mounted) async {
    dataUserGift = [];
    if (pageViewers == 0) isloadingViewers = true;
    notifyListeners();
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "_id": dataStream.sId,
        };

        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.listGift);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          fetch.data.forEach((v) => dataUserGift.add(ListGiftModel.fromJson(v)));
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
    isloadingViewers = false;
    notifyListeners();
  }

  Future checkBeforeLive(BuildContext context, mounted) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();

        if (mounted) {
          await notifier.getStream(context, UrlConstants.checkStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          print('====---=== status ${fetch.statusStream}');
          if (fetch.statusStream == false) {
            statusLive = StatusStream.banned;
            dataBanned = BannedStreamModel.fromJson(fetch.data);
          }
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
    isloadingViewers = false;
    notifyListeners();
  }

  Future shareCount(BuildContext context, bool mounted, String id, int total) async {
    Map data = {"_id": id, "shareCount": total, "type": "SHARE"};
    updateStream(context, mounted, data).then((value) {});
  }
}
