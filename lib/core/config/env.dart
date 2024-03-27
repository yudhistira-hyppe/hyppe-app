import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/config/url_constants.dart';

class Env {
  static EnvData? _env;

  static EnvData get data => _env!;

  static void init(EnvType env) {
    switch (env) {
      case EnvType.development:
        _env = Env.dev;
        break;
      case EnvType.production:
        _env = Env.prod;
        break;
      default:
    }
  }

  static final List dataBaseUrl2 = [
    UrlConstants.interactive,
    UrlConstants.discuss,
    UrlConstants.deleteDiscuss,
    UrlConstants.deleteChat,
    UrlConstants.updateProfile,
    UrlConstants.joinChallange,
    UrlConstants.verificationIDSupportingDocs,
    UrlConstants.verificationIDWithSupportDocs,
    UrlConstants.uploadProfilePictureV2,
    UrlConstants.createuserposts,
    UrlConstants.updatepost,
  ];

  static final EnvData dev = EnvData(
    debug: true,
    appID: appID,
    title: "Hyppe TEST",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    // baseUrl: "https://p1-5003.hyppe.cloud",
    // baseUrl2: "https://p1-5003.hyppe.cloud",
    // baseUrlSocket: "https://p3-5003.hyppe.cloud",
    // apiBaseUrl: "https://p1-5003.hyppe.cloud",

    baseUrl: "https://s1.hyppe.cloud",
    baseUrl2: "https://s1.hyppe.cloud",
    baseUrlSocket: "https://s1.hyppe.cloud",
    apiBaseUrl: "https://s1.hyppe.cloud",

    deeplinkBaseUrl: "https://share.hyppe.app",
    versionApi: UrlConstants.apiV0,
  );

  static final EnvData prod = EnvData(
    debug: false,
    appID: appID,
    title: "Hyppe",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    baseUrl: "https://p1-new.hyppe.cloud",
    baseUrl2: "https://p2-new.hyppe.cloud",
    baseUrlSocket: "https://p3.hyppe.cloud",
    apiBaseUrl: "https://p1-new.hyppe.cloud",
    deeplinkBaseUrl: "https://share.hyppe.app",
    versionApi: UrlConstants.apiV0,
  );
}

class EnvData {
  final bool debug;
  final bool debugShowCheckedModeBanner;
  final bool debugShowMaterialGrid;
  final String title;
  final String apiBaseUrl;
  final String deeplinkBaseUrl;
  final String appID;
  final String appStoreID;
  final String baseUrl;
  final String baseUrl2;
  final String baseUrlSocket;
  final String versionApi;

  EnvData({
    required this.debug,
    required this.debugShowCheckedModeBanner,
    required this.debugShowMaterialGrid,
    required this.title,
    required this.apiBaseUrl,
    required this.deeplinkBaseUrl,
    required this.appID,
    required this.appStoreID,
    required this.baseUrl,
    required this.baseUrl2,
    required this.baseUrlSocket,
    required this.versionApi,
  });
}
