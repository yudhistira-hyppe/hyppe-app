import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/models/collection/chalange/banner_chalange_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';

class ChallangeNotifier with ChangeNotifier {
  static final _system = System();
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  ///////
  bool isConnect = false;
  bool isLoading = false;

  List<BannerChalangeModel> bannerData = [];
  List<BannerChalangeModel> bannerSearchData = [];

  ///////

  Future getBannerLanding(BuildContext context, {bool ispopUp = false}) async {
    final connect = await _system.checkConnections();
    if (!connect) {
      isConnect = false;
      notifyListeners();
      ShowGeneralDialog.showToastAlert(
        context,
        language.internetConnectionLost ?? ' Error',
        () async {},
      );
    } else {
      isConnect = true;
      notifyListeners();
    }

    isLoading = true;
    notifyListeners();

    Map data = {"page": 0};
    if (ispopUp) {
      data['target'] = "popup";
    } else {
      data['target'] = "search";
    }

    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: data, url: UrlConstants.getBannerChalange);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      if (ispopUp) {
        bannerFatch.data.forEach((v) => bannerData.add(BannerChalangeModel.fromJson(v)));
      } else {
        bannerFatch.data.forEach((v) => bannerSearchData.add(BannerChalangeModel.fromJson(v)));
      }
      isLoading = false;
      notifyListeners();
    }
  }
}
