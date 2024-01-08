import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/live_stream/streaming_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
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
import '../../../../../../core/services/socket_service.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'dart:math' as math;

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
  static const String eventStatusStream = 'STATUS_STREAM';

  String userName = '';
  String? _currentUserId = SharedPreference().readStorage(SpKeys.userID);
  String get currentUserId => _currentUserId ?? '';

  StreamingModel dataStreaming = StreamingModel();

  ///Status => Offline - Prepare - StandBy - Ready - Online
  StatusStream statusLive = StatusStream.offline;

  List<ViewersLiveModel> dataViewers = [];
  List<CommentLiveModel> comment = [];
  List<int> animationIndexes = [];
  int totLikes = 0;
  int totViews = 0;
  int totViewsEnd = 0;

  Offset positionDxDy = Offset(0, 0);

  bool endLive = false;

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
    // comment.clear();
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
    // notifyListeners();
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
          dataStreaming = StreamingModel.fromJson(fetch.data);
          isCommentDisable = dataStreaming.commentDisabled ?? false;
          totViews = dataStreaming.viewCountActive ?? 0;
          returnNext = true;
          comment.insert(
            0,
            CommentLiveModel(
              email: SharedPreference().readStorage(SpKeys.email),
              avatar: Avatar(mediaEndpoint: context.read<HomeNotifier>().profileImage),
              messages: 'joined',
              username: context.read<SelfProfileNotifier>().user.profile?.username,
            ),
          );
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
    notifyListeners();
    var init = await initLiveStream(context, mounted, data);
    if (init) {
      Future.delayed(Duration(seconds: 1));
      _connectAndListenToSocket(eventComment, data);
      _connectAndListenToSocket(eventLikeStream, data);
      _connectAndListenToSocket(eventViewStream, data);
      _connectAndListenToSocket(eventStatusStream, data);
      _connectAndListenToSocket(eventCommentDisable, data);

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
      host: Env.data.socketUrl,
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
        comment.insert(0, messages);
      }
    } else if (event == eventLikeStream) {
      var messages = CountLikeLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      String userId = SharedPreference().readStorage(SpKeys.userID);
      if (messages.idStream == dataStream.sId && userId != messages.userId) {
        totLikes += messages.likeCount ?? 0;
        print("totalnya ${animationIndexes}");
        // for (var i = 0; i < (messages.likeCount ?? 0); i++) {
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
      if (messages.idStream == dataStream.sId) {
        if (messages.pause != null) {
          await Future.delayed(const Duration(milliseconds: 4500));
          dataStreaming.pause = messages.pause;
        } else {
          endLive = true;
          notifyListeners();
          Fluttertoast.showToast(
            msg: 'Live Streaming akan segera berakhir',
            gravity: ToastGravity.CENTER,
          );
          totViewsEnd = messages.totalViews ?? 0;
        }
      }
    } else if (event == eventCommentDisable) {
      var messages = StatusCommentLiveModel.fromJson(GenericResponse.fromJson(json.decode('$message')).responseData);
      if (messages.idStream == dataStream.sId) {
        isCommentDisable = messages.comment ?? false;
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
}
