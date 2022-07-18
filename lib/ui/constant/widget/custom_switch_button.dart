import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

class CustomSwitchButton extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final bool value;

  const CustomSwitchButton({Key? key, required this.onChanged, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: kHyppePrimary,
      activeTrackColor: kHyppePrimaryShadow,
      inactiveThumbColor: const Color(0xff9f9f9f),
      inactiveTrackColor: const Color(0xff737577),
      value: value,
      onChanged: onChanged,
    );
  }
}
