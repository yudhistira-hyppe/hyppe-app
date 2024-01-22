import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class DiaryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final List<ContentData>? diaryData;
  final int? page;
  final int? limit;
  final TypePlaylist type;
  final Function(int e)? function;
  final bool? ismute;
  final int? seekPosition;

  @override
  FeatureType get featureType => FeatureType.diary;

  DiaryDetailScreenArgument({
    this.index = 0,
    this.diaryData,
    this.page,
    this.limit,
    required this.type,
    this.function,
    this.ismute,
    this.seekPosition,
  });
}
