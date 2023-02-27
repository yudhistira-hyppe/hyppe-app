import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/event/event_key.dart';
import 'package:hyppe/core/event/upload_event_handler.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';

class ProcessUploadComponent extends StatefulWidget {
  final double topMargin;
  final bool showAlert;
  const ProcessUploadComponent({Key? key, this.topMargin = 10.0, this.showAlert = true}) : super(key: key);

  @override
  State<ProcessUploadComponent> createState() => _ProcessUploadComponentState();
}

class _ProcessUploadComponentState extends State<ProcessUploadComponent> with UploadEventHandler {
  final Routing _routing = Routing();
  final EventService _eventService = EventService();
  final TranslateNotifierV2 _language = TranslateNotifierV2();

  late UploadNotifier _uploadNotifier;
  late PreUploadContentNotifier _preUploadContentNotifier;

  @override
  void initState() {
    _uploadNotifier = Provider.of<UploadNotifier>(materialAppKey.currentContext ?? context, listen: false);
    _preUploadContentNotifier = Provider.of<PreUploadContentNotifier>(materialAppKey.currentContext ?? context, listen: false);
    _eventService.addUploadHandler(EventKey.uploadEventKey, this);
    print("================initState");
    super.initState();
  }

  @override
  void onUploadReceiveProgress(double count, double total) {
    print("================onUploadReceiveProgress");
    _uploadNotifier.message = "${_language.translate.processUpload}";
    if (!_uploadNotifier.isUploading) {
      _uploadNotifier.isUploading = true;
    }
    _uploadNotifier.progress = count / total;
  }

  @override
  void onUploadSendProgress(double count, double total) {
    print("================onUploadSendProgress");
    _uploadNotifier.message = "${_language.translate.processUpload}";
    if (!_uploadNotifier.isUploading) {
      _uploadNotifier.isUploading = true;
    }
    _uploadNotifier.progress = count / total;
  }

  @override
  void onUploadFinishingUp() {
    _uploadNotifier.message = "${_language.translate.finishingUp}...";
  }

  @override
  void onUploadSuccess(dio.Response response) {
    print("================onUploadSuccess");
    _uploadNotifier.isUploading = false;
    'Upload Success with message ${response.statusMessage}'.logger();
    _uploadNotifier.message = "${_language.translate.contentCreatedSuccessfully}";
    if (widget.showAlert) {
      _uploadNotifier.reset();
      //bool isCheckedOwnership = _eventService.streamService.uploadContentWithOwnership as bool;
      bool isCheckedOwnership = _preUploadContentNotifier.certifiedTmp; // get certified status

      'Upload Success with certified checked $isCheckedOwnership'.logger();

      if (isCheckedOwnership) {
        ShowBottomSheet.onShowSuccessPostContentOwnership(materialAppKey.currentContext ?? context);
      } else {
        ShowBottomSheet().onShowColouredSheet(materialAppKey.currentContext ?? context, _uploadNotifier.message, color: kHyppeTextSuccess, maxLines: 2);
      }
    }
  }

  @override
  void onUploadFailed(dio.DioError message) {
    _uploadNotifier.isUploading = false;
    'Upload Failed with message ${message.message}'.logger();
    _uploadNotifier.message = '${_language.translate.contentCreatedFailedWithMessage} ${message.message}';
    ShowBottomSheet().onShowColouredSheet(context, _uploadNotifier.message, color: kHyppeDanger, maxLines: 2, iconSvg: 'close.svg');
    // _showSnackBar(color: kHyppeDanger, message: _uploadNotifier.message, icon: 'close.svg');
    _uploadNotifier.reset();
  }

  @override
  void dispose() {
    print("========dispose");
    _uploadNotifier.reset(isNotify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<UploadNotifier>(context);
    print("========isuploading ${notifier.isUploading}");

    if (notifier.isUploading) {
      return Container(
        height: 35,
        width: 343,
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: widget.topMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.message,
                      textStyle: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                // Container(
                //   height: 30,
                //   child: Consumer<PreUploadContentNotifier>(
                //     builder: (_, value, __) {
                //       return CustomTextButton(
                //         onPressed: () {
                //           if (value.progressDev == 1.0) {
                //             print('Do nothing, because is in Finishing up... state');
                //           } else {
                //             if (value.isLoading) {
                //               context.read<PreUploadContentNotifier>().cancelUpload = true;
                //             } else {
                //               context.read<PreUploadContentNotifier>().showProgress = false;
                //             }
                //           }
                //         },
                //         style: Theme.of(context).textButtonTheme.style.copyWith(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                //         child: CustomTextWidget(
                //           textToDisplay: value.isLoading ? value.language.cancelPost : 'Ok',
                //           textStyle: Theme.of(context).textTheme.button.apply(
                //                 color: value.progressDev == 1.0
                //                     ? Theme.of(context).colorScheme.secondary
                //                     : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                //               ),
                //         ),
                //       );
                //     },
                //   ),
                // )
              ],
            ),
            onePx,
            ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: LinearProgressIndicator(
                value: notifier.progress,
                backgroundColor: Theme.of(context).textTheme.button?.color?.withOpacity(0.4),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            )
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // String iconData(FeatureType? featureType) {
  //   switch (featureType) {
  //     case FeatureType.vid:
  //       return "${AssetPath.vectorPath}vid.svg";
  //     case FeatureType.diary:
  //       return "${AssetPath.vectorPath}diary.svg";
  //     case FeatureType.pic:
  //       return "${AssetPath.vectorPath}pic.svg";
  //     default:
  //       return "${AssetPath.vectorPath}story.svg";
  //   }
  // }

  void _showSnackBar({
    String? icon,
    required Color color,
    required String message,
  }) {
    _routing.showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              fromSnackBar: true,
              iconSvg: icon != null ? "${AssetPath.vectorPath}$icon" : null,
            ),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
}

class UploadNotifier extends ChangeNotifier {
  final TranslateNotifierV2 _language = TranslateNotifierV2();

  double _progress = 0.0;
  bool _isUploading = false;
  String _message = "";

  double get progress => _progress;
  bool get isUploading => _isUploading;
  String get message => _message;

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  set isUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  void reset({isNotify = true}) {
    _progress = 0.0;
    _isUploading = false;
    _message = _language.translate.contentUploaded ?? '';
    if (isNotify) {
      notifyListeners();
    }
  }
}
