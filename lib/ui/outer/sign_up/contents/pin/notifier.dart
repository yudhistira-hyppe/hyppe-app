import 'dart:async';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/sign_in/sign_in.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../constant/entities/loading/notifier.dart';

class SignUpPinNotifier extends ChangeNotifier with WidgetsBindingObserver, LoadingNotifier {
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
  bool _resendPilih = false;

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
  bool get resendPilih => _resendPilih;

  bool _startTimers = true;
  bool get startTimers => _startTimers;

  late VerifyPageArgument argument;

  TextEditingController pinController = TextEditingController();

  final String resendLoadKey = 'resendRegistKey';


  set startTimers(bool val) {
    _startTimers = val;
    notifyListeners();
  }

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

  set resendPilih(bool val) {
    _resendPilih = val;
    notifyListeners();
  }

  void initState(VerifyPageArgument argument) {
    WidgetsBinding.instance.addObserver(this);
    this.argument = argument;
    _inCorrectCode = false;
    pinController = TextEditingController();
    // startTimer();
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
      Routing().moveAndRemoveUntil(Routes.welcomeLogin, Routes.root);
    }
  }

  Color verifyButtonColor(BuildContext context) {
    if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty && !loading) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle verifyTextColor(BuildContext context) {
    if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) ?? const TextStyle();
    } else {
      return Theme.of(context).primaryTextTheme.button ?? const TextStyle();
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
    print('start timer');
  }

  resetTimer() {
    _timer = '';
    _myTimer?.cancel();
  }

  String resendString() => language.resendNewCode ?? '';

  TextStyle? resendStyle(BuildContext context) {
    return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.primary);
  }

  // String resendString() {
  //   if (_timer != "00:00") {
  //     return "${language.pleaseWaitFor}" " $_timer";
  //   } else {
  //     return "${language.resendNewCode}";
  //   }
  // }
  //
  // TextStyle resendStyle(BuildContext context) {
  //   if (_timer != "00:00") {
  //     return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary) ?? const TextStyle();
  //   } else {
  //     return Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.primary) ?? const TextStyle();
  //   }
  // }

  Future resend(BuildContext context, Function afterExecute) async {
    final notifier = UserBloc();
    try {
      setLoading(true, loadingObject: resendLoadKey);

      await notifier.recoverPasswordBloc(
        context,
        email: argument.email,
        event: "RECOVER_PASS",
        status: "INITIAL",
      );
      final fetch = notifier.userFetch;

      if (fetch.userState == UserState.RecoverSuccess) {
        SharedPreference().removeValue(SpKeys.lastTimeStampReachMaxAttempRecoverPassword);
        afterExecute();
        // ShowBottomSheet().onShowColouredSheet(
        //   context,
        //   language.checkYourEmail ?? '',
        //   subCaption: language.weHaveSentAVerificationCodeToYourEmail ?? '',
        // );
      }
    } finally {
      setLoading(false, loadingObject: resendLoadKey);
    }
  }

  Future onVerifyButton(BuildContext context, Function afterSuccess) async{
    try {
      bool connection = await System().checkConnections();
      if(connection){
        final notifier = UserBloc();
        loading = true;
        SignIn? _accountResponse;
        final _verifyCode = pinController.text;
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
              message: language.yourResetCodeHasBeenVerified ?? '',
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
            SharedPreference().writeStorage(SpKeys.lastHitPost, '');
            SharedPreference().removeValue(SpKeys.isUserInOTP);
            SharedPreference().removeValue(SpKeys.referralFrom);

            // DynamicLinkService.hitReferralBackend(context);
            ShowBottomSheet().onShowColouredSheet(
                context,
                language.congrats ?? '',
                subCaption: language.messageSuccessVerification,
                maxLines: 3,
                borderRadius: 8,
                sizeIcon: 20,
                color: kHyppeLightSuccess,
                isArrow: false,
                iconColor: kHyppeBorder,
                padding: EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 25),
                iconSvg: "${AssetPath.vectorPath}ic_success.svg",
                function: (){

                }
            );
            Future.delayed(const Duration(seconds: 2), (){
              _setUserCompleteData(context);
              Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root, argument: UserInterestScreenArgument(fromSetting: false, userInterested: []));
            });

          } else {
            _loading = false;
            _inCorrectCode = true;
            notifyListeners();
          }
        }
      }else{
        throw 'No Internet Connection';
      }

    }catch(e){
      'error pin verification $e'.logger();
      // _loading = false;
    } finally {
      // try {
      //   handleShowCountdown(notifier.userFetch.data.messages.info[0]);
      // } catch (e) {
      //   print(e);
      // }
      loading = false;
    }
  }

  // Function? onVerifyButton(BuildContext context, {required VerifyPageArgument argument}) {
  //   if (tec1.value.text.isNotEmpty && tec2.value.text.isNotEmpty && tec3.value.text.isNotEmpty && tec4.value.text.isNotEmpty) {
  //     return () async {
  //       bool connection = await System().checkConnections();
  //       if (connection) {
  //         // update loading state
  //         loading = true;
  //
  //         SignIn? _accountResponse;
  //
  //         // concatenate code
  //         String _verifyCode = "";
  //         _verifyCode += tec1.value.text;
  //         _verifyCode += tec2.value.text;
  //         _verifyCode += tec3.value.text;
  //         _verifyCode += tec4.value.text;
  //
  //         final notifier = UserBloc();
  //
  //         if (argument.redirect == VerifyPageRedirection.toHome) {
  //           await notifier.recoverPasswordOTPBloc(
  //             context,
  //             email: email,
  //             otp: _verifyCode,
  //           );
  //           final fetch = notifier.userFetch;
  //           if (fetch.userState == UserState.RecoverSuccess) {
  //             _handleVerifyAction(
  //               context: context,
  //               verifyPageArgument: argument,
  //               message: language.yourResetCodeHasBeenVerified ?? '',
  //             );
  //           } else {
  //             _loading = false;
  //             _inCorrectCode = true;
  //             notifyListeners();
  //           }
  //         } else {
  //           await notifier.verifyAccountBlocV2(context, email: email, otp: _verifyCode);
  //
  //           final fetch = notifier.userFetch;
  //           if (fetch.userState == UserState.verifyAccountSuccess) {
  //             _accountResponse = SignIn.fromJson(fetch.data);
  //
  //             SharedPreference().writeStorage(SpKeys.email, _accountResponse.data?.email);
  //             SharedPreference().writeStorage(SpKeys.userID, _accountResponse.data?.userId);
  //             SharedPreference().writeStorage(SpKeys.userToken, _accountResponse.data?.token);
  //             SharedPreference().writeStorage(SpKeys.lastHitPost, '');
  //             SharedPreference().removeValue(SpKeys.isUserInOTP);
  //             SharedPreference().removeValue(SpKeys.referralFrom);
  //
  //             // DynamicLinkService.hitReferralBackend(context);
  //
  //             _handleVerifyAction(
  //               context: context,
  //               verifyPageArgument: argument,
  //               message: language.yourEmailHasBeenVerified ?? '',
  //             );
  //           } else {
  //             _loading = false;
  //             _inCorrectCode = true;
  //             notifyListeners();
  //           }
  //         }
  //       } else {
  //         loading = false;
  //         ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
  //           Routing().moveBack();
  //           onVerifyButton(context, argument: argument);
  //         });
  //       }
  //     };
  //   } else {
  //     return null;
  //   }
  // }

  Future _handleVerifyAction({
    required String message,
    required BuildContext context,
    required VerifyPageArgument verifyPageArgument,
  }) async {
    loading = false;
    await ShowBottomSheet().onShowColouredSheet(context, language.verified ?? 'Verified', subCaption: message).whenComplete(() async {
      switch (verifyPageArgument.redirect) {
        case VerifyPageRedirection.toLogin:
          Routing().moveAndRemoveUntil(Routes.welcomeLogin, Routes.root);
          break;
        case VerifyPageRedirection.toHome:
          Routing().moveAndRemoveUntil(
            Routes.signUpVerified,
            Routes.root,
            argument: VerifyPageArgument(redirect: VerifyPageRedirection.toHome, email: argument.email),
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

  // Function()? resendCode(BuildContext context, {bool withStartTimer = true}) {
  //   print(_timer);
  //   if (_timer != "00:00") {
  //     // ignore: avoid_print
  //     return null;
  //   } else {
  //     print(withStartTimer);
  //     return () async {
  //       if (withStartTimer) {
  //         _timer = '';
  //         startTimer();
  //       }
  //       resend(context);
  //     };
  //   }
  // }

  // Future resend(BuildContext context) async {
  //   bool connection = await System().checkConnections();
  //   if (connection) {
  //     final notifier = UserBloc();
  //     await notifier.resendOTPBloc(context, email: email, function: () => resendCode(context));
  //     final fetch = notifier.userFetch;
  //     if (fetch.userState == UserState.resendOTPSuccess) {
  //       print('Resend code success');
  //       ShowBottomSheet().onShowColouredSheet(
  //         context,
  //         language.checkYourEmail ?? 'Check Your Email',
  //         subCaption: language.weHaveSentAVerificationCodeToYourEmail ?? '',
  //       );
  //       // _timer = '';
  //       // startTimer();
  //       return true;
  //     } else {
  //       print('Resend code failed');
  //       return false;
  //     }
  //   } else {
  //     ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
  //       Routing().moveBack();
  //       resendCode(context);
  //     });
  //   }
  // }

  void _setUserCompleteData(BuildContext context) {
    // final notifier = Provider.of<UserCompleteProfileNotifier>(context, listen: false);
    // notifier.email = _email;
    // notifier.fullName = _username.capitalized;
  }
}
