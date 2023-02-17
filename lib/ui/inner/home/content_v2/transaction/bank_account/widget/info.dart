import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class infoMaxAccount extends StatelessWidget {
  String title;
  infoMaxAccount({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          const CustomIconWidget(
            iconData: "${AssetPath.vectorPath}info-icon.svg",
            defaultColor: false,
          ),
          fourteenPx,
          CustomTextWidget(
            textToDisplay: title,
            textAlign: TextAlign.start,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
          ),
        ],
      ),
    );
  }
}
