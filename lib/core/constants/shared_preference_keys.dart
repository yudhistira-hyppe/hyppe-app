class SpKeys {
  SpKeys._private();

  static final SpKeys _instance = SpKeys._private();

  factory SpKeys() {
    return _instance;
  }

  static const String email = "email";
  static const String userID = "userID";
  static const String fcmToken = 'fcmToken';
  static const String userToken = "userToken";
  static const String isLoginSosmed = 'false';
  static const String lastHitPost = "lastHitPost";
  static const String isShowPopAds = "isShowPopAds";

  static const String isoCode = "isoCode";
  static const String themeData = 'themeData';

  static const String isUserRequestRecoverPassword = 'isUserRequestRecoverPassword';
  static const String isUserInOTP = 'isUserInOTP';
  static const String lastTimeStampReachMaxAttempRecoverPassword = 'reachMaxAttempRecoverPassword';
  static const String countAds = 'countAds';
  static const String setPin = 'setPin';
  static const String statusVerificationId = 'statusVerificationId';

  static const String referralFrom = 'referralFrom';
  static const String brand = 'brand';
  static const String canDeppAr = 'canDeppAr';
}
