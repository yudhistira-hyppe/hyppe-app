
// import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:hyppe/core/arguments/summary_live_argument.dart';
// import 'package:hyppe/core/bloc/live_stream/bloc.dart';
// import 'package:hyppe/core/bloc/live_stream/state.dart';
// import 'package:hyppe/core/config/env.dart';
// import 'package:hyppe/core/config/url_constants.dart';
// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/constants/shared_preference_keys.dart';
// import 'package:hyppe/core/extension/log_extension.dart';
// import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
// import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
// import 'package:hyppe/core/models/collection/live_stream/live_summary_model.dart';
// import 'package:hyppe/core/models/collection/live_stream/viewers_live_model.dart';
// import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
// import 'package:hyppe/core/response/generic_response.dart';
// import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/services/socket_live_service.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
// import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
// import 'package:hyppe/ux/path.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:socket_io_client/socket_io_client.dart';

// import 'dart:math' as math;

// class StreameriOSNotifier with ChangeNotifier {
//   String appId = '4c61e95ab6f148f8a5cd6796ceb11fab';
//   String token = '007eJxTYGh6UjpJnGPeigd/ru7ZuW3LlAAH9pe+uz7duvm9rPe4SGqMAoNJsplhqqVpYpJZmqGJRZpFomlyipm5pVlyapKhYVpikuwkjbSGQEaGtVN5GRihEMRnZyhJLS7JzEtnYAAAuOMjiw==';
//   static const String eventComment = 'COMMENT_STREAM_SINGLE';
//   static const String eventViewStream = 'VIEW_STREAM';
//   static const String eventLikeStream = 'LIKE_STREAM';
//   static const String eventCommentDisable = 'COMMENT_STREAM_DISABLED';

//   final _socketService = SocketLiveService();
  
//   LinkStreamModel dataStream = LinkStreamModel();
  
//   bool isloading = true;
//   bool isloadingPreview = true;
//   int? remoteUid;
//   bool localUserJoined = false;
//   bool isStreamer = false;
//   bool isCancel = false;
//   int timeReady = 3;
//   int totLikes = 0;
//   int totViews = 0;
//   int pageViewers = 0;
//   int rowViewers = 10;
//   int totPause = 0;

//   late RtcEngine engine;

//   DateTime dateTimeStart = DateTime.now();
//   LiveSummaryModel dataSummary = LiveSummaryModel();

//   StatusStream statusLive = StatusStream.offline;
//   FocusNode titleFocusNode = FocusNode();

//   TextEditingController titleLiveCtrl = TextEditingController();
//   TextEditingController titleUrlLiveCtrl = TextEditingController();
//   TextEditingController commentCtrl = TextEditingController();
//   TextEditingController urlLiveCtrl = TextEditingController();

//   List<ViewersLiveModel> dataViewers = [];
//   List<CommentLiveModel> comment = [];
//   List<int> animationIndexes = [];
  
//   LocalizationModelV2? tn;
//   String userName = '';
//   String _titleLive = '';
//   String get titleLive => _titleLive;

//   Future<void> init(BuildContext context) async {
//     isloading = true;
//     notifyListeners();

//     await initAgora();
    
//   }

//   Future<void> initAgora() async {
//     // retrieve permissions
//     await [Permission.microphone, Permission.camera].request();

//     //create the engine
//     engine = createAgoraRtcEngine();
//     await engine.initialize(RtcEngineContext(
//       appId: appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));

//     engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           localUserJoined = true;
//           notifyListeners();
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           remoteUid = remoteUid;
//           notifyListeners();
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           debugPrint("remote user $remoteUid left channel");
//           remoteUid = -1;
//           statusLive = StatusStream.offline;
//           notifyListeners();
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );

//     if (isStreamer){
//       await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     }else{
//       await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
//     }
    
//     await engine.enableAudio();
//     await engine.enableVideo();
//     await engine.startPreview();

//     isloadingPreview = true;
//     isloading = false;
//     notifyListeners();
//   }

//   Future<void> startStreamer(String channelName) async {
//     await engine.joinChannel(
//       token: token,
//       channelId: channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   void flipCamera() {
//     engine.switchCamera();
//   }

//   Future<void> clickPushAction(BuildContext context, mounted) async {
//     isCancel = false;
//     timeReady = 3;
//     userName = context.read<SelfProfileNotifier>().user.profile?.username ?? '';
//     dateTimeStart = DateTime.now();
//     statusLive = StatusStream.prepare;
//     notifyListeners();

