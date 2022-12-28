import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/progress_upload_argument.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/verification_id/bloc.dart';
import 'package:hyppe/core/bloc/verification_id/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/camera_interface.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class UploadVerificationIDResult {
  UploadVerificationIDResult({
    required this.idMediaproofpicts,
    required this.valid,
  });

  String idMediaproofpicts;
  bool valid;

  factory UploadVerificationIDResult.fromJson(Map<String, dynamic> json) => UploadVerificationIDResult(
        idMediaproofpicts: json["id_mediaproofpicts"],
        valid: json["valid"],
      );

  Map<String, dynamic> toJson() => {
        "id_mediaproofpicts": idMediaproofpicts,
        "valid": valid,
      };
}

class VerificationIDNotifier with ChangeNotifier implements CameraInterface {
  final _eventService = EventService();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String _realName = "";
  String _imagePath = "";
  String _selfiePath = "";
  String _scannedText = "";
  double _aspectRatio = 1;
  String _idCardNumber = "";
  String _idCardName = "";
  String _idCardDateBirth = "";
  String _idCardPlaceBirth = "";
  String _idVerificationResponse = "";
  String _errorName = "";
  String _errorKtp = "";
  String _errorGender = "";
  String _errorPlaceBirth = "";
  String _errorDateBirth = "";
  bool _acceptTos = false;
  bool _step5CanNext = false;
  bool _selfieOnSupportDocs = false;
  DateTime _selectedBirthDate = DateTime(1990, 1, 1, 0, 0);
  List<File>? _pickedSupportingDocs = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CameraNotifier cameraNotifier = CameraNotifier();
  CameraDevicesNotifier cameraDevicesNotifier = CameraDevicesNotifier();
  TextEditingController _realNameController = TextEditingController();
  TextEditingController _birtDateController = TextEditingController();
  TextEditingController _birtPlaceController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  TextEditingController get realNameController => _realNameController;
  set realNameController(TextEditingController val) {
    _realNameController = val;
    notifyListeners();
  }

  TextEditingController get birtDateController => _birtDateController;
  set birtDateController(TextEditingController val) {
    _birtDateController = val;
    notifyListeners();
  }

  TextEditingController get birtPlaceController => _birtPlaceController;
  set birtPlaceController(TextEditingController val) {
    _birtPlaceController = val;
    notifyListeners();
  }

  TextEditingController get genderController => _genderController;
  set genderController(TextEditingController val) {
    _genderController = val;
    notifyListeners();
  }

  String get realName => _realName;
  set realName(String val) {
    _realName = val;
    notifyListeners();
  }

  String get imagePath => _imagePath;
  set imagePath(String val) {
    _imagePath = val;
    notifyListeners();
  }

  double get aspectRatio => _aspectRatio;
  set aspectRatio(double val) {
    _aspectRatio = val;
    notifyListeners();
  }

  String get scannedText => _scannedText;
  set scannedText(String val) {
    _scannedText = val;
    notifyListeners();
  }

  String get idCardNumber => _idCardNumber;
  set idCardNumber(String val) {
    _idCardNumber = val;
    notifyListeners();
  }

  String get idCardName => _idCardName;
  set idCardName(String val) {
    _idCardName = val;
    notifyListeners();
  }

  String get idCardDateBirth => _idCardDateBirth;
  set idCardDateBirth(String val) {
    _idCardDateBirth = val;
    notifyListeners();
  }

  String get idCardPlaceBirth => _idCardPlaceBirth;
  set idCardPlaceBirth(String val) {
    _idCardPlaceBirth = val;
    notifyListeners();
  }

  String get selfiePath => _selfiePath;
  set selfiePath(String val) {
    _selfiePath = val;
    notifyListeners();
  }

  String get idVerificationResponse => _idVerificationResponse;
  set idVerificationResponse(String val) {
    _idVerificationResponse = val;
    notifyListeners();
  }

