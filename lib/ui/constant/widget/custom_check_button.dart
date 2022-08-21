import 'package:flutter/material.dart';

class CustomCheckButton extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final bool value;

  const CustomCheckButton(
      {Key? key, required this.onChanged, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: const Color(0xffdd30b5),
      checkColor: Colors.white,
      // activeTrackColor: const Color(0xffb72290),
      // inactiveThumbColor: const Color(0xff9f9f9f),
      // inactiveTrackColor: const Color(0xff737577),
      value: value,
      onChanged: onChanged,
    );
  }
}
