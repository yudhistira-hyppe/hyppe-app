import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class PicFullscreenArgument {
  List<ContentData> picData;
  int index;
  bool? scrollPic;
  PicFullscreenArgument({required this.picData, required this.index, this.scrollPic});
}
