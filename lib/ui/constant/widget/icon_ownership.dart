import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class IconOwnership extends StatelessWidget {
  final bool correct;
  const IconOwnership({Key? key, required this.correct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return correct
        ? Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black.withOpacity(0.3),
            ),
            child: const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}ownership.svg',
              defaultColor: false,
            ))
        : const SizedBox.shrink();
  }
}
