import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/hyppe_version.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/check_version.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';
import 'package:hyppe/core/services/google_sign_in_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../../app.dart';
import '../../../core/constants/themes/hyppe_colors.dart';

class WelcomeLoginNotifier extends LoadingNotifier with ChangeNotifier {
  final _routing = Routing();
  final _googleSignInService = GoogleSignInService();
  final signOutGoogle = GoogleSignInService();
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  double _latitude = 0.0; // Latitude, in degrees
  double _longitude = 0.0; // Longitude, in degrees
  String _version = "";

  String _email = "";
  String _password = "";
  String? _emailValidation;
  String? _passwordValidation;
  bool _hide = true;
  bool _incorrect = false;
  GoogleSignInAccount? _userGoogleSignIn;
  String? googleSignInError;
  late bool rememberMe;

  double get latitude => _latitude;
  double get longitude => _longitude;

  String get version => _version;
  String get email => _email;
  String get password => _password;
  String? get emailValidation => _emailValidation;
  String? get passwordValidation => _passwordValidation;
  bool get hide => _hide;
  bool get incorrect => _incorrect;
  GoogleSignInAccount? get userGoogleSignIn => _userGoogleSignIn;
  int _currIndex = 0;
  int get currIndex => _currIndex;
  set currIndex(int val) {
    _currIndex = val;
    notifyListeners();
  }

  set latitude(double val) {
    _latitude = val;
    notifyListeners();
  }

  set longitude(double val) {
    _longitude = val;
    notifyListeners();
  }

  set version(String val) {
    _version = val;
    notifyListeners();
  }

  set email(String val) {
    _email = val;
    notifyListeners();
  }

  set password(String val) {
    _password = val;
    notifyListeners();
  }

  set emailValidation(String? val) {
    _emailValidation = val;
    notifyListeners();
  }

  set passwordValidation(String? val) {
    _passwordValidation = val;
    notifyListeners();
  }

  set hide(bool val) {
    _hide = val;
    notifyListeners();
  }

  set incorrect(bool val) {
    _incorrect = val;
    notifyListeners();
  }

  void goToEula() => _routing.move(Routes.userAgreement);

  static const loadingForgotPasswordKey = 'loadingForgotPasswordKey';
  static const loadingLoginGoogleKey = 'loadingLoginGoogleKey';

  String? emailValidator(String v) {
    if (v.isNotEmpty) {
      return System().validateEmail(v) ? '' : language.notAValidEmailAddress;
    } else {
      return '';
    }
  }

  String? passwordValidator(String v) => v.length > 4 ? null : "Incorrect Password";
  bool buttonDisable() => email.isNotEmpty && password.isNotEmpty && emailValidator(emailController.text) == '' ? true : false;

  Future onClickForgotPassword(BuildContext context) async {
    emailController.clear();
    passwordController.clear();
    _routing.move(Routes.forgotPassword);
  }

  Future onClickLogin(BuildContext context) async {
    bool connection = await System().checkConnections();
    print('--> welcome_login/notifier.dart onClickLogin:rememberMe:' + rememberMe.toString());
    print('--> welcome_login/notifier.dart onClickLogin:email:' + emailController.text.toString());
    print('--> welcome_login/notifier.dart onClickLogin:password:' + passwordController.text.toString());
    setLoading(true);
    await System().getLocation(context).then((value) async {
      if (value) {
        if (connection) {
          unFocusController();
          incorrect = false;
          // ignore: avoid_print
          // print(a.latitude);
          await FcmService().initializeFcmIfNot();
          final notifier = UserBloc();
          await notifier.signInBlocV2(
            context,
            email: emailController.text,
            password: passwordController.text,
            latitude: latitude,
            longtitude: longitude,
            function: () => onClickLogin(context),
          );

          final fetch = notifier.userFetch;
          if (fetch.userState == UserState.LoginSuccess) {
            // String realDeviceID = await System().getDeviceIdentifier();
            // print('wee $realDeviceID');
            DynamicLinkService.hitReferralBackend(context);
            hide = true;
            final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
            if (rememberMe)
              SharedPreference().writeStorage(SpKeys.valRememberMe, [emailController.text, passwordController.text]);
            else
              SharedPreference().writeStorage(SpKeys.valRememberMe, ["", ""]);
            _validateUserData(context, _result, false, onlineVersion: fetch.version, onlineIosVersion: fetch.versionIos);
          }
          if (fetch.userState == UserState.LoginError) {
            if (fetch.data != null) {
              clearTextController();
              incorrect = true;
            }
          }
        } else {
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
        }
        setLoading(false);
      }
      setLoading(false);
    });
  }

