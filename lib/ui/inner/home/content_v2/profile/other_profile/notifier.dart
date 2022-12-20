import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
// import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/arguments/message_detail_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
// import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart';
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
// import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/query_request/users_data_query.dart';
import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_pics.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_vids.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';

class OtherProfileNotifier with ChangeNotifier {
  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserInfoModel _user = UserInfoModel();
  StatusFollowing _statusFollowing = StatusFollowing.rejected;
  String? _userID;
  String? _userEmail;
  String? _username;
  int _limit = 10;
  int _pageIndex = 0;

  UserInfoModel get user => _user;
  Routing get routing => _routing;
  StatusFollowing get statusFollowing => _statusFollowing;
  int get limit => _limit;
  int get pageIndex => _pageIndex;
  String? get userID => _userID;
  String? get userEmail => _userEmail;
  String? get username => _username;

  bool _isCheckLoading = false;
  bool get isCheckLoading => _isCheckLoading;

  int get vidCount => vidContentsQuery.hasNext ? (user.vids?.length ?? 0) + 2 : (user.vids?.length ?? 0);
  bool get vidHasNext => vidContentsQuery.hasNext;

  int get diaryCount => diaryContentsQuery.hasNext ? (user.diaries?.length ?? 0) + 2 : (user.diaries?.length ?? 0);
  bool get diaryHasNext => diaryContentsQuery.hasNext;

  int get picCount => picContentsQuery.hasNext ? (user.pics?.length ?? 0) + 2 : (user.pics?.length ?? 0);
  bool get picHasNext => picContentsQuery.hasNext;

  setReportPeople(UserInfoModel val) => _user = val;

