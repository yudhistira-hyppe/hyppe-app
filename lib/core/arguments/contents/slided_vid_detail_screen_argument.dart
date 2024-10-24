import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';

import '../../constants/enum.dart';
import '../../models/collection/posts/content_v2/content_data.dart';

class SlidedVidDetailScreenArgument extends ContentScreenArgument {
  final double index;
  final List<ContentData>? vidData;
  final int? page;
  final int? limit;
  final TypePlaylist type;
  final Widget? titleAppbar;
  final PageSrc? pageSrc;
  final String? key;
  final String? postId;
  final ScrollController? scrollController;
  final double? heightBox;
  final double? heightTopProfile;
  final bool? isProfile;

  @override
  FeatureType get featureType => FeatureType.pic;

  SlidedVidDetailScreenArgument({
    this.index = 0,
    this.vidData,
    this.isProfile = false,
    this.page,
    this.limit,
    required this.type,
    this.titleAppbar,
    this.pageSrc,
    this.key,
    this.postId,
    this.scrollController,
    this.heightBox,
    this.heightTopProfile,
  });
}