  String get errorName => _errorName;
  set errorName(String val) {
    _errorName = val;
    notifyListeners();
  }

  String get errorKtp => _errorKtp;
  set errorKtp(String val) {
    _errorKtp = val;
    notifyListeners();
  }

  String get errorGender => _errorGender;
  set errorGender(String val) {
    _errorGender = val;
    notifyListeners();
  }

  String get errorPlaceBirth => _errorPlaceBirth;
  set errorPlaceBirth(String val) {
    _errorPlaceBirth = val;
    notifyListeners();
  }

  String get errorDateBirth => _errorDateBirth;
  set errorDateBirth(String val) {
    _errorDateBirth = val;
    notifyListeners();
  }

  bool get acceptTos => _acceptTos;
  set acceptTos(bool val) {
    _acceptTos = val;
    step5CanNext = false;
    if (val) {
      step5CanNext = true;
    }
    notifyListeners();
  }

  bool get step5CanNext => _step5CanNext;
  set step5CanNext(bool val) {
    _step5CanNext = val;
    notifyListeners();
  }

  bool get selfieOnSupportDocs => _selfieOnSupportDocs;
  set selfieOnSupportDocs(bool val) {
    _selfieOnSupportDocs = val;
    notifyListeners();
  }

  List<File>? get pickedSupportingDocs => _pickedSupportingDocs;
  set pickedSupportingDocs(List<File>? val) {
    _pickedSupportingDocs = val;
    notifyListeners();
  }

