import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
import 'package:hyppe/core/models/collection/user_v2/facebook_sign_in/facebook_sign_in.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/api_action.dart';
import 'package:hyppe/core/services/check_version.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';
import 'package:hyppe/core/services/google_sign_in_service.dart';
import 'package:hyppe/core/services/locations.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class WelcomeLoginNotifier extends LoadingNotifier with ChangeNotifier {
  final _routing = Routing();
  final _googleSignInService = GoogleSignInService();
  final signOutGoogle = GoogleSignInService();
  LocalizationModelV2 language = LocalizationModelV2();
  late PermissionStatus _permissionGranted;
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  double? latitude; // Latitude, in degrees
  double? longitude; // Longitude, in degrees
  String _version = "";

  String _email = "";
  String _password = "";
  String? _emailValidation;
  String? _passwordValidation;
  bool _hide = true;
  bool _incorrect = false;
  GoogleSignInAccount? _userGoogleSignIn;
  String? googleSignInError;
  // AccessToken? _accessToken;
  FacebookSignIn? _currentUser;

  String get version => _version;
  String get email => _email;
  String get password => _password;
  String? get emailValidation => _emailValidation;
  String? get passwordValidation => _passwordValidation;
  bool get hide => _hide;
  bool get incorrect => _incorrect;
  GoogleSignInAccount? get userGoogleSignIn => _userGoogleSignIn;

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

  static const loadingForgotPasswordKey = 'loadingForgotPasswordKey';
  static const loadingLoginGoogleKey = 'loadingLoginGoogleKey';

  String? emailValidator(String v) => System().validateEmail(v) ? null : "Not a valid email address";
  String? passwordValidator(String v) => v.length > 4 ? null : "Incorrect Password";
  bool buttonDisable() => email.isNotEmpty && password.isNotEmpty ? true : false;

  Future<bool> getLocation(BuildContext context) async {
    await Locations().permissionLocation();
    final check = await Locations().getLocation().then((value) async {
      if (value['latitude'] == 0.0) {
        return false;
      } else {
        latitude = value['latitude'];
        longitude = value['longitude'];
        return true;
      }
    });
    if (check) {
      return true;
    } else {
      await ShowBottomSheet().onShowColouredSheet(
        context,
        'Please Allow Permission for Location',
        maxLines: 2,
        enableDrag: false,
        dismissible: false,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );
      openAppSettings();

      return false;
    }
  }

  Future onClickForgotPassword(BuildContext context) async {
    _routing.move(Routes.forgotPassword);
  }

  Future onClickLogin(BuildContext context) async {
    bool connection = await System().checkConnections();
    setLoading(true);
    await getLocation(context).then((value) async {
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
            _validateUserData(context, _result, false, onlineVersion: fetch.version);
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
      }
    });

    setLoading(false);
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

  _validateUserData(BuildContext context, UserProfileModel signData, bool isSociaMediaLogin, {String? onlineVersion}) async {
    await CheckVersion().check(context, onlineVersion);
    if (isSociaMediaLogin) {
      clearTextController();
      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      DeviceBloc().activityAwake(context);
      if (signData.interest!.isEmpty) {
        Routing().moveAndRemoveUntil(Routes.userInterest, Routes.root, argument: UserInterestScreenArgument());
      } else {
        Routing().moveReplacement(Routes.lobby);
      }
    } else if (signData.userType == null) {
      print('apa0 ${signData.userType?.index}');
      clearTextController();
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    } else if (signData.userType == UserType.verified) {
      print('apa1 ${signData.userType?.index}');
      clearTextController();
      SharedPreference().writeStorage(SpKeys.userToken, signData.token);
      SharedPreference().writeStorage(SpKeys.email, signData.email);
      // SharedPreference().writeStorage(SpKeys.onlineVersion, onlineVersion);
      DeviceBloc().activityAwake(context);
      Routing().moveReplacement(Routes.lobby);
    } else if (signData.userType == UserType.notVerified) {
      print('apa2 ${signData.userType?.index}');
      final signUpPinNotifier = Provider.of<SignUpPinNotifier>(context, listen: false);

      await ShowBottomSheet().onShowColouredSheet(
        context,
        'Your email has not been verified, click Ok to verify your email.',
        maxLines: 2,
        enableDrag: false,
        dismissible: false,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );

      _googleSignInService.handleSignOut();

      signUpPinNotifier.username = signData.username ?? '';
      signUpPinNotifier.email = signData.email ?? '';
      signUpPinNotifier.resend(context);
      signUpPinNotifier.resendPilih = true;
      // signUpPinNotifier.timer = '00:00';

      signUpPinNotifier.userToken = signData.token!;
      // signUpPinNotifier.userID = signData.profileID!;
      Routing().move(Routes.signUpPin, argument: VerifyPageArgument(redirect: VerifyPageRedirection.toLogin)).whenComplete(() {
        clearTextController();
      });
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
    await getLocation(context).then((value) async {
      if (value) {
        if (connection) {
          UserCredential? userCredential;
          _userGoogleSignIn = await GoogleSignIn().signIn();
          final GoogleSignInAuthentication? googleAuth = await _userGoogleSignIn?.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
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
              email: userCredential.user!.email!,
              latitude: latitude,
              longtitude: longitude,
              function: () => loginGoogleSign(context),
            );
            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.LoginSuccess) {
              hide = true;
              final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
              _validateUserData(context, _result, true, onlineVersion: fetch.version);
            }
            if (fetch.userState == UserState.LoginError) {
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
        setLoading(false);
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
    await getLocation(context).then((value) async {
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
              email: userCredential.user!.email!,
              latitude: latitude,
              longtitude: longitude,
              function: () => loginAppleSign(context),
            );
            final fetch = notifier.userFetch;
            if (fetch.userState == UserState.LoginSuccess) {
              hide = true;
              final UserProfileModel _result = UserProfileModel.fromJson(fetch.data);
              _validateUserData(context, _result, true, onlineVersion: fetch.version);
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
          //     if (credentialApple.givenName != null) 'firstName': credentialApple.givenName!,
          //     if (credentialApple.familyName != null) 'lastName': credentialApple.familyName!,
          //     'useBundleId': !kIsWeb && (Platform.isIOS || Platform.isMacOS) ? 'true' : 'false',
          //     if (credentialApple.state != null) 'state': credentialApple.state!,
          //   },
          // );

          // final session = await http.Client().post(
          //   signInWithAppleEndpoint,
          // );

        } else {
          ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
        }
        setLoading(false);
      }
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
  //         accessToken: value.authToken!, secret: value.authTokenSecret!);

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
}
