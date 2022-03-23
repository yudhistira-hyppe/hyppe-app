import 'package:flutter/material.dart';

class CustomSwitchButton extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final bool value;

  const CustomSwitchButton({Key? key, required this.onChanged, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Switch(
      activeColor: const Color(0xffdd30b5),
      activeTrackColor: const Color(0xffb72290),
      inactiveThumbColor: const Color(0xff9f9f9f),
      inactiveTrackColor: const Color(0xff737577),
      value: value,
      onChanged: onChanged,
    );
  }
}
