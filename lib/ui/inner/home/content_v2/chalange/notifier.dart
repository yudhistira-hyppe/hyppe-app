import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/chalange/achievement_model.dart';
import 'package:hyppe/core/models/collection/chalange/badge_collection_model.dart';
import 'package:hyppe/core/models/collection/chalange/banner_chalange_model.dart';
import 'package:hyppe/core/models/collection/chalange/banner_response.dart';
import 'package:hyppe/core/models/collection/chalange/challange_model.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_slider.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  bool isLoadingBanner = false;
  bool isLoadingLeaderboard = false;
  bool isLoadingAchivement = false;
  bool isLoadingCollection = false;
  bool _newJoinChallenge = false;
  bool get newJoinChallenge => _newJoinChallenge;

  int pageGetChallange = 0;
  int pageAchievement = 0;
  int pageCollection = 0;

  List<BannerChalangeModel> bannerData = [];
  List<BannerChalangeModel> bannerSearchData = [];
  List<BannerChalangeModel> bannerLeaderboardData = [];
  List<ChallangeModel> listChallangeData = [];
  List<LeaderboardChallangeModel>? leaderBoardDataArray = [];
  LeaderboardChallangeModel? leaderBoardData;
  LeaderboardChallangeModel? leaderBoardDetailData;
  LeaderboardChallangeModel? leaderBoardEndData;
  LeaderboardChallangeModel? leaderBoardDetaiEndlData;
  List<AcievementModel>? achievementData = [];
  List<BadgeCollectionModel>? collectionBadgeData = [];
  UserBadgeModel? badgeUser;

  //list untuk option
  DetailSub optionData = DetailSub();
  int _selectOptionSession = 0;
  int get selectOptionSession => _selectOptionSession;

  String berlangsung = "BERLANGSUNG";
  String berakhir = "BERAKHIR";
  String akanDatang = "AKAN DATANG";

  String _referralLink = "";
  String _referralLinkText = "";
  String get referralLink => _referralLink;
  String get referralLinkText => _referralLinkText;

  String _iduserbadge = '';
  String get iduserbadge => _iduserbadge;

  DateTime challangeOption = DateTime.now();

  ///////

  set newJoinChallenge(bool val) {
    _newJoinChallenge = val;
    notifyListeners();
  }

  set iduserbadge(String val) {
    _iduserbadge = val;
    notifyListeners();
  }

  set selectOptionSession(int val) {
    _selectOptionSession = val;
    notifyListeners();
  }

  set referralLink(val) {
    _referralLink = val;
    _referralLinkText = "Hei, Ayo bergabung dan berkreasi di Hyppe!\nJelajahi Dan Tuangkan Ide Kreatifmu Di Mobile Hyppe App Sekarang!\n\n$val";
    notifyListeners();
  }

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

  List<BannerData>? _banners = null;
  List<BannerData>? get banners => _banners;
  set banners(List<BannerData>? values) {
    _banners = values;
    notifyListeners();
  }

  Future getBanners(BuildContext context) async {
    try {
      checkInet(context);
      isLoading = true;
      final bannerNotifier = ChallangeBloc();
      await bannerNotifier.getBanners(context);
      final fetch = bannerNotifier.userFetch;

      if (fetch.challengeState == ChallengeState.getPostSuccess) {
        List<BannerData>? res = (fetch.data as List<dynamic>?)?.map((e) => BannerData.fromJson(e as Map<String, dynamic>)).toList();
        banners = res;
      }
    } catch (e) {
      e.logger();
    } finally {
      isLoading = false;
    }
  }

  Future getBannerLanding(BuildContext context, {bool ispopUp = false, bool isSearch = false, bool isLeaderBoard = false}) async {
    checkInet(context);
    isLoadingBanner = true;
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
        if (isSearch) {
          bannerSearchData = [];
          bannerFatch.data.forEach((v) => bannerSearchData.add(BannerChalangeModel.fromJson(v)));
        } else {
          bannerLeaderboardData = [];
          bannerFatch.data.forEach((v) => bannerLeaderboardData.add(BannerChalangeModel.fromJson(v)));
        }
      }
      isLoadingBanner = false;
      notifyListeners();
    }
  }

  Future initLeaderboard(BuildContext context) async {
    isLoadingLeaderboard = true;
    notifyListeners();
    checkInet(context);
    await getBannerLanding(context, isLeaderBoard: true);
    await getLeaderBoard(context, bannerLeaderboardData[0].sId ?? '');
    await getOtherChallange(context);

    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future initLeaderboardDetail(BuildContext context, bool mounted, String id, {bool? isNewJoin}) async {
    isLoadingLeaderboard = true;
    notifyListeners();
    checkInet(context);
    await getLeaderBoard(context, id, isDetail: true);
    if (mounted) {
      var result = await System().createdReferralLink(context);
      referralLink = result.toString();
      print("hahahaha $referralLink");
    }

    isLoadingLeaderboard = false;
    if (isNewJoin != null || isNewJoin == true) {
      newJoinChallenge = true;
    }

    notifyListeners();
  }

  Future getLeaderBoard(BuildContext context, String idchallenge, {bool isDetail = false, bool oldLeaderboard = false}) async {
    Map param = {
      "idchallenge": idchallenge,
      // "idchallenge": "6486f6d4b8ab34f61602f85a",
      "iduser": SharedPreference().readStorage(SpKeys.userID),
      // "status":"BERLANGSUNG",
      // "session":1
    };
    if (oldLeaderboard) {
      param["session"] = selectOptionSession;
    }
    isLoading = true;
    notifyListeners();
    final bannerNotifier = ChallangeBloc();
    await bannerNotifier.postChallange(context, data: param, url: oldLeaderboard ? UrlConstants.getLeaderBoardSession : UrlConstants.getLeaderBoard);
    final bannerFatch = bannerNotifier.userFetch;

    if (bannerFatch.challengeState == ChallengeState.getPostSuccess) {
      if (bannerFatch.data.isNotEmpty) {
        LeaderboardChallangeModel? getdata;
        leaderBoardDataArray = [];
        leaderBoardDetaiEndlData ??= LeaderboardChallangeModel();
        leaderBoardDetailData ??= LeaderboardChallangeModel();
        bannerFatch.data.forEach((v) => leaderBoardDataArray?.add(LeaderboardChallangeModel.fromJson(v)));

        getdata = leaderBoardDataArray?.firstWhereOrNull((element) => element.status == berlangsung);
        getdata ??= leaderBoardDataArray?.firstWhereOrNull((element) => element.status == akanDatang);
        getdata ??= leaderBoardDataArray?[0];

        // getdata?.session = 3;

        if (!oldLeaderboard) {
          getOption(getdata ?? LeaderboardChallangeModel());
        }

        if (getdata?.startDatetime != '' || getdata?.startDatetime != null) {
          var dateNote = await System().compareDate(getdata?.startDatetime ?? '', getdata?.endDatetime ?? '');
          print("--===-=-=-=- date $dateNote");
          getdata?.onGoing = dateNote[0];
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

          if (oldLeaderboard) {
            leaderBoardDetaiEndlData = getdata;
            if (leaderBoardDetailData == null) {
              getLeaderBoard(context, idchallenge, isDetail: true);
              // leaderBoardDetailData = getdata;
              // getOption(getdata ?? LeaderboardChallangeModel(), session: selectOptionSession);
            }
          } else {
            leaderBoardDetailData = getdata;
          }
          print("leaderBoardDetailData ${leaderBoardDetailData?.onGoing} - ${leaderBoardDetailData?.totalDays}  - ${leaderBoardDetailData?.noteTime}");
        } else {
          print("===2");
          if (oldLeaderboard) {
            leaderBoardEndData = getdata;
          } else {
            leaderBoardData = getdata;
          }
        }
      } else {
        Routing().moveReplacement(Routes.chalenge);
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
    notifyListeners();
    Map param = {
      "page": pageAchievement,
      "limit": 10,
      // "iduser": "62c25b765f458435760af2dd",
      "iduser": SharedPreference().readStorage(SpKeys.userID),
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
    isLoadingCollection = true;
    notifyListeners();
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
      isLoadingCollection = false;
      notifyListeners();
      return true;
    } else {
      isLoadingCollection = false;
      notifyListeners();
      return false;
    }
  }

  void navigateToScreen(BuildContext context, index, email, postType) async {
    // Routing().move(
    //   Routes.shimmerSlider,
    //   argument: SlidedPicDetailScreenArgument(
    //     type: TypePlaylist.mine,
    //     titleAppbar: Text("Pict"),
    //     pageSrc: PageSrc.otherProfile,
    //   ),
    // );
    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
          transitionDuration: Duration.zero,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          opaque: false,
        ),
      ),
    );
    OtherProfileNotifier on = context.read<OtherProfileNotifier>();

    // await on.initialOtherProfile(context, argument: OtherProfileArgument(senderEmail: email));
    on.user.profile = null;
    on.user = UserInfoModel();
    List<ContentData> data;
    on.manyUser = [];
    on.manyUser.add(UserInfoModel(profile: UserProfileModel(email: email)));
    on.userEmail = email;

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
    Widget widgetTitle;
    String title = "";

    await on.getDataPerPgage(context, email: email);
    if (postType == 'pict') {
      data = on.manyUser.last.pics ?? [];
      title = "Pict";
    } else if (postType == 'diary') {
      data = on.manyUser.last.diaries ?? [];
      title = "Diary";
    } else {
      data = on.manyUser.last.vids ?? [];
      title = "Vid";
    }

    widgetTitle = Text(
      title,
      style: TextStyle(color: kHyppeTextLightPrimary),
    );
    Routing().moveBack();
    on.navigateToSeeAllScreen(context, index - 1, data: data, title: widgetTitle);
  }

  Future getOption(LeaderboardChallangeModel data, {DateTime? dateTime, int? session}) async {
    if (dateTime == null) {
      data.subChallenges?.forEach((element) {
        element.detail?.forEach((e) {
          e.detail?.forEach((el) {
            if (session != null) {
              if (el.session == session) {
                optionData = e;
                String month = (e.bulan ?? 0) < 10 ? "0${e.bulan}" : "${e.bulan}";
                String monthYear = "${e.tahun}-$month-01 00:00:00";
                challangeOption = DateTime.parse(monthYear);
                selectOptionSession = session;
              }
            } else {
              if (el.session == (data.session ?? 0) - 1) {
                optionData = e;
                String month = (e.bulan ?? 0) < 10 ? "0${e.bulan}" : "${e.bulan}";
                String monthYear = "${e.tahun}-$month-01 00:00:00";
                challangeOption = DateTime.parse(monthYear);
                selectOptionSession = (data.session ?? 0) - 1;
              }
            }
          });
        });
      });
    } else {
      data.subChallenges?.forEach((element) {
        if (element.tahun == dateTime.year) {
          for (var e in element.detail ?? []) {
            if (e.bulan == dateTime.month && e.tahun == dateTime.year) {
              optionData = e;
              String month = (e.bulan ?? 0) < 10 ? "0${e.bulan}" : "${e.bulan}";
              String monthYear = "${e.tahun}-$month-01 00:00:00";
              challangeOption = DateTime.parse(monthYear);
              notifyListeners();
              break;
            } else {
              optionData = DetailSub();
              challangeOption = dateTime;
              notifyListeners();
            }
          }
        }
      });
    }
  }

  Future setFilter(BuildContext context, String idchallenge, int session, bool isDetail) async {
    selectOptionSession = session;
    getLeaderBoard(context, idchallenge, oldLeaderboard: true, isDetail: isDetail);
  }

  void selectBadge(BadgeAktif? badgeData) {
    badgeUser = UserBadgeModel(
      id: badgeData?.sId,
      idUserBadge: badgeData?.idBadge,
      badgeProfile: badgeData?.badgeData?[0].badgeProfile,
      badgeOther: badgeData?.badgeData?[0].badgeOther,
    );
    notifyListeners();
  }

  Future postSelectBadge(BuildContext context, bool mounted, String idUserBadge) async {
    notifyListeners();
    Map param = {
      "iduserbadge": idUserBadge,
    };
    final achivementNotifier = ChallangeBloc();
    await achivementNotifier.postChallange(context, data: param, url: UrlConstants.selectBadge);
    final achievementFatch = achivementNotifier.userFetch;

    if (achievementFatch.challengeState == ChallengeState.getPostSuccess) {
      if (mounted) {
        iduserbadge = idUserBadge;
        notifyListeners();
        ShowGeneralDialog.showToastAlert(
          context,
          'Badge kamu berhasil diterapkan.',
          () async {},
          title: "Selamat!",
          bgColor: kHyppeGreen,
          withIcon: true,
        );
      }
      return true;
    } else {
      return false;
    }
  }
}
