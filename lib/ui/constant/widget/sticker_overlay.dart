import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/ui/constant/widget/custom_gif_widget.dart';

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
      children: [for (StickerModel sticker in stickers ?? []) fullscreen ? viewSticker(sticker) : FittedBox(fit: BoxFit.contain, child: viewSticker(sticker))],
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
              child: canPause && (sticker.image ?? '').toLowerCase().endsWith('.gif') ? CustomGifWidget(url: sticker.image ?? '', isPause: isPause) : CachedNetworkImage(imageUrl: sticker.image ?? ''),
            ),
          ),
        ),
      ),
    );
  }
}
