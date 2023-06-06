import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';

import '../../constants/enum.dart';
import '../../models/collection/posts/content_v2/content_data.dart';

class SlidedDiaryDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final List<ContentData>? diaryData;
  final int? page;
  final int? limit;
  final TypePlaylist type;
  final Widget? titleAppbar;
  final PageSrc? pageSrc;
  final String? key;

  @override
  FeatureType get featureType => FeatureType.pic;

  SlidedDiaryDetailScreenArgument({this.index = 0, this.diaryData, this.page, this.limit, required this.type, this.titleAppbar, this.pageSrc, this.key});
}