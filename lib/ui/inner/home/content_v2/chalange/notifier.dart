import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/chalange/banner_chalange_model.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
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
  bool isLoadingLeaderboard = false;

  List<BannerChalangeModel> bannerData = [];
  List<BannerChalangeModel> bannerSearchData = [];
  LeaderboardChallangeModel? leaderBoardData;

  ///////

  void checkInet(BuildContext context) async {
    final connect = await _system.checkConnections();
    if (!connect) {
      isConnect = false;

      ShowGeneralDialog.showToastAlert(
        context,
        language.internetConnectionLost ?? ' Error',
        () async {},
      );
      return;
    } else {
      isConnect = true;
    }
  }

  Future getBannerLanding(BuildContext context, {bool ispopUp = false}) async {
    checkInet(context);
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
        bannerData = [];
        bannerFatch.data.forEach((v) => bannerData.add(BannerChalangeModel.fromJson(v)));
      } else {
        bannerSearchData = [];
        bannerFatch.data.forEach((v) => bannerSearchData.add(BannerChalangeModel.fromJson(v)));
      }
      isLoading = false;
      notifyListeners();
    }
  }

  Future initLeaderboard(BuildContext context) async {
    print("=========asdasdasd");
    isLoadingLeaderboard = true;
    notifyListeners();
    checkInet(context);
    await getBannerLanding(context);
    // await getLeaderBoard(context);
    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future getLeaderBoard(BuildContext context) async {
    Map param = {
      "idchallenge": "6486f6d4b8ab34f61602f85a",
      "iduser": SharedPreference().readStorage(SpKeys.userID)
      // "status":"BERLANGSUNG",
      // "session":1
    };
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.getLeaderBoard);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      leaderBoardData = LeaderboardChallangeModel.fromJson(bannerFatch.data);
      isLoading = false;
      notifyListeners();
    }
  }
}
