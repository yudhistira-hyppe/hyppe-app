import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:provider/provider.dart';

class StatusNControl extends StatelessWidget {
  const StatusNControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Expanded(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(color: kHyppeDanger, borderRadius: BorderRadius.circular(3)),
              child: Text(
                'LIVE',
                style: TextStyle(color: kHyppeTextPrimary, wordSpacing: 10),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: kHyppeTransparent, borderRadius: BorderRadius.circular(3)),
              child: Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: kHyppeTextPrimary,
                    size: 12,
                  ),
                  twoPx,
                  Text(
                    '100',
                    style: TextStyle(color: kHyppeTextPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButtonLive(
                    widget: Icon(
                      Icons.power_settings_new,
                      color: kHyppeTextPrimary,
                    ),
                    onPressed: () {}),
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
                    widget: CustomIconWidget(
                      width: 24,
                      iconData: "${AssetPath.vectorPath}flip.svg",
                      defaultColor: false,
                    ),
                    onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}
