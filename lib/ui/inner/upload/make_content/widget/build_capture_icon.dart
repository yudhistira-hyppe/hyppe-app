import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildCaptureIcon extends StatelessWidget {
  final bool? mounted;
  const BuildCaptureIcon({Key? key, this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MakeContentNotifier>(
      builder: (context, notifier, child) => SizedBox(
        height: 105 * SizeConfig.scaleDiagonal,
        child: notifier.isVideo
            ? notifier.conditionalCaptureVideoIcon()
                ? GestureDetector(
                    onTap: () {
                      submitContent(context, notifier);
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  color: const Color(0xffCECECE),
                                  borderRadius: BorderRadius.circular(65)),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        Positioned.fill(child: CircularProgressIndicator())
                      ],
                    ),
                  )
                : CustomIconButtonWidget(
                    onPressed: () {
                      // context.read<CameraNotifier>().showEffect(isClose: true);
                      submitContent(context, notifier);
                    },
                    iconData: notifier.isVideo
                        ? notifier.conditionalCaptureVideoIcon()
                            ? "${AssetPath.vectorPath}recording.svg"
                            : "${AssetPath.vectorPath}video.svg"
                        : "${AssetPath.vectorPath}photo.svg",
                  )
            : CustomIconButtonWidget(
                onPressed: () {
                  // context.read<CameraNotifier>().showEffect(isClose: true);
                  submitContent(context, notifier);
                },
                iconData: notifier.isVideo
                    ? notifier.conditionalCaptureVideoIcon()
                        ? "${AssetPath.vectorPath}recording.svg"
                        : "${AssetPath.vectorPath}video.svg"
                    : "${AssetPath.vectorPath}photo.svg",
              ),
      ),
    );
  }

  submitContent(BuildContext context, MakeContentNotifier notifier) {
    if (notifier.isRecordingVideo) {
      if (notifier.featureType != FeatureType.pic &&
          notifier.selectedDuration != 0) {
        if (notifier.progressHuman < notifier.selectedDuration) {
          context.read<MakeContentNotifier>().onStopRecordedVideo(context);
          // if (!notifier.isRecordingPaused) {
          //   notifier.onPauseRecordedVideo(context);
          // } else {
          //   notifier.onResumeRecordedVideo(context);
          // }
        } else {
          ShowBottomSheet()
              .onShowColouredSheet(
                  context, notifier.language.isThisOkayClickOkToContinue ?? '')
              .then((value) {
            if (value) notifier.onStopRecordedVideo(context);
          });
        }
      } else {
        if (!notifier.isRecordingPaused) {
          context.read<MakeContentNotifier>().onStopRecordedVideo(context);
          // notifier.onPauseRecordedVideo(context);
        } else {
          notifier.onResumeRecordedVideo(context);
        }
      }
    } else {
      if (notifier.isVideo) {
        notifier.onRecordedVideo(context);
      } else {
        notifier.onTakePicture(context);
      }
    }
  }
}
