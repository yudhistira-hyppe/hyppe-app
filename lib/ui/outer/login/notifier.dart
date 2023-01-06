// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

import '../../../core/arguments/faq_argument.dart';
import '../../../core/bloc/faq/bloc.dart';
import '../../../core/bloc/faq/state.dart';
import '../../../core/constants/asset_path.dart';
import '../../../core/models/collection/faq/faq_data.dart';
import '../../../core/models/collection/faq/faq_request.dart';
import '../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';

// import 'package:twitter_login/twitter_login.dart';

class LoginNotifier extends LoadingNotifier with ChangeNotifier {
  final _routing = Routing();

  LocalizationModelV2 language = LocalizationModelV2();

  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  double? latitude; // Latitude, in degrees
  double? longitude; // Longitude, in degrees
  String _version = "";

  String _email = "";
  String _password = "";
  String? _emailValidation;
  String? _passwordValidation;
  bool _hide = true;
  bool _incorrect = false;
  GoogleSignInAccount? _userGoogleSignIn;
  String? googleSignInError;
  // AccessToken? _accessToken;

  String get version => _version;
  String get email => _email;
  String get password => _password;
  String? get emailValidation => _emailValidation;
  String? get passwordValidation => _passwordValidation;
  bool get hide => _hide;
  bool get incorrect => _incorrect;
  GoogleSignInAccount? get userGoogleSignIn => _userGoogleSignIn;

  set version(String val) {
    _version = val;
    notifyListeners();
  }

  set email(String val) {
    _email = val;
    notifyListeners();
  }

  set password(String val) {
    _password = val;
    notifyListeners();
  }

  set emailValidation(String? val) {
    _emailValidation = val;
    notifyListeners();
  }

  set passwordValidation(String? val) {
    _passwordValidation = val;
    notifyListeners();
  }

  set hide(bool val) {
    _hide = val;
    notifyListeners();
  }

  set incorrect(bool val) {
    _incorrect = val;
    notifyListeners();
  }

  static const loadingForgotPasswordKey = 'loadingForgotPasswordKey';
  static const loadingLoginGoogleKey = 'loadingLoginGoogleKey';

  Future onClickForgotPassword(BuildContext context) async {
    _routing.move(Routes.forgotPassword);
  }

  void onClickSignUpHere() {
    incorrect = false;
    _routing.move(Routes.register);
  }

  void tapBack() {
    Routing().moveBack();
  }

  clearTextController() {
    emailController.clear();
    passwordController.clear();
    _email = "";
    _password = "";
    notifyListeners();
  }

  unFocusController() {
    emailFocus.unfocus();
    passwordFocus.unfocus();
  }

  Future goToHelpLogin(BuildContext context) async{
    try{
      final listFAQ = [];
      final bloc = FAQBloc();
      await bloc.getAllFAQs(context, arg: FAQRequest(type: 'faq', kategori: 'Masuk dan Pengaturan Akun'));
      final fetch = bloc.faqFetch;
      if(fetch.state == FAQState.faqSuccess){
        if(fetch.data != null){
          fetch.data.forEach((v){
            listFAQ.add(FAQData.fromJson(v));
          });
          if(listFAQ.isNotEmpty){
            Routing().move(Routes.faqDetail, argument: FAQArgument(details: listFAQ[0].detail, isLogin: true));
          }else{
            throw 'Data is Empty';
          }
        }else{
          throw 'Data is null';
        }
      }else if (fetch.state == FAQState.faqError){
        throw fetch.data;
      }
    }catch(e){
      'Error getListOfFAQ: $e'.logger();
      try{
        await ShowBottomSheet().onShowColouredSheet(
          context,
          '$e',
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          sizeIcon: 15,
        );
      }catch(e){
        e.logger();
      }
    }

  }
}
