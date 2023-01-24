final String databaseName = 'hyppe.db';
final String tableEfect = 'efect';
final int databaseVersion = 2;

class EfectFields {
  static const String effectId = 'effectId';
  static const String dirName = 'dirName';
  static const String fileName = 'fileName';
  static const String preview = 'preview';
}

class EffectModel {
  final String? effectId;
  final String? dirName;
  final String? fileName;
  final String? preview;

  const EffectModel({
    this.effectId,
    this.fileName,
    this.preview,
    this.dirName,
  });
}
