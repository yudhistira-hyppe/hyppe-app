import 'package:flutter/material.dart';

import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../constant/widget/icon_button_widget.dart';

class ReactStreamItem extends StatelessWidget {
  final String svg;
  final String desc;
  final Function() onTap;
  const ReactStreamItem({super.key, required this.svg, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: CustomIconButtonWidget(
            height: 30,
            width: 30,
            onPressed: onTap,
            iconData: svg,
          ),
        ),
        CustomTextWidget(
          textToDisplay: desc,
          textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
        ),
      ],
    );
  }
}
