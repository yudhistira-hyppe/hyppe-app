import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class VidFullscreenArgument {
  List<ContentData> vidData;
  ContentData data;
  int index;
  bool? scrollVid;
  final PageSrc? pageSrc;
  bool? isMute;
  final String? key;
  VidFullscreenArgument({required this.vidData, required this.data, required this.index, this.scrollVid, this.pageSrc, this.key, this.isMute});
}
