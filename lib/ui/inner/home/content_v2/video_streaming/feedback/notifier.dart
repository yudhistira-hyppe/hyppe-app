import 'package:flutter/material.dart';

import '../../../../../../core/models/collection/localization_v2/localization_model.dart';

class StreamingFeedbackNotifier with ChangeNotifier{

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

}