import 'package:flutter/material.dart';
import 'package:gif/gif.dart' as gif;
import 'package:gif_view/gif_view.dart' as gif_view;

class CustomGifWidget extends StatefulWidget {
  final String url;
  final bool isPause;

  const CustomGifWidget({
    super.key,
    required this.url,
    required this.isPause,
  });

  @override
  State<CustomGifWidget> createState() => _CustomGifWidgetState();
}

class _CustomGifWidgetState extends State<CustomGifWidget> {
  ValueNotifier<int>? notifier;
  gif_view.GifController? controller;

  @override
  void initState() {
    super.initState();
    controller = gif_view.GifController();
    notifier = ValueNotifier(0);
    widget.isPause ? controller?.pause() : controller?.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomGifWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPause != widget.isPause) {
      if (widget.isPause) {
        controller?.pause();
        notifier?.value = controller?.currentIndex ?? 0;
      } else {
        controller?.play(initialFrame: notifier?.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return gif_view.GifView.network(widget.url, controller: controller);
  }
}

// class CustomGifWidget extends StatefulWidget {
//   final String url;
//   final bool isPause;

//   const CustomGifWidget({
//     super.key,
//     required this.url,
//     required this.isPause,
//   });

//   @override
//   State<CustomGifWidget> createState() => _CustomGifWidgetState();
// }

// class _CustomGifWidgetState extends State<CustomGifWidget> with TickerProviderStateMixin {
//   ValueNotifier<double> notifier = ValueNotifier(0);
//   late gif.GifController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = gif.GifController(vsync: this);
//     widget.isPause ? controller.stop() : controller.repeat(period: const Duration(seconds: 100));
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(covariant CustomGifWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.isPause != widget.isPause) {
//       if (widget.isPause) {
//         controller.stop();
//         notifier.value = controller.value;
//       } else {
//         controller.forward();
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return gif.Gif(
//       controller: controller,
//       image: NetworkImage(widget.url),
//       autostart: gif.Autostart.loop,
//     );
//   }
// }
