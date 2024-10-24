import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/extension/log_extension.dart';

class SocketService {
  /// socket instance
  Socket? _socket;

  final EventService _eventService = EventService();

  /// socket events
  //-------------------------------- Message Events --------------------------------------//
  static const String sendNewMsg = 'send_new_msg';
  static const String receiveNewMsg = 'receive_new_msg';

  //-------------------------------- Upload Content Events --------------------------------------//
  static const String videoProcess = 'video_process';
  static const String videoUploadedMessage = 'video_uploaded_message';
  static const String videoTranscodingMessage = 'video_transcoding_message';

  //-------------------------------- User Connect Events --------------------------------------//
  static const String userConnected = 'user_connected';

  //-------------------------------- Version 2 --------------------------------------//
  static const String eventNotif = 'event_notif';
  static const String eventDiscuss = 'event_disqus';
  static const String eventAds = 'ads_test';

  /// connect to socket
  void connectToSocket(VoidCallback onEvent, {required String host, required Map<String, dynamic> options}) {
    print('host socket io');
    print(host);
    print(options);
    _socket = io(host, options);

    _socket?.connect();

    _socket?.onConnect((message) {
      'Your connected to socket'.logger();
      _eventService.notifyRootSocketConnected(message);
    });

    _socket?.onDisconnect((message) {
      print(host);
      'Your disconnected from socket'.logger();
      _eventService.notifyRootSocketDisconnected(message);
    });

    _socket?.onConnectError((message) {
      'Your connection error from socket $onEvent $host'.logger();
      _eventService.notifyRootSocketError(message);
    });

    var startTime = DateTime.now();
    _socket?.emit("ping", (_) {
      var endTime = DateTime.now();
      var duration = endTime.difference(startTime).inMilliseconds;
      print("Ping duration: $duration ms");
    });

    onEvent();
  }

  /// emit something
  emit(String event, [dynamic data]) {
    'Emit data $data'.logger();
    _socket?.emit(event, data);
  }

  /// check socket is running or not
  bool get isRunning => _socket?.connected ?? false;

  /// close socket connection
  void closeSocket() {
    'Dispose socket'.logger();
    _socket?.dispose();
  }

  /// socket events
  void events<T>(String name, Function(T result) action) => _socket?.on(name, (data) => action(data));
}
