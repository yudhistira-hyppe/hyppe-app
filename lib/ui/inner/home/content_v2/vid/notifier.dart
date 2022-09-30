import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PreviewVidNotifier with ChangeNotifier, GeneralMixin {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final _system = System();
  final _routing = Routing();

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
        print('initial video');
        vidData = [...(vidData ?? [] as List<ContentData>)] + res;
      }
      final _searchData = context.read<SearchNotifier>();
      _searchData.allContents = UserInfoModel();
      print('ini video data');
      print(_searchData);
      print(_searchData.allContents);
      // print(_searchData.allContents!.vids);
      if (_searchData.allContents!.vids == null) {
        _searchData.vidContentsQuery.featureType = FeatureType.vid;
        _searchData.allContents?.vids = vidData;
      }
      print('ini video data22');
      print(_searchData.allContents?.vids);
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

    final index = vidData!.indexWhere((element) => element.postID == postID);
    print(vidData![index].tagPeople!.length);
    vidData![index].tagPeople?.removeWhere((element) => element.email == email);

    print(vidData![index].tagPeople!.length);
    // _updatedData!.tagPeople!.removeWhere((element) => element.email == email);
    // _updatedData.description = 'hflkjsdhkfjhskdjfhk';

    notifyListeners();
  }

  void navigateToHyppeVidDetail(BuildContext context, ContentData? data) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }
}
