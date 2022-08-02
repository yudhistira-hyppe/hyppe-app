import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class PreviewVidNotifier with ChangeNotifier, GeneralMixin {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.vid;
  PageController pageController = PageController();

  List<ContentData>? _vidData;

  List<ContentData>? get vidData => _vidData;

  int _selectedRadioTile = 0;

  int get selectedRadioTile => _selectedRadioTile;

  set selectedRadioTile(int val) {
    _selectedRadioTile = val;
    notifyListeners();
  }

  set vidData(List<ContentData>? val) {
    _vidData = val;
    notifyListeners();
  }

  int get itemCount => _vidData == null ? 1 : (_vidData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  bool _forcePause = false;
  Duration? _currentPosition;
  ContentData? _selectedVidData;
  PostsState? _vidPostState;

  bool get forcePause => _forcePause;
  Duration? get currentPosition => _currentPosition;
  ContentData? get selectedVidData => _selectedVidData;
  PostsState? get vidPostState => _vidPostState;

  set forcePause(bool val) {
    _forcePause = val;
    notifyListeners();
  }

  set selectedVidData(ContentData? val) {
    _selectedVidData = val;
    notifyListeners();
  }

  set currentPosition(Duration? val) {
    _currentPosition = val;
    notifyListeners();
  }

  set vidPostState(PostsState? val) {
    _vidPostState = val;
    notifyListeners();
  }

  Future<void> initialVid(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<ContentData>> _resFuture;

    try {
      if (reload) {
        _resFuture = contentsQuery.reload(context);
      } else {
        _resFuture = contentsQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        vidData = res;
        if (pageController.hasClients) {
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } else {
        vidData = [...(vidData ?? [] as List<ContentData>)] + res;
      }
    } catch (e) {
      'load vid list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (pageController.offset >= pageController.position.maxScrollExtent && !pageController.position.outOfRange && !contentsQuery.loading && hasNext) {
      initialVid(context);
    }
  }

  void navigateToSeeAll(BuildContext context) async {
    final connect = await System().checkConnections();
    if (connect) {
      forcePause = true;
      await Routing().move(Routes.vidSeeAllScreen).whenComplete(() {
        forcePause = false;
      });
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void reportContent(BuildContext context) {
    ShowBottomSheet.onReportContent(context);
  }

  void showUserTag(BuildContext context, index, postId) {
    ShowBottomSheet.onShowUserTag(context, value: _vidData![index].tagPeople!, function: () {}, postId: postId);
  }

  void onDeleteSelfTagUserContent(BuildContext context, {required String postID, required String content, required String email}) {
    ContentData? _updatedData;
    // final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    // final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    // final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    // final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    // switch (content) {
    //   case hyppeVid:
    //     _updatedData = vid.vidData!.firstWhereOrNull((element) => element.postID == postID);
    //     break;
    //   case hyppeDiary:
    //     _updatedData = diary.diaryData!.firstWhereOrNull((element) => element.postID == postID);
    //     break;
    //   case hyppePic:
    //     _updatedData = pic.pic!.firstWhereOrNull((element) => element.postID == postID);
    //     break;
    //   case hyppeStory:
    //     _updatedData = stories.myStoriesData!.firstWhereOrNull((element) => element.postID == postID);
    //     break;
    //   default:
    //     "$content It's Not a content of $postID".logger();
    //     break;
    // }

    final index = vidData!.indexWhere((element) => element.postID == postID);
    print(vidData![index].tagPeople!.length);
    vidData![index].tagPeople?.removeWhere((element) => element.email == email);
    vidData![index].description = 'asdaksdjha jsd';

    print(vidData![index].tagPeople!.length);
    // _updatedData!.tagPeople!.removeWhere((element) => element.email == email);
    // _updatedData.description = 'hflkjsdhkfjhskdjfhk';

    notifyListeners();
  }
}
