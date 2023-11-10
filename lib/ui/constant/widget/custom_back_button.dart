import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Function()? onBack;

  const CustomBackButton({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomIconButtonWidget(
        onPressed: onBack ?? () => Routing().moveBack(),
        iconData: "${AssetPath.vectorPath}back-arrow.svg",
        color: Theme.of(context).colorScheme.primary);
  }
}
