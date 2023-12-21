import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

class IconButtonLive extends StatelessWidget {
  final Widget? widget;
  final Function()? onPressed;
  final Function(bool)? onClicked;
  const IconButtonLive({super.key, this.onPressed, this.widget, this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Material(
        color: kHyppeTransparent,
        shape: const CircleBorder(),
        child: InkWell(
          splashColor: Colors.black,
          onTap: onPressed,
          onTapUp: (val) {
            if (onClicked != null) {
              onClicked!(false);
            }
          },
          onTapDown: (val) {
            if (onClicked != null) {
              onClicked!(true);
            }
          },
          onTapCancel: (){
            if (onClicked != null) {
              onClicked!(false);
            }
          },
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            height: 40,
            width: 40,
            child: widget,
          ),
        ),
      ),
    );
  }
}
