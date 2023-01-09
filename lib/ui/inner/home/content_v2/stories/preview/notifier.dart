import 'dart:convert';

import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import '../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../../core/models/collection/music/music.dart';

class PreviewStoriesNotifier with ChangeNotifier {
  final _routing = Routing();
  ScrollController scrollController = ScrollController();

  ContentsDataQuery peopleContentsQuery = ContentsDataQuery()
    ..limit = 5
    ..featureType = FeatureType.story;

  ContentsDataQuery myContentsQuery = ContentsDataQuery()
    ..onlyMyData = true
    ..featureType = FeatureType.story;

  List<ContentData>? _peopleStoriesData;

  Map<String, List<ContentData>> _groupPeopleStory = {};

  List<ContentData>? _myStoriesData;

  Map<String, List<ContentData>> _myStoryGroup = {};

  int _totalViews = 0;

  List<ContentData>? get peopleStoriesData => _peopleStoriesData;

  Map<String, List<ContentData>> get groupPeopleStory => _groupPeopleStory;

  List<ContentData>? get myStoriesData => _myStoriesData;

  Map<String, List<ContentData>> get myStoryGroup => _myStoryGroup;

  int get totalViews => _totalViews;

  StoryController storyController = StoryController();

  changeBorderColor(ContentData contentData) {
    contentData.isViewed = true;
    notifyListeners();
  }

  set peopleStoriesData(List<ContentData>? val) {
    _peopleStoriesData = val;
    notifyListeners();
  }

  set groupPeopleStory(Map<String, List<ContentData>> map) {
    _groupPeopleStory = map;
    notifyListeners();
  }

  set myStoriesData(List<ContentData>? val) {
    _myStoriesData = val;
    notifyListeners();
  }

  set myStoryGroup(Map<String, List<ContentData>> map) {
    _myStoryGroup = map;
    notifyListeners();
  }

  set totalViews(int val) {
    _totalViews = val;
    notifyListeners();
  }

  int groupItemCount(dynamic error) => _groupPeopleStory == null && error == null
      ? 10
      : peopleContentsQuery.hasNext
          ? (_groupPeopleStory.length) + 1
          : (_groupPeopleStory.length) + 1;

  int peopleItemCount(dynamic error) => _peopleStoriesData == null && error == null
      ? 10
      : peopleContentsQuery.hasNext
          ? (_peopleStoriesData?.length ?? 0) + 1
          : (_peopleStoriesData?.length ?? 0) + 1;

  bool get hasNext => peopleContentsQuery.hasNext;

  Future initialStories(BuildContext context, {List<ContentData>? list}) async {
    // initialMyStories(context);
    initialMyStoryGroup(context);
    print('initialStories');
    initialPeopleStories(context, reload: true, list: list);
  }

  Future<void> initialMyStories(BuildContext context) async {
    Future<List<ContentData>> _resFuture;

    try {
      print('reload contentsQuery : 13');
      _resFuture = myContentsQuery.reload(context);
      final res = await _resFuture;
      myStoriesData = res;
      if (myStoriesData != null) {
        totalViews = 0;
        for (var element in myStoriesData!) {
          totalViews += (element.insight?.views ?? 0);
        }
      }
    } catch (e) {
      'load my story list: ERROR: $e'.logger();
    }
  }

  Future initialMyStoryGroup(BuildContext context) async {
    try {
      final email = SharedPreference().readStorage(SpKeys.email);
      final res = await myContentsQuery.reload(context);
      myStoryGroup[email] = res;
    } catch (e) {
      'load my story list: ERROR: $e'.logger();
    }
  }

  Future<void> initialAllPeopleStories(BuildContext context, bool isStart) async {}

  Future<void> initialPeopleStories(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        for (var data in list) {
          print('data stories: ${data.toJson().toString()}');
        }
        if (reload) {
          peopleContentsQuery.page = 1;
          peopleContentsQuery.hasNext = true;
        }
        res.addAll(list);
        peopleContentsQuery.hasNext = list.length == peopleContentsQuery.limit;
        if (list.isNotEmpty) peopleContentsQuery.page++;
      } else {
        if (reload) {
          res = await peopleContentsQuery.loadNext(context, isLandingPage: true);
          // res = await peopleContentsQuery.reload(context);
        } else {
          res = await peopleContentsQuery.loadNext(context, isLandingPage: true);
        }
      }

