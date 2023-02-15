import 'package:hyppe/core/constants/enum.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class StoryColorValidator extends StatelessWidget {
  final double width;
  final Widget child;
  final bool haveStory;
  final FeatureType featureType;
  final ContentData? contentData;

  const StoryColorValidator(
      {Key? key, this.width = 2.0, required this.child, required this.haveStory,this.contentData, this.featureType = FeatureType.story})
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
          color: contentData?.isViewed==true ?   theme.colorScheme.secondary: featureType == FeatureType.story ? theme.colorScheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
