import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:hyppe/core/arguments/progress_upload_argument.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

import 'package:hyppe/core/models/collection/utils/reaction/like_interactive.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';

class StreamService {
  /// Uploading stream
  late StreamController<dio.DioError> _uploadFailedController;
  late StreamController<dio.DioError> _uploadCancelController;
  late StreamController<dio.Response> _uploadSuccessController;
  late StreamController<dio.Response> _uploadFinishingUp;
  late StreamController<ProgressUploadArgument> _uploadSendProgressController;
  late StreamController<ProgressUploadArgument> _uploadReceiveProgressController;

  /// Interactive stream
  late StreamController<ReactionInteractive> _reactionContentController;
  late StreamController<LikeInteractive> _likeContentController;

  /// Root socket stream
  late StreamController<dynamic> _rootSocketController;

  /// Cloud messaging stream
  late StreamController<RemoteMessage> _cloudMessagingController;
  late StreamController<String> _cloudFcmTokenRefreshController;

  /// Socket chat stream
  late StreamController<MessageDataV2> _messageReceivedController;

  StreamService() {
    _uploadFailedController = StreamController<dio.DioError>.broadcast();
    _uploadCancelController = StreamController<dio.DioError>.broadcast();
    _uploadSuccessController = StreamController<dio.Response>.broadcast();
    _uploadFinishingUp = StreamController<dio.Response>.broadcast();
    _uploadSendProgressController = StreamController<ProgressUploadArgument>.broadcast();
    _uploadReceiveProgressController = StreamController<ProgressUploadArgument>.broadcast();
    _reactionContentController = StreamController<ReactionInteractive>.broadcast();
    _likeContentController = StreamController<LikeInteractive>.broadcast();
    _rootSocketController = StreamController<dynamic>.broadcast();
    _cloudMessagingController = StreamController<RemoteMessage>.broadcast();
    _cloudFcmTokenRefreshController = StreamController<String>.broadcast();
    _messageReceivedController = StreamController<MessageDataV2>.broadcast();
  }

  StreamController<dio.DioError> get uploadFailed => _uploadFailedController;
  StreamController<dio.DioError> get uploadCancel => _uploadCancelController;
  StreamController<dio.Response> get uploadSuccess => _uploadSuccessController;
  StreamController<dio.Response> get uploadFinishingUp => _uploadFinishingUp;
  StreamController<ProgressUploadArgument> get uploadSendProgress => _uploadSendProgressController;
  StreamController<ProgressUploadArgument> get uploadReceiveProgress => _uploadReceiveProgressController;
  StreamController<ReactionInteractive> get reactionContent => _reactionContentController;
  StreamController<LikeInteractive> get likeContent => _likeContentController;
  StreamController<dynamic> get rootSocket => _rootSocketController;
  StreamController<RemoteMessage> get cloudMessaging => _cloudMessagingController;
  StreamController<String> get cloudFcmTokenRefresh => _cloudFcmTokenRefreshController;
  StreamController<MessageDataV2> get messageReceived => _messageReceivedController;

  void reset() {
    _uploadFailedController.close();
    _uploadCancelController.close();
    _uploadFinishingUp.close();
    _uploadSuccessController.close();
    _uploadSendProgressController.close();
    _uploadReceiveProgressController.close();
    _reactionContentController.close();
    _likeContentController.close();
    _rootSocketController.close();
    _cloudMessagingController.close();
    _cloudFcmTokenRefreshController.close();
    _messageReceivedController.close();

    _uploadFailedController = StreamController<dio.DioError>.broadcast();
    _uploadCancelController = StreamController<dio.DioError>.broadcast();
    _uploadSuccessController = StreamController<dio.Response>.broadcast();
    _uploadFinishingUp = StreamController<dio.Response>.broadcast();
    _uploadSendProgressController = StreamController<ProgressUploadArgument>.broadcast();
    _uploadReceiveProgressController = StreamController<ProgressUploadArgument>.broadcast();
    _reactionContentController = StreamController<ReactionInteractive>.broadcast();
    _likeContentController = StreamController<LikeInteractive>.broadcast();
    _rootSocketController = StreamController<dynamic>.broadcast();
    _cloudMessagingController = StreamController<RemoteMessage>.broadcast();
    _cloudFcmTokenRefreshController = StreamController<String>.broadcast();
    _messageReceivedController = StreamController<MessageDataV2>.broadcast();
  }
}
