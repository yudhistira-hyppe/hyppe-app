import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/google_sign_in_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/constants/enum.dart';

class LoginNotifier extends LoadingNotifier with ChangeNotifier {
  final _routing = Routing();
  final _googleSignInService = GoogleSignInService();
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  String _email = "";
  String _password = "";
  String? _emailValidation;
  String? _passwordValidation;
  bool _hide = true;
  bool _incorrect = false;

  String get email => _email;
  String get password => _password;
  String? get emailValidation => _emailValidation;
  String? get passwordValidation => _passwordValidation;
  bool get hide => _hide;
  bool get incorrect => _incorrect;

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

  String? emailValidator(String v) => System().validateEmail(v) ? null : "Not a valid email address";
  String? passwordValidator(String v) => v.length > 4 ? null : "Incorrect Password";
  bool buttonDisable() => email.isNotEmpty && password.isNotEmpty ? true : false;

  Future onClickForgotPassword(BuildContext context) async {
    _routing.move(Routes.forgotPassword);
  }

  Future onClickLogin(BuildContext context) async {
    bool connection = await System().checkConnections();
    if (connection) {
      unFocusController();
      setLoading(true);
      incorrect = false;
      await FcmService().initializeFcmIfNot();
      final notifier = UserBloc();
      await notifier.signInBlocV2(
        context,
        email: emailController.text,
        password: passwordController.text,
        function: () => onClickLogin(context),
      );
      setLoading(false);

      final fetch = notifier.userFetch;
      if (fetch.userState == UserState.LoginSuccess) {
        hide = true;
        final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
        _validateUserData(context, _result);
      }
      if (fetch.userState == UserState.LoginError) {
        if (fetch.data != null) {
          clearTextController();
          incorrect = true;
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
    }
  }

  void onClickSignUpHere() {
    incorrect = false;
    _routing.move(Routes.register);
  }

  Future onClickGoogle(BuildContext context) async {
    bool connection = await System().checkConnections();
    if (connection) {
      unFocusController();
      await FcmService().initializeFcmIfNot();
      final _account = await _googleSignInService.handleSignIn(context);

      if (_account?.id != null) {
        final notifier = UserBloc();
        setLoading(true, loadingObject: loadingLoginGoogleKey);
        await notifier.signInWithGoogleBloc(context, userAccount: _account);
        setLoading(false, loadingObject: loadingLoginGoogleKey);
        final fetch = notifier.userFetch;
        if (fetch.userState == UserState.LoginGoogleSuccess) {
          hide = true;
          final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
          _validateUserData(context, _result);

          // TODO: handle google auth error
          // _googleSignInService.handleSignOut();
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
    }
  }

  _validateUserData(BuildContext context, UserProfileModel signData) async {
    if (signData.userType == null) {
      clearTextController();
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    } else if (signData.userType == UserType.verified) {
      clearTextController();
      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      DeviceBloc().activityAwake(context);
      Routing().moveReplacement(Routes.lobby);
    } else if (signData.userType == UserType.notVerified) {
      final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

      await ShowBottomSheet().onShowColouredSheet(
        context,
        'Your email has not been verified, click Ok to verify your email.',
        maxLines: 2,
        enableDrag: false,
        dismissible: false,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );

      _googleSignInService.handleSignOut();

      signUpPinNotifier.username = signData.username ?? '';
      signUpPinNotifier.email = signData.email ?? '';
      signUpPinNotifier.resend(context);

      signUpPinNotifier.userToken = signData.token!;
      // signUpPinNotifier.userID = signData.profileID!;
      Routing().move(Routes.signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toLogin)).whenComplete(() {
        clearTextController();
      });
    }
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

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }
}
