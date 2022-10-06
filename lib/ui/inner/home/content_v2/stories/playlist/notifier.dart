import 'dart:convert';
import 'dart:math';
import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/arguments/post_reaction_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';

import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/bloc/reaction/bloc.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import 'package:hyppe/core/models/collection/utils/reaction/reaction.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/show_reactions_icon.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';

import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/item.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'package:story_view/story_view.dart';

class StoriesPlaylistNotifier with ChangeNotifier, GeneralMixin {
  ContentsDataQuery myContentsQuery = ContentsDataQuery()
    ..onlyMyData = true
    ..featureType = FeatureType.story;

  final _sharedPrefs = SharedPreference();
  final _system = System();
  final _routing = Routing();

  StoryDetailScreenArgument? _routeArgument;
  bool _isReactAction = false;
  bool _fadeReaction = false;
  String? _reaction;
  final List<Item> _items = <Item>[];
  List<StoryItem> _result = [];
  List<StoryItem> get result => _result;

  int _currentStory = 0;
  int _storyParentIndex = 0;
  bool _isShareAction = false;
  bool _isKeyboardActive = false;
  bool _linkCopied = false;
  bool _forceStop = false;
  double? _currentPage = 0;
  Timer? _searchOnStoppedTyping;
  Color? _sendButtonColor;
  PageController? _pageController = PageController(initialPage: 0);
  List<ContentData> _dataUserStories = [];
  final TextEditingController _textEditingController = TextEditingController();

  bool get isReactAction => _isReactAction;
  bool get fadeReaction => _fadeReaction;
  String? get reaction => _reaction;
  List<Item> get items => _items;

  int get currentStory => _currentStory;
  int get storyParentIndex => _storyParentIndex;
  bool get isShareAction => _isShareAction;
  bool get isKeyboardActive => _isKeyboardActive;
  bool get linkCopied => _linkCopied;
  bool get forceStop => _forceStop;
  double? get currentPage => _currentPage;
  Color? get buttonColor => _sendButtonColor;
  PageController? get pageController => _pageController;
  List<ContentData> get dataUserStories => _dataUserStories;
  TextEditingController get textEditingController => _textEditingController;

  set result(List<StoryItem> val) {
    _result = val;
    notifyListeners();
  }

  set reaction(String? val) {
    _reaction = val;
    notifyListeners();
  }

  set fadeReaction(bool newValue) {
    _fadeReaction = newValue;
    notifyListeners();
  }

  set isReactAction(bool val) {
    _isReactAction = val;
    notifyListeners();
  }

  set linkCopied(bool val) {
    _linkCopied = val;
    notifyListeners();
  }

  set forceStop(bool val) {
    _forceStop = val;
    notifyListeners();
  }

  set currentPage(double? val) {
    _currentPage = val;
    notifyListeners();
  }

  set storyParentIndex(int val) {
    _storyParentIndex = val;
    notifyListeners();
  }

  set dataUserStories(List<ContentData> val) {
    _dataUserStories = val;
    notifyListeners();
  }

  setCurrentStory(int val) => _currentStory = val;

  set isShareAction(bool val) {
    _isShareAction = val;
    notifyListeners();
  }

  setIsKeyboardActive(bool val) => _isKeyboardActive = val;

