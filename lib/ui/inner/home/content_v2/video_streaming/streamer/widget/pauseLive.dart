import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class PauseLive extends StatelessWidget {
  final StreamerNotifier notifier;
  const PauseLive({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;

    final timePause = notifier.timePause;
    final date2 = DateTime.now();
    final time = date2.difference(timePause ?? date2).inSeconds;

    var finaltime = 300 - time - 1;

    var duration = Duration(seconds: finaltime > 0 ? finaltime : 2);

    return SizedBox(
      // padding: const EdgeInsets.only(bottom: 100),
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tn.liveBroadcastIsPausedViewersCannotCurrentlySeeYou ?? 'Siaran LIVE dijeda, penonton saat ini tidak dapat melihatmu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TweenAnimationBuilder<Duration>(
                        duration: notifier.timePause == null ? const Duration(minutes: 5, seconds: 0) : duration,
                        tween: Tween(begin: notifier.timePause == null ? const Duration(minutes: 5, seconds: 0) : duration, end: Duration.zero),
                        onEnd: () {
                          context.read<StreamerNotifier>().endLive(context, context.mounted, isBack: false);
                        },
                        builder: (BuildContext context, Duration value, Widget? child) {
                          final minutes = value.inMinutes;
                          final seconds = value.inSeconds % 60;
                          return CustomTextWidget(
                            textToDisplay: '${minutes < 10 ? '0' : ''}$minutes : ${seconds < 10 ? '0' : ''}$seconds',
                            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: kHyppeTextPrimary,
                                  fontSize: 60,
                                  fontWeight: FontWeight.w700,
                                ),
                          );
                        },
                      ),
                    ),
                    Text(
                      tn.theLiveBroadcastWillEndAfterTheCountdown ?? 'Siaran LIVE akan berakhir setelah hitung mundur',
                      style: const TextStyle(
                        color: kHyppeBurem,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sixteenPx,
                    CustomTextButton(
                      onPressed: () {
                        if (!notifier.isloadingButton) {
                          context.read<StreamerNotifier>().resumeStreamer(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 48),
                        child: Text(
                          tn.continueLive ?? 'Lanjutkan LIVE',
                          style: const TextStyle(
                            color: kHyppeTextPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
