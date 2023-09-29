import 'package:hyppe/core/models/collection/sticker/sticker_category_model.dart';

class StickerTab {
  int index;
  String name;
  String type;
  int column;
  List<StickerCategoryModel> data;

  StickerTab({
    required this.index,
    required this.name,
    required this.type,
    required this.column,
    required this.data,
  });
}
