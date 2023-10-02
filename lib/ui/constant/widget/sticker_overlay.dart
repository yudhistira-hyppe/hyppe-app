import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:gif_view/gif_view.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class StickerOverlay extends StatelessWidget {
  final List<StickerModel>? stickers;
  final double width;
  final double height;
  final bool fullscreen;
  final bool isPause;
  final bool canPause;
  

  const StickerOverlay({
    super.key,
    required this.stickers,
    required this.width,
    required this.height,
    this.fullscreen = true,
    this.isPause = false,
    this.canPause = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (StickerModel sticker in stickers ?? [])
          fullscreen
              ? viewSticker(sticker)
              : FittedBox(fit: BoxFit.contain, child: viewSticker(sticker))
      ],
    );
  }

  Widget viewSticker(StickerModel sticker) {
    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Transform(
            transform: Matrix4.fromList(
              sticker.position?.map((i) => i.toDouble()).toList() ?? [],
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              // child: Image.network(sticker.image ?? ''),
              child: canPause && (sticker.image ?? '').toLowerCase().endsWith('.gif')
                  ? GifWidget(url: sticker.image ?? '', isPause: isPause)
                  : OptimizedCacheImage(imageUrl: sticker.image ?? ''),
            ),
          ),
        ),
      ),
    );
  }
}

class GifWidget extends StatefulWidget {
  final String url;
  final bool isPause;

  const GifWidget({
    super.key,
    required this.url,
    required this.isPause,
  });

  @override
  State<GifWidget> createState() => _GifWidgetState();
}

class _GifWidgetState extends State<GifWidget> {
  ValueNotifier<int> notifier = ValueNotifier(0);
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController();
    notifier = ValueNotifier(0);
    widget.isPause ? controller.pause() : controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void didUpdateWidget(covariant GifWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPause != widget.isPause) {
      if (widget.isPause) {
        controller.pause();
        notifier.value = controller.currentIndex;
      } else {
        controller.play(initialFrame: notifier.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GifView.network(widget.url, controller: controller);
  }
}