  nextPage() {
    if (_pageController!.page == dataUserStories.length - 1) {
      return;
    }
    _pageController!.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  degreeToRadian(double deg) {
    return deg * pi / 180;
  }

  initialCurrentPage(double? page) {
    _currentPage = page;
    notifyListeners();
  }

  onChangeHandler(BuildContext context, String value) {
    if (_searchOnStoppedTyping != null) {
      _searchOnStoppedTyping!.cancel();
    }
    _searchOnStoppedTyping = Timer(const Duration(milliseconds: 200), () {
      if (value.isNotEmpty) {
        _sendButtonColor = const Color(0xff822E6E);
      } else {
        _sendButtonColor = kHyppeLightButtonText;
      }
      notifyListeners();
    });
  }

  void checkIfKeyboardIsFocus(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void makeItems(AnimationController animationController) {
    items.clear();
    for (int i = 0; i < 100; i++) {
      items.add(Item());
    }
    notifyListeners();
    animationController.reset();
    animationController.forward();
  }

  // List<StoryItem> initializeData(BuildContext context, StoryController storyController, ContentData data) {
  Future initializeData(BuildContext context, StoryController storyController, ContentData data) async {
    // List<StoryItem> _result = [];
    _result = [];
    if (data.mediaType?.translateType() == ContentType.image) {
      _result.add(
        StoryItem.pageImage(
          url: data.isApsara! ? data.mediaThumbUri! : data.fullThumbPath ?? '',
          controller: storyController,
          imageFit: BoxFit.contain,
          requestHeaders: {
            'post-id': data.postID ?? '',
            'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
            'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
          },
        ),
      );
    }
    if (data.mediaType?.translateType() == ContentType.video) {
      String urlApsara = '';
      if (data.isApsara!) {
        await getVideoApsara(context, data.apsaraId!).then((value) {
          urlApsara = value;
        });
      }
      _result.add(
        StoryItem.pageVideo(
          urlApsara != '' ? urlApsara : data.fullContentPath ?? '',
          controller: storyController,
          requestHeaders: {
            'post-id': data.postID ?? '',
            'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
            'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
          },
          duration: Duration(seconds: data.metadata?.duration ?? 15),
        ),
      );
    }
    notifyListeners();
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

  void navigateToOtherProfile(BuildContext context, ContentData data, StoryController storyController) {
    Provider.of<OtherProfileNotifier>(context, listen: false).userEmail = data.email!;
    storyController.pause();
    _routing.move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: data.email)).whenComplete(() => storyController.play());
  }

  void initState(BuildContext context, StoryDetailScreenArgument routeArgument) {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index;

    if (_routeArgument?.postID != null) {
      _initialStory(context);
    } else {
      _dataUserStories = _routeArgument?.storyData ?? [];
      notifyListeners();
    }
  }

  Future<void> _initialStory(
    BuildContext context,
  ) async {
    Future<List<ContentData>> _resFuture;

    myContentsQuery.postID = _routeArgument?.postID;
    myContentsQuery.onlyMyData = false;

    try {
      print('test13');
      _resFuture = myContentsQuery.reload(context);

      final res = await _resFuture;
      _dataUserStories = res;
      notifyListeners();
      _followUser(context);
    } catch (e) {
      'load story: ERROR: $e'.logger();
    }
  }

  void showMyReaction(
    BuildContext context,
    ContentData? data,
    StoryController storyController,
    AnimationController? animationController,
  ) async {
    storyController.pause();
    // _system.actionReqiredIdCard(
    //   context,
    //   action: () async {
    checkIfKeyboardIsFocus(context);
    Reaction? _data;
    _data = Provider.of<MainNotifier>(context, listen: false).reactionData;

    if (_data == null) {
      var _popupDialog = _system.createPopupDialog(
        Container(
          alignment: Alignment.center,
          color: const Color(0xff1D2124).withOpacity(0.8),
          child: const UnconstrainedBox(child: CustomLoading()),
        ),
      );
      Overlay.of(context)!.insert(_popupDialog);
      await context.read<MainNotifier>().getReaction(context).whenComplete(() {
        _data = context.read<MainNotifier>().reactionData;
        _popupDialog.remove();
      });
    }

    // flag reaction action
    _isReactAction = true;

    if (_data != null) {
      storyController.pause();
      showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ShowReactionsIcon(
              onTap: () => _routing.moveBack(),
              crossAxisCount: 3,
              data: _data!.data,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    reaction = _data?.data[index].icon;
                    _routing.moveBack();
                    makeItems(animationController!);
                    Future.delayed(const Duration(seconds: 3), () => fadeReaction = true);
                    Future.delayed(const Duration(seconds: 7), () => fadeReaction = false);
                    try {
                      await sendMessageReaction(
                        context,
                        contentData: data,
                        reaction: _data?.data[index],
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: CustomTextWidget(
                      textToDisplay: _data!.data[index].icon!,
                      textStyle: Theme.of(context).textTheme.headline4!.apply(color: null),
                    ),
                  ),
                );
              });
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);

          return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
        },
      ).whenComplete(() => Future.delayed(const Duration(seconds: 6), () => isReactAction = false));
    }
    //   },
    //   uploadContentAction: false,
    // );
  }

  Future<void> createdDynamicLink(
    context,
    ContentData? data, {
    StoryController? storyController,
  }) async {
    _isShareAction = true;
    storyController?.pause();

    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.storyDetail,
        postID: data?.postID,
        fullName: data?.username,
        description: 'Hyppe Story',
        thumb: '${data?.fullThumbPath}',
      ),
      copiedToClipboard: false,
    ).whenComplete(() => _isShareAction = false);
  }

  void sendMessage(BuildContext context, ContentData? data) async {
    // _system.actionReqiredIdCard(
    //   context,
    //   action: () async {
    if (_textEditingController.text.isNotEmpty) {
      try {
        textEditingController.text.logger();

        final param = DiscussArgument(
          receiverParty: data?.email ?? '',
          email: _sharedPrefs.readStorage(SpKeys.email),
        )
          ..postID = data?.postID ?? ''
          ..txtMessages = textEditingController.text;

        final notifier = MessageBlocV2();
        await notifier.createDiscussionBloc(context, disqusArgument: param).then((value) {
          'Your message was sent'.logger();
        });
      } finally {
        _textEditingController.clear();
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          _forceStop = false;
        }
      }
    }
    //   },
    //   uploadContentAction: false,
    // );
  }

  String onProfilePicShow(String? urlPic) => _system.showUserPicture(urlPic) ?? '';

  List<Widget> buildItems(AnimationController? animationController) {
    return items.map((item) {
      var tween = Tween<Offset>(
        begin: Offset(0, Random().nextDouble() * 1 + 1),
        end: Offset(Random().nextDouble() * 0.5, -2),
      ).chain(CurveTween(curve: Curves.linear));
      return SlideTransition(
        position: animationController!.drive(tween),
        child: AnimatedAlign(
          alignment: item.alignment,
          duration: const Duration(seconds: 10),
          child: AnimatedOpacity(
            opacity: fadeReaction ? 0.0 : 1.0,
            duration: const Duration(seconds: 1),
            child: Material(
              color: Colors.transparent,
              child: Text(
                reaction!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: item.size),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future sendMessageReaction(
    BuildContext context, {
    ContentData? contentData,
    ReactionInteractive? reaction,
  }) async {
    try {
      reaction?.url.logger();
      contentData?.postID.logger();

      final notifier = ReactionBloc();
      await notifier.addPostReactionBlocV2(
        context,
        argument: PostReactionArgument(
          eventType: 'REACTION',
          reactionUri: reaction?.url ?? '',
          postID: contentData?.postID ?? '',
          receiverParty: contentData?.email ?? '',
        ),
      );
    } catch (e) {
      e.toString().logger();
    }
  }

  void onCloseStory(bool mounted) {
    if (mounted) {
      _textEditingController.clear();
      if (_routeArgument?.postID != null) {
        _routing.moveAndPop(Routes.lobby);
      } else {
        _routing.moveBack();
      }
    }
  }

  bool isUserLoggedIn(String? email) => _sharedPrefs.readStorage(SpKeys.email) == email;

  Future _followUser(BuildContext context) async {
    if (_sharedPrefs.readStorage(SpKeys.email) != _dataUserStories.single.email) {
      try {
        final notifier = FollowBloc();
        await notifier.followUserBlocV2(
          context,
          data: FollowUserArgument(
            eventType: InteractiveEventType.following,
            receiverParty: _dataUserStories.single.email ?? '',
          ),
        );
        final fetch = notifier.followFetch;
        if (fetch.followState == FollowState.followUserSuccess) {
          'follow user success'.logger();
        } else {
          'follow user failed'.logger();
        }
      } catch (e) {
        'follow user: ERROR: $e'.logger();
      }
    }
  }

  void reportContent(BuildContext context, {StoryController? storyController}) {
    storyController?.pause();
    ShowBottomSheet.onReportContent(context);
  }
}


// void onCloseStory(BuildContext context, Map? arguments) {
  //   // final notifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
  //   // Story? _model;
  //   // List<StoryData> viewedStories = [];

  //   // validate story
  //   if (userID == null) {
  //     // get viewed stories data
  //     // viewedStories = notifier.peopleStoriesData!.data.where((e1) => !e1.story.map((e2) => e2.isView).contains(0)).toList();

  //     // delete viewed stories data
  //     // notifier.peopleStoriesData!.data.removeWhere((e1) => !e1.story.map((e2) => e2.isView).contains(0));

  //     // check if any viewed stories data, and then insert to peopleStoriesData object
  //     // if (viewedStories.isNotEmpty) notifier.peopleStoriesData!.data.insertAll(notifier.peopleStoriesData!.data.length, viewedStories);

  //     // _model = notifier.peopleStoriesData;
  //     // notifier.peopleStoriesData = Story();
  //     _textEditingController.clear();
  //     // notifyListeners();
  //   }
  //   // if (arguments != null && !arguments.containsKey('isSearch')) {
  //   //   Routing().moveAndPop(lobby);
  //   // } else {
  //   //   Routing().moveBack();
  //   // }
  //   _routing.moveBack();
  //   // if (userID == null) _socketService.closeSocket();
  //   // Timer(Duration(milliseconds: 50), () {
  //   //   if (userID == null) {
  //   //     notifier.peopleStoriesData = _model;
  //   //     notifyListeners();
  //   //   }
  //   //   Timer(Duration(milliseconds: 50), () {
  //   //     // _storyItems.clear();
  //   //     _items.clear();
  //   //   });
  //   // });

  //   // context.read<PreviewVidNotifier>().forcePause = false;
  // }