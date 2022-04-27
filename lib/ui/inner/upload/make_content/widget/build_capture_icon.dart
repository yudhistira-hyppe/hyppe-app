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
        child: CustomIconButtonWidget(
          onPressed: () {
            if (notifier.isRecordingVideo) {
              if (notifier.featureType != FeatureType.pic && notifier.selectedDuration != 0) {
                if (notifier.progressHuman < notifier.selectedDuration) {
                  if (!notifier.isRecordingPaused) {
                    notifier.onPauseRecordedVideo(context);
                  } else {
                    notifier.onResumeRecordedVideo(context);
                  }
                } else {
                  ShowBottomSheet().onShowColouredSheet(context, notifier.language.isThisOkayClickOkToContinue!).then((value) {
                    if (value) notifier.onStopRecordedVideo(context);
                  });
                }
              } else {
                if (!notifier.isRecordingPaused) {
                  notifier.onPauseRecordedVideo(context);
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
}
