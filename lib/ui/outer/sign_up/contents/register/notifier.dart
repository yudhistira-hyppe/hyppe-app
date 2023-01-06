import 'dart:io';

import 'package:hyppe/core/arguments/sign_up_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/sign_up/sign_up_response.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:provider/provider.dart';

class RegisterNotifier with ChangeNotifier {
  final _system = System();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FocusNode passwordNode = FocusNode();
  final FocusNode emailNode = FocusNode();

  String _password = "";
  String _email = "";
  bool _hidePassword = true;
  bool _loading = false;

  String get password => _password;
  String get email => _email;
  bool get hidePassword => _hidePassword;
  bool get loading => _loading;

  set password(String val) {
    _password = val;
    notifyListeners();
  }

  set email(String val) {
    _email = val;
    notifyListeners();
  }

  set hidePassword(bool val) {
    _hidePassword = val;
    notifyListeners();
  }

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void onBackPressed(BuildContext context) {
    onReset();
    Routing().moveBack();
  }

  void onReset() {
    passwordNode.unfocus();
    emailNode.unfocus();
    passwordController.clear();
    emailController.clear();
    password = "";
    email = "";
    _hidePassword = true;
  }

  Future<bool> onWillPopScope(BuildContext context) async {
    onBackPressed(context);
    return false;
  }

  void passwordToEmail() {
    if (passwordNode.hasPrimaryFocus) {
      passwordNode.unfocus();
    }
    emailNode.requestFocus();
    notifyListeners();
  }

  void emailToPassword() {
    if (emailNode.hasPrimaryFocus) {
      emailNode.unfocus();
    }
    passwordNode.requestFocus();
    notifyListeners();
  }

  Widget passwordSuffixIcon(BuildContext context) => CustomIconButtonWidget(
        iconData: "${AssetPath.vectorPath}${hidePassword ? "eye-off" : "eye"}.svg",
        defaultColor: true,
        onPressed: () => hidePassword = !hidePassword,
      );

  Widget emailSuffixIcon() {
    if (_system.validateEmail(email)) {
      return const CustomIconWidget(
        defaultColor: false,
        iconData: '${AssetPath.vectorPath}valid.svg',
      );
    } else {
      return const SizedBox.shrink();
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

  bool _validationRegister() {
    bool state1 = password.isNotEmpty;
    bool state2 = _system.atLeastEightCharacter(text: password);
    bool state3 = _system.atLeastContainOneCharacterAndOneNumber(text: password);
    return state1 && state2 && state3;
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

  Function? nextButton(BuildContext context) {
    if (_validationRegister()) {
      return () async {
        if (!_system.validateEmail(email)) {
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.checkYourEmail ?? 'Check Your Email',
            subCaption: language.notAValidEmailAddress,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            sizeIcon: 15,
          );
          return;
        } else if (!_system.atLeastEightCharacter(text: password)) {
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.incorrectPassword ?? 'Incorrect Password',
            subCaption: language.atLeast8Characters,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            sizeIcon: 15,
          );
          return;
        } else if (!_system.atLeastContainOneCharacterAndOneNumber(text: password)) {
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.incorrectPassword ?? 'Incorrect Password',
            sizeIcon: 15,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            subCaption: language.atLeastContain1CharacterAnd1Number,
          );
          return;
        } else {
          if (loading) {
            return;
          }
          bool connection = await System().checkConnections();
          if (connection) {
            email = email.toLowerCase();
            final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

            // initialize Fcm service if not
            await FcmService().initializeFcmIfNot();

            // update loading state
            loading = true;

            String realDeviceId = await System().getDeviceIdentifier();
            String platForm = Platform.isAndroid ? "android" : "ios";
            String deviceId = SharedPreference().readStorage(SpKeys.fcmToken);
            String lang = SharedPreference().readStorage(SpKeys.isoCode);

            final notifier = UserBloc();
            await notifier.signUpBlocV2(
              context,
              data: SignUpDataArgument(email: email, password: password, deviceId: deviceId, imei: realDeviceId != "" ? realDeviceId : deviceId, platForm: platForm, lang: lang),
            );
            final fetch = notifier.userFetch;
            loading = false;
            if (fetch.userState == UserState.signUpSuccess) {
              final SignUpResponse _result = SignUpResponse.fromJson(fetch.data);

              SharedPreference().writeStorage(SpKeys.email, _result.email);
              SharedPreference().writeStorage(SpKeys.isUserInOTP, true);
              // signUpPinNotifier.userToken = fetch.data['token'];
              // signUpPinNotifier.userID = _result.userID; >>>>> Backend tidak memberikan key userID
              signUpPinNotifier.username = _result.userName ?? "";
              signUpPinNotifier.email = _result.email ?? "";
              // signUpEulaNotifier.fullName = _result.fullName ?? "";
              // signUpEulaNotifier.userName = _result.userName ?? "";
              // signUpEulaNotifier.email = _result.email ?? "";

              _hidePassword = true;
              onReset();
              notifyListeners();
              Routing().moveAndRemoveUntil(
                Routes.signUpPin,
                Routes.root,
                argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
              );
            } else {
              // loading = false;
              // // >>>>> Agar failed tetap ke signUpPin page
              // signUpPinNotifier.email = emailController.text;
              // Routing().moveAndRemoveUntil(
              //   Routes.signUpPin,
              //   Routes.root,
              //   argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
              // );
            }
          } else {
            loading = false;
            ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
              Routing().moveBack();
              nextButton(context);
            });
          }
        }
      };
    } else {
      return null;
    }
  }
}
