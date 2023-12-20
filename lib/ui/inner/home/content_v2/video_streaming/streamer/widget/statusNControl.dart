import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class StatusNControl extends StatelessWidget {
  const StatusNControl({super.key});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Expanded(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(color: kHyppeDanger, borderRadius: BorderRadius.circular(3)),
              child: const Text(
                'LIVE',
                style: TextStyle(color: kHyppeTextPrimary, wordSpacing: 10),
              ),
            ),
            GestureDetector(
              onTap: () {
                ShowBottomSheet.onStreamWatchersStatus(context, notifier);
              },
              child: Container(
                width: 50 * SizeConfig.scaleDiagonal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: kHyppeTransparent, borderRadius: BorderRadius.circular(3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: kHyppeTextPrimary,
                      size: 12,
                    ),
                    sixPx,
                    Text(
                      '${notifier.totViews}',
                      style: const TextStyle(color: kHyppeTextPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                IconButtonLive(
                    widget: const Icon(
                      Icons.power_settings_new,
                      color: kHyppeTextPrimary,
                    ),
                    onPressed: () async {
                      await ShowGeneralDialog.generalDialog(
                        context,
                        titleText: tn.endofLIVEBroadcast,
                        bodyText: tn.areYouSureYouWantToEndTheLIVEBroadcast,
                        maxLineTitle: 1,
                        maxLineBody: 4,
                        functionPrimary: () async {
                          notifier.endLive(context, context.mounted);
                        },
                        functionSecondary: () {
                          Routing().moveBack();
                        },
                        titleButtonPrimary: "${tn.endNow}",
                        titleButtonSecondary: "${tn.cancel}",
                        barrierDismissible: true,
                        isHorizontal: false,
                      );
                    }),
                sixteenPx,
                IconButtonLive(
                    widget: Icon(
                      notifier.mute ? Icons.mic_off_outlined : Icons.mic_none_sharp,
                      color: kHyppeTextPrimary,
                    ),
                    onPressed: () {
                      notifier.soundMute();
                    }),
                sixteenPx,
                IconButtonLive(
                    widget: const CustomIconWidget(
                      width: 24,
                      iconData: "${AssetPath.vectorPath}flip.svg",
                      defaultColor: false,
                    ),
                    onPressed: () {
                      notifier.flipCamera();
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
