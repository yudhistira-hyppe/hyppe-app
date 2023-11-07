import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/filter/layer_model.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:image/image.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class EditPhotoNotifier extends ChangeNotifier {
  // LayerModel _hue = LayerModel(name: 'Hue', value: 0, min: -100, max: 100);
  // LayerModel get hue => _hue;
  // set hue(LayerModel val) {
  //   _hue = val;
  //   notifyListeners();
  // }

  int? _activeFilter;
  int? get activeFilter => _activeFilter;
  set activeFilter(int? val) {
    _activeFilter = val;
    notifyListeners();
  }

  final List<LayerModel> _filters = [
    // airdrop
    // brightness
    // contrast
    // highlight
    // saturation
    // shadow
    // triangle-down
    // triange
    // vynette
    // warmness
    LayerModel(name: 'Color', icon: 'airdrop.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
    LayerModel(name: 'Contrast', icon: 'contrast.svg', value: 0, min: -100, max: 100),
  ];
  List<LayerModel> get filters => _filters;
  void setFilterValue({required int index, required double value}) {
    filters[index].value = value;
    notifyListeners();
  }

  void saveImage(BuildContext context, ui.Image image) async {
    // Create a ByteData buffer to hold the image data.
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Get the device's default directory for storing files.
    // final directory = await getTemporaryDirectory();
    final directory = Directory('/storage/emulated/0/Download');

    // Create a file to write the image data to.
    final File file = File('${directory.path}/filtered_image.png');

    // Write the image data to the file.
    await file.writeAsBytes(pngBytes);

    // context.read<PreviewContentNotifier>().fileContent?[0] = file.path;
    // Routing().moveBack();

    // if (kDebugMode) {
    //   print("File Saved:${file.path}");
    // }
  }
}
