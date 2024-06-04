import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/live_stream/gift_live_model.dart';
import 'package:hyppe/core/models/collection/live_stream/streaming_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/services/socket_live_service.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/respon_allready_report.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../../../core/bloc/live_stream/bloc.dart';
import '../../../../../../core/bloc/live_stream/state.dart';
import '../../../../../../core/config/env.dart';
import '../../../../../../core/config/url_constants.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/models/collection/live_stream/comment_live_model.dart';
import '../../../../../../core/models/collection/live_stream/link_stream_model.dart';
import '../../../../../../core/models/collection/live_stream/viewers_live_model.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../../../../core/response/generic_response.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'dart:math' as math;
import 'widget/already_reported.dart';
import 'widget/report_live.dart';
import 'widget/respon_report_live.dart';

class ViewStreamingNotifier with ChangeNotifier, GeneralMixin {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final _socketService = SocketLiveService();

  final commentController = TextEditingController();

  static const String eventComment = 'COMMENT_STREAM_SINGLE';
  static const String eventViewStream = 'VIEW_STREAM';
  static const String eventLikeStream = 'LIKE_STREAM';
  static const String eventCommentDisable = 'COMMENT_STREAM_DISABLED';
  static const String eventStatusStream = 'STATUS_STREAM';
  static const String eventKickUser = 'KICK_USER_STREAM';
  static const String eventCommentPin = 'COMMENT_PINNED_STREAM_SINGLE';
  static const String eventCommentDelete = 'COMMENT_DELETE_STREAM_SINGLE';

  String userName = '';
  String? _currentUserId = SharedPreference().readStorage(SpKeys.userID);
  String get currentUserId => _currentUserId ?? '';

  StreamingModel dataStreaming = StreamingModel();
  CommentLiveModel? pinComment;

  ///Status => Offline - Prepare - StandBy - Ready - Online
  StatusStream statusLive = StatusStream.offline;
  GiftLiveModel? giftSelect;

  List<CommentLiveModel> giftBasic = [];
  List<CommentLiveModel> giftBasicTemp = [];
  List<CommentLiveModel> giftDelux = [];
  List<CommentLiveModel> giftDeluxTemp = [];
  List<GiftLiveModel> dataGift = [];
  List<GiftLiveModel> dataGiftDeluxe = [];

  List<ViewersLiveModel> dataViewers = [];
  List<CommentLiveModel> comment = [];
  List<int> animationIndexes = [];

  int totLikes = 0;
  int totViews = 0;
  int totViewsEnd = 0;

  Offset positionDxDy = Offset(0, 0);

