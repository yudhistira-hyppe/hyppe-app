import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class PickitemTitle extends StatelessWidget {
  final String title;
  final bool select;
  final bool button;
  final Function? function;
  final TextStyle? textStyle;
  const PickitemTitle({Key? key, required this.title, required this.select, this.function, required this.button, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      deleteIcon: button
          ? select
              ? const Icon(
                  Icons.check,
                  color: kHyppeLightButtonText,
                  size: 15,
                )
              : const Icon(
                  Icons.add_rounded,
                  color: kHyppePrimary,
                  size: 15,
                )
          : SizedBox(),
      onDeleted: button ? function as void Function()? : null,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextWidget(textAlign: TextAlign.left, textOverflow: TextOverflow.clip, textToDisplay: title, textStyle: textStyle),
        ],
      ),
      shape: StadiumBorder(side: BorderSide(color: select ? kHyppePrimary : kHyppeDisabled)),
      padding: const EdgeInsets.all(8),
      backgroundColor: !select ? kHyppeLightButtonText : kHyppePrimary,
    );
  }
}
