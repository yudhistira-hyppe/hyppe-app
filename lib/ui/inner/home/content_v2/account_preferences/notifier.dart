import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/core/arguments/progress_upload_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/constant/widget/show_overlay_loading.dart';
import 'package:hyppe/core/models/collection/user_v2/sign_up/sign_up_complete_profile.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class AccountPreferencesNotifier extends ChangeNotifier {
  final _eventService = EventService();

  CancelToken? _dioCancelToken;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  late AccountPreferenceScreenArgument _argument;

  notifyNotifier() => notifyListeners();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  String _progress = "0%";
  bool _hold = false;
  int _initialIndex = 0;
  OverlayEntry? uploadProgress;

  String get progress => _progress;
  bool get hold => _hold;
  int get initialIndex => _initialIndex;
  List<dynamic>? _optionDelete;
  List<dynamic>? get optionDelete => _optionDelete;
  int _currentOptionDelete = 1;
  int get currentOptionDelete => _currentOptionDelete;
  bool _confirmDeleteAccount = false;
  bool get confirmDeleteAccount => _confirmDeleteAccount;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set initialIndex(int val) {
    _initialIndex = val;
    notifyListeners();
  }

  set hold(bool val) {
    _hold = val;
    notifyListeners();
  }

  set progress(String val) {
    _progress = val;
    notifyListeners();
  }

  set optionDelete(List<dynamic>? val) {
    _optionDelete = val;
    notifyListeners();
  }

  set currentOptionDelete(int val) {
    _currentOptionDelete = val;
    notifyListeners();
  }

  set confirmDeleteAccount(bool val) {
    _confirmDeleteAccount = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  TextStyle label(BuildContext context) => Theme.of(context).textTheme.headline6?.copyWith(color: kHyppePrimary) ?? const TextStyle();
  TextStyle text(BuildContext context) => Theme.of(context).textTheme.bodyText1 ?? const TextStyle();
  TextStyle hint(BuildContext context) => Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).tabBarTheme.unselectedLabelColor) ?? const TextStyle();

  void onInitial(BuildContext context, AccountPreferenceScreenArgument argument) {
    _argument = argument;
    initialIndex = 0;
    _clearTxt();
    final notifierData = Provider.of<SelfProfileNotifier>(context, listen: false);
    userNameController.text = notifierData.user.profile?.username ?? "";
    fullNameController.text = notifierData.user.profile?.fullName ?? "";
    emailController.text = notifierData.user.profile?.email ?? SharedPreference().readStorage(SpKeys.email) ?? "";
    bioController.text = notifierData.user.profile?.bio ?? "";
    countryController.text = notifierData.user.profile?.country ?? "";
    areaController.text = notifierData.user.profile?.area ?? "";
    cityController.text = notifierData.user.profile?.city ?? "";
    genderController.text = (notifierData.user.profile?.gender ?? "").getGenderByLanguage();
    dobController.text = notifierData.user.profile?.dob ?? "";
    mobileController.text = notifierData.user.profile?.mobileNumber ?? "";
  }

  DateTime initialDateTime() {
    if (dobController.text != "") {
      return DateTime(
        int.parse(dobController.text.substring(0, 4)),
        int.parse(dobController.text.substring(5, 7)),
        int.parse(dobController.text.substring(8, 10)),
      );
    } else {
      return DateTime.now();
    }
  }

  Function()? genderOnTap(BuildContext context) => () {
        ShowBottomSheet.onShowOptionGender(
          context,
          onSave: () {
            Routing().moveBack();
            Provider.of<AccountPreferencesNotifier>(context, listen: false).genderController.text = genderController.text;
            notifyListeners();
          },
          onCancel: () {
            Routing().moveBack();
            FocusScope.of(context).unfocus();
          },
          onChange: (value) {
            genderController.text = value;
            notifyListeners();
          },
          value: genderController.text,
          initFuture: UtilsBlocV2().getGenderBloc(context),
        );
      };

  void _clearTxt() {
    userNameController.clear();
    fullNameController.clear();
    emailController.clear();
    bioController.clear();
    countryController.clear();
    areaController.clear();
    cityController.clear();
    genderController.clear();
    dobController.clear();
    mobileController.clear();
  }

  Future<bool> onWillPop() async {
    if (hold) {
      return Future.value(false);
    } else {
      if (_dioCancelToken?.isCancelled ?? true) {
        return Future.value(true);
      } else {
        _resetDioCancelToken();
        return Future.value(false);
      }
    }
  }

  bool somethingChanged(BuildContext context) {
    final notifierData = Provider.of<SelfProfileNotifier>(context, listen: false);
    return (userNameController.text != notifierData.user.profile?.username ||
            fullNameController.text != notifierData.user.profile?.fullName ||
            emailController.text != notifierData.user.profile?.email ||
            bioController.text != notifierData.user.profile?.bio ||
            countryController.text != notifierData.user.profile?.country ||
            areaController.text != notifierData.user.profile?.area ||
            cityController.text != notifierData.user.profile?.city ||
            genderController.text != notifierData.user.profile?.gender ||
            dobController.text != notifierData.user.profile?.dob ||
            mobileController.text != notifierData.user.profile?.mobileNumber) &&
        fullNameController.text.isNotEmpty;
  }

  void cancelRequest({String? reason}) {
    _dioCancelToken?.cancel(reason ?? 'Request Canceled');
    _resetDioCancelToken();
    uploadProgress?.remove();
    try {
      _eventService.notifyUploadCancel(
        DioError(
          error: reason,
          requestOptions: _dioCancelToken?.requestOptions ?? RequestOptions(path: ''),
        ),
      );
    } catch (e) {
      e.logger();
    }
  }

  void _assignDioCancelToken() {
    _dioCancelToken = CancelToken();
  }

  void _resetDioCancelToken() {
    _dioCancelToken = null;
  }

  Future onClickChangeImageProfile(BuildContext context, String imageUrl) async {
    bool connect = await System().checkConnections();
    if (connect) {
      // bool _isPermissionGranted = await System().requestPermission(context, permissions: [
      //   Permission.storage,
      //   Permission.mediaLibrary,
      //   Permission.photos,
      // ]);
      // if (_isPermissionGranted) {
      try {
        final _file = await System().getLocalMedia(context: context);
        uploadProgress = System().createPopupDialog(ShowOverlayLoading());
        _assignDioCancelToken();

        if (_file.values.single != null) {
          progress = "0%";
          print("dari gambar $imageUrl");

          Overlay.of(context).insert(uploadProgress ?? OverlayEntry(builder: (context) => Container()));

          final notifier = UserBloc();

          await notifier.uploadProfilePictureBlocV2(
            context,
            verifyID: false,
            cancelToken: _dioCancelToken,
            file: _file.values.single?.single.path ?? '',
            email: SharedPreference().readStorage(SpKeys.email),
            onSendProgress: (received, total) {
              _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received.toDouble(), total: total.toDouble()));
            },
          );

          final fetch = notifier.userFetch;
          if (fetch.userState == UserState.uploadProfilePictureSuccess) {
            notifyListeners();

            hold = true;
            progress = "${language.finishingUp}...";
            imageCache.clear();
            imageCache.clearLiveImages();
            await context.read<SelfProfileNotifier>().getDataPerPgage(context, isReload: true);
            context.read<SelfProfileNotifier>().onUpdate();

            context.read<MainNotifier>().initMain(context, onUpdateProfile: true, updateProfilePict: true).then((_) {
              hold = false;
              ShowBottomSheet().onShowColouredSheet(context, language.successfullyUpdatedYourProfilePicture ?? '');
              notifyListeners();
            }).whenComplete(() {
              print('data gambar');

              _eventService.notifyUploadSuccess(fetch.data);
            });
          } else {
            ShowBottomSheet().onShowColouredSheet(context, language.failedUpdatedYourProfilePicture ?? '', color: Theme.of(context).colorScheme.error);
            _eventService.notifyUploadFailed(
              DioError(
                requestOptions: RequestOptions(
                  path: UrlConstants.uploadProfilePictureV2,
                ),
                error: language.failedUpdatedYourProfilePicture ?? '',
              ),
            );
          }
        }
      } catch (e) {
        _eventService.notifyUploadFailed(
          DioError(
            requestOptions: RequestOptions(
              path: UrlConstants.uploadProfilePictureV2,
            ),
            error: e,
          ),
        );
        'e'.logger();
      } finally {
        _resetDioCancelToken();

        if (uploadProgress != null) {
          uploadProgress?.remove();
        }
      }
    } else {
      ShowGeneralDialog.permanentlyDeniedPermission(context, permissions: language.permissionStorage ?? '');
    }
    // } else {
    //   ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
    //     Routing().moveBack();
    //     onClickChangeImageProfile(context);
    //   });
    // }
  }

  Future onClickSaveProfile(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (!System().canOnlyContainLettersNumbersDotAndUnderscores(userNameController.text) || !System().atLeastThreeThreetyCharacter(userNameController.text)) {
      await ShowBottomSheet().onShowColouredSheet(
        context,
        "${language.usernameOnlyContainLetters}",
        color: Colors.red,
        iconSvg: "${AssetPath.vectorPath}remove.svg",
        maxLines: 2,
      );
      return false;
    }

    var fullname = fullNameController.text.split(' ');
    print(fullname);
    if (fullname[0] == '') {
      await ShowBottomSheet().onShowColouredSheet(
        context,
        "${language.fullNameCannotContainLeadingSpace}",
        color: Colors.red,
        iconSvg: "${AssetPath.vectorPath}remove.svg",
        maxLines: 2,
      );
      return false;
    }
    if (connect) {
      if (somethingChanged(context)) {
        try {
          progress = "0%";
          FocusScopeNode currentFocus = FocusScope.of(context);
          uploadProgress = System().createPopupDialog(ShowOverlayLoading());
          Overlay.of(context).insert(uploadProgress ?? OverlayEntry(builder: (context) => Container()));

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }

          // FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
          // String bio = bioController.text.contains(RegExp(r'^[a-zA-Z0-9._]+$'));

          String bio = bioController.text.trimNewLines();
          bio = bio.trimNewLines();
          bio = bio.trimLeft();
          bio = bio.trim();

          print("======== bio $bio");

          final trimmed = '\nDart\n\n\n\n\n is fun\n\n'.trimRight();
          print('-');
          print(trimmed);
          print('-');

          SignUpCompleteProfiles _dataBio = SignUpCompleteProfiles(
            email: emailController.text,
            bio: bio,
            fullName: fullNameController.text,
            username: userNameController.text,
          );

          SignUpCompleteProfiles _dataPersonalInfo = SignUpCompleteProfiles(
            email: emailController.text,
            country: countryController.text,
            area: areaController.text,
            city: cityController.text,
            mobileNumber: mobileController.text,
            gender: genderController.text,
            dateOfBirth: dobController.text,
            // username: userNameController.text,
            langIso: SharedPreference().readStorage(SpKeys.isoCode) ?? 'en',
          );

          final notifier = UserBloc();
          final notifier2 = UserBloc();

          await notifier.updateProfileBlocV2(context, data: _dataBio.toUpdateBioJson());
          await notifier2.updateProfileBlocV2(context, data: _dataPersonalInfo.toUpdateProfileJson());

          final fetch = notifier.userFetch;

          if (fetch.userState == UserState.postBioSuccess) {}
          if (fetch.userState == UserState.postBioError) {}

          if (fetch.userState == UserState.completeProfileSuccess) {
            hold = true;
            progress = "${language.finishingUp}...";
            try {
              SelfProfileNotifier userNotifier = context.read<SelfProfileNotifier>();
              userNotifier.isLoadingBio = true;

              // userNotifier.user.profile?.bio = bio;

              userNotifier.onUpdate();
            } catch (e) {
              print("======== bio ${e}}");
            }

            if (_argument.fromSignUpFlow) {
              hold = false;
              ShowBottomSheet().onShowColouredSheet(context, language.successUpdatePersonalInformation ?? '');
              notifyListeners();
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
            } else {
              final _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
              await _mainNotifier.initMain(context, onUpdateProfile: true);
              hold = false;
              ShowBottomSheet().onShowColouredSheet(context, language.successUpdatePersonalInformation ?? '');
              notifyListeners();
            }
          } else {
            if (fetch.data['messages']['info'][0] != '') {
              if (fetch.data['messages']['info'][0] == 'Unabled to proceed, username is already in use') {
                return ShowBottomSheet().onShowColouredSheet(
                  context,
                  language.usernameisAlreadyinUse ?? '',
                  color: Colors.red,
                  iconSvg: "${AssetPath.vectorPath}remove.svg",
                  milisecond: 1000,
                );
              } else {
                return ShowBottomSheet().onShowColouredSheet(
                  context,
                  fetch.data['messages']['info'][0] ?? '',
                  color: Colors.red,
                  iconSvg: "${AssetPath.vectorPath}remove.svg",
                  milisecond: 1000,
                );
              }
            }

            ShowBottomSheet().onShowColouredSheet(context, language.somethingsWrong ?? '', color: Colors.red);
          }
        } catch (e) {
          e.logger();
        } finally {
          if (uploadProgress != null) {
            uploadProgress?.remove();
          }
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onClickSaveProfile(context);
      });
    }
  }

  Future onClickCompletionProfile(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      if (somethingChanged(context)) {
        try {
          progress = "0%";
          FocusScopeNode currentFocus = FocusScope.of(context);

          uploadProgress = System().createPopupDialog(ShowOverlayLoading());

          Overlay.of(context).insert(uploadProgress ?? OverlayEntry(builder: (context) => Container()));

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }

          SignUpCompleteProfiles _dataPersonalInfo = SignUpCompleteProfiles(
            email: emailController.text,
            fullName: fullNameController.text,
            country: countryController.text,
            area: areaController.text,
            city: cityController.text,
            mobileNumber: mobileController.text,
            gender: genderController.text,
            dateOfBirth: dobController.text,
            username: userNameController.text,
            langIso: SharedPreference().readStorage(SpKeys.isoCode) ?? 'en',
          );

          final notifier2 = UserBloc();

          await notifier2.updateProfileBlocV2(context, data: _dataPersonalInfo.toUpdateProfileJson());

          final fetch2 = notifier2.userFetch;

          if (fetch2.userState == UserState.completeProfileSuccess) {
            hold = true;
            progress = "${language.finishingUp}...";

            final _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
            await _mainNotifier.initMain(context, onUpdateProfile: true);
            hold = false;
            ShowBottomSheet().onShowColouredSheet(context, language.successUpdatePersonalInformation ?? '');
            notifyListeners();

            Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
          }
        } catch (e) {
          e.logger();
        } finally {
          if (uploadProgress != null) {
            uploadProgress?.remove();
          }
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onClickSaveProfile(context);
      });
    }
  }

  Future onClickSaveInterests(BuildContext context, List<String> interests) async {
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        progress = "0%";
        FocusScopeNode currentFocus = FocusScope.of(context);
        uploadProgress = System().createPopupDialog(ShowOverlayLoading());
        Overlay.of(context).insert(uploadProgress ?? OverlayEntry(builder: (context) => Container()));
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        SignUpCompleteProfiles _dataPersonalInfo = SignUpCompleteProfiles(
          email: SharedPreference().readStorage(SpKeys.email),
          interests: interests,
        );

        final notifier = UserBloc();
        await notifier.updateInterestBloc(context, data: _dataPersonalInfo.toUpdateProfileJson());
        final fetch = notifier.userFetch;
        if (fetch.userState == UserState.updateInterestSuccess) {
          hold = true;
          progress = "${language.finishingUp}...";
          await Provider.of<MainNotifier>(context, listen: false).initMain(context, onUpdateProfile: true);
          hold = false;
          ShowBottomSheet().onShowColouredSheet(context, language.successUpdatePersonalInformation ?? '').whenComplete(() => Routing().moveBack());
          notifyListeners();
        }
      } catch (e) {
        e.logger();
      } finally {
        if (uploadProgress != null) {
          uploadProgress?.remove();
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onClickSaveProfile(context);
      });
    }
  }

  Future onUploadProofPicture(BuildContext context, String? picture) async {
    try {
      // await System().getLocalMedia(featureType: FeatureType.pic, context: context).then((value) async {
      //   Future.delayed(const Duration(milliseconds: 1000), () async {
      //     try {
      //       if (value.values.single != null) {
      //         uploadProgress = System().createPopupDialog(ShowOverlayLoading());
      //         _assignDioCancelToken();

      //         progress = "0%";
      //         Overlay.of(context)?.insert(uploadProgress);

      //         final notifier = UserBloc();
      //         await notifier.uploadProfilePictureBlocV2(
      //           context,
      //           verifyID: true,
      //           cancelToken: _dioCancelToken,
      //           file: value.values.single.files.single.path,
      //           email: SharedPreference().readStorage(SpKeys.email),
      //           onSendProgress: (received, total) {
      //             _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received, total: total));
      //           },
      //         );

      //         final fetch = notifier.userFetch;
      //         if (fetch.userState == UserState.uploadProfilePictureSuccess) {
      //           hold = true;
      //           progress = "${language.finishingUp}...";
      //           Provider.of<MainNotifier>(context, listen: false).initMain(context, onUpdateProfile: true).then((value) {
      //             hold = false;
      //             ShowBottomSheet().onShowColouredSheet(context, language.successUploadId);
      //             _determineIdProofStatusUser(context);
      //             notifyListeners();
      //           }).whenComplete(() {
      //             _eventService.notifyUploadSuccess(fetch.data);
      //           });
      //         }

      //         if (fetch.userState == UserState.uploadProfilePictureError) {
      //           ShowBottomSheet().onShowColouredSheet(
      //             context,
      //             language.failedUploadId,
      //             color: Theme.of(context).colorScheme.error,
      //             iconSvg: "${AssetPath.vectorPath}remove.svg",
      //           );

      //           _eventService.notifyUploadFailed(
      //             DioError(
      //               requestOptions: RequestOptions(
      //                 path: APIs.uploadProfilePictureV2,
      //               ),
      //               error: language.failedUploadId ?? '',
      //             ),
      //           );
      //         }
      //       } else {
      //         if (value.keys.single.isNotEmpty) {
      //           ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
      //         }
      //       }
      //     } catch (e) {
      //       _eventService.notifyUploadFailed(
      //         DioError(
      //           requestOptions: RequestOptions(
      //             path: APIs.uploadProfilePictureV2,
      //           ),
      //           error: e,
      //         ),
      //       );
      //       'e'.logger();
      //     } finally {
      //       _resetDioCancelToken();

      //       if (uploadProgress != null) {
      //         uploadProgress?.remove();
      //       }
      //     }
      //   });
      // });
      try {
        if (picture != null) {
          uploadProgress = System().createPopupDialog(ShowOverlayLoading());
          _assignDioCancelToken();

          progress = "0%";
          Overlay.of(context).insert(uploadProgress ?? OverlayEntry(builder: (context) => Container()));

          final notifier = UserBloc();
          await notifier.uploadProfilePictureBlocV2(
            context,
            file: picture,
            verifyID: true,
            cancelToken: _dioCancelToken,
            email: SharedPreference().readStorage(SpKeys.email),
            onSendProgress: (received, total) {
              _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received.toDouble(), total: total.toDouble()));
            },
          );

          final fetch = notifier.userFetch;
          if (fetch.userState == UserState.uploadProfilePictureSuccess) {
            hold = true;
            progress = "${language.finishingUp}...";
            Provider.of<MainNotifier>(context, listen: false).initMain(context, onUpdateProfile: true).then((value) async {
              hold = false;
              await ShowBottomSheet().onShowColouredSheet(context, language.successUploadId ?? '');
              _determineIdProofStatusUser(context);

              final userNotifier = Provider.of<SelfProfileNotifier>(context, listen: false);

              // force complete id proof status (KTP terverifikasi)
              userNotifier.setIdProofStatusUser(IdProofStatus.complete);

              debugPrint("PROFILE STATE => ${userNotifier.user.profile?.isComplete}");
              if (userNotifier.user.profile != null) {
                if (!(userNotifier.user.profile?.isComplete ?? true)) {
                  Routing().moveAndPop(Routes.completeProfile);
                } else {
                  Routing().moveAndPop(Routes.lobby);
                }
              }

              notifyListeners();
            }).whenComplete(() {
              _eventService.notifyUploadSuccess(fetch.data);
            });
          }

          if (fetch.userState == UserState.uploadProfilePictureError) {
            ShowBottomSheet().onShowColouredSheet(
              context,
              language.failedUploadId ?? '',
              color: Theme.of(context).colorScheme.error,
              iconSvg: "${AssetPath.vectorPath}remove.svg",
            );

            _eventService.notifyUploadFailed(
              DioError(
                requestOptions: RequestOptions(
                  path: UrlConstants.uploadProfilePictureV2,
                ),
                error: language.failedUploadId ?? '',
              ),
            );
          }
        } else {
          ShowGeneralDialog.pickFileErrorAlert(context, language.somethingWentWrong ?? "");
        }
      } catch (e) {
        _eventService.notifyUploadFailed(
          DioError(
            requestOptions: RequestOptions(
              path: UrlConstants.uploadProfilePictureV2,
            ),
            error: e,
          ),
        );
        'e'.logger();
      } finally {
        _resetDioCancelToken();

        if (uploadProgress != null) {
          uploadProgress?.remove();
        }
      }
    } catch (e) {
      ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred ?? '');
    }
  }

  dateOfBirthSelected(String date) {
    dobController.text = date;
    notifyListeners();
  }

  locationCountryListSelected(String data) {
    if (countryController.text != data) {
      areaController.clear();
      cityController.clear();
    }
    countryController.text = data;
    notifyListeners();
    Routing().moveBack();
  }

  locationProvinceListSelected(String data) {
    if (areaController.text != data) {
      cityController.clear();
    }
    areaController.text = data;
    notifyListeners();
    Routing().moveBack();
  }

  locationCityListSelected(String data) {
    cityController.text = data;
    notifyListeners();
    Routing().moveBack();
  }

  void _determineIdProofStatusUser(BuildContext context) {
    final _selfNotifier = Provider.of<SelfProfileNotifier>(context, listen: false);
    _selfNotifier.setIdProofStatusUser(_selfNotifier.user.profile?.idProofStatus);
  }

  void navigateToDeleteProfile() => Routing().move(Routes.deleteAccount).whenComplete(() => notifyListeners());
  void navigateToConfirmDeleteProfile() => Routing().move(Routes.confirmDeleteAccount).whenComplete(() => notifyListeners());

  getListDeleteOption() {
    _optionDelete = [
      {'code': 1, 'title': language.iHaveAnotherProfileAndIDontNeedThisOne},
      {'code': 2, 'title': language.iDontFindItUseful},
      // {'code': 3, 'title': language.iDontKnowHowToEarnMoneyWithThisApp},
      {'code': 4, 'title': language.iHaveSafetyConcern},
      {'code': 5, 'title': language.iHavePrivacyConcern},
      {'code': 6, 'title': language.iCantFindPeopleToFollow},
      {'code': 7, 'title': language.iveSeenTooManyAds},
      {'code': 8, 'title': language.anotherReason},
    ];
  }

  Future onClickDeleteAccount(BuildContext context) async {
    isLoading = true;
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = UserBloc();
        await notifier.deleteAccountBlocV2(context);
        final fetch = notifier.userFetch;
        if (fetch.userState == UserState.deleteAccountSuccess) {
          context.read<SettingNotifier>().logOut(context);
        }
      } catch (e) {}
    }
    isLoading = false;
    notifyListeners();
  }
}
