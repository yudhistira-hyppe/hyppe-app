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

  static final List dataUrlv3 = [
    UrlConstants.signUp,
    UrlConstants.verifyAccount,
    UrlConstants.getSearchPeople,
    UrlConstants.deleteDiscuss,
    UrlConstants.deleteChat,
    UrlConstants.getSearchContentV3,
    UrlConstants.deletTagUser,
    UrlConstants.viewLike,
    UrlConstants.deleteAccount,
    UrlConstants.getBuyContent,
    UrlConstants.postBuyContent,
    UrlConstants.getAllBank,
    UrlConstants.getBankByCode,
    UrlConstants.createuserposts,
    UrlConstants.userBankAccounts,
    UrlConstants.myUserBankAccounts,
    UrlConstants.transactionHistorys,
    UrlConstants.detailTransactionHistorys,
    UrlConstants.deleteUserBankAccounts,
    UrlConstants.accountBalances,
    UrlConstants.getuserposts,
    UrlConstants.getUserPosts,
    UrlConstants.userPin,
    UrlConstants.getuserprofile,
    UrlConstants.getVideoApsara,
    UrlConstants.getOtherUserPosts,
    UrlConstants.updateLanguage,
    UrlConstants.referralCount,
  ];

  static final EnvData dev = EnvData(
    debug: true,
    appID: appID,
    title: "Hyppe TEST",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    baseUrl: UrlConstants.stagingBaseApi,
    deeplinkBaseUrl: UrlConstants.devDeeplinkUrl,
    apiBaseUrl: UrlConstants.stagingBaseApi,
    // apiBaseUrl: UrlConstants.stagingBaseApi,
  );

  static final EnvData prod = EnvData(
    debug: false,
    appID: appID,
    title: "Hyppe",
    appStoreID: appStoreID,
    debugShowMaterialGrid: false,
    debugShowCheckedModeBanner: false,
    baseUrl: UrlConstants.productionBaseApi,
    deeplinkBaseUrl: UrlConstants.prodDeeplinkUrl,
    apiBaseUrl: UrlConstants.productionBaseApi,
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
  });
}
