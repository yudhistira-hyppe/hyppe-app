import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class CustomListTile extends StatelessWidget {
  final String iconData;
  final String title;
  final Function() onTap;
  const CustomListTile({super.key, required this.iconData, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth : 10,
      leading: CustomIconWidget(iconData: iconData, defaultColor: false),
      title: Text(title, style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(
              fontWeight: FontWeight.bold
            ),),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}