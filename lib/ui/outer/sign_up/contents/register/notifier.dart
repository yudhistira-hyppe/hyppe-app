import 'dart:io';

import 'package:hyppe/core/arguments/sign_up_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/google_map_place/model_google_map_place.dart';
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

import '../../../../../core/bloc/google_map_place/bloc.dart';
import '../../../../../core/bloc/google_map_place/state.dart';
import '../../../../../core/services/locations.dart';

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
  String? _invalidEmail = null;
  bool _hidePassword = true;
  bool _loading = false;

  String get password => _password;
  String get email => _email;
  String? get invalidEmail => _invalidEmail;
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

  set invalidEmail(String? val) {
    _invalidEmail = val;
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
    bool state4 = _system.specialCharPass(password);
    return state1 && state2 && state3 && state4;
  }

  Color nextButtonColor(BuildContext context) {
    if (_validationRegister() && !loading) {
      return Theme.of(context).colorScheme.primary;
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
    // getLocationDetails(context);
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
          if (!loading) {
            loading = true;
            bool connection = await System().checkConnections();
            if (connection) {
              email = email.toLowerCase();
              final signUpPinNotifier = Provider.of<SignUpPinNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);

              // initialize Fcm service if not
              await FcmService().initializeFcmIfNot();

              // update loading state

              String realDeviceId = await System().getDeviceIdentifier();
              String platForm = Platform.isAndroid ? "android" : "ios";
              String deviceId = SharedPreference().readStorage(SpKeys.fcmToken);
              String lang = SharedPreference().readStorage(SpKeys.isoCode);

              final notifier = UserBloc();
              await notifier.signUpBlocV2(
                Routing.navigatorKey.currentContext ?? context,
                data: SignUpDataArgument(email: email, password: password, deviceId: deviceId, imei: realDeviceId != "" ? realDeviceId : deviceId, platForm: platForm, lang: lang),
              );

              final fetch = notifier.userFetch;
              if (fetch.userState == UserState.signUpSuccess) {
                final SignUpResponse _result = SignUpResponse.fromJson(fetch.data);
                if (_result.insight == null && _result.isEmailVerified == "false") {
                  await ShowBottomSheet().onShowColouredSheet(Routing.navigatorKey.currentContext ?? context, language.emailVerification ?? '',
                      subCaption: language.emailHasRegistered,
                      maxLines: 3,
                      borderRadius: 8,
                      sizeIcon: 20,
                      color: kHyppeTextLightPrimary,
                      isArrow: true,
                      iconColor: kHyppeBorder,
                      padding: const EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 25),
                      iconSvg: "${AssetPath.vectorPath}info_white.svg", function: () {
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
                    final tempEmail = email;
                    onReset();
                    notifyListeners();
                    Routing().move(
                      Routes.signUpPin,
                      argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2, email: tempEmail),
                    );
                  });
                } else if (_result.insight != null && _result.isEmailVerified == "false") {
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
                  final tempEmail = email;
                  onReset();
                  notifyListeners();
                  loading = false;
                  Routing().move(
                    Routes.signUpPin,
                    argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2, email: tempEmail),
                  );
                } else {
                  await ShowBottomSheet().onShowColouredSheet(
                    Routing.navigatorKey.currentContext ?? context,
                    fetch.message?.info[0] ?? '',
                    maxLines: 3,
                    borderRadius: 8,
                    sizeIcon: 20,
                    color: kHyppeTextLightPrimary,
                    iconColor: kHyppeBorder,
                    padding: EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 25),
                  );
                }

                loading = false;
              } else {
                loading = false;
                // // >>>>> Agar failed tetap ke signUpPin page
                // signUpPinNotifier.email = emailController.text;
                // Routing().moveAndRemoveUntil(
                //   Routes.signUpPin,
                //   Routes.root,
                //   argument: VerifyPageArgument(redirect: VerifyPageRedirection.toSignUpV2),
                // );
              }
            } else {
              ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
                Routing().moveBack();
                nextButton(context);
              });
            }
          }
        }
      };
    } else {
      return null;
    }
  }
  
  LocationResponse? _location;
  LocationResponse? get location => _location;
  set location(LocationResponse? val){
    _location = val;
    notifyListeners();
  }

  getLocationDetails(BuildContext context) async{
    await Locations().getLocation().then((value) async {
      final double? latitude = value['latitude'];
      final double? longitude = value['longitude'];
      if (latitude != null && longitude != null) {
        getLocation(context, '$latitude,%20$longitude');
      }
    });
  }

  Future getLocation(BuildContext context, String coordinate) async {

    final notifier = GoogleMapPlaceBloc();
    await notifier.getResults(
      context,
      latlng: coordinate,
    );
    final fetch = notifier.googleMapPlaceFetch;
    if (fetch.googleMapPlaceState == GoogleMapPlaceState.getGoogleMapPlaceBlocSuccess) {
      if(fetch.data is LocationResponse){
        location = location;
        print('Location response: ${location?.toJson()}');
      }
    }
  }
}
