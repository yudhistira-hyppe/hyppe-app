import 'package:dio/dio.dart' as dio;
import 'package:hyppe/core/services/event_service.dart';

class UploadEventHandler implements EventHandler {
  void onUploadReceiveProgress(int count, int total) {}

  void onUploadSendProgress(int count, int total) {}

  void onUploadFinishingUp() {}

  void onUploadSuccess(dio.Response response) {}

  void onUploadFailed(dio.DioError message) {}

  void onUploadCancel(dio.DioError message) {}
}
