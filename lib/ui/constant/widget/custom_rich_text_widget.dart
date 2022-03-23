import 'package:flutter/material.dart';

class CustomRichTextWidget extends StatelessWidget {
  final int? maxLines;
  final TextSpan textSpan;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final TextOverflow textOverflow;

  const CustomRichTextWidget(
      {Key? key,
      this.maxLines,
      this.textAlign = TextAlign.center,
      this.textOverflow = TextOverflow.ellipsis,
      this.textStyle,
      required this.textSpan})
      :
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(text: textSpan, maxLines: maxLines, textAlign: textAlign, overflow: textOverflow);
  }
}
