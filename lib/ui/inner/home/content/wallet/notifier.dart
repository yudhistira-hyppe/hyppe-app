// import 'dart:convert';
// import 'package:hyppe/core/bloc/user/bloc.dart';
// import 'package:hyppe/core/bloc/user/state.dart';
// import 'package:hyppe/core/constants/api.dart';
// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/constants/shared_preference_keys.dart';
// import 'package:hyppe/core/models/collection/localization/localization_model.dart';
// import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
// import 'package:hyppe/core/models/collection/user/sign_up/sign_up_complete_profile.dart';
// import 'package:hyppe/core/models/collection/wallet/wallet_reponse.dart';
// import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
// import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/services/stomp_service.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
// import 'package:hyppe/ux/path.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
// import 'package:hyppe/core/extension/log_extension.dart';

// class WalletNotifier extends LoadingNotifier with ChangeNotifier {
//   static final _routing = Routing();
//   static final _stomp = StompService();
//   static final _sharedPrefs = SharedPreference();

//   // controller
//   TextEditingController phoneNumberController = TextEditingController();

//   // key
//   final completeProfileKey = 'completeProfileKey';

//   String? sessionID;
//   UserInfoModel? user;
//   LocalizationModelV2? language;

//   String? _userID;
//   String? _authToken;
//   bool _isEditPhoneNumber = false;
//   String _phoneNumber = '';

//   bool get isEditPhoneNumber => _isEditPhoneNumber;
//   String get phoneNumber => _phoneNumber;

//   set isEditPhoneNumber(bool val) {
//     _isEditPhoneNumber = val;
//     notifyListeners();
//   }

//   set phoneNumber(String val) {
//     _phoneNumber = val;
//     notifyListeners();
//   }

//   void syncToDana({required bool fromHome}) {
//     if (!anyObjectsIsLoading) {
//       if (!fromHome) if (!isValidPhoneNumber) return;

//       setLoading(true);

//       _stomp.connectToStomp(
//         (stomFrame) => _handleOnConnect(stomFrame, fromHome: fromHome),
//         host: APIs.baseApi + APIs.eventBus,
//         beforeConnect: () {
//           _userID = _sharedPrefs.readStorage(SpKeys.userID);
//           _authToken = _sharedPrefs.readStorage(SpKeys.userToken);
//         },
//         onStompError: (stompFrame) => setLoading(false),
//       );
//     }
//   }

//   void _handleOnConnect(StompFrame _, {required bool fromHome}) {
//     try {
//       'Stomp is running ${_stomp.isRunning}'.logger();

//       _stomp.eventsSubscribe(StompService.WALLET_RECV + _userID! + "_" + sessionID!, (result) {
//         result.body.logger();
//         _handleOnEvent(result.body, fromHome: fromHome);
//       });

//       _binding();
//     } catch (e) {
//       e.toString().logger();
//       setLoading(false);
//       _stomp.closeStomp();
//     }
//   }

//   void _binding() {
//     _stomp.send(
//       StompService.WALLET_REQ,
//       jsonEncode(
//         {
//           'sessionId': sessionID,
//           'event': StompService.ACQUIRING,
//           'userID': _userID,
//           'authToken': _authToken,
//         },
//       ),
//     );
//   }

//   _handleOnEvent(dynamic data, {required bool fromHome}) {
//     try {
//       WalletResponse _walletResponse = WalletResponse.fromJson(jsonDecode(data));

//       if (_walletResponse.status == StompService.SUCCESS && _walletResponse.data.infos.isNotEmpty) {
//         switch (_walletResponse.data.event) {
//           case WalletEventEnum.miniDana:
//             // Open mini DANA to already Binded before
//             _handleMiniDana(_walletResponse);
//             return;
//           case WalletEventEnum.acquiring:
//             // Binding to a New or Existing DANA Account
//             _handleAcquiring(_walletResponse, fromHome: fromHome);
//             return;
//           default:
//             // no action
//             return;
//         }
//       }
//     } catch (e) {
//       e.logger();
//     } finally {
//       setLoading(false);
//     }
//   }

//   _handleMiniDana(WalletResponse walletResponse) =>
//       _routing.move(walletWebView, argument: walletResponse.data.infos[WalletResourceType.transactionUrl]);

//   _handleAcquiring(WalletResponse walletResponse, {required bool fromHome}) {
//     if (fromHome) {
//       // go to wallet page to confirm phone number
//       _routing.move(wallet);
//     } else {
//       _routing.move(walletWebView, argument: walletResponse.data.infos[WalletResourceType.oauthUrl]);
//     }
//   }

//   backToHome() => _routing.moveBack();

//   onDispose() {
//     if (_stomp.isRunning) _stomp.closeStomp();
//     setLoading(false, setState: false);
//   }

//   void initial() {
//     phoneNumberController.text = user!.profile!.mobileNumber!;
//     phoneNumber = phoneNumberController.text;
//     isEditPhoneNumber = false;
//   }

//   onClickSaveProfile(BuildContext context) async {
//     bool connect = await System().checkConnections();
//     if (connect && isValidPhoneNumber) {
//       SignUpCompleteProfiles _data = SignUpCompleteProfiles(
//         fullName: user!.profile?.fullName,
//         dateOfBirth: user!.profile?.dob,
//         // idProofNumber: myProfile!.userProfile?.userDetail?.data?.idProofNumber,
//         // idProofName: myProfile!.userProfile?.userDetail?.data?.idProofName,
//         gender: user!.profile?.gender,
//         phoneNumber: phoneNumberController.text,
//         email: user!.profile?.email,
//         // eulaID: myProfile!.userProfile?.userDetail?.data?.eulaID,
//         country: user!.profile?.country,
//         // province: myProfile!.userProfile?.userDetail?.data?.stateName,
//         // city: myProfile!.userProfile?.profileOverviewData?.userOverviewData.city,
//         language: user!.profile?.langIso,
//         // userID: myProfile!.userProfile?.userDetail?.data?.userID,
//       );

//       final notifier = Provider.of<UserBloc>(context, listen: false);
//       setLoading(true, loadingObject: completeProfileKey);
//       await notifier.completeProfileBloc(context, data: _data);
//       setLoading(false, loadingObject: completeProfileKey);
//       final fetch = notifier.userFetch;
//       if (fetch.userState == UserState.completeProfileSuccess) {}
//       isEditPhoneNumber = false;
//     } else {
//       ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
//         Routing().moveBack();
//         onClickSaveProfile(context);
//       });
//     }
//   }

//   bool get isValidPhoneNumber => phoneNumber.length >= 5 && phoneNumber.length <= 20;

//   Future<bool> onWillPop() async {
//     if (anyObjectsIsLoading) {
//       return Future.value(false);
//     } else {
//       Routing().moveBack();
//       return Future.value(true);
//     }
//   }

//   @override
//   void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
//     super.setLoading(val);
//     if (setState) notifyListeners();
//   }
// }