  bool _goToGuest = false;
  bool get goToGuest => _goToGuest;
  set goToGuest(bool state) {
    _goToGuest = state;
    notifyListeners();
  }

  Future onClickGuest(BuildContext context) async {
    bool connection = await System().checkConnections();
    if (!goToGuest) {
      goToGuest = true;
      await System().getLocation(context).then((value) async {
        if (value) {
          if (connection) {
            unFocusController();
            incorrect = false;
            // ignore: avoid_print
            // print(a.latitude);
            var email = await UniqueIdentifier.serial;
            email = "$email@hyppeguest.com";
            await FcmService().initializeFcmIfNot();
            final notifier = UserBloc();
            await notifier.guestMode(
              context,
              email: email,
              latitude: latitude.toString(),
              longtitude: longitude.toString(),
            );

            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.LoginSuccess) {
              hide = true;
              SharedPreference().removeValue(SpKeys.referralFrom);
              final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
              _validateUserData(context, _result, false, onlineVersion: fetch.version, onlineIosVersion: fetch.versionIos, isGuest: true);
            }
            if (fetch.userState == UserState.LoginError) {
              if (fetch.data != null) {
                clearTextController();
                incorrect = true;
              }
            }
          } else {
            ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
          }
          goToGuest = false;
        }
        goToGuest = false;
      });
    }
  }

  void onClickSignUpHere() {
    incorrect = false;
    _routing.move(Routes.register);
  }

  void onClickLoginEmail() {
    incorrect = false;
    _routing.move(Routes.login);
  }

  // Future onClickGoogle(BuildContext context) async {
  //   bool connection = await System().checkConnections();
  //   if (connection) {
  //     unFocusController();
  //     await FcmService().initializeFcmIfNot();
  //     final _account = await _googleSignInService.handleSignIn(context);

  //     if (_account?.id != null) {
  //       final notifier = UserBloc();
  //       setLoading(true, loadingObject: loadingLoginGoogleKey);
  //       await notifier.signInWithGoogleBloc(context, userAccount: _account);
  //       setLoading(false, loadingObject: loadingLoginGoogleKey);
  //       final fetch = notifier.userFetch;
  //       if (fetch.userState == UserState.LoginGoogleSuccess) {
  //         hide = true;
  //         final UserProfileModel _result =
  //             UserProfileModel.fromJson(fetch.data);
  //         _validateUserData(context, _result,false);

  //         // TODO: handle google auth error
  //         // _googleSignInService.handleSignOut();
  //       }
  //     }
  //   } else {
  //     ShowBottomSheet.onNoInternetConnection(context,
  //         tryAgainButton: () => Routing().moveBack());
  //   }
  // }

  _validateUserData(BuildContext context, UserProfileModel signData, bool isSociaMediaLogin, {String? onlineVersion, String? onlineIosVersion, bool isGuest = false}) async {
    await CheckVersion().check(context, onlineVersion, onlineIosVersion);
    if (System().isGuest()) {
      fromGuest = true;
    }
    if (isGuest) {
      clearTextController();
      SharedPreference().writeStorage(SpKeys.isGuest, isGuest);
      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      SharedPreference().writeStorage(SpKeys.userID, signData.idUser);
      SharedPreference().writeStorage(SpKeys.isoCode, signData.langIso);
      SharedPreference().writeStorage(SpKeys.isLoginSosmed, 'guest');
      await context.read<TranslateNotifierV2>().initTranslate(context);
      DeviceBloc().activityAwake(context);
      Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
    } else if (isSociaMediaLogin) {
      clearTextController();

      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      SharedPreference().writeStorage(SpKeys.isLoginSosmed, 'socmed');
      SharedPreference().writeStorage(SpKeys.userID, signData.idUser);
      print('login bahasa ${signData.langIso}');
      SharedPreference().writeStorage(SpKeys.isoCode, signData.langIso);
      await context.read<TranslateNotifierV2>().initTranslate(context);

      DeviceBloc().activityAwake(context);

      final _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
      await _mainNotifier.initMain(context, onUpdateProfile: true);
      SharedPreference().writeStorage(SpKeys.isGuest, isGuest);

      if (signData.interest?.isEmpty ?? false) {
        //new user
        SharedPreference().writeStorage(SpKeys.newUser, "TRUE");
        Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root, argument: UserInterestScreenArgument());
      } else {
        Routing().moveReplacement(Routes.lobby);
      }
    } else if (signData.userType == null) {
      clearTextController();
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    } else if (signData.userType == UserType.verified) {
      clearTextController();

      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      SharedPreference().writeStorage(SpKeys.isLoginSosmed, 'manual');
      SharedPreference().writeStorage(SpKeys.userID, signData.idUser);
      SharedPreference().writeStorage(SpKeys.isoCode, signData.langIso);
      SharedPreference().writeStorage(SpKeys.rememberMe, rememberMe);
      await context.read<TranslateNotifierV2>().initTranslate(context);
      // SharedPreference().writeStorage(SpKeys.onlineVersion, onlineVersion);

      print('--> welcome_login/notifier.dart _validateUserData:rememberMe:' + SharedPreference().readStorage('rememberMe').toString());
      print('--> welcome_login/notifier.dart _validateUserData:valRememberMe:' + SharedPreference().readStorage('valRememberMe').toString());

      DeviceBloc().activityAwake(context);
      final _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
      await _mainNotifier.initMain(context, onUpdateProfile: true);
      SharedPreference().writeStorage(SpKeys.isGuest, isGuest);
      // if (signData.interest?.isEmpty ?? false) {
      //   //new user
      //   SharedPreference().writeStorage(SpKeys.newUser, "TRUE");
      //   Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root, argument: UserInterestScreenArgument());
      // } else {
      Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
      // }
    } else if (signData.userType == UserType.notVerified) {
      print('apa2 ${signData.userType?.index}');
      final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

      await ShowBottomSheet().onShowColouredSheet(context, language.emailVerification ?? '',
          subCaption: language.emailHasRegistered,
          maxLines: 3,
          borderRadius: 8,
          sizeIcon: 20,
          color: kHyppeTextLightPrimary,
          isArrow: true,
          iconColor: kHyppeBorder,
          padding: EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 25),
          iconSvg: "${AssetPath.vectorPath}info_white.svg", function: () {
        _googleSignInService.handleSignOut();
        passwordController.clear();
        emailController.clear();
        signUpPinNotifier.username = signData.username ?? '';
        signUpPinNotifier.email = signData.email ?? '';
        // signUpPinNotifier.resend(context);
        signUpPinNotifier.resendPilih = true;
        // signUpPinNotifier.timer = '00:00';

        signUpPinNotifier.userToken = signData.token ?? '';
        // signUpPinNotifier.userID = signData.profileID;
        Routing().move(Routes.signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toLogin, email: email)).whenComplete(() {
          clearTextController();
        });
      });

      // await ShowBottomSheet().onShowColouredSheet(
      //   context,
      //   language.pleaseVerifyYourEmailFrst ?? '',
      //   maxLines: 2,
      //   enableDrag: false,
      //   dismissible: false,
      //   color: Theme.of(context).colorScheme.error,
      //   iconSvg: "${AssetPath.vectorPath}close.svg",
      // );
      //
      // _googleSignInService.handleSignOut();
      //
      // signUpPinNotifier.username = signData.username ?? '';
      // signUpPinNotifier.email = signData.email ?? '';
      // // signUpPinNotifier.resend(context);
      // signUpPinNotifier.resendPilih = true;
      // // signUpPinNotifier.timer = '00:00';
      //
      // signUpPinNotifier.userToken = signData.token ?? '';
      // // signUpPinNotifier.userID = signData.profileID;
      // Routing().move(Routes.signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toLogin, email: email)).whenComplete(() {
      //   clearTextController();
      // });
    }
  }

  clearTextController() {
    emailController.clear();
    passwordController.clear();
    _email = "";
    _password = "";
    notifyListeners();
  }

  unFocusController() {
    emailFocus.unfocus();
    passwordFocus.unfocus();
  }

  Future loginGoogleSign(BuildContext context) async {
    bool connection = await System().checkConnections();
    setLoading(true);
    await System().getLocation(context).then((value) async {
      if (value) {
        if (connection) {
          UserCredential? userCredential;
          _userGoogleSignIn = await GoogleSignIn().signIn();
          final GoogleSignInAuthentication? googleAuth = await _userGoogleSignIn?.authentication;
          if (googleAuth == null) {
            setLoading(false);
            return false;
          }
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          unFocusController();
          incorrect = false;
          await FcmService().initializeFcmIfNot();
          final notifier = UserBloc();
          if (userCredential.credential == null) {
            _googleSignInService.handleSignOut();
            ShowBottomSheet.onShowSomethingWhenWrong(context);
          } else {
            await notifier.googleSignInBlocV2(
              context,
              email: userCredential.user?.email ?? '',
              latitude: latitude,
              longtitude: longitude,
              function: () => loginGoogleSign(context),
              uuid: userCredential.user?.uid,
            );
            final fetch = notifier.userFetch;
            print('ini respone google ${fetch.data}');
            if (fetch.userState == UserState.LoginSuccess) {
              globalAliPlayer?.stop();
              globalAliPlayer?.destroy();
              hide = true;
              final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
              print("===== version ${fetch.versionIos}");
              _validateUserData(context, _result, true, onlineVersion: fetch.version, onlineIosVersion: fetch.versionIos);
            }
            if (fetch.userState == UserState.LoginError) {
              _googleSignInService.handleSignOut();
              if (fetch.data != null) {
                clearTextController();
                incorrect = true;
              }
            }
          }

          // if (data != null) {
          //   Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root,
          //       argument: UserInterestScreenArgument());
          //   notifyListeners();
          // }
        } else {
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
        }
      }
      setLoading(false);
    });
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future loginAppleSign(BuildContext context) async {
    bool connection = await System().checkConnections();
    setLoading(true);
    await System().getLocation(context).then((value) async {
      if (value) {
        if (connection) {
          UserCredential? userCredential;
          if (!await SignInWithApple.isAvailable()) {
            print('this devices not eligable for Apple Sign in');
          }
          print('kIsWeb ${kIsWeb}');
          final rawNonce = generateNonce();
          final nonce = sha256ofString(rawNonce);
          final credentialApple = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
              // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
              clientId: 'com.hyppe.hyppeapp',

              redirectUri:
                  // For web your redirect URI needs to be the host of the "current page",
                  // while for Android you will be using the API server that redirects back into your app via a deep link
                  kIsWeb
                      ? Uri.parse('https://${window.location.host}/')
                      : Uri.parse(
                          '',
                        ),
            ),
            // TODO: Remove these if you have no need for them
            // nonce: 'example-nonce',
            // state: 'example-state',
            nonce: nonce,
          );
          print(credentialApple.authorizationCode);
          print(credentialApple.identityToken);
          final oauthCredential = OAuthProvider("apple.com").credential(
            idToken: credentialApple.identityToken,
            rawNonce: rawNonce,
          );

          userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
          unFocusController();

          incorrect = false;
          await FcmService().initializeFcmIfNot();
          final notifier = UserBloc();

          if (userCredential.credential == null) {
            FirebaseAuth.instance.signOut();
            ShowBottomSheet.onShowSomethingWhenWrong(context);
          } else {
            await notifier.appleSignInBlocV2(
              context,
              email: userCredential.user?.email ?? '',
              latitude: latitude,
              longtitude: longitude,
              function: () => loginAppleSign(context),
            );
            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.LoginSuccess) {
              hide = true;
              final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
              _validateUserData(context, _result, true, onlineVersion: fetch.version, onlineIosVersion: fetch.versionIos);
            }
            if (fetch.userState == UserState.LoginError) {
              if (fetch.data != null) {
                clearTextController();
                incorrect = true;
              }
            }
          }

          //FOR ANDROID ONLY & WEB ONLY
          // final signInWithAppleEndpoint = Uri(
          //   scheme: 'https',
          //   host: 'hyppeapp-297310.firebaseapp.com',
          //   path: '/__/auth/handler',
          //   queryParameters: <String, String>{
          //     'code': credentialApple.authorizationCode,
          //     if (credentialApple.givenName != null) 'firstName': credentialApple.givenName,
          //     if (credentialApple.familyName != null) 'lastName': credentialApple.familyName,
          //     'useBundleId': !kIsWeb && (Platform.isIOS || Platform.isMacOS) ? 'true' : 'false',
          //     if (credentialApple.state != null) 'state': credentialApple.state,
          //   },
          // );

          // final session = await http.Client().post(
          //   signInWithAppleEndpoint,
          // );
        } else {
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
        }
      }
      setLoading(false);
    });
  }

  // Future<UserCredential?> loginGoogleSignIn(BuildContext context) async {
  //   UserCredential? userCredential;
  //   // final googleUser = await googleSignIn.signIn();
  //   // if (googleUser == null) return;
  //   // _userGoogleSignIn = googleUser;

  //   // final googleAuth = await googleUser.authentication;

  //   // final credential = GoogleAuthProvider.credential(
  //   //     accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  //   // await FirebaseAuth.instance.signInWithCredential(credential);
  //   //  print('haloo ${googleUser.displayName}');
  //   print('loading');
  //   try {
  //     _userGoogleSignIn = await GoogleSignIn().signIn();

  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication? googleAuth =
  //         await _userGoogleSignIn?.authentication;
  //     print('helo ${_userGoogleSignIn?.id}');

  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );

  //     // Once signed in, return the UserCredential
  //     userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //   } catch (e) {
  //     googleSignInError = e.toString();
  //   }

  //   notifyListeners();
  //   print('helos ${userCredential?.user?.providerData[0].uid}');
  //   return userCredential;
  // }

  // Future loginTwitter() async {
  //   UserCredential? userCredential;
  //   final result = TwitterLogin(
  //       apiKey: '4Ao5xrjpnloquL4iNK4ZEhDlc',
  //       apiSecretKey: 'H4MiLAf2uib1VL12urwCdfrxDdcF2nrKR5du2UNpvIzl9yj50A',
  //       redirectURI: 'flutter-twitter-login://');
  //   print('helo ${result.apiKey}');

  //   await result.login().then((value) async {
  //     print('halo ${value.errorMessage}');
  //     print('halo ${value.status}');
  //     final credential = TwitterAuthProvider.credential(
  //         accessToken: value.authToken, secret: value.authTokenSecret);

  //     userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //     print('wadaw ${userCredential?.user?.displayName}');
  //     notifyListeners();
  //   });
  // }

  // Future loginTwitter() async {
  //   final twitterLogin = TwitterLogin(
  //     /// Consumer API keys
  //     apiKey: SosmedConstants.twitterApiKey,

  //     /// Consumer API Secret keys
  //     apiSecretKey: SosmedConstants.twitterApiSecretKey,

  //     /// Registered Callback URLs in TwitterApp
  //     /// Android is a deeplink
  //     /// iOS is a URLScheme
  //     redirectURI: SosmedConstants.twitterRedirectURI,
  //   );

  //   /// Forces the user to enter their credentials
  //   /// to ensure the correct users account is authorized.
  //   /// If you want to implement Twitter account switching, set [force_login] to true
  //   /// login(forceLogin: true);
  //   final authResult = await twitterLogin.loginV2();
  //   switch (authResult.status) {
  //     case TwitterLoginStatus.loggedIn:
  //       // success
  //       print('====== Login success ======');
  //       print("TWITTER_TOKEN => ${authResult.authToken}");
  //       print("TWITTER_USER_ID => ${authResult.user?.id}");
  //       print("TWITTER_USER_NAME => ${authResult.user?.name}");
  //       print("TWITTER_USER_SCREEN_NAME => ${authResult.user?.screenName}");
  //       print("TWITTER_USER_THUMB => ${authResult.user?.thumbnailImage}");

  //       break;
  //     case TwitterLoginStatus.cancelledByUser:
  //       // cancel
  //       print('====== Login cancel ======');
  //       break;
  //     case TwitterLoginStatus.error:
  //     case null:
  //       // error
  //       print('====== Login error ======');
  //       break;
  //   }
  // }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  // Future<void> FacebookSignin() async {
  //   final LoginResult loginResult = await FacebookAuth.i.login();
  //   print('halo ${loginResult.accessToken}');
  //   if (loginResult.status == LoginStatus.success) {
  //     _accessToken = loginResult.accessToken;

  //     final data = await FacebookAuth.i.getUserData();
  //     print('datanya $data');

  //     // FacebookSignIn fbUser = FacebookSignIn.fromJson(data);
  //     // debugPrint("FB_USER_ID => ${_accessToken?.userId}");
  //     // debugPrint("FB_TOKEN => ${_accessToken?.token}");
  //     // debugPrint("FB_TOKEN_EXPIRES => ${_accessToken?.expires}");
  //     // debugPrint("FB_APPID => ${_accessToken?.applicationId}");
  //     // debugPrint("FB_ID => ${fbUser.id}");
  //     // debugPrint("FB_EMAIL => ${fbUser.email}");
  //     // debugPrint("FB_NAME => ${fbUser.name}");
  //     // debugPrint("FB_PIC => ${fbUser.picture?.picture}");

  //     // _currentUser = fbUser;
  //   }
  // }

  List<WelcomeData> get welcomeList => [
        WelcomeData(image: 'welcome_image_1.svg', title: 'Welcome Hyppers', desc: (language.welcomeDescOne ?? '')),
        WelcomeData(image: 'welcome_image_2.svg', title: (language.welcomeTitleTwo ?? ''), desc: (language.welcomeDescTwo ?? '')),
        WelcomeData(image: 'welcome_image_3.svg', title: (language.welcomeTitleThree ?? ''), desc: (language.welcomeDescThree ?? '')),
        WelcomeData(image: 'welcome_image_4.svg', title: (language.welcomeTitleFour ?? ''), desc: (language.welcomeDescFour ?? '')),
      ];

  Future testLogin(BuildContext context) async {
    bool connection = await System().checkConnections();
    setLoading(true);
    await System().getLocation(context).then((value) async {
      print(value);
      if (value) {
        if (connection) {
          await FcmService().initializeFcmIfNot();
          final notifier = UserBloc();

          await notifier.googleSignInBlocV2(
            context,
            email: emailController.text,
            latitude: latitude,
            longtitude: longitude,
            function: () => loginGoogleSign(context),
            uuid: 'asddddfsd',
          );
          final fetch = notifier.userFetch;
          print('ini respone google ${fetch.data}');
          if (fetch.userState == UserState.LoginSuccess) {
            hide = true;
            final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
            _validateUserData(context, _result, true, onlineVersion: fetch.version);
          }
          if (fetch.userState == UserState.LoginError) {
            _googleSignInService.handleSignOut();
            if (fetch.data != null) {
              clearTextController();
              incorrect = true;
            }
          }

          // if (data != null) {
          //   Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root,
          //       argument: UserInterestScreenArgument());
          //   notifyListeners();
          // }
        } else {
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
        }
      }
      setLoading(false);
    });
  }
}

class WelcomeData {
  final String image;
  final String title;
  final String desc;
  WelcomeData({required this.image, required this.title, required this.desc});
}