  set user(UserInfoModel val) {
    _user = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set username(String? val) {
    _username = val;
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

  set userEmail(String? val) {
    _userEmail = val;
    notifyListeners();
  }

  set statusFollowing(StatusFollowing newValue) {
    _statusFollowing = newValue;
    notifyListeners();
  }

  set userID(String? val) {
    _userID = val;
    notifyListeners();
  }

  set isCheckLoading(bool val) {
    _isCheckLoading = val;
    notifyListeners();
  }

  void onUpdate() => notifyListeners();

  String displayUserName() => user.profile != null
      ? "@" + (user.profile?.username ?? '')
      : username != null
          ? "@" + (username ?? '')
          : "";

  String? displayPhotoProfile() => _system.showUserPicture(user.profile?.avatar?.mediaEndpoint);

  String displayPostsCount() => user.profile?.insight != null ? _system.formatterNumber((user.profile?.insight?.posts ?? 0).toInt()) : "0";

  String displayFollowers() => user.profile?.insight != null ? _system.formatterNumber((user.profile?.insight?.followers ?? 0).toInt()) : "0";

  String displayFollowing() => user.profile?.insight != null ? _system.formatterNumber((user.profile?.insight?.followings ?? 0).toInt()) : "0";

  String? displayFullName() => user.profile != null ? (user.profile?.fullName ?? "") : "";

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

  onScrollListener(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      switch (pageIndex) {
        case 0:
          {
            if (!vidContentsQuery.loading && vidHasNext) {
              List<ContentData> _res = await vidContentsQuery.loadNext(context, otherContent: true);
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
              List<ContentData> _res = await diaryContentsQuery.loadNext(context, otherContent: true);
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
              List<ContentData> _res = await picContentsQuery.loadNext(context, otherContent: true);
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

  initialOtherProfile(BuildContext context, {OtherProfileArgument? argument, bool refresh = false}) async {
    print('ini argument');
    print(argument?.postID);
    print(argument?.postID);
    user = UserInfoModel();
    if (user.vids == null && user.diaries == null && user.pics == null) _isLoading = true;

    if (argument?.senderEmail != null) {
      userEmail = argument?.senderEmail;
    }

    vidContentsQuery.featureType = FeatureType.vid;
    diaryContentsQuery.featureType = FeatureType.diary;
    picContentsQuery.featureType = FeatureType.pic;

    vidContentsQuery.limit = 12;
    diaryContentsQuery.limit = 12;
    picContentsQuery.limit = 12;

    vidContentsQuery.searchText = userEmail ?? '';
    diaryContentsQuery.searchText = userEmail ?? '';
    picContentsQuery.searchText = userEmail ?? '';

    if(argument?.profile != null){
      user.profile = argument?.profile;
      notifyListeners();
    }else{
      final usersNotifier = UserBloc();
      await usersNotifier.getUserProfilesBloc(context, search: userEmail, withAlertMessage: true);
      final usersFetch = usersNotifier.userFetch;

      if (usersFetch.userState == UserState.getUserProfilesSuccess) {
        user.profile = usersFetch.data;
        notifyListeners();
      }
    }


    if (refresh) {
      checkFollowingToUser(context, userEmail ?? '');
    }

    print('test10');
    user.vids = await vidContentsQuery.reload(context, otherContent: true);
    user.diaries = await diaryContentsQuery.reload(context, otherContent: true);
    user.pics = await picContentsQuery.reload(context, otherContent: true);
    _isLoading = false;
    notifyListeners();
  }

  Future followUser(BuildContext context) async {
    try {
      // _system.actionReqiredIdCard(
      //   context,
      //   action: () async {
      // statusFollowing = StatusFollowing.requested;
      isCheckLoading = true;
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: _userEmail ?? '',
          eventType: InteractiveEventType.following,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        statusFollowing = StatusFollowing.following;
      } else {
        statusFollowing = StatusFollowing.none;
      }
      //   },
      //   uploadContentAction: false,
      // );
      isCheckLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
      statusFollowing = StatusFollowing.none;
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    }
  }

  Widget optionButton() {
    List pages = [
      !isLoading ? const OtherProfileVids() : BothProfileContentShimmer(),
      !isLoading ? const OtherProfileDiaries() : BothProfileContentShimmer(),
      !isLoading ? const OtherProfilePics() : BothProfileContentShimmer()
    ];
    return pages[pageIndex];
  }

  navigateToSeeAllScreen(BuildContext context, int index, {contentPosition? inPosition}) async {
    context.read<ReportNotifier>().inPosition = contentPosition.otherprofile;
    final connect = await _system.checkConnections();
    if (connect) {
      if (pageIndex == 0) _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: user.vids?[index]));
      if (pageIndex == 1)
        _routing.move(Routes.diaryDetail,
            argument: DiaryDetailScreenArgument(diaryData: user.diaries, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.other));
      if (pageIndex == 2)
        _routing.move(Routes.picSlideDetailPreview,
            argument: SlidedPicDetailScreenArgument(picData: user.pics, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.other));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  // create generic function that can be detect profile is have story or not
  bool checkHaveStory(BuildContext context) {
    return false;
    // if (itsMe) {
    //   final storyNotifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    //   return storyNotifier.myStoriesData != null && storyNotifier.myStoriesData.story.isNotEmpty;
    // } else {
    //   return false;
    // }
  }

  Future viewStory(BuildContext context) async {
    // if (itsMe) {
    // final storyNotifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    // if (storyNotifier.myStoriesData != null && storyNotifier.myStoriesData.story.isNotEmpty) {
    //   storyNotifier.tapHandler(context, storyNotifier.myStoriesData);
    // }
    // }
  }

  void onExit() {
    routing.moveBack();
    userEmail = null;
  }

  Future createDiscussion(BuildContext context) async {
    try {
      // _system.actionReqiredIdCard(
      //   context,
      //   action: () {
      // get email sender
      final emailSender = SharedPreference().readStorage(SpKeys.email);

      // get self profile data
      final _selfProfile = Provider.of<SelfProfileNotifier>(context, listen: false);
      Routing()
          .move(Routes.messageDetail,
              argument: MessageDetailArgument(
                mate: Mate(
                  email: emailSender,
                  fullName: _selfProfile.user.profile?.fullName,
                  username: _selfProfile.user.profile?.username,
                  avatar: Avatar(
                    mediaUri: _selfProfile.user.profile?.avatar?.mediaUri,
                    mediaType: _selfProfile.user.profile?.avatar?.mediaType,
                    mediaEndpoint: _selfProfile.user.profile?.avatar?.mediaEndpoint,
                    mediaBasePath: _selfProfile.user.profile?.avatar?.mediaBasePath,
                  ),
                ),
                emailReceiver: userEmail ?? '',
                usernameReceiver: displayUserName(),
                fullnameReceiver: displayFullName() ?? '',
                photoReceiver: displayPhotoProfile() ?? '',
                disqusID: '',
              ))
          .then((value) {});
      //   },
      //   uploadContentAction: false,
      // );
    } catch (e) {
      e.toString().logger();
    }
  }

  Future<void> checkFollowingToUser(BuildContext context, String email) async {
    _isCheckLoading = true;
    userEmail = email;
    statusFollowing = StatusFollowing.rejected;
    try {
      _usersFollowingQuery.senderOrReceiver = email;
      _usersFollowingQuery.limit = 200;
      print('reload contentsQuery : 11');
      final _resFuture = _usersFollowingQuery.reload(context);
      final _resRequest = await _resFuture;

      if (_resRequest.isNotEmpty) {
        if (_resRequest.any((element) => element.event == InteractiveEvent.accept)) {
          statusFollowing = StatusFollowing.following;
        } else if (_resRequest.any((element) => element.event == InteractiveEvent.initial)) {
          statusFollowing = StatusFollowing.requested;
        }
      }
      isCheckLoading = false;
    } catch (e) {
      'load following request list: ERROR: $e'.logger();
      isCheckLoading = false;
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

    print('show other profil');
    print(_updatedData);

    if (_updatedData != null) {
      _updatedData.reportedStatus = '';
    }
    if (_updatedData2 != null) {
      _updatedData2.reportedStatus = '';
    }

    notifyListeners();
  }
}
