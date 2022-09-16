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
  String email = SharedPreference().readStorage(SpKeys.email);
  bool _confirm = false;
  bool _matchingPin = true;
  String _pin1 = '';
  String _pin2 = '';
  String _timer = "";
  String _timer2 = "";
  Timer? _myTimer;
  Timer? _myTimer2;
  bool _loading = false;
  bool pinCreate = false;

  CountdownController? get countdownController => _countdownController;
  bool get confirm => _confirm;
  bool get matchingPin => _matchingPin;
  String get pin1 => _pin1;
  String get pin2 => _pin2;
  bool get loading => _loading;
  String get timer2 => _timer2;
  TextEditingController pin1Controller = TextEditingController();
  TextEditingController pin2Controller = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController get otpController => _otpController;

  set confirm(bool val) {
    _confirm = val;
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
    _pin1 = val;
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

  set countdownController(CountdownController? val) {
    _countdownController = val;
    notifyListeners();
  }

  set otpController(TextEditingController val) {
    _otpController = val;
    notifyListeners();
  }

  void cekUserPin(BuildContext context) {
    pinCreate = context.read<SelfProfileNotifier>().user.profile!.pinCreate!;
  }

  void pinChecking(context, String val) {
    var setPin = SharedPreference().readStorage(SpKeys.setPin);
    if (confirm == false) {
      _pin1 = val;
      if (_pin1.length == 6) {
        Routing().move(Routes.pinScreen);
        confirm = true;
      }
    } else {
      _pin2 = val;
      if (_pin2.length == 6) {
        if (_pin2 == _pin1) {
          matchingPin = true;
          Routing().move(Routes.verificationPinScreen);
          startTimer2();
          sendVerificationMail(context);
        } else {
          matchingPin = false;
        }
      }
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
    resetTimer();
    Routing().moveBack();
  }

  Future sendVerificationMail(BuildContext context, {bool resend = false}) async {
    bool connect = await System().checkConnections();
    if (connect) {
      startTimer();
      String type = '';
      if (pinCreate) {
        type = 'CHANGE_PIN';
      } else {
        type = 'CREATE_PIN';
      }
      Map param = {};
      if (resend) {
        param = {"type": "CHANGE_PIN", "event": "NOTIFY_OTP", "status": "NOTIFY"};
      } else {
        param = {"pin": _pin2, "type": type, "event": type, "status": "INITIAL"};
      }

      final notifier = TransactionBloc();
      await notifier.sendVerificationPin(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.sendVerificationSuccess) {}

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

  Future checkOtp(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      loading = true;
      String type = '';
      if (pinCreate) {
        type = 'CHANGE_PIN';
      } else {
        type = 'CREATE_PIN';
      }
      final param = {"otp": otpController.text, "type": type, "event": "VERIFY_OTP", "status": "REPLY"};
      final notifier = TransactionBloc();
      await notifier.sendVerificationPin(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.sendVerificationSuccess) {
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
      return Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant);
    } else {
      return Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.primaryVariant);
    }
  }

  Function()? resendCode(BuildContext context, {bool withStartTimer = true}) {
    if (_timer != "00:00") {
      // ignore: avoid_print
      print('resendCode');
      return null;
    } else {
      return () async {
        if (withStartTimer) {
          startTimer();
        }
        sendVerificationMail(context, resend: true);
      };
    }
  }

  startTimer() {
    int _start = 60;
    // if (_timer != "00:00") {
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
    // }
  }

  startTimer2() {
    _countdownController = CountdownController(
        duration: Duration(seconds: 30),
        onEnd: () {
          print('onEnd');
        });
    notifyListeners();
  }

  resetTimer() {
    _timer = '';
    _myTimer?.cancel();
  }

  Color verifyButtonColor(BuildContext context) {
    if (otpController.text.length >= 3 && !loading) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle verifyTextColor(BuildContext context) {
    if (otpController.text.length >= 4) {
      return Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText);
    } else {
      return Theme.of(context).primaryTextTheme.button!;
    }
  }

  void backHome() {
    _pin1 = '';
    _pin2 = '';
    pin1Controller.clear();
    pin2Controller.clear();
    _otpController.clear();
    matchingPin = true;
    confirm = false;
    resetTimer();
    Routing().moveBack();
    Routing().moveBack();
    Routing().moveBack();
    Routing().moveBack();
  }
}
