import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class GiftDeluxe extends StatefulWidget {
  const GiftDeluxe({super.key});

  @override
  State<GiftDeluxe> createState() => _GiftDeluxeState();
}

class _GiftDeluxeState extends State<GiftDeluxe> {
  int currentAnimationIndex = 0;
  Timer? _timer;
  Timer? _time2;
  bool show = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _time2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(
      builder: (_, notifier, __) => SafeArea(
        child: Stack(
          // fit: StackFit.expand,
          children: [
            if (notifier.giftDelux.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 540 / 960,
                  child: notifier.giftDelux.isEmpty
                      ? const SizedBox.shrink()
                      : Lottie.network(
                          notifier.giftDelux[0].urlGift ?? '',
                          repeat: true,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            // if (notifier.giftDelux.isNotEmpty) Text("timer ${notifier.giftDelux[0].urlGift}"),
          ],
        ),
      ),
    );
  }
}
