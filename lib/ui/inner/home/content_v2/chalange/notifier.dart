import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/chalange/achievement_model.dart';
import 'package:hyppe/core/models/collection/chalange/badge_collection_model.dart';
import 'package:hyppe/core/models/collection/chalange/banner_chalange_model.dart';
import 'package:hyppe/core/models/collection/chalange/challange_model.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

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
  bool isLoadingAchivement = false;

  int pageGetChallange = 0;
  int pageAchievement = 0;
  int pageCollection = 0;

  List<BannerChalangeModel> bannerData = [];
  List<BannerChalangeModel> bannerSearchData = [];
  List<ChallangeModel> listChallangeData = [];
  List<LeaderboardChallangeModel>? leaderBoardDataArray = [];
  LeaderboardChallangeModel? leaderBoardData;
  LeaderboardChallangeModel? leaderBoardDetailData;
  List<AcievementModel>? achievementData = [];
  List<BadgeCollectionModel>? collectionBadgeData = [];

  String berlangsung = "BERLANGSUNG";
  String berakhir = "BERAKHIR";
  String akanDatang = "AKAN DATANG";

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

  Future getBannerLanding(BuildContext context, {bool ispopUp = false, bool isLeaderBoard = false}) async {
    checkInet(context);
    isLoading = true;
    notifyListeners();

    Map data = {"page": 0};
    if (ispopUp) {
      data['target'] = "popup";
    } else {
      data['target'] = "search";
      if (isLeaderBoard) {
        data['jenischallenge'] = "647055de0435000059003462";
      }
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
    await getBannerLanding(context, isLeaderBoard: true);
    await getLeaderBoard(context, bannerSearchData[0].sId ?? '');
    await getOtherChallange(context);
    // await getBannerLanding(context, isLeaderBoard: true).then((value) async {
    //   await getLeaderBoard(context, bannerSearchData[0].sId ?? '').then((value) async {
    //     print(value);
    //     await getOtherChallange(context);
    //   });
    // });
    print("selesai");

    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future initLeaderboardDetail(BuildContext context, String id) async {
    print("=========asdasdasd");
    isLoadingLeaderboard = true;
    notifyListeners();
    checkInet(context);
    await getLeaderBoard(context, id, isDetail: true);
    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future getLeaderBoard(BuildContext context, String idchallenge, {bool isDetail = false}) async {
    Map param = {
      "idchallenge": idchallenge,
      // "idchallenge": "6486f6d4b8ab34f61602f85a",
      "iduser": SharedPreference().readStorage(SpKeys.userID),
      // "status":"BERLANGSUNG",
      // "session":1
    };
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.getLeaderBoard);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      if (bannerFatch.data.isNotEmpty) {
        LeaderboardChallangeModel? getdata;
        leaderBoardDataArray = [];
        bannerFatch.data.forEach((v) => leaderBoardDataArray?.add(LeaderboardChallangeModel.fromJson(v)));
        getdata = leaderBoardDataArray?.firstWhereOrNull((element) => element.status == berlangsung);
        getdata ??= leaderBoardDataArray?.firstWhereOrNull((element) => element.status == akanDatang);

        if (getdata?.startDatetime != '' || getdata?.startDatetime != null) {
          var dateNote = await System().compareDate(getdata?.startDatetime ?? '', getdata?.endDatetime ?? '');
          getdata?.onGoing = dateNote[0];
          print("===000000");
          if (dateNote[1].inDays == 0) {
            if (dateNote[1].inHours == 0) {
              getdata?.totalDays = dateNote[1].inMinutes;
              getdata?.noteTime = 'inMinutes';
            } else {
              getdata?.totalDays = dateNote[1].inHours;
              getdata?.noteTime = 'inHours';
            }
          } else {
            getdata?.totalDays = dateNote[1].inDays;
            getdata?.noteTime = 'inDays';
          }
          print("===000 ${getdata?.totalDays}");
        }

        if (isDetail) {
          print("===1");
          leaderBoardDetailData = getdata;
          print("leaderBoardDetailData ${leaderBoardDetailData?.onGoing} - ${leaderBoardDetailData?.totalDays}  - ${leaderBoardDetailData?.noteTime}");
        } else {
          print("===2");
          leaderBoardData = getdata;
        }
      }

      isLoading = false;
      notifyListeners();
      print("selesai");
    }
  }

  Future getOtherChallange(BuildContext context) async {
    Map param = {
      "iduser": SharedPreference().readStorage(SpKeys.userID),
      "page": pageGetChallange,
      "limit": 10,
      "jenischallenge": "64706cbfd3d174ff4989b167",
    };
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.getOtherChallange);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      listChallangeData = [];

      await bannerFatch.data.forEach((v) => listChallangeData.add(ChallangeModel.fromJson(v)));
      if (listChallangeData.isNotEmpty) {
        for (var e in listChallangeData) {
          var dateNote = await System().compareDate("${e.startChallenge} ${e.startTime}", "${e.endChallenge} ${e.endTime}");
          e.onGoing = dateNote[0];
          e.totalDays = dateNote[1].inDays;
        }
      }

      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinChallange(BuildContext context, String idChallenge) async {
    Map param = {
      "idChallenge": idChallenge,
      "idUser": SharedPreference().readStorage(SpKeys.userID),
    };
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: UrlConstants.joinChallange);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      isLoading = false;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future achievementInit(BuildContext context) async {
    isLoadingAchivement = true;
    Map param = {
      "page": pageAchievement,
      "limit": 10,
      "iduser": "62c25b765f458435760af2dd",
      // "iduser": SharedPreference().readStorage(SpKeys.userID),
    };
    final achivementNotifier = ChallangeBloc();
    await achivementNotifier.postChallange(context, data: param, url: UrlConstants.listAchievement);
    final achievementFatch = achivementNotifier.userFetch;

    if (achievementFatch.challengeState == ChallengeState.getPostSuccess) {
      achievementData = [];
      achievementFatch.data.forEach((v) => achievementData?.add(AcievementModel.fromJson(v)));
      isLoadingAchivement = false;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future collectionBadgeInit(BuildContext context) async {
    isLoadingAchivement = true;
    Map param = {
      "page": pageCollection,
      "limit": 10,
      // "iduser": "62c25b765f458435760af2dd",
      "iduser": SharedPreference().readStorage(SpKeys.userID),
    };
    final achivementNotifier = ChallangeBloc();
    await achivementNotifier.postChallange(context, data: param, url: UrlConstants.collectionBadge);
    final achievementFatch = achivementNotifier.userFetch;

    if (achievementFatch.challengeState == ChallengeState.getPostSuccess) {
      collectionBadgeData = [];
      achievementFatch.data.forEach((v) => collectionBadgeData?.add(BadgeCollectionModel.fromJson(v)));
      isLoadingAchivement = false;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void navigateToScreen(BuildContext context, index, email, postType) async {
    Routing().move(Routes.shimmerSlider);
    OtherProfileNotifier on = context.read<OtherProfileNotifier>();
    // await on.initialOtherProfile(context, argument: OtherProfileArgument(senderEmail: email));
    on.user.profile = null;
    on.user = UserInfoModel();
    List<ContentData> data;
    on.manyUser = [];
    on.manyUser.add(UserInfoModel(profile: UserProfileModel(email: email)));

    on.vidContentsQuery.featureType = FeatureType.vid;
    on.diaryContentsQuery.featureType = FeatureType.diary;
    on.picContentsQuery.featureType = FeatureType.pic;

    if (postType == 'pict') {
      on.pageIndex = 0;
    } else if (postType == 'diary') {
      on.pageIndex = 1;
    } else {
      on.pageIndex = 2;
    }

    print(email);

    await on.getDataPerPgage(context, email: email);
    print("====${on.manyUser[0].profile}");
    print("====${on.manyUser[0].diaries}");
    print("====${on.manyUser[0].vids}");
    print("====${on.manyUser[0].pics}");
    if (postType == 'pict') {
      data = on.manyUser.last.pics ?? [];
    } else if (postType == 'diary') {
      data = on.manyUser.last.diaries ?? [];
    } else {
      data = on.manyUser.last.vids ?? [];
    }

    print("=da=da=da=da=d $data");

    on.navigateToSeeAllScreen(context, index - 1, data: data);
  }
}
