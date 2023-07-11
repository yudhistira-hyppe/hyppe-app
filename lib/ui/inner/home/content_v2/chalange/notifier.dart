import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/chalange/banner_chalange_model.dart';
import 'package:hyppe/core/models/collection/chalange/challange_model.dart';
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

  int pageGetChallange = 0;

  List<BannerChalangeModel> bannerData = [];
  List<BannerChalangeModel> bannerSearchData = [];
  List<ChallangeModel> listChallangeData = [];
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
    await getLeaderBoard(context, bannerSearchData[0].sId ?? '');
    await getOtherChallange(context);
    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future getLeaderBoard(BuildContext context, String idchallenge) async {
    Map param = {
      "idchallenge": idchallenge,
      "iduser": SharedPreference().readStorage(SpKeys.userID),
      // "status":"BERLANGSUNG",
      // "session":1
    };
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.getLeaderBoard);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      leaderBoardData = LeaderboardChallangeModel.fromJson(bannerFatch.data[0]);
      isLoading = false;
      notifyListeners();
    }
  }

  Future getOtherChallange(BuildContext context) async {
    Map param = {"iduser": SharedPreference().readStorage(SpKeys.userID), "page": pageGetChallange, "limit": 10};
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.getOtherChallange);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      listChallangeData = [];
      bannerFatch.data.forEach((v) => listChallangeData.add(ChallangeModel.fromJson(v)));
      isLoading = false;
      notifyListeners();
    }
  }
}
