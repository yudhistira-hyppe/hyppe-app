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

  static final EnvData dev = EnvData(
    debug: true,
    appID: appID,
    title: "Hyppe TEST",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    baseUrl: "https://s1.hyppe.cloud",
    deeplinkBaseUrl: "https://share.hyppe.app",
    apiBaseUrl: "https://s1.hyppe.cloud",
    versionApi: UrlConstants.apiV0,
  );

  static final EnvData prod = EnvData(
    debug: false,
    appID: appID,
    title: "Hyppe",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    baseUrl: "https://p1.hyppe.cloud",
    deeplinkBaseUrl: "https://share.hyppe.app",
    apiBaseUrl: "https://p1.hyppe.cloud",
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
    required this.versionApi,
  });
}
