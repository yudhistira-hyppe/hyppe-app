import 'dart:convert';
import 'package:hyppe/core/bloc/faq/bloc.dart';
import 'package:hyppe/core/bloc/faq/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/faq/faq_request.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/utils/language/language_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/payment_summary/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';

import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';

import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';

import 'package:hyppe/ui/inner/notification/notifier.dart';
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

import '../../core/arguments/ticket_argument.dart';
import '../../core/bloc/support_ticket/bloc.dart';
import '../../core/models/collection/faq/faq_data.dart';
import '../../core/models/collection/support_ticket/ticket_model.dart';
import '../../ui/constant/entities/comment_v2/notifier.dart';
import '../../ui/inner/home/content_v2/diary/playlist/notifier.dart';
import '../../ui/inner/home/content_v2/help/detail_ticket/notifier.dart';

class TranslateNotifierV2 with ChangeNotifier {
  TranslateNotifierV2._private();
  static final TranslateNotifierV2 _instance = TranslateNotifierV2._private();
  factory TranslateNotifierV2() => _instance;

  LocalizationModelV2 _translate = LocalizationModelV2();
  LocalizationModelV2 get translate => _translate;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  set translate(LocalizationModelV2 val) {
    _translate = val;
    notifyListeners();
  }

  final List<LanguageData> _listLanguage = [];
  int _listIndex = 0;
  bool _loadMore = false;

  bool get loadMore => _loadMore;
  List<LanguageData> get listLanguage => _listLanguage;

  List<FAQData> _listFAQ = [];
  List<FAQData> get listFAQ => _listFAQ;
  set listFAQ(List<FAQData> values) {
    _listFAQ = values;
    notifyListeners();
  }

  List<TicketModel> _onProgressTickets = [];
  List<TicketModel> get onProgressTicket => _onProgressTickets;
  set onProgressTicket(List<TicketModel> values){
    _onProgressTickets = values;
    notifyListeners();
  }

  set loadMore(bool val) {
    _loadMore = val;
    notifyListeners();
  }

  startLoadingFAQ() {
    _isLoading = true;
  }

  Future getListOfFAQ(BuildContext context, {String? category}) async {
    try {
      _isLoading = true;
      notifyListeners();
      _listFAQ = [];
      final bloc = FAQBloc();
      await getOnProgressTickets(context);
      await bloc.getAllFAQs(context, arg: FAQRequest(type: 'faq', kategori: category));
      final fetch = bloc.faqFetch;
      if (fetch.state == FAQState.faqSuccess) {
        if (fetch.data != null) {
          fetch.data.forEach((v) {
            _listFAQ.add(FAQData.fromJson(v));
          });
        }
        notifyListeners();
      } else if (fetch.state == FAQState.faqError) {
        throw fetch.data;
      }
    } catch (e) {
      'Error getListOfFAQ: $e'.logger();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getOnProgressTickets(BuildContext context) async{
    final idUser = SharedPreference().readStorage(SpKeys.userID);
    try{
      final bloc = SupportTicketBloc();
      await bloc.getTicketHistories(context, TicketArgument(page: 0, limit: 10, descending: true, iduser: idUser, close: false));
      final fetch = bloc.supportTicketFetch;

      onProgressTicket = (fetch.data as List<dynamic>?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    }catch(e){
      'TicketsDataQuery Reload Error : $e'.logger();
    }
  }

  Future getListOfLanguage(BuildContext context) async {
    if (_listLanguage.isEmpty) {
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
  }



  Future loadLanguage({int? index}) async {
    late String langIso;
    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);
    print('langiso adalah 1 $_isoCodeCache');

    if (index == null && _isoCodeCache != null) {
      langIso = _isoCodeCache == "en" ? "en" : "id";
    } else {
      langIso = index != null && _listLanguage.isNotEmpty ? _listLanguage[index].langIso ?? "en" : "id";
    }

    SharedPreference().writeStorage(SpKeys.isoCode, langIso);
    print('langiso adalah $langIso');

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

  Future initTranslate(BuildContext context, {int? index, Function(dynamic)? onError}) async {
    try{
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
      context.read<DiariesPlaylistNotifier>().translate(translate);
      context.read<PreUploadContentNotifier>().translate(translate);
      context.read<SelfProfileNotifier>().translate(translate);
      context.read<OtherProfileNotifier>().translate(translate);
      context.read<ChangePasswordNotifier>().translate(translate);
      context.read<SearchNotifier>().translate(translate);
      context.read<NotificationNotifier>().translate(translate);
      context.read<ProfileCompletionNotifier>().translate(translate);
      context.read<ReferralNotifier>().translate(translate);
      context.read<ReviewBuyNotifier>().translate(translate);
      context.read<PaymentMethodNotifier>().translate(translate);
      context.read<PaymentNotifier>().translate(translate);
      context.read<PaymentSummaryNotifier>().translate(translate);
      context.read<CommentNotifierV2>().translate(translate);
      context.read<TicketHistoryNotifier>().translate(translate);
      context.read<DetailTicketNotifier>().translate(translate);
      context.read<VidDetailNotifier>().translate(translate);
      // await context.read<TransactionNotifier>().translate(translate);
      // await context.read<PinAccountNotifier>().translate(translate);

      context.read<VerificationIDNotifier>().translate(translate);

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
    }catch(e){
      'initTranslate error: $e'.logger();
      if(onError != null){
       onError(e);
      }
    }

  }
}
