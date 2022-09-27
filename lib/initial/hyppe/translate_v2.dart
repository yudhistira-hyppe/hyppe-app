import 'dart:convert';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/utils/language/language_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/payment_summary/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
// import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/register/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_agreement/user_aggrement_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_complete_profile/user_complete_profile_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';

class TranslateNotifierV2 with ChangeNotifier {
  TranslateNotifierV2._private();
  static final TranslateNotifierV2 _instance = TranslateNotifierV2._private();
  factory TranslateNotifierV2() => _instance;

  LocalizationModelV2 _translate = LocalizationModelV2();
  LocalizationModelV2 get translate => _translate;

  set translate(LocalizationModelV2 val) {
    _translate = val;
    notifyListeners();
  }

  final List<LanguageData> _listLanguage = [];
  int _listIndex = 0;
  bool _loadMore = false;

  bool get loadMore => _loadMore;
  List<LanguageData> get listLanguage => _listLanguage;

  set loadMore(bool val) {
    _loadMore = val;
    notifyListeners();
  }

  Future getListOfLanguage(BuildContext context) async {
    final notifier = UtilsBlocV2();
    await notifier.getLanguages(context, pageNumber: _listIndex);
    final fetch = notifier.utilsFetch;
    if (fetch.utilsState == UtilsState.languagesSuccess) {
      if (fetch.data.isNotEmpty) {
        if (_listIndex == 0) _listLanguage.clear();
        fetch.data.forEach((v) => _listLanguage.add(LanguageData.fromJson(v)));
        _listIndex++;
        loadMore = false;
      } else {
        print("Language has reach max value");
      }
    }
  }

  Future loadLanguage({int? index}) async {
    late String langIso;
    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);

    if (index == null && _isoCodeCache != null) {
      langIso = _isoCodeCache == "en" ? "en" : "id";
    } else {
      langIso = index != null && _listLanguage.isNotEmpty ? _listLanguage[index].langIso ?? "en" : "id";
    }

    SharedPreference().writeStorage(SpKeys.isoCode, langIso);

    // final localeDir = await getApplicationDocumentsDirectory();
    // File txt = File('${localeDir.path}/primaryLanguage.txt');
    Map<String, dynamic> _langDefault = jsonDecode(await rootBundle.loadString('${AssetPath.jsonPath}$langIso.json'));

    // bool downloaded = await txt.exists();
    // if (downloaded) {
    //   Map<String, dynamic> _langTxt = jsonDecode(await txt.readAsString());
    //   if (_langTxt.keys.length == _langDefault.keys.length) {
    //     translate = LocalizationModelV2.fromJson(_langTxt);
    //   } else {
    //     translate = LocalizationModelV2.fromJson(_langDefault);
    //   }
    // } else {
    //   translate = LocalizationModelV2.fromJson(_langDefault);
    // }
    translate = LocalizationModelV2.fromJson(_langDefault);
    notifyListeners();
  }

  Future initTranslate(BuildContext context, {int? index}) async {
    print('kesini translate');
    await loadLanguage(index: index);

    /// Outer
    // Login
    context.read<LoginNotifier>().translate(translate);
    context.read<WelcomeLoginNotifier>().translate(translate);
    // Forgot Password
    context.read<ForgotPasswordNotifier>().translate(translate);
    context.read<UserOtpNotifier>().translate(translate);
    // Sign-Up
    context.read<RegisterNotifier>().translate(translate);
    context.read<SignUpPinNotifier>().translate(translate);
    context.read<UserAgreementNotifier>().translate(translate);
    context.read<UserInterestNotifier>().translate(translate);
    context.read<SignUpWelcomeNotifier>().translate(translate);
    context.read<UserCompleteProfileNotifier>().translate(translate);

    /// Inner
    context.read<HomeNotifier>().translate(translate);
    context.read<PreviewPicNotifier>().translate(translate);
    context.read<AccountPreferencesNotifier>().translate(translate);
    context.read<MakeContentNotifier>().translate(translate);
    context.read<PreviewContentNotifier>().translate(translate);
    context.read<PreUploadContentNotifier>().translate(translate);
    context.read<SelfProfileNotifier>().translate(translate);
    context.read<OtherProfileNotifier>().translate(translate);
    context.read<ChangePasswordNotifier>().translate(translate);
    context.read<SearchNotifier>().translate(translate);
    context.read<HashtagNotifier>().translate(translate);
    context.read<NotificationNotifier>().translate(translate);
    context.read<ProfileCompletionNotifier>().translate(translate);
    context.read<ReferralNotifier>().translate(translate);
    context.read<ReviewBuyNotifier>().translate(translate);
    context.read<PaymentMethodNotifier>().translate(translate);
    context.read<PaymentNotifier>().translate(translate);
    context.read<PaymentSummaryNotifier>().translate(translate);
    // context.read<TransactionNotifier>().translate(translate);
    // context.read<PinAccountNotifier>().translate(translate);

    notifyListeners();
    if (index != null && _listLanguage.isNotEmpty) {
      _listIndex = 0;
      Routing().moveBack();
    }
    var lang = SharedPreference().readStorage(SpKeys.isoCode);
    final notifier = UtilsBlocV2();
    await notifier.updateLanguages(context, lang: lang);
    final fetch = notifier.utilsFetch;
    if (fetch.utilsState == UtilsState.updateLangSuccess) {}
  }
}
