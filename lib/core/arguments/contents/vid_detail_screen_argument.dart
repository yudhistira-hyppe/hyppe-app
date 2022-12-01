import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class VidDetailScreenArgument extends ContentScreenArgument {
  final ContentData? vidData;
  final contentPosition? inPosition;

  @override
  FeatureType get featureType => FeatureType.vid;

  VidDetailScreenArgument({this.vidData, this.inPosition});
}
