import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class BuildListTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Function? onTap;
  const BuildListTile({required this.icon, this.title = '', this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap as void Function()?,
      title: CustomTextWidget(
        textToDisplay: title,
        textStyle: Theme.of(context).textTheme.subtitle2,
        textAlign: TextAlign.start,
        textOverflow: TextOverflow.clip,
      ),
      subtitle: subtitle != null
          ? CustomTextWidget(
              textToDisplay: subtitle!,
              textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeSecondary),
              textAlign: TextAlign.start,
              textOverflow: TextOverflow.clip,
            )
          : null,
      leading: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: CustomIconWidget(iconData: icon, defaultColor: false, width: 30),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
