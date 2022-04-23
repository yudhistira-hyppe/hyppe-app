class SosmedConstants {
  SosmedConstants._private();

  static final SosmedConstants _instance = SosmedConstants._private();

  factory SosmedConstants() {
    return _instance;
  }

  static const String twitterApiKey = 'eFfVUIo1WXCQMwhQ4PixJH65g';
  static const String twitterApiSecretKey =
      'oaX8Aa8WTsh3K5sIl8y4jstgsuHdpoc6FxV8GuYTqs4u1xwlm7';
  static const String twitterRedirectURI = 'flutter-twitter-login://';
}
