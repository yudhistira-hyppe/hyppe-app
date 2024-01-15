import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class PicFullscreenArgument {
  ImageProvider<Object> imageProvider;
  List<ContentData> picData;
  int index;
  PicFullscreenArgument({required this.imageProvider, required this.picData, required this.index});
}
