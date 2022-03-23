import 'package:hyppe/core/constants/enum.dart';
import 'package:flutter/material.dart';

class StoryColorValidator extends StatelessWidget {
  final double width;
  final Widget child;
  final bool haveStory;
  final FeatureType featureType;

  const StoryColorValidator(
      {Key? key, this.width = 2.0, required this.child, required this.haveStory, this.featureType = FeatureType.story})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      child: child,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: width,
          color: haveStory ? theme.colorScheme.primaryVariant : featureType == FeatureType.story ? theme.colorScheme.secondaryVariant : Colors.transparent,
        ),
      ),
    );
  }
}
