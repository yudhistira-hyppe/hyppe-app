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
  String _referralLinkText = "";
  String get referralLink => _referralLink;
  String get referralLinkText => _referralLinkText;

  set referralLink(val) {
    _referralLink = val;
    _referralLinkText =
        "Hei, Ayo bergabung dan berkreasi di Hyppe!\nJelajahi Dan Tuangkan Ide Kreatifmu Di Mobile Hyppe App Sekarang!\n\n$val";
    notifyListeners();
  }

  void onInitial(BuildContext context) async {
    var _result = await System().createdReferralLink(context);
    debugPrint("REFERRAL => " + _result.toString());
    referralLink = _result.toString();
  }
}
