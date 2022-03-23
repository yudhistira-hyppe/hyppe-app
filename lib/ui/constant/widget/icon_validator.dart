import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class IconValidator extends StatelessWidget {
  final bool correct;
  const IconValidator({Key? key, required this.correct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return correct ? const CustomIconWidget(iconData: '${AssetPath.vectorPath}valid.svg', defaultColor: false) : const SizedBox.shrink();
  }
}
