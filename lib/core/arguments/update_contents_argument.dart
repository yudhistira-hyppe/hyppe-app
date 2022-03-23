import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class UpdateContentsArgument {
  final ContentData? contentData;
  final String? content;
  final bool onEdit;

  UpdateContentsArgument({
    this.contentData,
    this.content,
    required this.onEdit,
  });
}