      print('get story ${res.length}');

      if (reload) {
        peopleStoriesData = res;
        groupPeopleStory = {};
        for (var data in res) {
          final email = data.email;
          print('people postID: ${data.postID}');
          if (email != null) {
            if (groupPeopleStory[email] == null) {
              groupPeopleStory[email] = [];
            }
            groupPeopleStory[email]?.add(data);
          }
        }
        groupPeopleStory.forEach((key, value) {
          groupPeopleStory[key]?.sort((a, b){
            final aDate = a.createdAt?.getMilliSeconds();
            final bDate = b.createdAt?.getMilliSeconds();
            if(aDate != null && bDate != null){
              return aDate.compareTo(bDate);
            }else{
              return 0;
            }
          });
        });
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.initialScrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } else {
        for (var data in res) {
          final email = data.email;
          if (email != null) {
            if (groupPeopleStory[email] == null) {
              groupPeopleStory[email] = [];
            }
            groupPeopleStory[email]?.add(data);
          }
        }
        peopleStoriesData = [...(peopleStoriesData ?? [] as List<ContentData>)] + res;
        groupPeopleStory.forEach((key, value) {
          groupPeopleStory[key]?.sort((a, b){
            final aDate = a.createdAt?.getMilliSeconds();
            final bDate = b.createdAt?.getMilliSeconds();
            if(aDate != null && bDate != null){
              return aDate.compareTo(bDate);
            }else{
              return 0;
            }
          });
        });
      }

      if (peopleStoriesData != null) {
        peopleStoriesData?.removeDuplicates(by: (item) => item.email);
      }
    } catch (e) {
      'load people story list: ERROR: $e'.logger();
    }
  }



  Future<MusicUrl?> getMusicApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print('jsonMap video Apsara : $jsonMap');
        final String dur = jsonMap['Duration'];
        final duration = double.parse(dur);
        return MusicUrl(playUrl: jsonMap['PlayUrl'], duration: duration);
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
    return null;
  }

  Future getVideoApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        return jsonMap['PlayUrl'].toString();
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
      return '';
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !peopleContentsQuery.loading && hasNext) {
      initialPeopleStories(context);
    }
  }

  void onTapHandler(BuildContext context) {
    if (myStoriesData != null && (myStoriesData?.isNotEmpty ?? false)) {
      _routing.move(
        Routes.storyDetail,
        argument: StoryDetailScreenArgument(
          storyData: myStoriesData,
        ),
      );
    } else {
      // System().actionReqiredIdCard(context, action: () => uploadStories(context));
      uploadStories(context);
    }
  }

  void navigateToMyStoryGroup(BuildContext context, List stories) {
    print('navigateToStoryGroup: ${myStoryGroup.isNotEmpty} : $myStoryGroup');
    if (stories.isNotEmpty) {
      _routing.move(
        Routes.showStories,
        argument: StoryDetailScreenArgument(
            groupStories: myStoryGroup,
        ),
      );
    } else {
      uploadStories(context);
    }
  }

  void navigateToPeopleStoryGroup(BuildContext context, int index) {
    print('navigateToStoryGroup: ${myStoryGroup.isNotEmpty} : $myStoryGroup');
    _routing.move(
        Routes.showStories,
        argument: StoryDetailScreenArgument(
            groupStories: groupPeopleStory,
            peopleIndex: index,
        )
    );
  }

  void uploadStories(BuildContext context) {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    // notifier.thumbnailLocalMedia();
    notifier.featureType = FeatureType.story;
    notifier.selectedDuration = 15;
    Routing().move(Routes.makeContent);
  }

  void navigateToShortVideoPlayer(BuildContext context, int index) {
    _routing.move(
      Routes.storyDetail,
      argument: StoryDetailScreenArgument(
        storyData: peopleStoriesData,
        index: index.toDouble(),
      ),
    );
  }
}