  DateTime get selectedBirthDate => _selectedBirthDate;
  set selectedBirthDate(DateTime val) {
    _selectedBirthDate = val;
    birtDateController.text = DateFormat('dd-MM-yyyy').format(val);
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void initSupportDocs() {
    selfieOnSupportDocs = true;
  }

  void submitStep2(BuildContext context) {
    var nameText = realNameController.text.toString();
    if (nameText == "") {
      ShowBottomSheet().onShowColouredSheet(
        context,
        "Silahkan masukan nama lengkap anda",
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
    } else {
      realName = nameText;
      Routing().moveAndPop(Routes.verificationIDStep3);
    }
  }

  bool isNumeric(String s) {
    if (s == "") {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> validateIDCard(context) async {
    isLoading = true;
    final inputImage = InputImage.fromFilePath(imagePath);
    final textDetector = TextRecognizer(script: TextRecognitionScript.latin);

    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';
    var lines = 0;
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        print("line =>${lines}");
        var cleanText = line.text.replaceAll(":", "");
        var trimText = cleanText.trim();

        if (kDebugMode) {
          print("Line => $trimText\n");
        }

        scannedText += "$trimText\n";

        if (trimText.length == 16) {
          if (isNumeric(trimText)) {
            idCardNumber = trimText;
          }
        }

        if (realName.toLowerCase().trim() == trimText.toLowerCase()) {
          idCardName = trimText.toUpperCase();
        }

        var regex = RegExp('(0[1-9]|[1-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-[0-9]{4}');
        String? match = regex.firstMatch(trimText)?.group(0);
        if (idCardDateBirth == "" && match != null) {
          debugPrint("Birth => " + match);
          debugPrint("On Line => " + lines.toString());
          idCardDateBirth = match;
          birtDateController.text = match;
          birtPlaceController.text = trimText.replaceAll(match, "").replaceAll(",", "").trim();
        }

        if (trimText.toLowerCase().contains("laki")) {
          if (kDebugMode) {
            print("Gender => $trimText\n");
          }
          genderController.text = "Laki-Laki";
        }

        if (trimText.toLowerCase().contains("perempuan")) {
          if (kDebugMode) {
            print("Gender => $trimText\n");
          }
          genderController.text = "Perempuan";
        }

        lines++;
      }
    }
    Routing().moveBack();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> onTakePicture(BuildContext context) async {
    dynamic cameraNotifier;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    ShowGeneralDialog.loadingDialog(context);
    cameraNotifier.takePicture().then((filePath) async {
      if (filePath != null) {
        imagePath = filePath.path;
        aspectRatio = cameraNotifier.cameraAspectRatio;
        await validateIDCard(context);
        Routing().moveAndPop(Routes.verificationIDStep5);
        context.read<CameraNotifier>().flashOff();
      }
    });
  }

  void onTakeSelfie(BuildContext context) {
    dynamic cameraNotifier;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    cameraNotifier.takePicture().then((filePath) async {
      if (filePath != null) {
        selfiePath = filePath.path;
        aspectRatio = cameraNotifier.cameraAspectRatio;

        // To Do : Submit to backend
        if (kDebugMode) {
          print("Selfie Path => " + selfiePath);
          print("Camera Path => " + imagePath);
        }

        if (selfieOnSupportDocs) {
          // onPickSupportedDocument(context, true);
          // pickedSupportingDocs!.add(filePath);
          Routing().moveAndPop(Routes.verificationIDStep7);
        } else {
          await postVerificationData(context);
        }
        // context.read<CameraNotifier>().flashOff();
      }
    });
  }

  Future initStep5(BuildContext context) async {
    print('kesini');
    // isLoading = true;
    Future.delayed(const Duration(seconds: 1), () {
      print("CARDNAME => " + idCardName);
      print("CARDNUM => " + idCardNumber);
      if (idCardName == "" || idCardNumber == "") {
        ShowBottomSheet.onShowIDVerificationFailed(context);
      }
      isLoading = false;
    });
    notifyListeners();
  }

  void checked() {
    acceptTos = !acceptTos;
    print('_acceptTos');
    print(_acceptTos);
    notifyListeners();
  }

  Future<void> postVerificationData(BuildContext context) async {
    isLoading = true;
    try {
      final bloc = VerificationIDBloc();
      await bloc.postVerificationIDBloc(
        context,
        idcardnumber: idCardNumber,
        nama: realName,
        tempatLahir: birtPlaceController.text,
        idCardFile: imagePath,
        selfieFile: selfiePath,
        alamat: '',
        agama: '',
        statusPerkawinan: '',
        pekerjaan: '',
        kewarganegaraan: '',
        jenisKelamin: genderController.text,
        onReceiveProgress: (count, total) async {
          await _eventService.notifyUploadReceiveProgress(ProgressUploadArgument(count: count, total: total));
        },
        onSendProgress: (received, total) async {
          await _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received, total: total));
        },
      );
      final fetch = bloc.postsFetch;
      if (fetch.verificationIDState == VerificationIDState.postVerificationIDSuccess) {
        'verification ID success'.logger();
        isLoading = false;
        _eventService.notifyUploadSuccess(fetch.data);

        SharedPreference().writeStorage(SpKeys.statusVerificationId, VERIFIED);

        Routing().moveAndPop(Routes.verificationIDSuccess);
      } else if (fetch.verificationIDState == VerificationIDState.loading) {
        {
          isLoading = true;
        }
      } else {
        isLoading = false;
        // _eventService.notifyUploadFailed(
        //   DioError(
        //     requestOptions: RequestOptions(
        //       path: UrlConstants.verificationID,
        //     ),
        //     error: fetch.data,
        //   ),
        // );
        'verification ID failed: ${fetch.data}'.logger();
        final UploadVerificationIDResult errorResponseData = UploadVerificationIDResult.fromJson(fetch.data);
        idVerificationResponse = errorResponseData.idMediaproofpicts;
        Routing().moveAndPop(Routes.verificationIDFailed);
      }
    } catch (e) {
      isLoading = false;
      // _eventService.notifyUploadFailed(
      //   DioError(
      //     requestOptions: RequestOptions(
      //       path: UrlConstants.verificationID,
      //     ),
      //     error: e,
      //   ),
      // );
      'verification ID: ERROR: $e'.logger();
      Routing().moveAndPop(Routes.verificationIDFailed);
    }
  }

  void onPickSupportedDocument(BuildContext context, mounted) async {
    isLoading = true;
    print('isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    try {
      await System().getLocalMedia(featureType: FeatureType.other, context: context).then((value) async {
        debugPrint('Pick => ' + value.toString());
        debugPrint('Pick =>  ${value.values.length}');
        if (pickedSupportingDocs != null) {
          if (pickedSupportingDocs!.length < 3) {
            if (value.values.single != null) {
              // pickedSupportingDocs = value.values.single;
              for (var element in value.values.single!) {
                if (pickedSupportingDocs!.length < 3) {
                  pickedSupportingDocs!.add(element);
                } else {
                  ShowGeneralDialog.pickFileErrorAlert(context, 'Max 3 image');
                }
              }

              // fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));

              isLoading = false;
              Routing().moveAndPop(Routes.verificationIDStepSupportingDocsPreview);
            } else {
              isLoading = false;
              if (value.keys.single.isNotEmpty) {
                ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
              }
            }
          } else {
            ShowGeneralDialog.pickFileErrorAlert(context, 'Max 3 image');
            isLoading = false;
          }
        }
      });
    } catch (e) {
      isLoading = false;
      ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred ?? '');
    }
  }

