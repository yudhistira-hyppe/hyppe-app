import 'package:hive_flutter/hive_flutter.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class Boxes {
  static final boxDataContents = Hive.box<AllContents>('data_contents');
}