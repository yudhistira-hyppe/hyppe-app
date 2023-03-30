import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class CustomLikeAnimation extends StatefulWidget {
  Function() onEnd;
  CustomLikeAnimation({Key? key, required this.onEnd}) : super(key: key);

  @override
  State<CustomLikeAnimation> createState() => _CustomLikeAnimationState();
}

class _CustomLikeAnimationState extends State<CustomLikeAnimation>
    with AfterFirstLayoutMixin {
  double opacity = 0.0;

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAppeared = opacity == 1.0;
    return AnimatedOpacity(
      onEnd: isAppeared
          ? () {
              Future.delayed(const Duration(milliseconds: 2000), () {
                setState(() {
                  opacity = 0.0;
                });
                widget.onEnd;
              });
            }
          : null,
      opacity: opacity,
      duration: const Duration(milliseconds: 2000),
      curve: isAppeared ? Curves.bounceOut : Curves.bounceIn,
      child: const CustomIconWidget(
        defaultColor: false,
        iconData: '${AssetPath.vectorPath}ic_like_red.svg',
        width: 40,
        height: 40,
      ),
    );
  }
}