  void onSaveSupportedDocument(BuildContext context) async {
    isLoading = true;
    try {
      debugPrint('idCardFile => ' + imagePath);
      debugPrint('selfieFile => ' + selfiePath);
      final bloc = VerificationIDBloc();
      await bloc
          .postVerificationIDWithSupportDocsBloc(
        context,
        idcardnumber: idCardNumber,
        nama: realName,
        tempatLahir: birtPlaceController.text,
        idCardFile: imagePath,
        selfieFile: selfiePath,
        alamat: '',
        agama: '',
        statusPerkawinan: '',
        pekerjaan: '',
        kewarganegaraan: '',
        jenisKelamin: genderController.text,
        docFiles: pickedSupportingDocs,
        // onReceiveProgress: (count, total) async {
        //   await _eventService.notifyUploadReceiveProgress(ProgressUploadArgument(count: count, total: total));
        // },
        // onSendProgress: (received, total) async {
        //   await _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received, total: total));
        // },
      )
          .then((value) {
        // _eventService.notifyUploadSuccess(value);
      });
      final fetch = bloc.postsFetch;
      if (fetch.verificationIDState == VerificationIDState.postVerificationIDSuccess) {
        'verification ID Docs success'.logger();
        'verification ID Docs success ${fetch.data}'.logger();
        isLoading = false;
        // _eventService.notifyUploadSuccess(fetch.data);

        SharedPreference().writeStorage(SpKeys.statusVerificationId, REVIEW);

        bool? _sheetResponse = await ShowBottomSheet().onShowColouredSheet(
          context,
          "Success Upload",
          maxLines: 2,
        );
        if (_sheetResponse) {
          clearAndMoveToLobby();
        }
      } else if (fetch.verificationIDState == VerificationIDState.loading) {
        {
          isLoading = true;
        }
      } else {
        isLoading = false;
        'verification ID Docs failed: ${fetch.data}'.logger();
        ShowBottomSheet().onShowColouredSheet(
          context,
          "Error Upload",
          color: Theme.of(context).colorScheme.error,
          maxLines: 2,
        );
      }
    } catch (e) {
      isLoading = false;
      'verification ID Docs: ERROR: $e'.logger();
      ShowBottomSheet().onShowColouredSheet(
        context,
        "Error Upload Catch",
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
    }
  }

  void retryTakeIdCard() {
    // imagePath = "";
    selfiePath = "";
    scannedText = "";
    idCardNumber = "";
    idCardName = "";
    idCardDateBirth = "";
    idCardPlaceBirth = "";
    errorGender = "";
    acceptTos = false;
    step5CanNext = false;
    selectedBirthDate = DateTime(1990, 1, 1, 0, 0);
    pickedSupportingDocs = [];
    genderController.clear();

    Routing().moveAndPop(Routes.verificationIDStep2);
  }

  void backFromSelfie(BuildContext context) {
    selfiePath = "";
    pickedSupportingDocs = [];

    if (selfieOnSupportDocs) {
      Routing().moveAndPop(Routes.verificationIDStepSupportingDocs);
    } else {
      Routing().moveAndPop(Routes.verificationIDStep5);
    }
  }

  void backToVerificationID() {
    selfiePath = "";
    pickedSupportingDocs = [];
    selfieOnSupportDocs = false;
    Routing().moveAndPop(Routes.verificationIDStep5);
  }

  void retrySelfie(BuildContext context) {
    selfiePath = "";
    pickedSupportingDocs = [];

    Routing().moveAndPop(Routes.verificationIDStep6);
  }

  void clearAndMoveToLobby() {
    clearAllTempData();

    Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
  }

  void clearAllTempData() {
    _realName = "";
    _imagePath = "";
    _selfiePath = "";
    _scannedText = "";
    _idCardNumber = "";
    _idCardName = "";
    _idCardDateBirth = "";
    _idCardPlaceBirth = "";
    _genderController.clear();
    _realNameController.clear();
    _birtDateController.clear();
    _birtPlaceController.clear();
    _acceptTos = false;
    _step5CanNext = false;
    _selectedBirthDate = DateTime(1990, 1, 1, 0, 0);
    _pickedSupportingDocs = [];

    // clear all error
    _errorName = "";
    _errorKtp = "";
    _errorGender = "";
    _errorPlaceBirth = "";
    _errorDateBirth = "";
    _errorGender = "";
    notifyListeners();
  }

  void continueSelfie(BuildContext context) {
    var error = 0;
    if (idCardName == "") {
      errorName = language.itDoesntMatchIdentity ?? "Nama tidak sesuai KTP";
      error++;
    }

    if (idCardNumber == "") {
      errorKtp = language.noKTPCantBeRead ?? "Nomor KTP tidak terbaca";
      error++;
    }

    if (genderController.text == "") {
      errorGender = language.genderMustBeFilled ?? "Jenis kelamin harus diisi";
      error++;
    }

    if (birtPlaceController.text == "") {
      errorPlaceBirth = language.placeOfBirthMustBeFilled ?? "Tempat lahir harus diisi";
      error++;
    }

    if (birtDateController.text == "") {
      errorDateBirth = language.dateOfBirthMustBeFilled ?? "Tanggal lahir harus diisi";
      error++;
    }

    if (error == 0) {
      print('isOnHomeScreen false');
      SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
      Routing().moveAndPop(Routes.verificationIDStep6);
    }
  }

  void genderOnTap(BuildContext context) {
    ShowBottomSheet.onShowOptionGender(
      context,
      onSave: () {
        Routing().moveBack();
        Provider.of<VerificationIDNotifier>(context, listen: false).genderController.text = genderController.text;
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
  }

  @override
  void onPauseRecordedVideo(BuildContext context) {
    // TODO: implement onPauseRecordedVideo
  }

  @override
  void onRecordedVideo(BuildContext context) {
    // TODO: implement onRecordedVideo
  }

  @override
  void onResumeRecordedVideo(BuildContext context) {
    // TODO: implement onResumeRecordedVideo
  }

  @override
  void onStopRecordedVideo(BuildContext context) {
    // TODO: implement onStopRecordedVideo
  }

  @override
  bool get hasError => cameraNotifier.hasError;

  @override
  bool get isInitialized => cameraNotifier.isInitialized;

  @override
  bool get isRecordingPaused => cameraNotifier.isRecordingPaused;

  @override
  bool get isRecordingVideo => cameraNotifier.isRecordingVideo;

  @override
  bool get isTakingPicture => cameraNotifier.isTakingPicture;
}
