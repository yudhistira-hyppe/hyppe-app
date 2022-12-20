import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/themes/hyppe_theme.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/extension/log_extension.dart';

class HyppeNotifier with ChangeNotifier {
  static final _repos = Repos();
  static final _system = System();
  static final _routing = Routing();

  ThemeData? _themeData;
  String? appVersion;

  ThemeData? get themeData => _themeData;

  set themeData(ThemeData? val) {
    _themeData = val;
    notifyListeners();
  }

  void setInitialTheme() {
    bool _themeState = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    _themeData = _themeState ? hyppeDarkTheme() : hyppeLightTheme();
  }

  Future handleStartUp(BuildContext context) async {
    _system.getPackageInfo().then((value) => appVersion = '${value.version}+${value.buildNumber}');
    await context.read<CameraDevicesNotifier>().prepareCameraPage();
    await context.read<TranslateNotifierV2>().initTranslate(context);

    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);
    bool isUserInOTP = SharedPreference().readStorage(SpKeys.isUserInOTP) ?? false;
    bool isUserRequestRecoverPassword = SharedPreference().readStorage(SpKeys.isUserRequestRecoverPassword) ?? false;

    //set light theme
    context.read<HyppeNotifier>().themeData = hyppeLightTheme();
    SharedPreference().writeStorage(SpKeys.themeData, false); //set light theme
    System().systemUIOverlayTheme();

    if (isUserRequestRecoverPassword) {
      _routing.moveReplacement(Routes.userOtpScreen, argument: UserOtpScreenArgument(email: email));
      return;
    } else if (isUserInOTP) {
      // print('pasti kesini');
      // print(isUserInOTP);
      context.read<SignUpPinNotifier>().email = email ?? "";
      _routing.moveReplacement(
        Routes.signUpPin,
        argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
      );
      return;
    } else if (token != null) {
      final formData = FormData();
      formData.fields.add(const MapEntry('pageRow', '1'));
      formData.fields.add(const MapEntry('pageNumber', '0'));

      print('getInnteractives');
      print(formData.fields);

      await _repos.reposPost(
        context,
        (onResult) async {
          if ((onResult.statusCode ?? 300) == HTTP_UNAUTHORIZED) {
            await SharedPreference().logOutStorage();
            _routing.moveReplacement(Routes.welcomeLogin);
          } else {
            _routing.moveReplacement(Routes.lobby);
          }
        },
        (errorData) {
          'Exception on authCheck with error ${errorData.toString()}'.logger();
          _routing.moveReplacement(Routes.lobby);
        },
        data: formData,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        },
        host: UrlConstants.getInnteractives,
        withAlertMessage: false,
        withCheckConnection: false,
        methodType: MethodType.post,
      );
    } else {
      _routing.moveReplacement(Routes.welcomeLogin);
      // _routing.moveReplacement(Routes.login);
    }
  }
}
