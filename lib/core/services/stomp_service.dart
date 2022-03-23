// import 'package:hyppe/core/extension/log_extension.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';

// class StompService {
//   /// stompClient instance
//   StompClient? _stomp;

//   //-------------------------------- Wallet Subscribe Events --------------------------------------//
//   static const String WALLET_RECV = '/queue/WALLET_RECV/';
//   static const String WALLET_REQ = '/app/WALLET_REQ';

//   //-------------------------------- Wallet Response Events --------------------------------------//
//   static const String ACQUIRING = 'ACQUIRING';
//   static const String MINI_DANA = 'MINI_DANA';

//   //-------------------------------- Wallet Response --------------------------------------//
//   static const String SUCCESS = 'SUCCESS';

//   /// connect to stompClient
//   void connectToStomp(Function(StompFrame stompFrame) onConnect,
//       {required String host, Map<String, String>? stompConnectHeaders, Function(StompFrame stompFrame)? onStompError, Function? beforeConnect}) {
//     _stomp = StompClient(
//       config: StompConfig.SockJS(
//         url: host,
//         onConnect: onConnect,
//         beforeConnect: () async {
//           if (beforeConnect != null) await beforeConnect();
//         },
//         stompConnectHeaders: stompConnectHeaders,
//         webSocketConnectHeaders: {'SECURED': 'EVENT'},
//         onWebSocketError: (dynamic error) => error.logger(),
//         onStompError: (stompFrame) {
//           'On Stomp Error ${stompFrame.body}'.logger();
//           if (onStompError != null) onStompError(stompFrame);
//         },
//       ),
//     );

//     _stomp!.activate();
//   }

//   /// send something
//   send(String eventDestination, dynamic data) {
//     'Send data $data'.logger();
//     _stomp!.send(destination: eventDestination, body: data);
//   }

//   /// check stompClient is running or not
//   bool get isRunning => _stomp?.connected ?? false;

//   /// close stompClient connection
//   void closeStomp() {
//     'Dispose stomp'.logger();
//     _stomp?.deactivate();
//   }

//   /// stomp events
//   void eventsSubscribe(String name, Function(StompFrame result) action, {Map<String, String>? headers}) =>
//       _stomp?.subscribe(destination: name, callback: (e) => action(e), headers: headers);
// }
