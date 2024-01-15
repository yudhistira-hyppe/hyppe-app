import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class StoryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final int peopleIndex;

  final List<ContentData>? storyData;
  final Map<String, List<ContentData>>? myStories;
  final List<StoriesGroup>? groupStories;
  final String? email;
  final bool fromProfile;
  final bool isOther;

  @override
  FeatureType get featureType => FeatureType.story;

  StoryDetailScreenArgument({this.index = 0, this.peopleIndex = 0, this.storyData, this.myStories, this.groupStories, this.email, this.fromProfile = false, this.isOther = false});
}
