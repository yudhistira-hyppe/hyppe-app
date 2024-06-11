import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class ForceStop extends StatelessWidget {
  const ForceStop({super.key});

  @override
  Widget build(BuildContext context) {
    var languange = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Container(
        color: Colors.black.withOpacity(0.5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}livestop.svg',
              defaultColor: false,
            ),
            twelvePx,
            Text(
              languange.localeDatetime == 'id' ? "LIVE akan dihentikan dalam" : "LIVE will end in",
              style: const TextStyle(color: kHyppeLightButtonText, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TweenAnimationBuilder<Duration>(
                duration: notifier.timeCountdownReported,
                tween: Tween(begin: notifier.timeCountdownReported, end: Duration.zero),
                onEnd: () {
                  bool blockLive = false;
                  bool blockUser = false;
                  if (notifier.dataBanned?.statusBannedStreaming ?? false) {
                    blockUser = true;
                  } else {
                    blockLive = true;
                  }
                  notifier.endLive(
                    context,
                    context.mounted,
                    isBack: false,
                    blockLive: blockLive,
                    blockUser: blockUser,
                  );
                },
                builder: (BuildContext context, Duration value, Widget? child) {
                  final seconds = value.inSeconds % 60;
                  final minutes = value.inMinutes;
                  final hours = value.inHours;

                  var time = '${hours != 0 ? '$hours : ' : ''} ${minutes != 0 ? '$minutes : ' : ''} ${seconds < 10 ? '0' : ''}$seconds ';

                  return CustomTextWidget(
                    textToDisplay: '$time ${languange.localeDatetime == 'id' ? 'dtk' : 's'} ',
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kHyppeTextPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
