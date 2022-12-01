import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class DiaryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final List<ContentData>? diaryData;
  final contentPosition? inPosition;

  @override
  FeatureType get featureType => FeatureType.diary;

  DiaryDetailScreenArgument({this.index = 0, this.diaryData, this.inPosition});
}
