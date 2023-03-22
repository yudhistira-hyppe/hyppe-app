import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/arguments/message_detail_argument.dart';
import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/bloc/message_v2/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/event/discuss_event_handler.dart';
import 'package:hyppe/core/event/event_key.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/query_request/discuss_data_query.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageDetailNotifier with ChangeNotifier, DiscussEventHandler {
  final _eventService = EventService();
  // final _socketService = SocketService();

  late MessageDetailArgument _argument;

  MessageDetailArgument get argument => _argument;

  final ScrollController scrollController = ScrollController();

  DiscussDataQuery discussQuery = DiscussDataQuery()..limit = 1000;

  int get itemCount => _discussData == null
      ? 1
      : discussQuery.hasNext
          ? (_discussData?.length ?? 0) + 1
          : (_discussData?.length ?? 0);

  bool get hasNext => discussQuery.hasNext;

  bool isMyMessage(String? email) => SharedPreference().readStorage(SpKeys.email) == email;

  List<MessageDataV2>? _discussData;

  List<MessageDataV2>? get discussData => _discussData;

  int _selectData = 0;

  int get selectData => _selectData;

  set discussData(List<MessageDataV2>? val) {
    _discussData = val;
    notifyListeners();
  }

  set selectData(int val) {
    _selectData = val;
    notifyListeners();
  }

  void initState(BuildContext context, MessageDetailArgument argument) {
    _argument = argument;

    // _connectAndListenToSocket(context);
    _selectData = -1;

    _eventService.addDiscussHandler(EventKey.messageReceivedKey, this);
    print(argument.discussData);
    _discussData = argument.discussData;
    try {
      discussData?.firstOrNull?.disqusLogs.sort((a, b) => DateTime.parse(b.createdAt ?? '').compareTo(DateTime.parse(a.createdAt ?? '')));
    } catch (e) {
      '$e'.logger();
    }

    if (argument.discussData == null) {
      newGetMessageDiscussion(context, reload: true);
    }
  }

  void disposeNotifier() {
    // _socketService.closeSocket();
    _selectData = -1;
    _eventService.removeDiscussHandler(EventKey.messageReceivedKey);
  }
  @override
  void onMessageReceived(MessageDataV2 message) {
    try {
      print('onMessageReceived active');
      // addMessage(logs: message.disqusLogs.firstOrNull, context: context);
      addMessage(logs: message.disqusLogs.firstOrNull ?? DisqusLogs());
    } catch (e) {
      '$e'.logger();
    }
  }

  // void _connectAndListenToSocket(BuildContext context) async {
  //   String? token = SharedPreference().readStorage(SpKeys.userToken);
  //   String? email = SharedPreference().readStorage(SpKeys.email);

  //   if (_socketService.isRunning) _socketService.closeSocket();
  //   _socketService.connectToSocket(
  //     () {
  //       _socketService.events(SocketService.eventDiscuss, (result) {
  //         '$result'.logger();
  //         try {
  //           final msgData = MessageDataV2.fromJson(result);
  //           msgData.toJson().logger();
  //           addMessage(logs: msgData.disqusLogs.firstOrNull, context: context);
  //         } catch (e) {
  //           '$e'.logger();
  //         }
  //       });
  //     },
  //     host: APIs.baseApi + '/disqus',
  //     options: OptionBuilder()
  //         .setAuth({
  //           "x-auth-user": "$email",
  //           "x-auth-token": "$token",
  //         })
  //         .setTransports(
  //           ['websocket'],
  //         )
  //         .disableAutoConnect()
  //         .build(),
  //   );
  // }

  Future<void> newGetMessageDiscussion(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<MessageDataV2>> _resFuture;

    discussQuery.receiverParty = _argument.emailReceiver;

    try {
      if (reload) {
        print('reload contentsQuery : 20');
        _resFuture = discussQuery.reload(context);
      } else {
        _resFuture = discussQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        List<MessageDataV2> resData = [];
        final data = res.firstWhereOrNull((element) {
          return element.senderOrReceiverInfo?.username == argument.usernameReceiver.replaceAll("@", '');
        });
        if (data != null) {
          resData.add(data);
        }
        discussData = resData;
      } else {
        discussData = [...(discussData ?? [] as List<MessageDataV2>)] + res;
      }

      // sort descending
      try {
        discussData?.firstOrNull?.disqusLogs.sort((a, b) => DateTime.parse(b.createdAt ?? '').compareTo(DateTime.parse(a.createdAt ?? '')));
      } catch (e) {
        '$e'.logger();
      }
    } catch (e) {
      'load discuss list: ERROR: $e'.logger();
    }
  }

  Future<void> getMessageDiscussion(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<MessageDataV2>> _resFuture;

    discussQuery.receiverParty = _argument.emailReceiver;

    try {
      if (reload) {
        print('reload contentsQuery : 20');
        _resFuture = discussQuery.reload(context);
      } else {
        _resFuture = discussQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        discussData = res;
      } else {
        discussData = [...(discussData ?? [] as List<MessageDataV2>)] + res;
      }

      // sort descending
      try {
        discussData?.firstOrNull?.disqusLogs.sort((a, b) => DateTime.parse(b.createdAt ?? '').compareTo(DateTime.parse(a.createdAt ?? '')));
      } catch (e) {
        '$e'.logger();
      }
    } catch (e) {
      'load discuss list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !discussQuery.loading && hasNext) {
      getMessageDiscussion(context);
    }
  }

  Future sendMessage(BuildContext context) async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      messageController.text.logger();

      final message = messageController.text;

      final emailSender = SharedPreference().readStorage(SpKeys.email);
      final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final param = DiscussArgument(
        email: emailSender,
        receiverParty: _argument.emailReceiver,
      )..txtMessages = message;

      messageController.clear();
      var uniquKey = UniqueKey().toString();
      addMessage(
        // context: context,
        logs: DisqusLogs(
          id: uniquKey,
          active: true,
          updatedAt: ts,
          createdAt: ts,
          postType: 'txt_msg',
          sender: emailSender,
          txtMessages: message,
          receiver: _argument.emailReceiver,
          parentID: (_discussData?.isEmpty ?? true) ? UniqueKey().toString() : _discussData?.first.room,
        ),
      );

      final notifier = MessageBlocV2();
      await notifier.createDiscussionBloc(context, disqusArgument: param);

      final fetch = notifier.messageFetch;

      if (fetch.chatState == MessageState.createDiscussionBlocSuccess) {
        DisqusLogs? _updatedData;
        _updatedData = discussData?.first.disqusLogs.firstWhere((element) => element.id == uniquKey);
        _updatedData?.id = fetch.data[0]['disqusLogs'][0]['_id'];
      }
      if (fetch.chatState == MessageState.createDiscussionBlocError) {}
    } catch (e) {
      e.toString().logger();
    }
  }

  void addMessage({required DisqusLogs logs}) {
    // final emailSender = SharedPreference().readStorage(SpKeys.email);
    // final _selfProfile = Provider.of<SelfProfileNotifier>(context, listen: false);
    final ts = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if ((discussData?.isEmpty ?? true)) {
      discussData?.insert(
        0,
        MessageDataV2(
          active: true,
          createdAt: ts,
          updatedAt: ts,
          disqusLogs: [logs],
          mate: _argument.mate,
          eventType: 'DIRECT_MSG',
          room: UniqueKey().toString(),
          email: argument.emailReceiver,
          disqusID: UniqueKey().toString(),
          fullName: argument.fullnameReceiver,
          username: argument.usernameReceiver,
        ),
      );
    } else {
      discussData?.first.disqusLogs.insert(0, logs);
    }
    notifyListeners();
  }

  // LocalizationModel language = LocalizationModel();
  // translate(LocalizationModel translate) {
  //   language = translate;
  //   notifyListeners();
  // }

  // /////////////////////////////////////// Chat Detail
  // String? _photoUrl;
  // String? _receiverUserName;
  // String? _receiverName;
  // String? _receiverUid;
  // bool _isHaveStory = false;
  // String? get photoUrl => _photoUrl;
  // String? get receiverName => _receiverName;
  // String? get receiverUserName => _receiverUserName;
  // String? get receiverUid => _receiverUid;
  // bool get isHaveStory => _isHaveStory;
  // set photoUrl(String? val) {
  //   _photoUrl = val;
  //   notifyListeners();
  // }

  // set receiverUserName(String? val) {
  //   _receiverUserName = val;
  //   notifyListeners();
  // }

  // set receiverName(String? val) {
  //   _receiverName = val;
  //   notifyListeners();
  // }

  // set receiverUid(String? val) {
  //   _receiverUid = val;
  //   notifyListeners();
  // }

  // set isHaveStory(bool val) {
  //   _isHaveStory = val;
  //   notifyListeners();
  // }
  // ///////////////////////////////////////////////////

  // int? _limitChat = 0;
  // String? _lCts;
  // String? _senderID;
  double _opacityButtonSend = 0.4;
  // List<MessageData> _listChatData = [];
  final TextEditingController _messageController = TextEditingController();

  // String? get senderID => _senderID;
  // List<MessageData> get listChatData => _listChatData;
  double get opacityButtonSend => _opacityButtonSend;
  TextEditingController get messageController => _messageController;

  // set senderID(String? val) {
  //   _senderID = val;
  //   notifyListeners();
  // }

  // set listChatData(List<MessageData> val) {
  //   _listChatData = val;
  //   notifyListeners();
  // }

  // initialData(context, ScrollController scrollController) async {
  //   bool connect = await System().checkConnections();
  //   if (connect) {
  //     connectToWebSocket();
  //     syncDetailChatFromServer(context, rows: 10, lCts: DateTime.now().millisecondsSinceEpoch.toString());
  //     scrollController.addListener(() => scrollListener(context, scrollController));
  //   } else {
  //     ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
  //       Routing().moveBack();
  //       initialData(context, scrollController);
  //     });
  //   }
  // }

  // void connectToWebSocket() async {
  //   senderID = SharedPreference().readStorage(SpKeys.userID);
  //   String? userToken = SharedPreference().readStorage(SpKeys.userToken);
  //   _socketService.connectToSocket(() {
  //     _socketService.events(SocketService.receiveNewMsg, (message) => eventSinkMsg(message['senderID'], message['receiverID'], message['message']));
  //   }, host: APIs.socketChatUrl, options: <String, dynamic>{
  //     'autoConnect': false,
  //     'withCredentials': false,
  //     'transports': ['websocket'],
  //     'query': {'x-auth-token': "$userToken"},
  //     'path': "${APIs.socketEndPointUrl}",
  //   });
  // }

  // void eventSinkMsg(String? senderId, String? receiverId, String? txtMsg) {
  //   _listChatData.insert(
  //     0,
  //     MessageData(
  //       type: 0,
  //       message: txtMsg,
  //       senderID: senderId,
  //       receiverID: receiverId,
  //       timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
  //     ),
  //   );
  //   notifyListeners();
  // }

  // void sendMessage(ScrollController scrollController) {
  //   if (_messageController.text.trim().isNotEmpty) {
  //     // format back end
  //     var _chatData = MessageData(
  //         senderID: senderID, receiverID: receiverUid, message: _messageController.text, timestamp: DateTime.now().millisecondsSinceEpoch.toString());
  //     _socketService.emit(SocketService.sendNewMsg, _chatData.toMap());
  //     eventSinkMsg(senderID, receiverUid, _messageController.text);
  //     if (scrollController.hasClients)
  //       scrollController.animateTo(scrollController.position.minScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  //     _messageController.clear();
  //   }
  //   notifyListeners();
  // }

  // Future syncDetailChatFromServer(context, {int? rows, String? lCts}) async {
  //   if (_limitChat > _listChatData.length || _listChatData.isEmpty) {
  //     final notifier = Provider.of<MessageBloc>(context, listen: false);
  //     await notifier.syncMessageDetailFromServerBloc(context,
  //         function: () => syncDetailChatFromServer(context, rows: rows, lCts: lCts), receiverId: receiverUid, rows: rows, lCts: lCts);
  //     final fetch = notifier.messageFetch;
  //     if (fetch.chatState == MessageState.syncMessageDetailFromServerBlocSuccess) {
  //       Message _result = fetch.data;
  //       _limitChat = _result.count ?? 0;
  //       _result.data.forEach((v) => _listChatData.add(v));
  //       if (_listChatData.isNotEmpty) _lCts = listChatData[_listChatData.length - 1].timestamp;
  //       notifyListeners();
  //     } else {
  //       if (_listChatData.isEmpty) print("No Chat Yet?????");
  //     }
  //   }
  // }

  // void scrollListener(context, ScrollController scrollController) async {
  //   if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
  //     bool connection = await System().checkConnections();
  //     if (connection) {
  //       _lCts = (int.parse(_lCts) - 1).toString();
  //       syncDetailChatFromServer(context, lCts: _lCts);
  //     } else {
  //       ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
  //         Routing().moveBack();
  //         scrollListener(context, scrollController);
  //       });
  //     }
  //   }
  // }

  void closeKeyboard(context) {
    _selectData = -1;
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    notifyListeners();
  }

  void onBack() {
    Routing().moveBack();
    // _socketService.closeSocket();
    // messageController.clear();
    // listChatData.clear();
  }

  onChangeHandler(String v) {
    v != "" ? _opacityButtonSend = 1.0 : _opacityButtonSend = 0.4;
    notifyListeners();
  }

  // void onTapLocalMedia(BuildContext context) async {
  //   try {
  //     await System().getLocalMedia(context: context).then((value) async {
  //       if (value.values.single != null) {
  //         print(value.values.single.paths);
  //       } else {
  //         print("Canceled pick data");
  //       }
  //     });
  //   } catch (e) {
  //     print('Sorry, unexpected error has occurred ☹️, please try again');
  //   }
  // }

  // Future navigateToProfile(BuildContext context, {String? userID, String? username}) async {
  //   if (userID != null) {
  //     System().navigateToProfileScreen(
  //       context,
  //       ContentData(
  //         userID: userID,
  //         username: username,
  //       ),
  //     );
  //   }
  // }

  Future<void> deleteChat(
    context,
  ) async {
    final _routing = Routing();
    final notifier = MessageBlocV2();
    String? _id = _discussData?.first.disqusLogs[_selectData].id;
    _discussData?.first.disqusLogs.removeWhere((item) => item.id == _id);

    try {
      await notifier.deleteDiscussionBloc(context, postEmail: '', id: _id ?? '');
      final fetch = notifier.messageFetch;
      if (fetch.chatState == MessageState.deleteDiscussionBlocSuccess) {
        _selectData = -1;
        // getMessageDiscussion(context, reload: true);
        // context.read<MessageNotifier>().getDiscussion();
      }
    } catch (e) {
      _routing.moveBack();
      e.logger();
    }
    notifyListeners();
  }
}
