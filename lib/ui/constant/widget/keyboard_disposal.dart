import 'package:flutter/material.dart';

class KeyboardDisposal extends StatelessWidget {
  final Widget child;
  final Function()? onTap;

  const KeyboardDisposal({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap ?? () {
          if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
        },
        child: child);
  }
}
