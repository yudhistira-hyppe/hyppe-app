import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class AdvertisingArgument {
  final String email;
  final String postID;
  final Metadata? metadata;

  AdvertisingArgument({
    required this.email,
    required this.postID,
    required this.metadata,
  });
}