  bool endLive = false;
  bool isloadingGift = false;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool state) {
    _loading = state;
    notifyListeners();
  }

  bool _loadMore = false;
  bool get loadMore => _loadMore;
  set loadMore(bool state) {
    _loadMore = state;
    notifyListeners();
  }

  bool _isCommentDisable = false;
  bool get isCommentDisable => _isCommentDisable;
  set isCommentDisable(bool state) {
    _isCommentDisable = state;
    notifyListeners();
  }

  bool _isClicked = false;
  bool get isClicked => _isClicked;
  set isClicked(bool state) {
    _isClicked = state;
    notifyListeners();
  }

  List<LinkStreamModel> _listStreamers = [];
  List<LinkStreamModel> get listStreamers => _listStreamers;
  set listStreamers(List<LinkStreamModel> data) {
    _listStreamers = data;
    notifyListeners();
  }

  LinkStreamModel? streamerData;

  initListStreamers() {
    _loading = true;
    _listStreamers = [];
    _page = 0;
    stopLoad = false;
    _loadMore = false;
  }

  initViewStreaming(LinkStreamModel data) {
    totLikes = data.totalLike ?? 0;
    totViews = data.totalView ?? 0;
    streamerData = data;
    isOver = false;
    endLive = false;
    comment = [];
    pinComment = null;
    notifyListeners();
  }

  // Engine Agora
  late RtcEngine engine;
  RemoteVideoState statusAgora = RemoteVideoState.remoteVideoStateStarting;
  RemoteVideoStateReason resionAgora = RemoteVideoStateReason.remoteVideoStateReasonNetworkRecovery;
  int? remoteUid = -1;
  bool localUserJoined = false;

  Future<bool> requestPermission(BuildContext context) async {
    final isGranted = await System().requestPermission(context, permissions: [Permission.camera, Permission.storage, Permission.microphone]);
    if (isGranted) {
      return isGranted;
    } else {
      await System().requestPermission(context, permissions: [Permission.camera, Permission.storage, Permission.microphone]);
      return true;
    }
  }

  Future<void> initAgora(LinkStreamModel data) async {
    // retrieve permissions
    // await [Permission.microphone, Permission.camera].request();

    //create the engine

    engine = createAgoraRtcEngine();

    await engine.initialize(const RtcEngineContext(
      appId: UrlConstants.agoraId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserStateChanged: (connection, remoteUid, state) {
          debugPrint("viewer local user ${connection} remote $remoteUid, ${state}");
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("viewer local user ${connection.localUid} joined");
          localUserJoined = true;
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          debugPrint("viewer remote user $uid joined");
          remoteUid = uid;
          isOver = false;
          notifyListeners();
        },
        onRemoteVideoStateChanged: ((connection, uid, state, RemoteVideoStateReason reason, elapsed) {
          debugPrint("viewer connection $connection, remote user $uid, state ${state.name}, resion ${reason.name}, $elapsed");
          statusAgora = state;
          resionAgora = reason;
          notifyListeners();
        }),
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          // destoryPusher();
          // if (!(dataStreaming.pause ?? false)) {
          debugPrint("viewer remote user $uid left channel");
          remoteUid = -1;
          statusLive = StatusStream.offline;
          isOver = true;
          notifyListeners();
          // }
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleAudience);

    await engine.enableAudio();
    await engine.enableVideo();
    await engine.startPreview();

    print('====== ${data.tempToken} ${dataStreaming.tokenAgora}');
    print('====== ${data.sId} ${dataStreaming.sId}');
    try {
      await engine.joinChannel(
        token: data.tempToken ?? (dataStreaming.tokenAgora ?? ''),
        channelId: data.sId ?? (dataStreaming.sId ?? ''),
        uid: 0,
        options: const ChannelMediaOptions(),
      );
    } catch (_) {
      debugPrint('===== error');
    }
  }

  sendComment(BuildContext context, LinkStreamModel model, String comment) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"_id": model.sId, "messages": comment, "type": "COMMENT", "commentType": "MESSAGGES"};
        commentController.clear();
        await notifier.getLinkStream(Routing.navigatorKey.currentContext ?? context, data, UrlConstants.updateStream);
        // final fetch = notifier.liveStreamFetch;
        // if (fetch.postsState == LiveStreamState.getApiSuccess) {
        //   fetch.data.forEach((v) => listStreamers.add(LinkStreamModel.fromJson(v)));
        //   notifyListeners();
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          sendComment(context, model, comment);
        });
      }
      commentController.clear();
    }
  }

  Future<void> destoryPusher() async {
    print("masuk destroy pusher");
    _socketService.closeSocket(eventComment);
    _socketService.closeSocket(eventViewStream);
    _socketService.closeSocket(eventLikeStream);
    _socketService.closeSocket(eventCommentDisable);
    _socketService.closeSocket(eventStatusStream);
    _socketService.closeSocket(eventKickUser);
    _socketService.closeSocket(eventCommentPin);
    _socketService.closeSocket(eventCommentDelete);
    disposeAgora();
    statusLive = StatusStream.offline;
    totLikes = 0;
    totViews = 0;
    isCommentDisable = false;
    commentController.clear();
    userName = '';
    statusLive = StatusStream.offline;
    dataViewers = [];
    comment = [];
    animationIndexes = [];
    WakelockPlus.disable();
  }

  List<String> likeList = [];
  List<String> likeListTapScreen = [];

  bool _isOver = false;
  bool get isOver => _isOver;
  set isOver(bool state) {
    _isOver = state;
  }

  bool _now = true;
  bool get now => _now;
  set now(bool state) {
    _now = state;
    notifyListeners();
  }

  void likeAdd() {
    likeList.add(System().getCurrentDate());
    totLikes++;
    notifyListeners();
  }

  void likeAddTapScreen() {
    likeListTapScreen.add(System().getCurrentDate());
    totLikes++;
    notifyListeners();
  }

  likeStreaming(BuildContext context, LinkStreamModel model, List<String> likes) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'_id': model.sId, "type": "LIKE", "like": likes};

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        // final fetch = notifier.liveStreamFetch;
        // if (fetch.postsState == LiveStreamState.getApiSuccess) {
        //   returnNext = true;
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
      notifyListeners();
    } else {
      // returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          exitStreaming(context, model);
        });
      }
    }
  }

  int _page = 0;
  int get page => _page;
  set page(int state) {
    _page = state;
    notifyListeners();
  }

  bool stopLoad = false;

  Future getListStreamers(BuildContext context, mounted, {bool isReload = true}) async {
    if (isReload) {
      loading = true;
    } else {
      loadMore = true;
    }
    bool connect = await System().checkConnections();
    if (isReload) {
      listStreamers = [];
      page = 0;
    } else {
      page += 1;
    }

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"page": page, "limit": 10};
        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.listLiveStreaming);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          final List<LinkStreamModel> tempList = [];
          if (isReload) {
            listStreamers = [];
          }
          fetch.data.forEach((v) => tempList.add(LinkStreamModel.fromJson(v)));
          if (tempList.isNotEmpty) {
            listStreamers.addAll(tempList);
          } else {
            if (!isReload) {
              stopLoad = true;
              notifyListeners();
            }
          }

          notifyListeners();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      if (isReload) {
        loading = false;
      } else {
        loadMore = false;
      }
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          getListStreamers(context, mounted);
        });
      }
    }
    if (isReload) {
      loading = false;
    } else {
      loadMore = false;
    }
  }

  Future exitStreaming(BuildContext context, LinkStreamModel model) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'_id': model.sId, "type": "CLOSE_VIEW"};

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        // final fetch = notifier.liveStreamFetch;
        // if (fetch.postsState == LiveStreamState.getApiSuccess) {
        //   returnNext = true;
        // }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      // returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          exitStreaming(context, model);
        });
      }
    }
  }

  bool loadingPause = false;
  Duration durationPause = const Duration(minutes: 5);
  Future initLiveStream(BuildContext context, mounted, LinkStreamModel model) async {
    bool returnNext = false;
    loadingPause = true;
    notifyListeners();
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'_id': model.sId, "type": "OPEN_VIEW"};

        if (mounted) {
          await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          dataStreaming = StreamingModel.fromJson(fetch.data);
          isCommentDisable = dataStreaming.commentDisabled ?? false;
          totViews = dataStreaming.viewCountActive ?? 0;

          print("=======duratoin ${dataStreaming.pause}");
          if (dataStreaming.pause ?? false) {
            statusAgora = RemoteVideoState.remoteVideoStateStopped;
            resionAgora = RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted;
            final timePause = DateTime.parse(dataStreaming.pauseDate ?? '2024-01-01');
            final date2 = DateTime.now();
            final time = date2.difference(timePause).inSeconds;

            var finaltime = 300 - time - 2;

            durationPause = Duration(seconds: finaltime > 0 ? finaltime : 2);
            print("=======duratoin $durationPause");
            notifyListeners();
          }

          if (dataStreaming.comment != null && (dataStreaming.comment?.isNotEmpty ?? [].isNotEmpty)) {
            pinComment = dataStreaming.comment?[0];
          }
          if (groupsReport.isEmpty && (dataStreaming.reportRemark?.isNotEmpty ?? [].isNotEmpty)) {
            for (var i = 0; i < (dataStreaming.reportRemark?.length ?? 0); i++) {
              var data = dataStreaming.reportRemark?[i];
              groupsReport.add(GroupModel(text: data ?? '', index: i, selected: false));
            }
          }
          comment.insert(
            0,
            CommentLiveModel(
              email: SharedPreference().readStorage(SpKeys.email),
              avatar: Avatar(mediaEndpoint: context.read<HomeNotifier>().profileImage),
              messages: 'joined',
              commentType: 'JOIN',
              username: context.read<SelfProfileNotifier>().user.profile?.username,
            ),
          );

          loadingPause = false;
          notifyListeners();
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
          initLiveStream(context, mounted, model);
        });
      }
    }
    return returnNext;
  }

  Future sendLike(BuildContext context, LinkStreamModel model) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "_id": model.sId,
          "like": likeList,
          // "like":["2023-12-14 12:01:49"],
          "type": "LIKE"
        };

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          likeList = [];
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
          exitStreaming(context, model);
        });
      }
    }
  }

  Future sendLikeTapScreen(BuildContext context, LinkStreamModel model) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "_id": model.sId,
          "like": likeListTapScreen,
          // "like":["2023-12-14 12:01:49"],
          "type": "LIKE"
        };

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          likeListTapScreen = [];
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
          exitStreaming(context, model);
        });
      }
    }
  }

  Future<void> startViewStreaming(BuildContext context, mounted, LinkStreamModel data) async {
    // notifyListeners();
    var init = await initLiveStream(context, mounted, data);
    if (init && (dataStreaming.status ?? false)) {
      // _socketService.closeSocket();

      await Future.delayed(const Duration(seconds: 1));
      await initAgora(data);
      print("======== ini socket status ${_socketService.isRunning} =========");

      // if (!_socketService.isRunning) {
      _connectAndListenToSocket(eventComment, data);
      _connectAndListenToSocket(eventLikeStream, data);
      _connectAndListenToSocket(eventViewStream, data);
      _connectAndListenToSocket(eventStatusStream, data);
      _connectAndListenToSocket(eventCommentDisable, data);
      _connectAndListenToSocket(eventKickUser, data);
      _connectAndListenToSocket(eventCommentPin, data);
      _connectAndListenToSocket(eventCommentDelete, data);
      // }

      // _alivcLivePusher.startPushWithURL(pushURL);
    } else {
      statusLive = StatusStream.offline;
      isOver = true;
      notifyListeners();
    }
  }

  Future<void> disposeAgora() async {
    await engine.leaveChannel();
    await engine.release();
    remoteUid = -1;
  }

  void _connectAndListenToSocket(String events, LinkStreamModel data) async {
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
              handleSocket(message, events, data);
              print('ini message dari socket $events ----- ${message}');
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

  void handleSocket(message, event, LinkStreamModel dataStream) async {
    if (event == eventComment) {
      var messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        if (messages.commentType == 'MESSAGGES' || messages.commentType == 'JOIN') {
          comment.insert(0, messages);
        } else if (messages.commentType == 'GIFT') {
          if (messages.urlGift != null) {
            if (giftDelux.isEmpty) {
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
        notifyListeners();
      }
    } else if (event == eventLikeStream) {
      var messages = CountLikeLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      String userId = SharedPreference().readStorage(SpKeys.userID);
      if (messages.idStream == dataStream.sId && userId != messages.userId) {
        totLikes = messages.likeCountTotal ?? 0;
        var run = getRandomDouble(1, 999999999999999);
        animationIndexes.add(run.toInt());

        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 700));
      }
    } else if (event == eventViewStream) {
      var messages = CountViewLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        totViews = messages.viewCount ?? 0;
      }
    } else if (event == eventStatusStream) {
      var messages = StatusStreamLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      print("===00 id ${dataStream.sId} -- ${messages.idStream} ${messages.idStream == dataStream.sId}");
      if (messages.idStream == dataStream.sId) {
        print("=====masuk true");
        if (messages.pause != null) {
          dataStreaming.pauseDate = null;
          // await Future.delayed(const Duration(milliseconds: 4500));
          dataStreaming.pause = messages.pause;

          notifyListeners();
        } else if (messages.datePelanggaran != null) {
        } else {
          print("=====masuk toast");
          // Fluttertoast.showToast(
          //   msg: 'Live Streaming akan segera berakhir',
          //   gravity: ToastGravity.CENTER,
          // );
          totViewsEnd = messages.totalViews ?? 0;
          endLive = true;
          notifyListeners();

          destoryPusher();
        }
      }
    } else if (event == eventCommentDisable) {
      var messages = StatusCommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        isCommentDisable = messages.comment ?? false;
        pinComment = null;
        comment = [];
      }
    } else if (event == eventKickUser) {
      var data = json.decode('$message');
      if (data['data']['email'] == SharedPreference().readStorage(SpKeys.email)) {
        isOver = true;
        totViewsEnd = data['totalViews'];
        // var dataStream = LinkStreamModel(sId: data['data']['idStream']);
        // await exitStreaming(Routing.navigatorKey.currentContext!, dataStream);
        destoryPusher();
      }
    } else if (event == eventCommentPin) {
      CommentLiveModel messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        if (messages.pinned ?? false) {
          insertPinComment(messages.idComment ?? '');
        } else {
          removePinComment();
        }
      }
    } else if (event == eventCommentDelete) {
      CommentLiveModel messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        removeComment(messages.idComment ?? '');
      }
    }

    notifyListeners();
  }

  void insertPinComment(String idComment) async {
    if (pinComment != null) {
      comment.insert(0, pinComment ?? CommentLiveModel());
    }
    for (var e in (dataStreaming.commentAll ?? [])) {
      if (e.idComment == idComment) {
        pinComment = e;
      }
    }
    comment.removeWhere((element) => element.idComment == idComment);
    notifyListeners();
  }

  void removePinComment() async {
    comment.insert(0, pinComment ?? CommentLiveModel());
    pinComment = null;
    notifyListeners();
  }

  void removeComment(String idComment) async {
    comment.removeWhere((element) => element.idComment == idComment);

    notifyListeners();
  }

  int? selectedReportValue;
  bool alreadyReported = false;

  //Modal List Transaction
  List<GroupModel> groupsReport = [
    // GroupModel(text: "Aktivitas ilegal", index: 1, selected: false),
    // GroupModel(text: "Hak cipta dan kekayaan intelektual", index: 2, selected: false),
    // GroupModel(text: "Keamanan anak", index: 3, selected: false),
    // GroupModel(text: "Keamanan dan integritas platform", index: 4, selected: false),
    // GroupModel(text: "Kekerasan dan ancaman", index: 5, selected: false),
    // GroupModel(text: "Ketelanjangan dan konten seksual", index: 6, selected: false),
    // GroupModel(text: "Konten berbahaya", index: 7, selected: false),
    // GroupModel(text: "Pelecehan dan penindasan", index: 8, selected: false),
    // GroupModel(text: "Privasi dan informasi pribadi", index: 9, selected: false),
    // GroupModel(text: "Spam dan penipuan", index: 10, selected: false),
    // GroupModel(text: "Ujaran kebencian", index: 11, selected: false),
  ];
  LinkStreamModel? reportdata;

  Future<void> reportLive(BuildContext context) async {
    if (alreadyReported) {
      showModalBottomSheet<int>(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return const AlreadyReported();
          }).whenComplete(() {
        debugPrint('Already Reported');
      });
    } else {
      showModalBottomSheet<int>(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return const ReportLive();
          }).whenComplete(() {
        selectedReportValue = null;
        debugPrint('Complete Report Live Streaming');
      });
    }
  }

  Future<void> sendReportLive(BuildContext context, String message) async {
    Map param = {"_id": dataStreaming.sId, "messages": message, "type": "REPORT"};
    await updateStream(context, context.mounted, param).then((value) {
      print("isi dari value $value");
      if (value != null) {
        Navigator.pop(context);
        if (value == 'Update stream succesfully') {
          responReportLive(context);
        } else if (value['reportStatus'] != null && value['reportStatus'] == true) {
          allReadyReport(context);
        }
      }
    });
  }

  Future<void> responReportLive(BuildContext context) async {
    try {
      showModalBottomSheet<int>(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (context) {
            return const ResponsReportLive();
          }).whenComplete(() {
        // selectedReportValue = null;
        debugPrint('Complete Report Live Streaming');
      });
    } catch (e) {
      print("error $e");
    }
  }

  Future<void> allReadyReport(BuildContext context) async {
    try {
      showModalBottomSheet<int>(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          builder: (context) {
            return const ResponsAllreadyReport();
          }).whenComplete(() {
        // selectedReportValue = null;
        debugPrint('Complete Report Live Streaming');
      });
    } catch (e) {
      print("error $e");
    }
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
        });
      }
    }
    return dataReturn;
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

  Timer? timerBasic;

  void startTimerBasic() {
    timerBasic = Timer.periodic(const Duration(seconds: 3), (timer) {
      print("=== ${timer}");
      print("=== ${giftBasic.isNotEmpty}");
      if (giftBasic.isNotEmpty) {
        print("===================================haous========================");
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

  Future createLinkStream(BuildContext context, {required bool copiedToClipboard, required String description}) async {
    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.viewStreaming,
        postID: dataStreaming.sId,
        fullName: "",
        description: '${dataStreaming.user?.fullName ?? dataStreaming.user?.username} (${dataStreaming.user?.username}) \n is LIVE ${dataStreaming.title}',
        // thumb: System().showUserPicture(profileImage),
        thumb: System().showUserPicture(dataStreaming.user?.avatar?.mediaEndpoint),
      ),
      copiedToClipboard: copiedToClipboard,
      afterShare: () {
        if (!copiedToClipboard) {
          shareCount(context, true, 1);
        }
      },
    ).then((value) {
      if (value) {
        if (copiedToClipboard && context.mounted) {
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

  Future getGift(BuildContext context, bool mounted, String type, {bool isLoadmore = false}) async {
    //type = CLASSIC -- DELUXE
    // if (type == 'CLASSIC' && dataGift.isNotEmpty) return;
    // if (type == 'DELUXE' && dataGiftDeluxe.isNotEmpty) return;
    if (!isLoadmore) isloadingGift = true;
    notifyListeners();
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"page": 0, "limit": 9999, "descending": true, "type": "GIFT", "typeGift": type};

        if (mounted) await notifier.getLinkStream(context, data, UrlConstants.listmonetization);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          if (type == 'CLASSIC') {
            if (!isLoadmore) dataGift = [];
            fetch.data.forEach((v) => dataGift.add(GiftLiveModel.fromJson(v)));
          } else {
            if (!isLoadmore) dataGiftDeluxe = [];
            fetch.data.forEach((v) => dataGiftDeluxe.add(GiftLiveModel.fromJson(v)));
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
    isloadingGift = false;
    notifyListeners();
  }

  void sendGift(BuildContext context, bool mounted, String idGift, String urlGiftThumb, String title, {String? urlGift, String? idViewStream}) async {
    Map param = {
      "_id": dataStreaming.sId,
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

  int saldoCoin = 0;
  bool buttonGift() {
    if (saldoCoin >= (giftSelect?.price ?? 0) && giftSelect != null) {
      return true;
    } else {
      return false;
    }
  }

  Future shareCount(BuildContext context, bool mounted, int total) async {
    Map data = {"_id": dataStreaming.sId, "shareCount": total, "type": "SHARE"};
    updateStream(context, mounted, data).then((value) {});
  }
}

class GroupModel {
  String text;
  int index;
  bool selected;
  String? startDate;
  String? endDate;
  GroupModel({required this.text, required this.index, required this.selected, this.startDate, this.endDate});
}
