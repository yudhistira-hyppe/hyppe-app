import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class StoryLoading extends StatelessWidget {
  final int size;

  const StoryLoading({Key? key, this.size = 8}) : super(key: key);

  @override
  Widget build(BuildContext context) => Lottie.asset(
        "assets/json/loading.json",
        width: size * 16,
        height: size * 9,
      );
}
