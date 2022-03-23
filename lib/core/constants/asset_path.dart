class AssetPath {
  AssetPath._private();

  static final AssetPath _instance = AssetPath._private();

  factory AssetPath() {
    return _instance;
  }

  static const String jsonPath = 'assets/json/';
  static const String pngPath = 'assets/png/';
  static const String vectorPath = 'assets/vector/';
  static const String dummyMdPath = 'assets/dummy_md/';
}