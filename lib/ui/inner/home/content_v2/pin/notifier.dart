import 'dart:async';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PinAccountNotifier extends ChangeNotifier {
  CountdownController? _countdownController;
  bool _confirm = false;
  bool _changeSetNewPin = false;
  bool _matchingPin = true;
  String _pin1 = '';
  String _pin2 = '';
  String _pin3 = '';
  String _pin4 = '';
  String _timer = "";
  String _timer2 = "";
  Timer? _myTimer;
  Timer? _myTimer2;
  bool _loading = false;
  bool pinCreate = false;
  bool checkPin = false;
  bool _isForgotPin = false;
  bool _isSetPinInForgot = false;

  CountdownController? get countdownController => _countdownController;
  bool get confirm => _confirm;
  bool get matchingPin => _matchingPin;
  String get pin1 => _pin1;
  String get pin2 => _pin2;
  String get pin3 => _pin3;
  String get pin4 => _pin4;
  bool get loading => _loading;
  String get timer2 => _timer2;
  TextEditingController pin1Controller = TextEditingController(); //set new pin
  TextEditingController pin2Controller = TextEditingController(); //confirm pin
  TextEditingController pin3Controller = TextEditingController(); //curent pin
  TextEditingController pin4Controller = TextEditingController(); //set new pin in forgot pin
  TextEditingController _otpController = TextEditingController();
  TextEditingController get otpController => _otpController;
  bool get changeSetNewPin => _changeSetNewPin;
  bool get isForgotPin => _isForgotPin;
  bool get isSetPinInForgot => _isSetPinInForgot;

  String _otpVerified = '';
  String get otpVerified => _otpVerified;

  set otpVerified(String val) {
    _otpVerified = val;
    notifyListeners();
  }

  set confirm(bool val) {
    _confirm = val;
    notifyListeners();
  }

  set changeSetNewPin(bool val) {
    _changeSetNewPin = val;
    notifyListeners();
  }

  set matchingPin(bool val) {
    _matchingPin = val;
    notifyListeners();
  }

  set pin1(String val) {
    _pin1 = val;
    notifyListeners();
  }

  set pin2(String val) {
    _pin2 = val;
    notifyListeners();
  }

  set pin3(String val) {
    _pin3 = val;
    notifyListeners();
  }

  set pin4(String val) {
    _pin4 = val;
    notifyListeners();
  }

  set timer(String val) {
    _timer = val;
    notifyListeners();
  }

  set timer2(String val) {
    _timer2 = val;
    notifyListeners();
  }

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  set isForgotPin(bool val) {
    _isForgotPin = val;
    notifyListeners();
  }

  set isSetPinInForgot(bool val) {
    _isSetPinInForgot = val;
    notifyListeners();
  }

  set countdownController(CountdownController? val) {
    _countdownController = val;
    notifyListeners();
  }

  set otpController(TextEditingController val) {
    _otpController = val;
    notifyListeners();
  }

  void cekUserPin(BuildContext context) {
    pinCreate = SharedPreference().readStorage(SpKeys.setPin) == "true";
  }

  void pinChecking(context, String val) {
    _pin1 = val;
    if (_pin1.length == 6) {
      Routing().move(Routes.confirmPinScreen);
    }
  }

  void pinConfirmChecking(context, String val) {
    _pin2 = val;
    if (isSetPinInForgot) {
      if (_pin2 == _pin4) {
        checkOtp(context, fromForgot: true);
      } else {
        matchingPin = false;
      }
    } else {
      if (_pin2 == _pin1) {
        matchingPin = true;
        resetTimer();
        Routing().move(Routes.verificationPinScreen);
        sendVerificationMail(context);
      } else {
        matchingPin = false;
      }
    }
  }

  void pinCurentCheking(context, String val) {
    _pin3 = val;
    if (_pin3.length == 6) {
      sendVerificationMail(context, checkPin: true).then((value) {
        checkPin = value;
        changeSetNewPin = true;
        Routing().move(Routes.pinScreen);
      });
    }
  }

  onBack() {
    resetTimer();
    Routing().moveBack();
  }

  void onExit() {
    if (confirm == true) {
      confirm = false;
      pin2Controller.clear();
    } else {
      pin1Controller.clear();
    }
    matchingPin = true;
    checkPin = false;
    resetTimer();
    Routing().moveBack();
  }

  Future sendVerificationMail(BuildContext context, {bool resend = false, bool checkPin = false, bool forgotPin = false}) async {
    bool connect = await System().checkConnections();
    if (connect) {
      final havePin = SharedPreference().readStorage(SpKeys.setPin);
      resetTimer();
      startTimer();
      String type = '';
      if (pinCreate) {
        type = 'CHANGE_PIN';
      } else {
        type = 'CREATE_PIN';
      }
      Map param = {};
      if (resend) {
        if (isForgotPin) {
          param = {"type": 'FORGOT_PIN', "event": "NOTIFY_OTP", "status": "NOTIFY"};
        } else {
          param = {"type": type, "event": "NOTIFY_OTP", "status": "NOTIFY"};
        }
      } else if (checkPin) {
        param = {"pin": _pin3, "type": "CECK_PIN", "event": "CECK_PIN", "status": "INITIAL"};
      } else if (forgotPin) {
        param = {"type": "FORGOT_PIN", "event": "FORGOT_PIN", "status": "INITIAL"};
      } else {
        param = {"pin": _pin2, "type": type, "event": type, "status": "INITIAL"};
      }

      final notifier = TransactionBloc();
      await notifier.sendVerificationPin(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.sendVerificationSuccess) {
        if (checkPin) {
          return true;
        }
      }

      // if (fetch.postsState == TransactionState.getHistoryError) {
      //   if (fetch.data != null) {
      //     ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
      //   }
      // }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
      });
    }
  }

  bool checkSubmitButtonOTP() {
    if (otpVerified.length >= 4) {
      return true;
    } else {
      return false;
    }
  }

  Future checkOtp(BuildContext context, {bool fromForgot = false}) async {
    bool connect = await System().checkConnections();
    if (connect) {
      loading = true;
      String type = '';
      Map param = {};

      if (isForgotPin) {
        type = 'FORGOT_PIN';
      } else if (pinCreate) {
        type = 'CHANGE_PIN';
      } else {
        type = 'CREATE_PIN';
      }
      if (fromForgot) {
        param = {"otp": _pin4, "type": 'FORGOT_PIN', "event": "CREATE_PIN", "status": "REPLY"};
      } else {
        param = {"otp": otpController.text, "type": type, "event": "VERIFY_OTP", "status": "REPLY"};
      }
      final notifier = TransactionBloc();
      await notifier.sendVerificationPin(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.sendVerificationSuccess) {
        if (isForgotPin) {
          if (fromForgot) {
            pinCreate = true;
            _isSetPinInForgot = false;
            SharedPreference().writeStorage(SpKeys.setPin, 'true');
            backHome();
            ShowBottomSheet().onShowColouredSheet(
              context,
              'PIN successful created',
              color: kHyppeTextSuccess,
              iconSvg: "${AssetPath.vectorPath}valid-invert.svg",
              subCaption: 'Your PIN has been successfully created',
            );
          } else {
            Routing().move(Routes.forgotPinScreen);
          }
        } else {
          pinCreate = true;
          SharedPreference().writeStorage(SpKeys.setPin, 'true');
          backHome();
          ShowBottomSheet().onShowColouredSheet(
            context,
            'PIN successful created',
            color: kHyppeTextSuccess,
            iconSvg: "${AssetPath.vectorPath}valid-invert.svg",
            subCaption: 'Your PIN has been successfully created',
          );
        }
      }

      if (fetch.postsState == TransactionState.getHistoryError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message['info'], color: Theme.of(context).colorScheme.error);
        }
      }
      loading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
      });
    }
  }

  String resendString(BuildContext context) {
    var lang = context.read<TranslateNotifierV2>().translate;
    if (_timer != "00:00") {
      return "${lang.pleaseWaitFor}" " $_timer";
    } else {
      return "${lang.resendNewCode}";
    }
  }

  TextStyle resendStyle(BuildContext context) {
    if (_timer != "00:00") {
      return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant) ?? const TextStyle();
    } else {
      return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.primaryVariant) ?? const TextStyle();
    }
  }

  Function()? resendCode(BuildContext context, {bool withStartTimer = true}) {
    if (_timer != "00:00") {
      // ignore: avoid_print
      return null;
    } else {
      return () async {
        resetTimer();
        startTimer();
        sendVerificationMail(context, resend: true);
      };
    }
  }

  startTimer() {
    int _start = 60;
    if (_timer != "00:00") {
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
  }

  resetTimer() {
    _timer = '';
    _myTimer?.cancel();
  }

  Color verifyButtonColor(BuildContext context) {
    if (checkSubmitButtonOTP() && !loading) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle verifyTextColor(BuildContext context) {
    if (otpController.text.length >= 4) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
    }
  }

  void backHome() {
    _pin1 = '';
    _pin2 = '';
    _pin3 = '';
    _pin4 = '';
    pin1Controller.clear();
    pin2Controller.clear();
    pin3Controller.clear();
    pin4Controller.clear();
    _otpController.clear();
    matchingPin = true;
    confirm = false;
    checkPin = false;
    isForgotPin = false;
    otpVerified = '';
    resetTimer();
    Routing().moveBack();
    Routing().moveBack();
    Routing().moveBack();
    Routing().moveBack();
  }

  void forgotPin(BuildContext context) {
    sendVerificationMail(context, forgotPin: true);
    _isForgotPin = true;
    Routing().move(Routes.verificationPinScreen);
    notifyListeners();
  }

  void setPinInForgot(BuildContext context, val) {
    _pin4 = val;
    if (_pin4.length == 6) {
      _isSetPinInForgot = true;
      notifyListeners();
      Routing().move(Routes.confirmPinScreen);
    }
  }
}
