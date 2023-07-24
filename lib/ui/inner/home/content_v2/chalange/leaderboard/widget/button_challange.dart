import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';

class ButtonChallangeWidget extends StatelessWidget {
  final Function? function;
  final String? text;
  final Color? bgColor;
  final bool isloading;
  final Color? borderColor;
  final Color? textColors;
  const ButtonChallangeWidget({super.key, this.function, this.text, this.bgColor, this.isloading = false, this.borderColor, this.textColors = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor ?? Colors.white,
              width: borderColor != null ? 2 : 0,
            )),
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
            padding: isloading ? null : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: isloading
                ? const CustomLoading()
                : Text(
                    text ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColors,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
