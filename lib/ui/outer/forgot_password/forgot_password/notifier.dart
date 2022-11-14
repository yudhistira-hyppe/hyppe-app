import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
// import 'package:provider/provider.dart';
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

        await notifier.recoverPasswordBloc(context, email: emailController.text);
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
          _sharedPrefs.writeStorage(SpKeys.isUserRequestRecoverPassword, true);
          await Future.delayed(const Duration(seconds: 1));
          // _routing.move(signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toHome));
          _routing.move(
            Routes.userOtpScreen,
            argument: UserOtpScreenArgument(
              email: emailController.text,
            ),
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

  TextStyle emailNextTextColor(BuildContext context) {
    if (_system.validateEmail(text) && !isLoading) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
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
