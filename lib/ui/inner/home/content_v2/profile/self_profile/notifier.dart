import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_pics.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_vids.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';

class SelfProfileNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  static final _system = System();
  final Routing _routing = Routing();
  ContentsDataQuery vidContentsQuery = ContentsDataQuery();
  ContentsDataQuery diaryContentsQuery = ContentsDataQuery();
  ContentsDataQuery picContentsQuery = ContentsDataQuery();

  UserInfoModel _user = UserInfoModel();
  String? _username;
  int _limit = 10;
  int _pageIndex = 0;
  int _maxLine = 2;
  bool _descTextShowFlag = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserInfoModel get user => _user;
  Routing get routing => _routing;

  int get limit => _limit;
  int get pageIndex => _pageIndex;
  int get maxLine => _maxLine;
  String? get username => _username;
  bool get descTextShowFlag => _descTextShowFlag;

  int get vidCount => vidContentsQuery.hasNext ? (user.vids?.length ?? 0) + 2 : (user.vids?.length ?? 0);
  bool get vidHasNext => vidContentsQuery.hasNext;

  int get diaryCount => diaryContentsQuery.hasNext ? (user.diaries?.length ?? 0) + 2 : (user.diaries?.length ?? 0);
  bool get diaryHasNext => diaryContentsQuery.hasNext;

  int get picCount => picContentsQuery.hasNext ? (user.pics?.length ?? 0) + 2 : (user.pics?.length ?? 0);
  bool get picHasNext => picContentsQuery.hasNext;

  set user(UserInfoModel val) {
    _user = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set limit(int val) {
    _limit = val;
    notifyListeners();
  }

  set pageIndex(int val) {
    _pageIndex = val;
    notifyListeners();
  }

  set descTextShowFlag(bool val) {
    _descTextShowFlag = val;
    notifyListeners();
  }

  set maxLine(int val) {
    _maxLine = val;
    notifyListeners();
  }

  String displayUserName() => user.profile != null ? "@" + (user.profile?.username ?? '') : "";

  String? displayPhotoProfile() => _system.showUserPicture(user.profile?.avatar?.mediaEndpoint);

  String displayPostsCount() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.posts?.toInt()) : "0";

  String displayFollowers() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.followers?.toInt()) : "0";

  String displayFollowing() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.followings?.toInt()) : "0";

  String? displayFullName() => user.profile != null ? (user.profile?.fullName ?? '') : "";

  String displayBio() => user.profile != null
      ? user.profile?.bio != null
          ? '"${user.profile?.bio}"'
          : ""
      : "";

  String? displayPlace() {
    String? _area = user.profile?.area;
    String? _country = user.profile?.country;
    if (_area != null && _country != null) {
      return " $_area - $_country";
    } else {
      return null;
    }
  }

  navigateToEditProfile() => Routing().move(Routes.accountPreferences).whenComplete(() => notifyListeners());

  onScrollListener(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      switch (pageIndex) {
        case 0:
          {
            if (!vidContentsQuery.loading && vidHasNext) {
              List<ContentData> _res = await vidContentsQuery.loadNext(context, myContent: true);
              if (_res.isNotEmpty) {
                user.vids = [...(user.vids ?? []), ..._res];
              } else {
                print("Post Vid Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
        case 1:
          {
            if (!diaryContentsQuery.loading && diaryHasNext) {
              List<ContentData> _res = await diaryContentsQuery.loadNext(context, myContent: true);
              if (_res.isNotEmpty) {
                user.diaries = [...(user.diaries ?? []), ..._res];
              } else {
                print("Post Diary Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
        case 2:
          {
            if (!picContentsQuery.loading && picHasNext) {
              List<ContentData> _res = await picContentsQuery.loadNext(context, myContent: true);
              if (_res.isNotEmpty) {
                user.pics = [...(user.pics ?? []), ..._res];
              } else {
                print("Post Pic Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
      }
    }
  }

  initialSelfProfile(BuildContext context) async {
    if (user.vids == null && user.diaries == null && user.pics == null) _isLoading = true;
    vidContentsQuery.featureType = FeatureType.vid;
    diaryContentsQuery.featureType = FeatureType.diary;
    picContentsQuery.featureType = FeatureType.pic;

    vidContentsQuery.limit = 12;
    diaryContentsQuery.limit = 12;
    picContentsQuery.limit = 12;

    vidContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);
    diaryContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);
    picContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);

    final usersNotifier = UserBloc();
    await usersNotifier.getUserProfilesBloc(context, withAlertMessage: true);
    final usersFetch = usersNotifier.userFetch;

    if (usersFetch.userState == UserState.getUserProfilesSuccess) {
      user.profile = null;
      user.profile = usersFetch.data;
      notifyListeners();
    }
    user.vids = await vidContentsQuery.reload(context, myContent: true);
    user.diaries = await diaryContentsQuery.reload(context, myContent: true);
    user.pics = await picContentsQuery.reload(context, myContent: true);
    _isLoading = false;
    notifyListeners();
  }

  Widget optionButton() {
    List pages = [
      !isLoading ? const SelfProfileVids() : BothProfileContentShimmer(),
      !isLoading ? const SelfProfileDiaries() : BothProfileContentShimmer(),
      !isLoading ? const SelfProfilePics() : BothProfileContentShimmer()
    ];
    return pages[pageIndex];
  }

  navigateToSeeAllScreen(BuildContext context, int index) async {
    final connect = await _system.checkConnections();
    if (connect) {
      if (pageIndex == 0) _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: user.vids?[index]));
      if (pageIndex == 1) _routing.move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: user.diaries, index: index.toDouble()));
      if (pageIndex == 2) _routing.move(Routes.picSlideDetailPreview, argument: SlidedPicDetailScreenArgument(picData: user.pics, index: index.toDouble()));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void onDeleteSelfPostContent(BuildContext context, {required String postID, required String content}) {
    switch (content) {
      case hyppeVid:
        if (user.vids != null) user.vids?.removeWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        if (user.diaries != null) user.diaries?.removeWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        if (user.pics != null) user.pics?.removeWhere((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }
    user.profile?.insight?.posts = (user.profile?.insight?.posts ?? 1) - 1;
    notifyListeners();
  }

  void onUpdateSelfPostContent(BuildContext context,
      {required String postID,
      required String content,
      String? description,
      String? visibility,
      bool? allowComment,
      bool? certified,
      List<String>? tags,
      List<String>? cats,
      List<TagPeople>? tagPeople,
      String? location,
      String? saleAmount,
      bool? saleLike,
      bool? saleView}) {
    ContentData? _updatedData;

    switch (content) {
      case hyppeVid:
        if (user.vids != null) {
          _updatedData = user.vids?.firstWhereOrNull((element) => element.postID == postID);
        }
        break;
      case hyppeDiary:
        if (user.diaries != null) {
          _updatedData = user.diaries?.firstWhereOrNull((element) => element.postID == postID);
        }
        break;
      case hyppePic:
        if (user.pics != null) {
          _updatedData = user.pics?.firstWhereOrNull((element) => element.postID == postID);
        }
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (_updatedData != null) {
      _updatedData.tags = tags;
      _updatedData.description = description;
      _updatedData.allowComments = allowComment;
      _updatedData.certified = certified;
      _updatedData.visibility = visibility;
      _updatedData.location = location;
      _updatedData.saleAmount = num.parse(saleAmount ?? '0');
      _updatedData.saleLike = saleLike;
      _updatedData.saleLike = saleView;
      _updatedData.cats = [];
      _updatedData.tagPeople = [];
      // _updatedData.tagPeople = tagPeople;
      _updatedData.tagPeople?.addAll(tagPeople ?? []);

      // if (tagPeople != null) {
      //   for (var v in tagPeople) {
      //     _updatedData.tagPeople!.add(TagPeople(username: v));
      //   }
      // }
      if (cats != null) {
        for (var v in cats) {
          _updatedData.cats?.add(
            Cats(
              interestName: v,
            ),
          );
        }
      }
      notifyListeners();
    }
  }

  // create generic function that can be detect profile is have story or not
  bool checkHaveStory(BuildContext context) {
    return false;
    // if (itsMe) {
    //   final storyNotifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    //   return storyNotifier.myStoriesData != null && storyNotifier.myStoriesData!.story.isNotEmpty;
    // } else {
    //   return false;
    // }
  }

  Future viewStory(BuildContext context) async {
    // if (itsMe) {
    // final storyNotifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    // if (storyNotifier.myStoriesData != null && storyNotifier.myStoriesData!.story.isNotEmpty) {
    //   storyNotifier.tapHandler(context, storyNotifier.myStoriesData);
    // }
    // }
  }

  void setIdProofStatusUser(IdProofStatus? initialStatus) {
    switch (initialStatus) {
      case IdProofStatus.initial:
      case IdProofStatus.revoke:
        user.profile?.idProofStatus = IdProofStatus.inProgress;
        break;
      case IdProofStatus.complete:
        user.profile?.idProofStatus = IdProofStatus.complete;
        user.profile?.statusKyc = VERIFIED;
        SharedPreference().writeStorage(SpKeys.statusVerificationId, VERIFIED);
        break;
      default:
        break;
    }
    notifyListeners();
  }
}
