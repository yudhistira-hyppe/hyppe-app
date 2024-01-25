import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/event/event_key.dart';
import 'package:hyppe/core/event/upload_event_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';

import '../../../app.dart';

class ShowOverlayLoading extends StatefulWidget {
  const ShowOverlayLoading({super.key});

  @override
  State<ShowOverlayLoading> createState() => _ShowOverlayLoadingState();
}

class _ShowOverlayLoadingState extends State<ShowOverlayLoading> with UploadEventHandler {
  final EventService _eventService = EventService();
  late AccountPreferencesNotifier _uploadNotifier;

  @override
  void initState() {
    _uploadNotifier = Provider.of<AccountPreferencesNotifier>(context, listen: false);
    _eventService.addUploadHandler(EventKey.uploadEventKey, this);
    super.initState();
  }

  @override
  void dispose() {
    _eventService.addUploadHandler(EventKey.uploadEventKey, this);
    super.dispose();
  }

  @override
  void onUploadSendProgress(double count, double total, bool isCompressing) {
    globalPreventAction = true;
    _uploadNotifier.progress = '${(count / total * 100).toStringAsFixed(0)}%';
  }

  @override
  void onUploadSuccess(Response response) {
    globalPreventAction = false;
    'Upload Success with message ${response.statusMessage}'.logger();
  }

  @override
  void onUploadFailed(DioError message) {
    globalPreventAction = false;
    'Upload Failed with message ${message.message}'.logger();
  }

  @override
  void onUploadCancel(DioError message) {
    globalPreventAction = false;
    'Upload Canceled with message ${message.message}'.logger();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Container(
        color: Colors.black38,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Material(
              color: Colors.transparent,
              child: Text(
                notifier.progress,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 16 * SizeConfig.scaleDiagonal,
                ),
              ),
            ),
            const UnconstrainedBox(
              child: CustomLoading(),
            ),
            // CustomTextButton(
            //   child: const CustomIconWidget(
            //     defaultColor: false,
            //     iconData: "${AssetPath.vectorPath}close.svg",
            //   ),
            //   onPressed: () {
            //     // notifier.cancelUpload = true;
            //     // notifier.uploadProgress?.remove();
            //     notifier.cancelRequest();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
