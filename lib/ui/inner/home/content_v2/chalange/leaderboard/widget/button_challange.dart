import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';

class ButtonChallangeWidget extends StatelessWidget {
  final Function? function;
  final String? text;
  final Color? bgColor;
  const ButtonChallangeWidget({super.key, this.function, this.text, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            function?.call();
          },
          child: Container(
            height: 44,
            width: SizeConfig.screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
