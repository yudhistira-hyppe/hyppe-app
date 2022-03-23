import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class StoryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final List<ContentData>? storyData;

  @override
  FeatureType get featureType => FeatureType.story;

  StoryDetailScreenArgument({
    this.index = 0,
    this.storyData,
  });
}
