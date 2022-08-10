import 'package:dio/dio.dart' as dio;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:hyppe/core/event/discuss_event_handler.dart';
import 'package:hyppe/core/event/upload_event_handler.dart';
import 'package:hyppe/core/event/cloud_messaging_handler.dart';
import 'package:hyppe/core/event/interactive_event_handler.dart';
import 'package:hyppe/core/event/root_socket_event_handler.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

import 'package:hyppe/core/services/stream_service.dart';
import 'package:hyppe/core/arguments/progress_upload_argument.dart';

import 'package:hyppe/core/models/collection/utils/reaction/like_interactive.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';

abstract class EventHandler {}

class EventService {
  EventService._internal();

  static final EventService _singleton = EventService._internal();

  factory EventService() {
    return _singleton;
  }

  Map<String, UploadEventHandler> _uploadHandlers = {};
  Map<String, InteractiveEventHandler> _interactiveHandlers = {};
  Map<String, RootSocketEventHandler> _rootSocketHandlers = {};
  Map<String, CloudMessagingEventHandler> _cloudMessagingHandlers = {};
  Map<String, DiscussEventHandler> _discussHandlers = {};

  StreamService get streamService => StreamService();

  void addUploadHandler(String identifier, UploadEventHandler handler) {
    _uploadHandlers[identifier] = handler;
  }

  void addInteractiveHandler(String identifier, InteractiveEventHandler handler) {
    _interactiveHandlers[identifier] = handler;
  }

  void addRootSocketHandler(String identifier, RootSocketEventHandler handler) {
    _rootSocketHandlers[identifier] = handler;
  }

  void addCloudMessagingHandler(String identifier, CloudMessagingEventHandler handler) {
    _cloudMessagingHandlers[identifier] = handler;
  }

  void addDiscussHandler(String identifier, DiscussEventHandler handler) {
    _discussHandlers[identifier] = handler;
  }

  void removeUploadHandler(String identifier) {
    _uploadHandlers.remove(identifier);
  }

  void removeInteractiveHandler(String identifier) {
    _interactiveHandlers.remove(identifier);
  }

  void removeRootSocketHandler(String identifier) {
    _rootSocketHandlers.remove(identifier);
  }

  void removeCloudMessagingHandler(String identifier) {
    _cloudMessagingHandlers.remove(identifier);
  }

  void removeDiscussHandler(String identifier) {
    _discussHandlers.remove(identifier);
  }

  UploadEventHandler? getUploadEventHandler(String identifier) {
    return _uploadHandlers[identifier];
  }

  InteractiveEventHandler? getInteractiveEventHandler(String identifier) {
    return _interactiveHandlers[identifier];
  }

  RootSocketEventHandler? getRootSocketEventHandler(String identifier) {
    return _rootSocketHandlers[identifier];
  }

  CloudMessagingEventHandler? getCloudMessagingEventHandler(String identifier) {
    return _cloudMessagingHandlers[identifier];
  }

  DiscussEventHandler? getDiscussEventHandler(String identifier) {
    return _discussHandlers[identifier];
  }

  void cleanUp() {
    _uploadHandlers = {};
    _interactiveHandlers = {};
    _rootSocketHandlers = {};
    _cloudMessagingHandlers = {};
    _discussHandlers = {};
  }

  // Uplaod
  Future notifyUploadReceiveProgress(ProgressUploadArgument receiveProgress) async {
    streamService.uploadReceiveProgress.add(receiveProgress);

    for (var element in _uploadHandlers.values) {
      element.onUploadReceiveProgress(receiveProgress.count, receiveProgress.total);
    }
  }

  Future notifyUploadSendProgress(ProgressUploadArgument sendProgress) async {
    streamService.uploadSendProgress.add(sendProgress);

    for (var element in _uploadHandlers.values) {
      element.onUploadSendProgress(sendProgress.count, sendProgress.total);
    }
  }

  void notifyUploadFinishingUp(dio.Response response) {
    streamService.uploadFinishingUp.add(response);

    for (var element in _uploadHandlers.values) {
      element.onUploadFinishingUp();
    }
  }

  void notifyUploadSuccess(dio.Response response) {
    streamService.uploadSuccess.add(response);

    for (var element in _uploadHandlers.values) {
      element.onUploadSuccess(response);
    }
  }

  void notifyUploadFailed(dio.DioError message) {
    streamService.uploadFailed.add(message);

    for (var element in _uploadHandlers.values) {
      element.onUploadFailed(message);
    }
  }

  void notifyUploadCancel(dio.DioError message) {
    streamService.uploadCancel.add(message);

    for (var element in _uploadHandlers.values) {
      element.onUploadCancel(message);
    }
  }

  // Interactive
  void notifyReactionContent(ReactionInteractive respons) {
    streamService.reactionContent.add(respons);

    for (var element in _interactiveHandlers.values) {
      element.onReactionContent(respons);
    }
  }

  void notifyLikeContent(LikeInteractive respons) {
    streamService.likeContent.add(respons);

    for (var element in _interactiveHandlers.values) {
      element.onLikeContent(respons);
    }
  }

  // RootSocket
  void notifyRootSocketConnected(dynamic message) {
    streamService.rootSocket.add(message);

    for (var element in _rootSocketHandlers.values) {
      element.onRootSocketConnected(message);
    }
  }

  void notifyRootSocketDisconnected(dynamic message) {
    streamService.rootSocket.add(message);

    for (var element in _rootSocketHandlers.values) {
      element.onRootSocketDisconnected(message);
    }
  }

  void notifyRootSocketError(dynamic message) {
    streamService.rootSocket.add(message);

    for (var element in _rootSocketHandlers.values) {
      element.onRootSocketError(message);
    }
  }

  void notifyRootSocketMessage(dynamic message) {
    streamService.rootSocket.add(message);

    for (var element in _rootSocketHandlers.values) {
      element.onRootSocketMessage(message);
    }
  }

  // CloudMessaging
  void notifyCloudFcmTokenRefresh(String token) {
    streamService.cloudFcmTokenRefresh.add(token);

    for (var element in _cloudMessagingHandlers.values) {
      element.onFcmTokenRefresh(token);
    }
  }

  void notifyForegroundMessage(RemoteMessage message) {
    streamService.cloudMessaging.add(message);

    for (var element in _cloudMessagingHandlers.values) {
      element.onForegroundMessage(message);
    }
  }

  void notifyMessageOpenedApp(RemoteMessage message) {
    streamService.cloudMessaging.add(message);

    for (var element in _cloudMessagingHandlers.values) {
      element.onMessageOpenedApp(message);
    }
  }

  // Discuss
  void notifyMessageReceived(MessageDataV2 message) {
    streamService.messageReceived.add(message);

    for (var element in _discussHandlers.values) {
      element.onMessageReceived(message);
    }
  }
}
