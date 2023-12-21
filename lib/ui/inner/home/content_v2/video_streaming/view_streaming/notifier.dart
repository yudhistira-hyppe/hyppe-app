import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hyppe/core/extension/log_extension.dart';
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
import '../../../../../../core/services/socket_service.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class ViewStreamingNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final _socketService = SocketService();

  final commentController = TextEditingController();

  static const String eventComment = 'COMMENT_STREAM_SINGLE';
  static const String eventViewStream = 'VIEW_STREAM';
  static const String eventLikeStream = 'LIKE_STREAM';
  static const String eventCommentDisable = 'COMMENT_STREAM_DISABLED';

  String userName = '';
  ///Status => Offline - Prepare - StandBy - Ready - Online
  StatusStream statusLive = StatusStream.offline;

  List<ViewersLiveModel> dataViewers = [];
  List<CommentLiveModel> comment = [];
  List<int> animationIndexes = [];
  int totLikes = 0;
  int totViews = 0;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool state){
    _loading = state;
    notifyListeners();
  }

  bool _isCommentDisable = false;
  bool get isCommentDisable => _isCommentDisable;
  set isCommentDisable(bool state){
    _isCommentDisable = state;
    notifyListeners();
  }

  List<LinkStreamModel> _listStreamers = [];
  List<LinkStreamModel> get listStreamers => _listStreamers;
  set listStreamers(List<LinkStreamModel> data){
    _listStreamers = data;
    notifyListeners();
  }

  LinkStreamModel? streamerData;

  initListStreamers(){
    _loading = true;
    _listStreamers = [];

  }

  initViewStreaming(LinkStreamModel data){
    totLikes = data.totalLike ?? 0;
    totViews = data.totalView ?? 0;
    streamerData = data;
  }

  sendComment(BuildContext context, LinkStreamModel model, String comment) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"_id": model.sId, "messages": comment, "type": "COMMENT"};
        await notifier.getLinkStream(Routing.navigatorKey.currentContext ?? context, data, UrlConstants.updateStream);
        // final fetch = notifier.liveStreamFetch;
        // if (fetch.postsState == LiveStreamState.getApiSuccess) {
        //   fetch.data.forEach((v) => listStreamers.add(LinkStreamModel.fromJson(v)));
        //   notifyListeners();
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
      commentController.clear();
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
    WakelockPlus.disable();
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
    _socketService.closeSocket();
  }

  List<String> likeList = [];

  bool _isOver = false;
  bool get isOver => _isOver;
  set isOver(bool state){
    _isOver = state;
    notifyListeners();
  }

  bool _now = true;
  bool get now => _now;
  set now(bool state){
    _now = state;
    notifyListeners();
  }

  likeStreaming(BuildContext context, LinkStreamModel model, List<String> likes) async{
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'_id': model.sId, "type": "LIKE", "like": likes};

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        final fetch = notifier.liveStreamFetch;
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

  Future getListStreamers(BuildContext context, mounted, {bool isReload = true}) async {
    loading = true;
    bool connect = await System().checkConnections();
    if(isReload){
      listStreamers = [];
    }

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {"page": 0, "limit": 20};
        if (mounted) {

          await notifier.getLinkStream(context, data, UrlConstants.listLiveStreaming);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          fetch.data.forEach((v) => listStreamers.add(LinkStreamModel.fromJson(v)));
          notifyListeners();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          getListStreamers(context, mounted);
        });
      }
    }
    loading = false;
  }

  Future exitStreaming(BuildContext context, LinkStreamModel model) async {
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {'_id': model.sId, "type": "CLOSE_VIEW"};

        await notifier.getLinkStream(context, data, UrlConstants.updateStream);
        final fetch = notifier.liveStreamFetch;
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

  Future initLiveStream(BuildContext context, mounted, LinkStreamModel model) async {
    bool returnNext = false;
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

  Future<void> startViewStreaming(BuildContext context, mounted, LinkStreamModel data) async {
    notifyListeners();
    var init = await initLiveStream(context, mounted, data);
    if (init) {
      Future.delayed(Duration(seconds: 1));
      _connectAndListenToSocket(eventComment, data);
      _connectAndListenToSocket(eventLikeStream, data);
      _connectAndListenToSocket(eventViewStream, data);

      // _alivcLivePusher.startPushWithURL(pushURL);
    } else {
      statusLive = StatusStream.offline;
      notifyListeners();
    }
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

  void handleSocket(message, event, LinkStreamModel dataStream) {
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
