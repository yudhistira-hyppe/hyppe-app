import 'package:flutter/material.dart';

class ButtomSosmed extends StatelessWidget {
  final Widget child;
  final Function? function;
  final ButtonStyle? buttonStyle;

  const ButtomSosmed({
    required this.child,
    required this.function,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: null,
      child: ElevatedButton(
        onPressed: function as void Function()?,
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(412, 40)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Color(0xFFEDEDED),
              ))),
          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
        ),
        child: child,
        //
      ),
    );
  }
}
