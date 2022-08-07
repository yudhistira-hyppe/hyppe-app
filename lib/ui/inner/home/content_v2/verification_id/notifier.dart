import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/entities/camera/camera_interface.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class VerificationIDNotifier extends ChangeNotifier implements CameraInterface {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String _realName = "";
  bool _isScanning = false;
  String _imagePath = "";
  String _scannedText = "";
  double _aspectRatio = 1;
  bool _isNameMatch = false;
  String _idCardNumber = "";
  String _idCardName = "";
  bool _acceptTos = false;
  bool _step5CanNext = false;
  DateTime _selectedBirthDate = DateTime.now();

  CameraNotifier cameraNotifier = CameraNotifier();
  TextEditingController _realNameController = TextEditingController();
  TextEditingController _birtDateController = TextEditingController();

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

  bool get isScanning => _isScanning;
  set isScanning(bool val) {
    _isScanning = val;
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
      Routing().move(Routes.verificationIDStep3);
    }
  }

  bool isNumeric(String s) {
    if (s == "") {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<bool> validateIDCard() async {
    isScanning = true;
    final inputImage = InputImage.fromFilePath(imagePath);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';
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
      }
    }

    sleep(const Duration(seconds: 1));
    if (idCardNumber != "" && isNameMatch) {
      return true;
    }

    isScanning = false;
    return false;
  }

  @override
  void onTakePicture(BuildContext context) {
    final cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    cameraNotifier.takePicture().then((filePath) async {
      if (filePath != null) {
        imagePath = filePath.path;
        aspectRatio = cameraNotifier.cameraAspectRatio;

        bool isIDCardValid = await validateIDCard();
        // validate ID Card
        if (isIDCardValid) {
          Routing().move(Routes.verificationIDStep5);
        } else {
          if (kDebugMode) {
            print("ID Card is not valid");
            print(scannedText);
          }
          Routing().move(Routes.verificationIDFailed);
        }
      }
    });
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
