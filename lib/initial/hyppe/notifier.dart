import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/themes/hyppe_theme.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';

import '../../app.dart';

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

  Future handleStartUp(bool mounted) async {
    final fixContext = materialAppKey.currentContext!;
    SharedPreference().writeStorage(SpKeys.datetimeLastShowAds, '');
    // try{
    _system.getPackageInfo().then((value) => appVersion = '${value.version}+${value.buildNumber}');
    await fixContext.read<CameraDevicesNotifier>().prepareCameraPage(onError: (e) {
      throw '$e';
    });

    await fixContext.read<TranslateNotifierV2>().initTranslate(fixContext, onError: (e) {
      throw '$e';
    });

    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);
    bool isUserInOTP = SharedPreference().readStorage(SpKeys.isUserInOTP) ?? false;

    //set light theme
    fixContext.read<HyppeNotifier>().themeData = hyppeLightTheme();
    SharedPreference().writeStorage(SpKeys.themeData, false); //set light theme
    System().systemUIOverlayTheme();

    if (isUserInOTP) {
      // print('pasti kesini');
      // print(isUserInOTP);
      fixContext.read<SignUpPinNotifier>().email = email ?? "";
      _routing.moveReplacement(
        Routes.signUpPin,
        argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2, email: email ?? ''),
      );
    } else if (token != null && email != null) {
      final formData = FormData();
      formData.fields.add(const MapEntry('pageRow', '1'));
      formData.fields.add(const MapEntry('pageNumber', '0'));

      print('getInnteractives');
      print(formData.fields);
      if (!mounted) return _routing.moveReplacement(Routes.welcomeLogin);
      await _repos.reposPost(
        fixContext,
        (onResult) async {
          // bool isPreventRoute = SharedPreference().readStorage(SpKeys.isPreventRoute) ?? false;
          // if(!isPreventRoute){
          if ((onResult.statusCode ?? 300) == HTTP_UNAUTHORIZED) {
            print('tidak ada eror');
            await SharedPreference().logOutStorage();
            _routing.moveReplacement(Routes.welcomeLogin);
          } else if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            await SharedPreference().logOutStorage();
            _routing.moveReplacement(Routes.welcomeLogin);
          } else {
            print('tidak ada eror 2');
            _routing.moveReplacement(Routes.lobby);
          }
          // }
        },
        (errorData) {
          // bool isPreventRoute = SharedPreference().readStorage(SpKeys.isPreventRoute) ?? false;
          // 'Exception on authCheck with error ${errorData.toString()}'.logger();
          // if(!isPreventRoute){
          SharedPreference().logOutStorage();
          _routing.moveReplacement(Routes.welcomeLogin);
          // }
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
      await SharedPreference().logOutStorage();
      _routing.moveReplacement(Routes.welcomeLogin);
      // _routing.moveReplacement(Routes.login);
    }
    // }catch(e){
    //   'handleStartUp error: $e'.logger();
    //   FirebaseCrashlytics.instance
    //       .log('Hyppe Error: $e');
    //   Future.delayed(const Duration(milliseconds: 700), (){
    //     bool isPreventRoute = SharedPreference().readStorage(SpKeys.isPreventRoute) ?? false;
    //     if(!isPreventRoute){
    //       _routing.moveReplacement(Routes.welcomeLogin);
    //     }
    //   });
    // }
  }
}
