import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CustomStrokeTextWidget extends StatelessWidget {
  final String textToDisplay;
  final double? stroke;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;

  const CustomStrokeTextWidget(
      {Key? key, required this.textToDisplay, this.stroke = 1, this.textStyle, this.maxLines, this.textOverflow, this.textAlign})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          CustomTextWidget(
            maxLines: maxLines,
            textOverflow: textOverflow,
            textToDisplay: textToDisplay,
            textAlign: textAlign ?? TextAlign.center,
            textStyle: textStyle?.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..color = kHyppeBackground
                ..strokeWidth = stroke ?? 0,
            ),
          ),
          CustomTextWidget(
            maxLines: maxLines,
            textOverflow: textOverflow,
            textToDisplay: textToDisplay,
            textAlign: textAlign ?? TextAlign.center,
            textStyle: textStyle?.copyWith(color: kHyppeLightBackground),
          ),
        ],
      );
}
