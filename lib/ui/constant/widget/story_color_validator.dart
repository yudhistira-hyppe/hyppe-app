import 'package:hyppe/core/constants/enum.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class StoryColorValidator extends StatelessWidget {
  final double width;
  final double borderRadius;
  final Widget child;
  final bool haveStory;
  final FeatureType featureType;
  final ContentData? contentData;
  final bool isMy;
  final bool isView;

  const StoryColorValidator({
    Key? key,
    this.width = 2.0,
    this.borderRadius = 27,
    required this.child,
    required this.haveStory,
    this.contentData,
    this.featureType = FeatureType.story,
    this.isMy = false,
    this.isView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
            width: width,
            color: haveStory
                ? !isMy
                    ? (isView)
                        ? kHyppeBorderTab
                        : featureType == FeatureType.story
                            ? theme.colorScheme.primary
                            : kHyppeBorderTab
                    : kHyppeBorderTab
                : isMy
                    ? kHyppeBorderTab
                    : Colors.transparent),
      ),
      child: child,
    );
  }
}
