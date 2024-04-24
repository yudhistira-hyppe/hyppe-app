import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final TextStyle? style;
  const SectionWidget({super.key, required this.title, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Text(
        title,
        style: style
      ),
    );
  }
}
