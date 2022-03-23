import 'package:hyppe/core/models/collection/stories/viewer_stories_data.dart';

class ViewerStories {
  int? statusCode;
  String? message;
  String? count;
  List<StoryViewsData> storyViews = [];

  ViewerStories.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data']['storyViews'] != null) {
      json['data']['storyViews'].forEach((v) {
        storyViews.add(StoryViewsData.fromJson(v));
      });
    }
    count = json['data']['count'];
  }
}