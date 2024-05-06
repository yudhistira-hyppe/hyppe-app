import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PauseLiveView extends StatelessWidget {
  final LinkStreamModel data;
  const PauseLiveView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(
      builder: (context, notifier, _) {
        return ClipRect(
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
                      const Text(
                        'Siaran LIVE dijeda',
                        // tn.liveBroadcastIsPausedViewersCannotCurrentlySeeYou ?? 'Siaran LIVE dijeda, penonton saat ini tidak dapat melihatmu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      sixteenPx,
                      if ((notifier.statusAgora ==
                              RemoteVideoState.remoteVideoStateStopped || notifier.statusAgora ==
                              RemoteVideoState.remoteVideoStateStopped) && (notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted || notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonSdkInBackground))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TweenAnimationBuilder<Duration>(
                          duration: const Duration(minutes: 5, seconds: 0),
                          tween: Tween(begin: const Duration(minutes: 5, seconds: 0), end: Duration.zero),
                          onEnd: () {
                            notifier.exitStreaming(context, data).whenComplete(() async {
                              await context.read<ViewStreamingNotifier>().destoryPusher();
                              Routing().moveBack();
                            });
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
                      sixteenPx,
                      const Text(
                        'Host akan segera kembali',
                        // tn.theLiveBroadcastWillEndAfterTheCountdown ?? 'Siaran LIVE akan berakhir setelah hitung mundur',
                        style: TextStyle(
                          color: kHyppeBurem,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      sixteenPx,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
