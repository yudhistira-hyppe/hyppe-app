import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class TwoColumnWidget extends StatelessWidget {
  final String? text1;
  final String? text2;
  final TextStyle? textStyle;
  const TwoColumnWidget(this.text1, {Key? key, this.text2, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            textToDisplay: text1!,
            textStyle: Theme.of(context).textTheme.caption!,
            textAlign: TextAlign.start,
          ),
          CustomTextWidget(
            textToDisplay: text2 ?? '',
            textStyle: textStyle ?? Theme.of(context).textTheme.caption!,
          ),
        ],
      ),
    );
  }
}
