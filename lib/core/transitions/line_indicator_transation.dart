

import 'package:flutter/material.dart';

class LineIndicatorTransition extends AnimatedWidget {
  LineIndicatorTransition({
    super.key,
    required Animation<double> value,
    required this.color,
    required this.backgroundColor
  }) : super(listenable: value);

  /// The animation that controls the child's alignment.
  Animation<double> get value => listenable as Animation<double>;

  final AlwaysStoppedAnimation<Color> color;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value.value,
      valueColor: color,
      backgroundColor: backgroundColor,
    );
  }
}