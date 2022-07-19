import 'dart:async';
import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';

import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';

import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class UserOtpNotifier extends ChangeNotifier with WidgetsBindingObserver, LoadingNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final _sharedPrefs = SharedPreference();

  String _timer = "";
  bool _inCorrectCode = false;
  bool _isOTPCodeFullFilled = false;
  final TextEditingController pinController = TextEditingController();

  late UserOtpScreenArgument argument;

  final String _excededMessage = "OTP max attempt exceeded, please try after 30 minute";

  Timer? _myTimer;
  bool get inCorrectCode => _inCorrectCode;
  bool get isOTPCodeFullFilled => _isOTPCodeFullFilled;

  final String resendLoadKey = 'resendLoadKey';

  set inCorrectCode(bool val) {
    _inCorrectCode = val;
    notifyListeners();
  }

  set isOTPCodeFullFilled(bool val) {
    _isOTPCodeFullFilled = val;
    notifyListeners();
  }

  set timer(String val) {
    _timer = val;
    notifyListeners();
  }

  void onResetData() {
    pinController.clear();
    _inCorrectCode = false;
    _isOTPCodeFullFilled = false;
  }

  Color verifyButtonColor(BuildContext context) {
    if (isOTPCodeFullFilled && !isLoading) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle verifyTextColor(BuildContext context) {
    if (isOTPCodeFullFilled) {
      return Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText);
    } else {
      return Theme.of(context).primaryTextTheme.button!;
    }
  }

  void initState(UserOtpScreenArgument argument) {
    WidgetsBinding.instance?.addObserver(this);
    this.argument = argument;
    // startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _sharedPrefs.writeStorage(SpKeys.lastTimeStampReachMaxAttempRecoverPassword, DateTime.now().subtract(const Duration(minutes: 31)).millisecondsSinceEpoch);
    }
    super.didChangeAppLifecycleState(state);
  }

  void startTimer() {
    int _start = 60;
    _myTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        if (_start != 0) {
          _start--;
          if (_start.toString().length == 2) {
            timer = "00:${_start.toString()}";
          } else {
            timer = "00:0${_start.toString()}";
          }
          notifyListeners();
        } else {
          t.cancel();
          _myTimer?.cancel();
          timer = "00:00";
          notifyListeners();
        }
      },
    );
  }

  void resetTimer() {
    _timer = '';
    _myTimer?.cancel();
  }

  // String resendString() {
  //   if (_timer != "00:00") {
  //     return "Please wait for" + " $_timer";
  //   } else {
  //     return "Resend New Code";
  //   }
  // }
  String resendString() => language.resendNewCode!;

  TextStyle? resendStyle(BuildContext context) {
    return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.primaryVariant);
  }

  Function? onVerifyButton(BuildContext context) {
    final notifier = UserBloc();
    if (isOTPCodeFullFilled) {
      return () async {
        try {
          // update loading state
          setLoading(true);

          await notifier.recoverPasswordOTPBloc(
            context,
            otp: pinController.text,
            email: argument.email ?? '',
          );
          final fetch = notifier.userFetch;
          if (fetch.userState == UserState.RecoverSuccess) {
            _handleVerifyAction(
              context: context,
              message: language.yourResetCodeHasBeenVerified!,
            );
          } else {
            _inCorrectCode = true;
          }
        } finally {
          try {
            handleShowCountdown(notifier.userFetch.data.messages.info[0]);
          } catch (e) {
            print(e);
          }
          setLoading(false);
        }
      };
    } else {
      return null;
    }
  }

  Future _handleVerifyAction({
    required String message,
    required BuildContext context,
  }) async {
    try {
      // TODO: old code
      // setLoading(false);
      // await ShowBottomSheet().onShowColouredSheet(context, language.verified!, subCaption: message);
      // Routing().moveAndRemoveUntil(
      //   signUpVerified,
      //   root,
      //   argument: VerifyPageArgument(
      //     otp: pinController.text,
      //     redirect: VerifyPageRedirection.toHome,
      //   ),
      // );
      SharedPreference().removeValue(SpKeys.isUserRequestRecoverPassword);
      await _directLogin(context, message);
    } catch (e) {
      print(e);
      Routing().moveAndRemoveUntil(Routes.welcomeLogin, Routes.root);
    } finally {
      setLoading(false);
      onResetData();
    }
  }

  Function()? resendCode(BuildContext context, {bool withStartTimer = true}) {
    if (_timer != "00:00") {
      return null;
    } else {
      return () async {
        if (withStartTimer) {
          startTimer();
        }
        resend(context);
      };
    }
  }

  Future resend(BuildContext context) async {
    final notifier = UserBloc();
    try {
      setLoading(true, loadingObject: resendLoadKey);
      await notifier.recoverPasswordBloc(
        context,
        email: argument.email ?? '',
      );
      final fetch = notifier.userFetch;

      if (fetch.userState == UserState.RecoverSuccess) {
        _sharedPrefs.removeValue(SpKeys.lastTimeStampReachMaxAttempRecoverPassword);
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.checkYourEmail!,
          subCaption: language.weHaveSentAVerificationCodeToYourEmail!,
        );
      }
    } finally {
      setLoading(false, loadingObject: resendLoadKey);
    }
  }

  void handleShowCountdown(String? message) {
    if (message?.toLowerCase().trim() == _excededMessage.toLowerCase().trim()) {
      final lts = _sharedPrefs.readStorage(SpKeys.lastTimeStampReachMaxAttempRecoverPassword);
      if (lts == null) {
        _sharedPrefs.writeStorage(SpKeys.lastTimeStampReachMaxAttempRecoverPassword, DateTime.now().subtract(const Duration(minutes: 31)).millisecondsSinceEpoch);
      }
      notifyListeners();
    }
  }

  Future _directLogin(BuildContext context, String message) async {
    try {
      await FcmService().initializeFcmIfNot();
      final notifier = UserBloc();
      await notifier.signInBlocV2(
        context,
        function: () {},
        email: argument.email ?? '',
        password: pinController.text,
      );

      final fetch = notifier.userFetch;
      if (fetch.userState == UserState.LoginSuccess) {
        final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
        if (_result.userType == null) {
          ShowBottomSheet.onShowSomethingWhenWrong(context);
        } else {
          SharedPreference().writeStorage(SpKeys.userToken, _result.token);
          SharedPreference().writeStorage(SpKeys.email, _result.email);
          try {
            DeviceBloc().activityAwake(context);
          } catch (e) {
            print(e);
          }
          ShowBottomSheet().onShowColouredSheet(context, language.verified!, subCaption: message);
          Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) {
      notifyListeners();
    }
  }
}
