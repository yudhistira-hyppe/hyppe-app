import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoveLootie extends StatefulWidget {
  final Function onAnimationFinished;
  final double size;

  const LoveLootie({Key? key, this.size = 8, required this.onAnimationFinished}) : super(key: key);

  @override
  State<LoveLootie> createState() => _LoveLootieState();
}

class _LoveLootieState extends State<LoveLootie> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationFinished();
      } else if (status == AnimationStatus.dismissed) {
        // widget.onAnimationFinished();
        widget.onAnimationFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Lottie.asset(
      "${AssetPath.jsonPath}loveicon_rev2.json",
      width: SizeConfig.screenWidth! * 0.3,
      height: SizeConfig.screenHeight! * 0.6,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward().whenComplete(() => widget.onAnimationFinished());
      },
      repeat: false,
    );
  }
}
