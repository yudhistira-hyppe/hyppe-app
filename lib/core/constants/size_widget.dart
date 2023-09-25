class SizeWidget {
  SizeWidget._private();

  static final SizeWidget _instance = SizeWidget._private();

  factory SizeWidget() {
    return _instance;
  }

  static const double appBarHome = 50.0;
  static const double barStoriesCircleHome = 88.0;
  static const double barHyppePic = 190;
  // static const double circleDiameterOutside = 50.0;
  static const double circleDiameterOutside = 60.0;
  static const double circleDiameterImageProfileInLongVideoView = 36.0;
  static const double baseWidthXD = 375;
  static const double baseHeightXD = 812;

  static const double stickerScale = 0.5;

  double calculateSize(double sizeWidget, double heightOrWidthXD, double heightOrWidthDevice) {
    double result = sizeWidget / heightOrWidthXD * heightOrWidthDevice;
    return result;
  }
}
