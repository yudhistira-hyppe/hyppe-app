import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';

class PicFullscreenArgument {
  List<ContentData> picData;
  int index;
  bool? scrollPic;
  Function(double offset, PreviewPicNotifier notifier)? function;
  PicFullscreenArgument({required this.picData, required this.index, this.scrollPic, this.function});
}
