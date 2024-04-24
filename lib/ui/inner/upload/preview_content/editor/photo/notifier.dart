import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/filter/layer_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

class EditPhotoNotifier extends ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String? _tempFilePath;
  String? get tempFilePath => _tempFilePath;
  set tempFilePath(String? val) {
    _tempFilePath = val;
    notifyListeners();
  }

  int? _activeFilter;
  int? get activeFilter => _activeFilter;
  set activeFilter(int? val) {
    _activeFilter = val;
    notifyListeners();
  }

  final List<LayerModel> _filters = [];
  List<LayerModel> get filters => _filters;
  void setFilterValue({required int index, required double value}) {
    filters[index].value = value;
    notifyListeners();
  }

  void initFilterCollection() {
    filters.addAll([
      LayerModel(name: '${language.brightness}', icon: 'brightness.svg'),
      LayerModel(name: '${language.contrast}', icon: 'contrast.svg'),
      LayerModel(name: '${language.saturation}', icon: 'warmness.svg'),
      LayerModel(name: '${language.tint}', icon: 'saturation.svg'),
      LayerModel(name: '${language.warmth}', icon: 'airdrop.svg'),
    ]);
  }

  void copyFile(BuildContext context) async {
    final notifier = context.read<PreviewContentNotifier>();
    final imagePath = notifier.fileContent?[0];
    if (imagePath != null) {
      String fileName = imagePath.split(Platform.pathSeparator).last;
      final newImagePath = imagePath.replaceAll(fileName, 'copy-$fileName');
      await File(imagePath).copy(newImagePath);
      tempFilePath = newImagePath;
      notifyListeners();
    } else {
      // do nothing
    }
  }

  Future saveImage(BuildContext context, GlobalKey key) async {
    final notifier = context.read<PreviewContentNotifier>();
    if (tempFilePath != null) {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final File file = File(tempFilePath ?? '');
      await file.writeAsBytes(pngBytes);

      notifyListeners();
      notifier.setFileContent(file.path, 0);
    }
  }

  void cropImage(BuildContext context) async {
    final notifier = context.read<PreviewContentNotifier>();
    try {
      final pathFile = tempFilePath;
      if (pathFile != null) {
        final newFile = await ImageCropper().cropImage(
          sourcePath: pathFile,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            // CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: notifier.language.editImage,
              toolbarColor: kHyppeBackground,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: notifier.language.editImage,
            ),
            WebUiSettings(
              context: context,
              presentStyle: CropperPresentStyle.page,
              enableExif: true,
              enableZoom: true,
              showZoomer: true,
            ),
          ],
        );
        if (newFile != null) {
          await File(pathFile).delete();
          tempFilePath = newFile.path;
        } else {
          throw 'file result is null';
        }
      } else {
        throw 'file is null';
      }
    } catch (e) {
      print('Error ImageCropper: $e');
    }
  }
}
