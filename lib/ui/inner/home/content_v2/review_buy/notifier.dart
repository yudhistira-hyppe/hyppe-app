import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

enum IntialBankSelect { vaBca, hyppeWallet }

class ReviewBuyNotifier extends ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  IntialBankSelect? _bankSelected = IntialBankSelect.vaBca;

  IntialBankSelect? get bankSelected => _bankSelected;

  set bankSelected(IntialBankSelect? val) {
    _bankSelected = val;
    notifyListeners();
  }
}
