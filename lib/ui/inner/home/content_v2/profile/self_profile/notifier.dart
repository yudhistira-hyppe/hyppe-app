import 'package:cached_network_image/cached_network_image.dart';
import 'package:hyppe/core/arguments/contents/slided_diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/slided_vid_detail_screen_argument.dart';
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
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_pics.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_vids.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';

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

  bool isConnect = true;
  bool isConnectContent = true;

  UserInfoModel _user = UserInfoModel();
  String? _username;
  int _limit = 10;
  int _pageIndex = 0;
  int _maxLine = 2;
  bool _descTextShowFlag = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingBio = false;
  bool get isLoadingBio => _isLoadingBio;

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
  String? _statusKyc = '';
  String? get statusKyc => _statusKyc;

  bool _scollLoading = false;
  bool get scollLoading => _scollLoading;

  int _heightBox = 0;
  int get heightBox => _heightBox;

  int heightIndex = 0;

  set heightBox(val) {
    _heightBox = val;
    notifyListeners();
  }

  set user(UserInfoModel val) {
    _user = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set isLoadingBio(bool val) {
    _isLoadingBio = val;
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

  setPageIndex(int val) {
    _pageIndex = val;
  }

  set descTextShowFlag(bool val) {
    _descTextShowFlag = val;
    notifyListeners();
  }

  set maxLine(int val) {
    _maxLine = val;
    notifyListeners();
  }

  void onUpdate() => notifyListeners();

  String displayUserName() {
    bool isGuest = SharedPreference().readStorage(SpKeys.isGuest) ?? false;
    if (!isGuest) {
      return user.profile != null ? "@" + (user.profile?.username ?? '') : "";
    } else {
      return '';
    }
  }

  String? displayPhotoProfile(String image) {
    print('ini gambar profil ${_system.showUserPicture(user.profile?.avatar?.mediaEndpoint)}');
    return _system.showUserPicture(image);
  }

  String? displayPhotoProfileOriginal() {
    var orginial = user.profile?.avatar?.mediaEndpoint!.split('/');
    var endpoint = "/profilepict/orignal/${orginial?.last}";
    return _system.showUserPicture(endpoint);
  }

  String displayPostsCount() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.posts?.toInt()) : "0";

  String displayFollowers() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.followers?.toInt()) : "0";

  String displayFollowing() => user.profile?.insight != null ? _system.formatterNumber(user.profile?.insight?.followings?.toInt()) : "0";

  String? displayFullName() => user.profile != null ? (user.profile?.fullName ?? '') : "";

  String displayBio() => user.profile != null
      ? user.profile?.bio != null
          ? '${user.profile?.bio}'
          : ""
      : "";

  void changeBio(String bio) {
    _user.profile?.bio = bio;
    notifyListeners();
  }

  String? displayPlace() {
    String? _area = user.profile?.area;
    String? _country = user.profile?.country;
    if (_area != null && _country != null) {
      return " $_area - $_country";
    } else {
      return null;
    }
  }

  updateProfilePost(FeatureType type, ContentData data) {
    if (type == FeatureType.pic) {
      user.pics?.insert(0, data);
    } else if (type == FeatureType.diary) {
      user.diaries?.insert(0, data);
    } else if (type == FeatureType.vid) {
      user.vids?.insert(0, data);
    }
    notifyListeners();
  }

  navigateToEditProfile() => Routing().move(Routes.accountPreferences).whenComplete(() => notifyListeners());

  onScrollListener(BuildContext context, {ScrollController? scrollController, bool isLoad = false}) async {
    var connection = await System().checkConnections();
    if (!connection) {
      return false;
    }

    if (isLoad || (scrollController != null && scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange)) {
      switch (pageIndex) {
        case 0:
          {
            if (!picContentsQuery.loading && picHasNext) {
              _scollLoading = true;
              notifyListeners();
              List<ContentData> _res = await picContentsQuery.loadNext(context, myContent: true);
              if (_res.isNotEmpty) {
                user.pics = [...(user.pics ?? []), ..._res];
                // if (user.pics != null) {
                //   await Future.wait(user.pics!.map((e) => cacheImage(context, e.mediaThumbEndPoint!)));
                // }
              } else {
                print("Post Pic Dah Mentok");
              }
              _scollLoading = false;
              notifyListeners();
            }
          }
          break;
        case 1:
          {
            if (!diaryContentsQuery.loading && diaryHasNext) {
              _scollLoading = true;
              notifyListeners();
              List<ContentData> _res = await diaryContentsQuery.loadNext(context, myContent: true);
              if (_res.isNotEmpty) {
                user.diaries = [...(user.diaries ?? []), ..._res];
              } else {
                print("Post Diary Dah Mentok");
              }
              _scollLoading = false;
              notifyListeners();
            }
          }
          break;
        case 2:
          {
            if (!vidContentsQuery.loading && vidHasNext) {
              _scollLoading = true;
              notifyListeners();
              List<ContentData> _res = await vidContentsQuery.loadNext(context, myContent: true);
              // _scollLoading = false;
              if (_res.isNotEmpty) {
                user.vids = [...(user.vids ?? []), ..._res];
              } else {
                "Post Vid Dah Mentok".logger();
              }
              _scollLoading = false;
              notifyListeners();
            }
          }
          break;
      }
    }
  }

  Future initialSelfProfile(BuildContext context) async {
    // pageIndex = 0;
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

    _statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    if (user.vids == null && user.diaries == null && user.pics == null) _isLoading = true;
    picContentsQuery.featureType = FeatureType.pic;
    diaryContentsQuery.featureType = FeatureType.diary;
    vidContentsQuery.featureType = FeatureType.vid;

    picContentsQuery.limit = 12;
    diaryContentsQuery.limit = 12;
    vidContentsQuery.limit = 12;

    picContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);
    diaryContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);
    vidContentsQuery.searchText = SharedPreference().readStorage(SpKeys.email);
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    if (!(isGuest ?? true)) {
      final usersNotifier = UserBloc();

      await usersNotifier.getUserProfilesBloc(context, withAlertMessage: true);
      final usersFetch = usersNotifier.userFetch;

      if (usersFetch.userState == UserState.getUserProfilesSuccess) {
        user.profile = null;
        user.profile = usersFetch.data;
        user.profile?.avatar?.imageKey = SharedPreference().readStorage(SpKeys.uniqueKey);
        // SharedPreference().writeStorage(SpKeys.isLoginSosmed, user.profile?.loginSource);
        SharedPreference().writeStorage(SpKeys.userID, user.profile?.idUser);
        notifyListeners();
      }
      // user.vids = await vidContentsQuery.reload(context, myContent: true);
      user.pics = await picContentsQuery.reload(context, myContent: true);
    }

    // context.read<ScrollPicNotifier>().pics = user.pics;

    // if (user.vids != null) {
    //   await Future.wait(user.vids!.map((e) => cacheImage(context, e.mediaThumbEndPoint!)));
    // }

    // user.diaries = await diaryContentsQuery.reload(context, myContent: true);
    // user.pics = await picContentsQuery.reload(context, myContent: true);
    _isLoading = false;
    notifyListeners();
  }

  Future cacheImage(BuildContext context, String url) async {
    precacheImage(CachedNetworkImageProvider(url, maxHeight: 50, maxWidth: 50), context);
  }

  String key({bool onUpdateProfile = false}) {
    var uniq = SharedPreference().readStorage(SpKeys.uniqueKey);
    print('ini ke key $uniq');
    if (uniq == null) {
      uniq = UniqueKey().toString();
      SharedPreference().writeStorage(SpKeys.uniqueKey, uniq);
      return uniq;
    } else {
      if (onUpdateProfile) {
        uniq = UniqueKey().toString();
        SharedPreference().writeStorage(SpKeys.uniqueKey, uniq);
      }
      return uniq;
    }
  }

  Future getDataPerPgage(BuildContext context, {bool isReload = false}) async {
    final connect = await _system.checkConnections();
    if (!connect) {
      isConnectContent = false;
      notifyListeners();
      return false;
    } else {
      isConnectContent = true;
      notifyListeners();
    }
    if (isReload) {
      final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);

      if (!(isGuest ?? true)) {
        final usersNotifier = UserBloc();
        await usersNotifier.getUserProfilesBloc(context, withAlertMessage: true);
        final usersFetch = usersNotifier.userFetch;

        if (usersFetch.userState == UserState.getUserProfilesSuccess) {
          var keyImageCache = key();
          user.profile = null;
          user.profile = usersFetch.data;
          user.profile?.avatar?.imageKey = keyImageCache;
          // SharedPreference().writeStorage(SpKeys.isLoginSosmed, user.profile?.loginSource);
          notifyListeners();
        }
      }

      PreviewStoriesNotifier stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
      stories.initialStories(context);
    }
    switch (pageIndex) {
      case 0:
        {
          if (user.pics == null || isReload) {
            user.pics = await picContentsQuery.reload(context, myContent: true);
            // if (user.pics != null) {
            //   await Future.wait(user.pics!.map((e) => cacheImage(context, e.mediaThumbEndPoint!)));
            // }
            notifyListeners();
          }
        }
        break;
      case 1:
        {
          if (user.diaries == null || isReload) {
            user.diaries = await diaryContentsQuery.reload(context, myContent: true);
            notifyListeners();
          }
        }
        break;
      case 2:
        {
          if (user.vids == null || isReload) {
            user.vids = await vidContentsQuery.reload(context, myContent: true);
            notifyListeners();
          }
        }
        break;
    }
  }

  Widget optionButton(ScrollController? scrollController, double height) {
    List pages = [
      !isLoading
          ? SelfProfilePics(
              height: height,
              scrollController: scrollController,
            )
          : BothProfileContentShimmer(),
      !isLoading
          ? SelfProfileDiaries(
              height: height,
              scrollController: scrollController,
            )
          : BothProfileContentShimmer(),
      !isLoading
          ? SelfProfileVids(
              height: height,
              scrollController: scrollController,
            )
          : BothProfileContentShimmer(),
    ];
    return pages[pageIndex];
  }

  navigateToSeeAllScreen(BuildContext context, int index, Widget title, {scrollController, double? heightProfile}) async {
    context.read<ReportNotifier>().inPosition = contentPosition.myprofile;
    // final connect = await _system.checkConnections();
    // if (connect) {
    // var result;
    if (pageIndex == 0) {
      _routing.move(Routes.scrollPic,
          argument: SlidedPicDetailScreenArgument(
            page: index,
            type: TypePlaylist.mine,
            titleAppbar: title,
            pageSrc: PageSrc.selfProfile,
            picData: user.pics,
            scrollController: scrollController,
            heightTopProfile: heightProfile,
          ));
      // _routing.move(Routes.picSlideDetailPreview,
      //     argument: SlidedPicDetailScreenArgument(picData: user.pics, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.mine));
    }
    if (pageIndex == 1) {
      _routing.move(Routes.scrollDiary,
          argument: SlidedDiaryDetailScreenArgument(
            page: index,
            type: TypePlaylist.mine,
            titleAppbar: title,
            pageSrc: PageSrc.selfProfile,
            diaryData: user.diaries,
            scrollController: scrollController,
            heightTopProfile: heightProfile,
          ));
      // _routing.move(Routes.diaryDetail,
      //     argument: DiaryDetailScreenArgument(diaryData: user.diaries, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.mine));
    }
    if (pageIndex == 2) {
      _routing.move(Routes.scrollVid,
          argument: SlidedVidDetailScreenArgument(
            page: index,
            type: TypePlaylist.mine,
            titleAppbar: title,
            pageSrc: PageSrc.selfProfile,
            vidData: user.vids,
            scrollController: scrollController,
            heightTopProfile: heightProfile,
          ));
      // result = await _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: user.vids?[index]));
    }
    // } else {
    //   ShowBottomSheet.onNoInternetConnection(context);
    // }
  }

  scrollAuto(String index) {
    // var indexHei = int.parse(index) + 1;
    // var hasilBagi = indexHei / 3;
    // heightIndex = 0;
    // if (isInteger(hasilBagi)) {
    //   hasilBagi = hasilBagi;
    // } else {
    //   hasilBagi += 1;
    // }
    // heightIndex = (heightBox * hasilBagi.toInt() - heightBox);
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

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

  Future onUpdateSelfPostContent(BuildContext context,
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
      bool? isShared,
      bool? saleLike,
      bool? saleView}) async {
    ContentData? _updatedData;
    print("ini kontennya $content");
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
      print('location nih $location');
      print('location nih ${_updatedData.location}');
      _updatedData.cats = [];
      _updatedData.tagPeople = [];
      _updatedData.isShared = isShared;
      // _updatedData.tagPeople = tagPeople;
      _updatedData.tagPeople?.addAll(tagPeople ?? []);

      // if (tagPeople != null) {
      //   for (var v in tagPeople) {
      //     _updatedData.tagPeople.add(TagPeople(username: v));
      //   }
      // }
      if (cats != null) {
        for (var v in cats) {
          _updatedData.cats?.add(
            Cats(
              id: v,
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
  }

  Future viewStory(BuildContext context) async {
    // if (itsMe) {
    // final storyNotifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    // if (storyNotifier.myStoriesData != null && storyNotifier.myStoriesData.story.isNotEmpty) {
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

  void showContentSensitive(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? _updatedData;
    ContentData? _updatedData2;

    switch (content) {
      case hyppeVid:
        if (user.vids!.isNotEmpty) _updatedData = user.vids?.firstWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        if (user.diaries!.isNotEmpty) _updatedData = user.diaries?.firstWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        if (user.pics!.isNotEmpty) _updatedData = user.pics?.firstWhere((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    print('show my profil');
    print(_updatedData?.postID);

    if (_updatedData != null) {
      _updatedData.reportedStatus = '';
    }
    _updatedData2?.reportedStatus = '';

    print(_updatedData?.reportedStatus);

    notifyListeners();
  }
}