//     var init = await initLiveStream(context, mounted);
//     if (init) {
//       Future.delayed(const Duration(seconds: 1));
//       startStreamer(userName);
//       if (_socketService.isRunning) {
//         _socketService.closeSocket(eventComment);
//         _socketService.closeSocket(eventLikeStream);
//         _socketService.closeSocket(eventViewStream);
//       }
//       _connectAndListenToSocket(eventComment);
//       _connectAndListenToSocket(eventLikeStream);
//       _connectAndListenToSocket(eventViewStream);
//     } else {
//       statusLive = StatusStream.offline;
//       notifyListeners();
//     }
//   }

//   Future<void> cancelLive(BuildContext context, mounted) async {
//     // isCancel = true;
//     statusLive = StatusStream.offline;
//     // _alivcLivePusher.stopPush();
//     // inactivityTimer?.cancel();
//     // stopStream(context, mounted);
//   }

//   Future<void> destoryPusher() async {
//     _socketService.closeSocket(eventComment);
//     _socketService.closeSocket(eventLikeStream);
//     _socketService.closeSocket(eventViewStream);
//   }

//   Future endLive(BuildContext context, mounted, {bool isBack = true}) async {
//     if (isBack) Routing().moveBack();
//     var dateTimeFinish = DateTime.now();
//     Duration duration = dateTimeFinish.difference(dateTimeStart);
//     await destoryPusher();
//     _dispose();
//     // await stopStream(context, mounted);
//     Routing().moveReplacement(Routes.streamingFeedback, argument: SummaryLiveArgument(duration: duration, data: dataSummary));
//   }

//   Future<void> _dispose() async {
//     await engine.leaveChannel();
//     await engine.release();
//   }

//     set titleLive(String val) {
//     _titleLive = val;
//     notifyListeners();
//   }

//   Future initLiveStream(BuildContext context, mounted) async {
//     bool returnNext = false;
//     bool connect = await System().checkConnections();

//     if (connect) {
//       try {
//         final notifier = LiveStreamBloc();
//         Map data = {'title': titleLive};

//         if (mounted) {
//           await notifier.getLinkStream(context, data, UrlConstants.getLinkStream);
//         }
//         final fetch = notifier.liveStreamFetch;
//         if (fetch.postsState == LiveStreamState.getApiSuccess) {
//           dataStream = LinkStreamModel.fromJson(fetch.data);
//           returnNext = true;
//         }
//       } catch (e) {
//         debugPrint(e.toString());
//       }

//       notifyListeners();
//     } else {
//       returnNext = false;
//       if (context.mounted) {
//         ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
//           Routing().moveBack();
//           initLiveStream(context, mounted);
//         });
//       }
//     }
//     return returnNext;
//   }

//   void _connectAndListenToSocket(String events) async {
//     String? token = SharedPreference().readStorage(SpKeys.userToken);
//     String? email = SharedPreference().readStorage(SpKeys.email);

//     _socketService.connectToSocket(
//       () {
//         _socketService.events(
//           events,
//           (message) {
//             try {
//               handleSocket(message, events);
//               print('ini message dari stremaer socket $events ----- ${message}');
//             } catch (e) {
//               e.toString().logger();
//             }
//           },
//         );
//       },
//       host: Env.data.baseUrlSocket,
//       options: OptionBuilder()
//           .setAuth({
//             "x-auth-user": "$email",
//             "x-auth-token": "$token",
//           })
//           .setTransports(
//             ['websocket'],
//           )
//           .setPath('${Env.data.versionApi}/socket.io')
//           .disableAutoConnect()
//           .build(),
//     );
//   }

//   void handleSocket(message, event) async {
//     if (event == eventComment) {
//       var messages = CommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
//       if (messages.idStream == dataStream.sId) {
//         comment.insert(0, messages);
//       }
//     } else if (event == eventLikeStream) {
//       var messages = CountLikeLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
//       if (messages.idStream == dataStream.sId) {
//         totLikes = messages.likeCountTotal ?? 0;
//         var run = getRandomDouble(1, 999999999999999);
//         animationIndexes.add(run.toInt());

//         notifyListeners();
//         await Future.delayed(const Duration(milliseconds: 700));
//         // }
//       }
//     } else if (event == eventViewStream) {
//       var messages = CountViewLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
//       if (messages.idStream == dataStream.sId) {
//         totViews = messages.viewCount ?? 0;
//       }
//     }
//     notifyListeners();
//   }

//   double getRandomDouble(double min, double max) {
//     final random = math.Random();
//     double randomValue = min + random.nextDouble() * (max - min);

//     randomValue = double.parse(randomValue.toStringAsFixed(4));

//     return randomValue;
//   }
// }