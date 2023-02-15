import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordNotifier with ChangeNotifier {
  final _system = System();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool _switchState = false;
  bool _onSave = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureReTypePassword = true;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reTypePasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();

  bool get obscureCurrentPassword => _obscureCurrentPassword;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureReTypePassword => _obscureReTypePassword;
  bool get switchState => _switchState;
  bool get onSave => _onSave;

  set switchState(bool val) {
    _switchState = val;
    notifyListeners();
  }

  set obscureCurrentPassword(bool val) {
    _obscureCurrentPassword = val;
    notifyListeners();
  }

  set obscureNewPassword(bool val) {
    _obscureNewPassword = val;
    notifyListeners();
  }

  set obscureReTypePassword(bool val) {
    _obscureReTypePassword = val;
    notifyListeners();
  }

  set onSave(bool val) {
    _onSave = val;
    notifyListeners();
  }

  bool _buttonValidation() {
    bool v1 = !onSave;
    bool v2 = currentPasswordController.text.isNotEmpty;
    bool v3 = newPasswordController.text.isNotEmpty;
    bool v4 = reTypePasswordController.text.isNotEmpty;
    return v1 && v2 && v3 && v4;
  }

  Color saveButtonColor(BuildContext context) {
    if (_buttonValidation()) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle saveTextColor(BuildContext context) {
    if (_buttonValidation()) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
    }
  }

  TextStyle label(BuildContext context) => Theme.of(context).textTheme.headline6?.copyWith(color: kHyppePrimary) ?? const TextStyle();
  TextStyle text(BuildContext context) => Theme.of(context).textTheme.bodyText1 ?? const TextStyle();
  TextStyle hint(BuildContext context) => Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).tabBarTheme.unselectedLabelColor) ?? const TextStyle();

  void onClickSave(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      final profileNotifier = Provider.of<SelfProfileNotifier>(context, listen: false);

      if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
      if (!_system.passwordMatch(password: newPasswordController.text, confirmPassword: reTypePasswordController.text)) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? '',
          sizeIcon: 15,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          subCaption: language.checkCarefullyPasswordAndReTypePassword,
        );
        return;
      } else if (!_system.atLeastEightCharacter(text: newPasswordController.text)) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? '',
          subCaption: language.atLeast8Characters,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          sizeIcon: 15,
        );
        return;
      } else if (!_system.atLeastContainOneCharacterAndOneNumber(text: newPasswordController.text)) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? '',
          sizeIcon: 15,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          subCaption: language.atLeastContain1CharacterAnd1Number,
        );
        return;
      } else if (_system.mustNotContainYourNameOrEmail(
        text: newPasswordController.text,
        email: profileNotifier.user.profile?.email ?? '',
        name: profileNotifier.user.profile?.fullName ?? '',
      )) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.incorrectPassword ?? '',
          sizeIcon: 15,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          subCaption: language.mustNotContainYourNameOrEmail,
        );
        return;
      } else {
        onSave = true;
        final notifier = UserBloc();
        await notifier.changePasswordBloc(context, oldPass: currentPasswordController.text, newPass: reTypePasswordController.text);
        final fetch = notifier.userFetch;
        if (fetch.userState == UserState.changePasswordSuccess) {
          onSave = false;
          obscureCurrentPassword = true;
          obscureNewPassword = true;
          obscureReTypePassword = true;
          clearTxt();
          ShowBottomSheet().onShowColouredSheet(context, language.passwordChangedSuccessfully ?? '');
          await context.read<SettingNotifier>().logOut(context);
        }
        if (fetch.userState == UserState.changePasswordError) {
          onSave = false;
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, language.incorrectPassword ?? '', color: Theme.of(context).colorScheme.error);
          }
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onClickSave(context);
      });
    }
  }

  void clearTxt() {
    newPasswordController.clear();
    reTypePasswordController.clear();
    currentPasswordController.clear();
  }

  Future<bool> onWillPop() async {
    if (onSave) {
      return Future.value(false);
    } else {
      clearTxt();
      return Future.value(true);
    }
  }
}
