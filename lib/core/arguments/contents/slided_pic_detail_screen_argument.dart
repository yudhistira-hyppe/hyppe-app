import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';

import '../../constants/enum.dart';
import '../../models/collection/posts/content_v2/content_data.dart';

class SlidedPicDetailScreenArgument extends ContentScreenArgument{
  final double index;
  final List<ContentData>? picData;

  @override
  FeatureType get featureType => FeatureType.pic;

  SlidedPicDetailScreenArgument({
    this.index = 0,
    this.picData,
  });
}