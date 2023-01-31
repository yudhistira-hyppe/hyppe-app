import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/sign_up/sign_up_response.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
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
import 'package:provider/provider.dart';

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
  bool _hidePassword = false;
  bool get hidePassword => _hidePassword;
  bool _hideConfirmPassword = false;
  bool get hideConfirmPassword => _hideConfirmPassword;

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
    Future.delayed(Duration.zero, () {
      emailController.clear();
      notifyListeners();
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
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.checkYourEmail ?? 'Check Your Email',
            subCaption: language.weHaveSentAVerificationCodeToYourEmail,
          );
          _sharedPrefs.writeStorage(SpKeys.email, emailController.text);
          // _sharedPrefs.writeStorage(SpKeys.isUserRequestRecoverPassword, true);
          await Future.delayed(const Duration(seconds: 1));
          // _routing.move(signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toHome));
          _routing.move(
            Routes.userOtpScreen,
            argument: UserOtpScreenArgument(
              email: emailController.text,
            ),
          );
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
      } catch (e) {
        setLoading(false);
      }
    } else {
      // ShowBottomSheet().onShowColouredSheet(
      //   context,
      //   language .formAccountDoesNotContainEmail,
      //   maxLines: 2,
      //   sizeIcon: 15,
      //   color: kHyppeTextWarning,
      //   iconColor: kHyppeTextPrimary,
      //   iconSvg: "${AssetPath.vectorPath}report.svg",
      //   subCaption: language.ifYouWantToResetPasswordFillTheFormAccountWithYourEmail,
      // );
    }
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
      return Theme.of(context).colorScheme.primaryVariant;
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

  bool _validationRegister() {
    bool state1 = password.isNotEmpty;
    bool state2 = _system.atLeastEightCharacter(text: password);
    bool state3 = _system.atLeastContainOneCharacterAndOneNumber(text: password);
    bool state4 = checkConfirmPassword();
    // bool state5 = System().specialCharPass(password);
    return state1 && state2 && state3 && state4;
  }

  Color nextButtonColor(BuildContext context) {
    if (_validationRegister() && !loading) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle nextTextColor(BuildContext context) {
    if (_validationRegister()) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
    }
  }

  void nextButton(BuildContext context, bool mounted) {
    if (_validationRegister()) {
      String subCaption = '';
      if (!_system.canSpecialCharPass(password)) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? 'Incorrect Password',
          subCaption: language.allowedSpecialCharacters,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          sizeIcon: 15,
        );
        return;
      }
      _createNewPassword(context, mounted);
    }
  }

  Future _createNewPassword(BuildContext context, bool mounted) async {
    bool connection = await System().checkConnections();
    if (connection) {
      _loading = true;
      notifyListeners();
      if (!mounted) return false;
      final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

      final notifier = UserBloc();
      await notifier.recoverPasswordBloc(
        context,
        email: emailController.text,
        event: 'COMPLETE',
        status: 'COMPLETE',
      );
      final fetch = notifier.userFetch;
      _loading = false;
      notifyListeners();
      print('ini hasil ${fetch.userState}');
      if (fetch.userState == UserState.RecoverSuccess) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? 'Incorrect Password',
          subCaption: language.allowedSpecialCharacters,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          sizeIcon: 15,
        );
        // final SignUpResponse _result = SignUpResponse.fromJson(fetch.data);
        Routing().moveAndRemoveUntil(Routes.welcomeLogin, Routes.welcomeLogin);
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

  // Future? nextButton(BuildContext context) async {
  //   if (_validationRegister()) {
  //     return () async {
  //       if (!_system.atLeastEightCharacter(text: password)) {
  //         ShowBottomSheet().onShowColouredSheet(
  //           context,
  //           language.incorrectPassword ?? 'Incorrect Password',
  //           subCaption: language.atLeast8Characters,
  //           color: Theme.of(context).colorScheme.error,
  //           iconSvg: "${AssetPath.vectorPath}close.svg",
  //           sizeIcon: 15,
  //         );
  //         return;
  //       } else if (!_system.atLeastContainOneCharacterAndOneNumber(text: password)) {
  //         ShowBottomSheet().onShowColouredSheet(
  //           context,
  //           language.incorrectPassword ?? 'Incorrect Password',
  //           sizeIcon: 15,
  //           color: Theme.of(context).colorScheme.error,
  //           iconSvg: "${AssetPath.vectorPath}close.svg",
  //           subCaption: language.atLeastContain1CharacterAnd1Number,
  //         );
  //         return;
  //       } else if (!checkConfirmPassword()) {
  //         ShowBottomSheet().onShowColouredSheet(
  //           context,
  //           language.incorrectPassword ?? 'Incorrect Password',
  //           sizeIcon: 15,
  //           color: Theme.of(context).colorScheme.error,
  //           iconSvg: "${AssetPath.vectorPath}close.svg",
  //           subCaption: language.atLeastContain1CharacterAnd1Number,
  //         );
  //         return;
  //       } else {
  //         if (loading) {
  //           return;
  //         }
  //         bool connection = await System().checkConnections();
  //         if (connection) {
  //           final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

  //           // update loading state
  //           loading = true;

  //           final notifier = UserBloc();

  //           await notifier.recoverPasswordBloc(
  //             context,
  //             email: emailController.text,
  //             event: 'COMPLETE',
  //             status: 'COMPLETE',
  //           );
  //           final fetch = notifier.userFetch;
  //           loading = false;
  //           if (fetch.userState == UserState.signUpSuccess) {
  //             final SignUpResponse _result = SignUpResponse.fromJson(fetch.data);

  //             SharedPreference().writeStorage(SpKeys.email, _result.email);
  //             SharedPreference().writeStorage(SpKeys.isUserInOTP, true);
  //             // signUpPinNotifier.userToken = fetch.data['token'];
  //             // signUpPinNotifier.userID = _result.userID; >>>>> Backend tidak memberikan key userID
  //             signUpPinNotifier.username = _result.userName ?? "";
  //             signUpPinNotifier.email = _result.email ?? "";
  //             // signUpEulaNotifier.fullName = _result.fullName ?? "";
  //             // signUpEulaNotifier.userName = _result.userName ?? "";
  //             // signUpEulaNotifier.email = _result.email ?? "";

  //             _hidePassword = true;
  //             onReset();
  //             notifyListeners();
  //             Routing().moveAndRemoveUntil(
  //               Routes.signUpPin,
  //               Routes.root,
  //               argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
  //             );
  //           } else {
  //             // loading = false;
  //             // // >>>>> Agar failed tetap ke signUpPin page
  //             // signUpPinNotifier.email = emailController.text;
  //             // Routing().moveAndRemoveUntil(
  //             //   Routes.signUpPin,
  //             //   Routes.root,
  //             //   argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
  //             // );
  //           }
  //         } else {
  //           loading = false;
  //           ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
  //             Routing().moveBack();
  //             nextButton(context);
  //           });
  //         }
  //       }
  //     };
  //   } else {
  //     return null;
  //   }
  // }

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
