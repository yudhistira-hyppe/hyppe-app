import 'package:flutter/material.dart';

class PositionWelcome extends StatelessWidget {
  final bool isActive;
  const PositionWelcome({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isActive
        ? Container(
            height: 5,
            width: 10,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: const Color(0xffBE31BC)),
          )
        : Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Color(0xffCECECE)),
          );
  }
}
