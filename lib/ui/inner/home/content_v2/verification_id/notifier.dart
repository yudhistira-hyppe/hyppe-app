import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/progress_upload_argument.dart';
import 'package:hyppe/core/bloc/verification_id/bloc.dart';
import 'package:hyppe/core/bloc/verification_id/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/camera_interface.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class UploadVerificationIDResult {
  UploadVerificationIDResult({
    required this.idMediaproofpicts,
    required this.valid,
  });

  String idMediaproofpicts;
  bool valid;

  factory UploadVerificationIDResult.fromJson(Map<String, dynamic> json) =>
      UploadVerificationIDResult(
        idMediaproofpicts: json["id_mediaproofpicts"],
        valid: json["valid"],
      );

  Map<String, dynamic> toJson() => {
        "id_mediaproofpicts": idMediaproofpicts,
        "valid": valid,
      };
}

class VerificationIDNotifier extends LoadingNotifier
    with ChangeNotifier
    implements CameraInterface {
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
  bool _isNameMatch = false;
  String _idCardNumber = "";
  String _idCardName = "";
  String _idCardDateBirth = "";
  String _idCardPlaceBirth = "";
  String _idVerificationResponse = "";
  bool _acceptTos = false;
  bool _step5CanNext = false;
  DateTime _selectedBirthDate = DateTime.now();
  List<File>? _pickedSupportingDocs = [];

  CameraNotifier cameraNotifier = CameraNotifier();
  TextEditingController _realNameController = TextEditingController();
  TextEditingController _birtDateController = TextEditingController();
  TextEditingController _birtPlaceController = TextEditingController();

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

  bool get isNameMatch => _isNameMatch;
  set isNameMatch(bool val) {
    _isNameMatch = val;
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

  Future<bool> validateIDCard() async {
    setLoading(true);
    final inputImage = InputImage.fromFilePath(imagePath);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';
    var lines = 0;
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
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
          isNameMatch = true;
          idCardName = trimText.toUpperCase();
        }

        var regex =
            RegExp('(0[1-9]|[1-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-[0-9]{4}');
        String? match = regex.firstMatch(trimText)?.group(0);
        if (idCardDateBirth == "" && match != null) {
          debugPrint("Birth => " + match);
          debugPrint("On Line => " + lines.toString());
          idCardDateBirth = match;
          birtDateController.text = match;
          birtPlaceController.text =
              trimText.replaceAll(match, "").replaceAll(",", "").trim();
        }

        lines++;
      }
    }

    sleep(const Duration(seconds: 1));
    if (idCardNumber != "" && isNameMatch) {
      setLoading(false);
      return true;
    }

    setLoading(false);
    return false;
  }

  @override
  void onTakePicture(BuildContext context) {
    final cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    cameraNotifier.takePicture().then((filePath) async {
      if (filePath != null) {
        imagePath = filePath.path;
        aspectRatio = cameraNotifier.cameraAspectRatio;
        Routing().moveAndPop(Routes.verificationIDStep5);
      }
    });
  }

  void onTakeSelfie(BuildContext context) {
    final cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    cameraNotifier.takePicture().then((filePath) async {
      if (filePath != null) {
        selfiePath = filePath.path;
        aspectRatio = cameraNotifier.cameraAspectRatio;

        // To Do : Submit to backend
        if (kDebugMode) {
          print("Selfie Path => " + selfiePath);
          print("Camera Path => " + imagePath);
        }

        await postVerificationData(context);
      }
    });
  }

  Future<void> postVerificationData(BuildContext context) async {
    setLoading(true);
    try {
      final bloc = VerificationIDBloc();
      await bloc.postVerificationIDBloc(
        context,
        idCardFile: imagePath,
        selfieFile: selfiePath,
        idcardnumber: idCardNumber,
        nama: realName,
        tempatLahir: birtPlaceController.text,
        onReceiveProgress: (count, total) async {
          await _eventService.notifyUploadReceiveProgress(
              ProgressUploadArgument(count: count, total: total));
        },
        onSendProgress: (received, total) async {
          await _eventService.notifyUploadSendProgress(
              ProgressUploadArgument(count: received, total: total));
        },
      );
      final fetch = bloc.postsFetch;
      if (fetch.verificationIDState ==
          VerificationIDState.postVerificationIDSuccess) {
        'verification ID success'.logger();
        setLoading(false);
        _eventService.notifyUploadSuccess(fetch.data);
        Routing().moveAndPop(Routes.verificationIDSuccess);
      } else if (fetch.verificationIDState == VerificationIDState.loading) {
        {
          setLoading(true);
        }
      } else {
        setLoading(false);
        // _eventService.notifyUploadFailed(
        //   DioError(
        //     requestOptions: RequestOptions(
        //       path: UrlConstants.verificationID,
        //     ),
        //     error: fetch.data,
        //   ),
        // );
        'verification ID failed: ${fetch.data}'.logger();
        final UploadVerificationIDResult errorResponseData =
            UploadVerificationIDResult.fromJson(fetch.data);
        idVerificationResponse = errorResponseData.idMediaproofpicts;
        Routing().moveAndPop(Routes.verificationIDFailed);
      }
    } catch (e) {
      setLoading(false);
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
    setLoading(true);
    try {
      await System()
          .getLocalMedia(featureType: FeatureType.other, context: context)
          .then((value) async {
        debugPrint('Pick => ' + value.toString());
        pickedSupportingDocs = value.values.single;
        setLoading(false);
        Routing().moveAndPop(Routes.verificationIDStepSupportingDocsPreview);
      });
    } catch (e) {
      setLoading(false);
      ShowGeneralDialog.pickFileErrorAlert(
          context, language.sorryUnexpectedErrorHasOccurred!);
    }
  }

  void onSaveSupportedDocument(BuildContext context) async {
    setLoading(true);
    try {
      final bloc = VerificationIDBloc();
      await bloc.postVerificationIDSupportDocsBloc(
        context,
        id: idVerificationResponse,
        docFiles: pickedSupportingDocs,
        onReceiveProgress: (count, total) async {
          await _eventService.notifyUploadReceiveProgress(
              ProgressUploadArgument(count: count, total: total));
        },
        onSendProgress: (received, total) async {
          await _eventService.notifyUploadSendProgress(
              ProgressUploadArgument(count: received, total: total));
        },
      );
      final fetch = bloc.postsFetch;
      if (fetch.verificationIDState ==
          VerificationIDState.postVerificationIDSuccess) {
        'verification ID Docs success'.logger();
        setLoading(false);
        _eventService.notifyUploadSuccess(fetch.data);
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
          setLoading(true);
        }
      } else {
        setLoading(false);
        'verification ID Docs failed: ${fetch.data}'.logger();
        ShowBottomSheet().onShowColouredSheet(
          context,
          "Error Upload",
          color: Theme.of(context).colorScheme.error,
          maxLines: 2,
        );
      }
    } catch (e) {
      setLoading(false);
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
    imagePath = "";
    selfiePath = "";
    scannedText = "";
    isNameMatch = false;
    idCardNumber = "";
    idCardName = "";
    idCardDateBirth = "";
    idCardPlaceBirth = "";
    acceptTos = false;
    step5CanNext = false;
    selectedBirthDate = DateTime.now();
    pickedSupportingDocs = [];

    Routing().moveAndPop(Routes.verificationIDStep4);
  }

  void clearAndMoveToLobby() {
    realName = "";
    imagePath = "";
    selfiePath = "";
    scannedText = "";
    isNameMatch = false;
    idCardNumber = "";
    idCardName = "";
    idCardDateBirth = "";
    idCardPlaceBirth = "";
    acceptTos = false;
    step5CanNext = false;
    selectedBirthDate = DateTime.now();
    pickedSupportingDocs = [];

    Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
  }

  void continueSelfie(BuildContext context) {
    var error = 0;
    if (idCardNumber == "") {
      ShowBottomSheet().onShowColouredSheet(
        context,
        "Silahkan masukan nomor KTP",
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
      error++;
    }

    if (birtPlaceController.text == "") {
      ShowBottomSheet().onShowColouredSheet(
        context,
        "Silahkan masukan tempat lahir",
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
      error++;
    }

    if (birtDateController.text == "") {
      ShowBottomSheet().onShowColouredSheet(
        context,
        "Silahkan masukan tanggal lahir",
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
      error++;
    }

    if (error == 0) {
      Routing().moveAndPop(Routes.verificationIDStep6);
    }
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
