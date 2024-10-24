import 'dart:async';

import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class ForgotPasswordNotifier extends ChangeNotifier with LoadingNotifier {
  final _system = System();
  final _routing = Routing();
  final _sharedPrefs = SharedPreference();

  final FocusNode focusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  bool _loading = false;
  bool get loading => _loading;

  String _password = "";
  String get password => _password;
  String _confirmPassword = "";
  String get confirmPassword => _confirmPassword;
  bool _hidePassword = true;
  bool get hidePassword => _hidePassword;
  bool _hideConfirmPassword = true;
  bool get hideConfirmPassword => _hideConfirmPassword;
  String? _invalidEmail = null;
  String? get invalidEmail => _invalidEmail;

  set password(String val) {
    _password = val;
    notifyListeners();
  }

  set confirmPassword(String val) {
    _confirmPassword = val;
    notifyListeners();
  }

  set hidePassword(bool val) {
    _hidePassword = val;
    notifyListeners();
  }

  set hideConfirmPassword(bool val) {
    _hideConfirmPassword = val;
    notifyListeners();
  }

  set invalidEmail(String? val) {
    _invalidEmail = val;
    notifyListeners();
  }

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String _text = "";

  String get text => _text;

  set text(String val) {
    _text = val;
    notifyListeners();
  }

  void initState() {
    _text = "";
    _invalidEmail = null;
    Future.delayed(Duration.zero, () {
      emailController.clear();
      notifyListeners();
    });
  }

  initStateNewPass() {
    _password = "";
    Future.delayed(Duration.zero, () {
      passwordConfirmController.clear();
      passwordController.clear();
    });
  }

  Future onClickForgotPassword(BuildContext context) async {
    if (isLoading) {
      return;
    }
    if (_system.validateEmail(emailController.text)) {
      try {
        setLoading(true);
        final notifier = UserBloc();
        // final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

        await notifier.recoverPasswordBloc(context, email: emailController.text, event: "RECOVER_PASS", status: 'INITIAL');
        final fetch = notifier.userFetch;
        setLoading(false);
        if (fetch.userState == UserState.RecoverSuccess) {
          // signUpPinNotifier.email = emailController.text;
          // ShowBottomSheet().onShowColouredSheet(
          //   context,
          //   language.checkYourEmail ?? 'Check Your Email',
          //   subCaption: language.weHaveSentAVerificationCodeToYourEmail,
          // );
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.titleSuccessPin ?? ' ',
            subCaption: language.messageSuccessPin,
            maxLines: 3,
            borderRadius: 8,
            color: kHyppeTextLightPrimary,
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 25),
          );
          _sharedPrefs.writeStorage(SpKeys.email, emailController.text);
          // _sharedPrefs.writeStorage(SpKeys.isUserRequestRecoverPassword, true);
          Future.delayed(const Duration(seconds: 2), () {
            _routing.moveReplacement(
              Routes.userOtpScreen,
              argument: UserOtpScreenArgument(
                email: emailController.text,
              ),
            );
          });
          // _routing.move(signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toHome));
        } else {
          final responseCode = fetch.data['response_code'];
          print('onClickForgotPassword: error $responseCode ');

          if (responseCode == 800) {
            ShowBottomSheet().onShowColouredSheet(context, language.titleEmailIsGmail ?? '',
                subCaption: language.messageEmailIsGmail,
                maxLines: 3,
                borderRadius: 8,
                sizeIcon: 20,
                color: kHyppeTextLightPrimary,
                isArrow: true,
                iconColor: kHyppeBorder,
                padding: EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 25),
                iconSvg: "${AssetPath.vectorPath}info_white.svg", function: () {
              _routing.moveAndRemoveUntil(Routes.welcomeLogin, Routes.root);
            });
          } else if (responseCode == 801) {
            invalidEmail = language.pleaseEnterRegisteredEmail;
          } else {
            ShowBottomSheet().onShowColouredSheet(
              context,
              "${fetch.data['messages']['info'][0]}",
              maxLines: 3,
              sizeIcon: 15,
              color: kHyppeRed,
              iconColor: kHyppeTextPrimary,
              iconSvg: "${AssetPath.vectorPath}remove.svg",
            );
          }
        }
      } catch (e) {
        setLoading(false);
      }
    }
    // else {
    //   ShowBottomSheet().onShowColouredSheet(
    //     context,
    //     language.formAccountDoesNotContainEmail ?? '',
    //     maxLines: 2,
    //     sizeIcon: 15,
    //     color: kHyppeTextWarning,
    //     iconColor: kHyppeTextPrimary,
    //     iconSvg: "${AssetPath.vectorPath}report.svg",
    //     subCaption: language.ifYouWantToResetPasswordFillTheFormAccountWithYourEmail,
    //   );
    // }
  }

  Widget emailSuffixIcon() {
    if (_system.validateEmail(text) && !isLoading) {
      return const CustomIconWidget(
        defaultColor: false,
        iconData: '${AssetPath.vectorPath}valid.svg',
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Color emailNextButtonColor(BuildContext context) {
    if (_system.validateEmail(text) && !isLoading) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  Widget checkBoxSuffix(bool state, {bool isEmail = false}) => Checkbox(
        value: state,
        onChanged: (e) {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: isEmail ? const BorderSide(color: Colors.transparent) : null,
        activeColor: kHyppeLightSuccess,
        checkColor: kHyppeLightButtonText,
      );

  TextStyle emailNextTextColor(BuildContext context) {
    if (_system.validateEmail(text) && !isLoading) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
    }
  }

  bool checkConfirmPassword() {
    if (password == passwordConfirmController.text && password != '') {
      return true;
    } else {
      return false;
    }
  }

  bool validationRegister() {
    bool state1 = password.isNotEmpty;
    bool state2 = _system.atLeastEightUntilTwentyCharacter(text: password);
    bool state3 = _system.atLeastContainOneCharacterAndOneNumber(text: password);
    bool state4 = _system.specialCharPass(password);
    // bool state5 = System().specialCharPass(password);
    return state1 && state2 && state3 && state4;
  }

  Color nextButtonColor(BuildContext context) {
    if (validationRegister() && !loading && confirmPassword == password) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle nextTextColor(BuildContext context) {
    if (validationRegister() && confirmPassword == password) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
    }
  }

  void nextButton(BuildContext context, bool mounted) {
    if (validationRegister() && !loading && confirmPassword == password) {
      _createNewPassword(context, mounted);
    }
  }

  Future _createNewPassword(BuildContext context, bool mounted) async {
    bool connection = await System().checkConnections();
    if (connection) {
      _loading = true;
      notifyListeners();
      if (!mounted) return false;
      // final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

      final notifier = UserBloc();
      await notifier.recoverPasswordBloc(
        context,
        email: emailController.text,
        event: 'COMPLETE',
        status: 'COMPLETE',
        newPassword: password,
      );
      final fetch = notifier.userFetch;
      _loading = false;
      notifyListeners();
      print('ini hasil ${fetch.userState}');
      if (fetch.userState == UserState.RecoverSuccess) {
        if (!mounted) return false;
        _handleSignIn(context, mounted);
      } else {}
    } else {
      _loading = false;
      if (!mounted) return false;
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        nextButton(context, mounted);
      });
    }
  }

  Future _handleSignIn(BuildContext context, bool mounted) async {
    passwordController.clear();
    passwordConfirmController.clear();
    try {
      ShowGeneralDialog.loadingDialog(context);
      await FcmService().initializeFcmIfNot();
      final notifier = UserBloc();
      if (!mounted) return false;
      await notifier.signInBlocV2(
        context,
        function: () {},
        email: emailController.text,
        password: password,
      );

      final fetch = notifier.userFetch;
      if (fetch.userState == UserState.LoginSuccess) {
        final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
        if (_result.userType == null) {
          ShowBottomSheet.onShowSomethingWhenWrong(context);
        } else {

          SharedPreference().writeStorage(SpKeys.isGuest, false);
          SharedPreference().writeStorage(SpKeys.userToken, _result.token);
          SharedPreference().writeStorage(SpKeys.email, _result.email);
          SharedPreference().writeStorage(SpKeys.userID, _result.idUser);
          try {
            DeviceBloc().activityAwake(context);
          } catch (e) {
            print(e);
          }
          Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void setLoading(
    bool val, {
    bool setState = true,
    Object? loadingObject,
  }) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) {
      notifyListeners();
    }
  }
}
