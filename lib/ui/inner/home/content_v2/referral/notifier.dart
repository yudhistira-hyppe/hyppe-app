import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';

class ReferralNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String _referralLink = "";

  String get referralLink => _referralLink;

  set referralLink(val) {
    _referralLink = val;
    notifyListeners();
  }

  void onInitial(BuildContext context) async {
    var _result = await System().createdReferralLink(context);
    debugPrint("REFERRAL => " + _result.toString());
    referralLink = _result.toString();
  }
}
