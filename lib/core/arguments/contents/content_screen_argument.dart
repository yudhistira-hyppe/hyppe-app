import 'package:hyppe/core/constants/enum.dart';

abstract class ContentScreenArgument {
  // postID to indicate which post to display
  // usually the postID is the same as the postID in the post object
  String? postID;

  // feature to indicate which feature to display
  FeatureType? featureType;
}
