import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PauseLiveView extends StatefulWidget {
  final LinkStreamModel data;
  const PauseLiveView({super.key, required this.data});

  @override
  State<PauseLiveView> createState() => _PauseLiveViewState();
}

class _PauseLiveViewState extends State<PauseLiveView> {
  bool loading = false;

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var notifier = Provider.of<ViewStreamingNotifier>(context, listen: false);
      if (notifier.dataStreaming.pause ?? false) {}

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(builder: (_, notifier, __) {
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
                    // Text(
                    //   "${notifier.dataStreaming.pauseDate} ${notifier.dataStreaming.pauseDate != null}",
                    //   style: TextStyle(color: Colors.white),
                    // ),
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
                    // if ((notifier.statusAgora == RemoteVideoState.remoteVideoStateStopped || notifier.statusAgora == RemoteVideoState.remoteVideoStateStopped) &&
                    //     (notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted || notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonSdkInBackground))
                    notifier.loadingPause
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: TweenAnimationBuilder<Duration>(
                              duration: notifier.dataStreaming.pauseDate != null ? notifier.durationPause : const Duration(minutes: 5, seconds: 0),
                              tween: Tween(begin: notifier.dataStreaming.pauseDate != null ? notifier.durationPause : const Duration(minutes: 5, seconds: 0), end: Duration.zero),
                              onEnd: () {
                                // notifier.exitStreaming(context, widget.data).whenComplete(() async {
                                //   await context.read<ViewStreamingNotifier>().destoryPusher();
                                //   Routing().moveBack();
                                // });
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
    });
  }
}
