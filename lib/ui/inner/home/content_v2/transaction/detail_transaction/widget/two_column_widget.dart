import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class TwoColumnWidget extends StatelessWidget {
  final String? text1;
  final String? text2;
  final TextStyle? textStyle;
  final Widget? widget;
  final Function? function;
  const TwoColumnWidget(this.text1, {Key? key, this.text2, this.textStyle, this.widget = const SizedBox(), this.function}) : super(key: key);

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
          InkWell(
            onTap: function as void Function()?,
            child: Row(
              children: [
                widget!,
                CustomTextWidget(
                  textToDisplay: text2 ?? '',
                  textStyle: textStyle ?? Theme.of(context).textTheme.caption!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
