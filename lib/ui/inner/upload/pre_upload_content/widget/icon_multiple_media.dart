import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class IconMultipleMedia extends StatelessWidget {
  final double width;
  final double height;
  final int lengthData;

  const IconMultipleMedia({Key? key, required this.lengthData, this.width = 22.64, this.height = 22.64}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (lengthData > 1) {
      return const CustomIconWidget(iconData: "${AssetPath.vectorPath}hyppe.svg");
    } else {
      return const SizedBox.shrink();
    }
  }
}
