import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class VidFullscreenArgument {
  List<ContentData> vidData;
  ContentData data;
  int index;
  bool? scrollVid;
  VidFullscreenArgument({required this.vidData, required this.data, required this.index, this.scrollVid});
}
