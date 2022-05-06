import 'dart:async';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/sign_in/sign_in.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPinNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController tec1 = TextEditingController();
  final TextEditingController tec2 = TextEditingController();
  final TextEditingController tec3 = TextEditingController();
  final TextEditingController tec4 = TextEditingController();
  final FocusNode fn1 = FocusNode();
  final FocusNode fn2 = FocusNode();
  final FocusNode fn3 = FocusNode();
  final FocusNode fn4 = FocusNode();
  String _input1 = "";
  String _input2 = "";
  String _input3 = "";
  String _input4 = "";
  String _timer = "";
  bool _inCorrectCode = false;
  bool _loading = false;
  String _username = "";
  String _email = "";
  String _userID = "";
  String _userToken = "";
  Timer? _myTimer;
  RawKeyEvent? _rawKeyEvent;

  String get input1 => _input1;
  String get input2 => _input2;
  String get input3 => _input3;
  String get input4 => _input4;
  bool get inCorrectCode => _inCorrectCode;
  bool get loading => _loading;
  String get username => _username;
  String get email => _email;
  String get userID => _userID;
  String get userToken => _userToken;
  RawKeyEvent? get rawKeyEvent => _rawKeyEvent;

  set input1(String val) {
    _input1 = val;
    notifyListeners();
  }

  set input2(String val) {
    _input2 = val;
    notifyListeners();
  }

  set input3(String val) {
    _input3 = val;
    notifyListeners();
  }

  set input4(String val) {
    _input4 = val;
    notifyListeners();
  }

  set inCorrectCode(bool val) {
    _inCorrectCode = val;
    notifyListeners();
  }

  set timer(String val) {
    _timer = val;
    notifyListeners();
  }

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  set username(String val) {
    _username = val;
    notifyListeners();
  }

  set email(String val) {
    _email = val;
    notifyListeners();
  }

  set userID(String val) {
    _userID = val;
    notifyListeners();
  }

  set userToken(String val) {
    _userToken = val;
    notifyListeners();
  }

  set rawKeyEvent(RawKeyEvent? val) {
    _rawKeyEvent = val;
    notifyListeners();
  }

  unFocusingNode() {
    fn1.unfocus();
    fn2.unfocus();
    fn3.unfocus();
    fn4.unfocus();
    notifyListeners();
  }

  onTextInputRectangle() {
    if (inCorrectCode) inCorrectCode = false;
    if (rawKeyEvent?.logicalKey == LogicalKeyboardKey.backspace) {
      if (input1.isEmpty) {
        fn1.requestFocus();
      } else {
        if (input2.isEmpty) {
          fn1.requestFocus();
        } else {
          if (input3.isEmpty) {
            fn2.requestFocus();
          } else {
            if (input4.isEmpty) {
              fn3.requestFocus();
            }
          }
        }
      }
    } else {
      if (input1.isEmpty) {
        fn1.requestFocus();
        fn2.unfocus();
        fn3.unfocus();
        fn4.unfocus();
      } else {
        if (input2.isEmpty) {
          fn1.unfocus();
          fn2.requestFocus();
          fn3.unfocus();
          fn4.unfocus();
        } else {
          if (input3.isEmpty) {
            fn1.unfocus();
            fn2.unfocus();
            fn3.requestFocus();
            fn4.unfocus();
          } else {
            if (input4.isEmpty) {
              fn1.unfocus();
              fn2.unfocus();
              fn3.unfocus();
              fn4.requestFocus();
            } else {
              unFocusingNode();
            }
          }
        }
      }
    }
  }

  onBackVerifiedEmail({bool indicateBack = true}) {
    tec1.clear();
    tec2.clear();
    tec3.clear();
    tec4.clear();
    input1 = "";
    input2 = "";
    input3 = "";
    input4 = "";
    inCorrectCode = false;
    if (indicateBack) {
      unFocusingNode();
      SharedPreference().removeValue(SpKeys.isUserInOTP);
      Routing().moveAndRemoveUntil(Routes.login, Routes.root);
    }
  }

  Color verifyButtonColor(BuildContext context) {
    if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty && !loading) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle verifyTextColor(BuildContext context) {
    if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty) {
      return Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText);
    } else {
      return Theme.of(context).primaryTextTheme.button!;
    }
  }

  startTimer() {
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

  resetTimer() {
    _timer = '';
    _myTimer?.cancel();
  }

  String resendString() {
    if (_timer != "00:00") {
      return "${language.pleaseWaitFor}" " $_timer";
    } else {
      return "${language.resendNewCode}";
    }
  }

  TextStyle resendStyle(BuildContext context) {
    if (_timer != "00:00") {
      return Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant);
    } else {
      return Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.primaryVariant);
    }
  }

  Function? onVerifyButton(BuildContext context, {required VerifyPageArgument argument}) {
    if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty) {
      return () async {
        bool connection = await System().checkConnections();
        if (connection) {
          // update loading state
          loading = true;

          SignIn? _accountResponse;

          // concatenate code
          String _verifyCode = "";
          _verifyCode += tec1.value.text;
          _verifyCode += tec2.value.text;
          _verifyCode += tec3.value.text;
          _verifyCode += tec4.value.text;

          final notifier = UserBloc();

          if (argument.redirect == VerifyPageRedirection.toHome) {
            await notifier.recoverPasswordOTPBloc(
              context,
              email: email,
              otp: _verifyCode,
            );
            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.RecoverSuccess) {
              _handleVerifyAction(
                context: context,
                verifyPageArgument: argument,
                message: language.yourResetCodeHasBeenVerified!,
              );
            } else {
              _loading = false;
              _inCorrectCode = true;
              notifyListeners();
            }
          } else {
            await notifier.verifyAccountBlocV2(context, email: email, otp: _verifyCode);

            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.verifyAccountSuccess) {
              _accountResponse = SignIn.fromJson(fetch.data);
              SharedPreference().writeStorage(SpKeys.email, _accountResponse.data?.email);
              SharedPreference().writeStorage(SpKeys.userID, _accountResponse.data?.userId);
              SharedPreference().writeStorage(SpKeys.userToken, _accountResponse.data?.token);
              SharedPreference().removeValue(SpKeys.isUserInOTP);

              _handleVerifyAction(
                context: context,
                verifyPageArgument: argument,
                message: language.yourEmailHasBeenVerified!,
              );
            } else {
              _loading = false;
              _inCorrectCode = true;
              notifyListeners();
            }
          }
        } else {
          loading = false;
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
            Routing().moveBack();
            onVerifyButton(context, argument: argument);
          });
        }
      };
    } else {
      return null;
    }
  }

  Future _handleVerifyAction({
    required String message,
    required BuildContext context,
    required VerifyPageArgument verifyPageArgument,
  }) async {
    loading = false;
    await ShowBottomSheet().onShowColouredSheet(context, language.verified!, subCaption: message).whenComplete(() async {
      switch (verifyPageArgument.redirect) {
        case VerifyPageRedirection.toLogin:
          Routing().moveAndRemoveUntil(Routes.login, Routes.root);
          break;
        case VerifyPageRedirection.toHome:
          Routing().moveAndRemoveUntil(
            Routes.signUpVerified,
            Routes.root,
            argument: VerifyPageArgument(redirect: VerifyPageRedirection.toHome),
          );
          break;
        // TODO: Changed sign up rules
        // case VerifyPageRedirection.toSignUpV2:
        //   Routing().moveAndRemoveUntil(userOverview, root);
        //   break;
        case VerifyPageRedirection.toSignUpV2:
          _setUserCompleteData(context);
          Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root, argument: UserInterestScreenArgument(fromSetting: false, userInterested: []));
          break;
        // END TODO
        case VerifyPageRedirection.none:
          Routing().moveAndRemoveUntil(Routes.signUpWelcome, Routes.root);
          break;
      }
    });
    onBackVerifiedEmail(indicateBack: false);
    _username = '';
    _userID = '';
    _userToken = '';
    _email = '';
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
    bool connection = await System().checkConnections();
    if (connection) {
      final notifier = UserBloc();
      await notifier.resendOTPBloc(context, username: username, function: () => resendCode(context));
      final fetch = notifier.userFetch;
      if (fetch.userState == UserState.resendOTPSuccess) {
        print('Resend code success');
        return true;
      } else {
        print('Resend code failed');
        return false;
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        resendCode(context);
      });
    }
  }

  void _setUserCompleteData(BuildContext context) {
    // final notifier = Provider.of<UserCompleteProfileNotifier>(context, listen: false);
    // notifier.email = _email;
    // notifier.fullName = _username.capitalized;
  }
}
