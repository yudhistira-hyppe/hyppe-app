import 'package:hyppe/core/constants/asset_path.dart';
import 'package:flutter/material.dart';
import 'custom_icon_widget.dart';

class CustomVerifiedWidget extends StatelessWidget {
  final bool? verified;

  const CustomVerifiedWidget({Key? key, this.verified = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return verified! ? const CustomIconWidget(iconData: '${AssetPath.vectorPath}user-verified.svg', defaultColor: false) : const SizedBox.shrink();
  }
}
