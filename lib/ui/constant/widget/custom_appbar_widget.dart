import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget {
  final Widget content;
  final bool useDefaultElevation;

  const CustomAppBarWidget({
    Key? key,
    required this.content,
    this.useDefaultElevation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PhysicalModel(
        color: Colors.black,
        elevation: useDefaultElevation ? 0.0 : 0.8,
        child: Container(
          child: content,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
