import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class TopIcon extends StatelessWidget {
  const TopIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CustomIconWidget(
      iconData: "${AssetPath.vectorPath}dana-hyppe.svg",
      defaultColor: false,
    );
  }
}
