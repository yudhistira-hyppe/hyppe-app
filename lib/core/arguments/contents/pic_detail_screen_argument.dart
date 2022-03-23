import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class PicDetailScreenArgument extends ContentScreenArgument {
  // contentData to indicate which contentData to display
  // usually the contentData is the same as the contentData in the post object
  final ContentData? picData;

  @override
  FeatureType get featureType => FeatureType.pic;

  PicDetailScreenArgument({this.picData});
}
