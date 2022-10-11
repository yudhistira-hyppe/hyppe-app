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
  static const String isOnHomeScreen = "isOnHomeScreen";

  static const String isoCode = "isoCode";
  static const String themeData = 'themeData';

  static const String searchHistory = 'searchHistory';
  static const String vidCacheData = 'vidCacheData';
  static const String diaryCacheData = 'diaryCacheData';
  static const String picCacheData = 'picCacheData';
  static const String profileCacheData = 'profileCacheData';
  static const String oldUserID = 'oldUserId';
  static const String cacheTimeStamp = 'cacheTimeStamp';
  static const String isUserRequestRecoverPassword = 'isUserRequestRecoverPassword';
  static const String isUserInOTP = 'isUserInOTP';
  static const String lastTimeStampReachMaxAttempRecoverPassword = 'reachMaxAttempRecoverPassword';
  static const String onlineVersion = 'onlineVersion';
  static const String countAds = 'countAds';
  static const String setPin = 'setPin';
  static const String statusVerificationId = 'statusVerificationId';

  static const String settingMarketPlace = 'settingMarketPlace';
}
