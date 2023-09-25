import 'package:gif_view/gif_view.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class BuildStickerWidget extends StatefulWidget {
  final String image;
  final VoidCallback onDragStart;
  final Function(Matrix4 matrix, Offset offset, Key? key) onDragEnd;
  final Function(Matrix4 matrix, Offset offset, Key? key) onDragUpdate;

  const BuildStickerWidget({
    Key? key,
    required this.image,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragUpdate,
  }) : super(key: key);

  @override
  State<BuildStickerWidget> createState() => _BuildStickerWidgetState();
}

class _BuildStickerWidgetState extends State<BuildStickerWidget> {
  late ValueNotifier<Matrix4> notifier = ValueNotifier(
    Matrix4.identity()
    .scaled(SizeWidget.stickerScale)
    ..setTranslationRaw(
      (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * SizeWidget.stickerScale)) / 2,
      MediaQuery.of(context).size.height / 5,
      0,
    )
  );
  late Offset offset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        offset = event.position;
        widget.onDragUpdate(notifier.value, offset, widget.key);
      },
      child: MatrixGestureDetector(
        initMatrixValue:
          Matrix4.identity()
          .scaled(SizeWidget.stickerScale)
          ..setTranslationRaw(
            (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * SizeWidget.stickerScale)) / 2,
            MediaQuery.of(context).size.height / 5,
            0,
          ),
        shouldRotate: true,
        onMatrixUpdate: (m, tm, sm, rm) {
          notifier.value = m;
        },
        onScaleStart: () {
          widget.onDragStart();
        },
        onScaleEnd: () {
          widget.onDragEnd(notifier.value, offset, widget.key);
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (context, childWidget) {
            return Transform(
              // alignment: FractionalOffset.topCenter,
              transform: notifier.value,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: OptimizedCacheImage(imageUrl: widget.image),
                    // child: widget.image.toLowerCase().endsWith('.gif')
                    //     ? GifView.network(widget.image)
                    //     : OptimizedCacheImage(imageUrl: widget.image),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
