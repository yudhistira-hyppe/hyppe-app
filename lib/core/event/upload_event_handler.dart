import 'package:dio/dio.dart' as dio;
import 'package:hyppe/core/services/event_service.dart';

class UploadEventHandler implements EventHandler {
  void onUploadReceiveProgress(double count, double total) {}

  void onUploadSendProgress(double count, double total) {}

  void onUploadFinishingUp() {}

  void onUploadSuccess(dio.Response response) {}

  void onUploadFailed(dio.DioError message) {}

  void onUploadCancel(dio.DioError message) {}
}
