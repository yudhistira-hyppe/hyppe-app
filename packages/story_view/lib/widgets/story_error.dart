import 'package:flutter/material.dart';

class StoryError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/content-error.png",
            width: 250,
            height: 160,
            fit: BoxFit.contain,
            package: 'story_view',
          ),
          const SizedBox(height: 35),
          const Text(
            "Something When Wrong",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Text("Please try again later", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2)
        ],
      ),
    );
  }
}
