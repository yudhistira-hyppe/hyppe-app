import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

class CustomCheckButton extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final bool value;
  final bool disable;

  const CustomCheckButton({Key? key, required this.onChanged, required this.value, this.disable = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: disable ? kHyppeDisabled : kHyppePrimary,
      checkColor: Colors.white,
      // activeTrackColor: const Color(0xffb72290),
      // inactiveThumbColor: const Color(0xff9f9f9f),
      // inactiveTrackColor: const Color(0xff737577),
      value: value,
      onChanged: onChanged,
    );
  }
}
