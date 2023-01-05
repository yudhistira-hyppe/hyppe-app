import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final int peopleIndex;

  final List<ContentData>? storyData;
  final Map<String, List<ContentData>>? groupStories;
  final Map<String, List<StoryItem>>? storyItems;
  final StoryController? controller;

  @override
  FeatureType get featureType => FeatureType.story;

  StoryDetailScreenArgument({this.index = 0, this.peopleIndex = 0, this.storyData, this.groupStories, this.storyItems, this.controller});
}
