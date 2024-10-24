import 'dart:convert';
import 'dart:math';
import 'package:hyppe/app.dart';
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
import 'package:hyppe/core/constants/utils.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/music/music.dart';

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

import '../../../../../../core/arguments/main_argument.dart';
// import 'package:story_view/story_view.dart';

class StoriesPlaylistNotifier with ChangeNotifier, GeneralMixin {
  ContentsDataQuery myContentsQuery = ContentsDataQuery()
    ..page = 2
    ..limit = 5
    ..onlyMyData = true
    ..featureType = FeatureType.story;

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..page = 0
    ..limit = 5
    ..featureType = FeatureType.story;

  final _sharedPrefs = SharedPreference();
  final _system = System();
  final _routing = Routing();

  StoryDetailScreenArgument? _routeArgument;
  bool _isReactAction = false;
  // bool _fadeReaction = false;
  String? _reaction;
  List<Item> _items = <Item>[];
  // List<StoryItem> _result = [];
  // List<StoryItem> get result => _result;

  int _currentStory = 0;
  int _storyParentIndex = 0;
  bool _isShareAction = false;
  bool _isKeyboardActive = false;
  bool _linkCopied = false;
  bool _forceStop = false;
  bool _isLoadMusic = true;
  MusicUrl? _urlMusic;
  double? _currentPage = 0;
  Timer? _searchOnStoppedTyping;
  Color? _sendButtonColor;
  PageController? _pageController = PageController(initialPage: 0);
  List<ContentData> _dataUserStories = [];
  List<StoriesGroup> _groupUserStories = [];
  final TextEditingController _textEditingController = TextEditingController();

  bool get isReactAction => _isReactAction;
  // bool get fadeReaction => _fadeReaction;
  String? get reaction => _reaction;
  List<Item> get items => _items;

  int get currentStory => _currentStory;
  int get storyParentIndex => _storyParentIndex;
  bool get isShareAction => _isShareAction;
  bool get isKeyboardActive => _isKeyboardActive;
  bool get linkCopied => _linkCopied;
  bool get forceStop => _forceStop;
  bool get isLoadMusic => _isLoadMusic;
  MusicUrl? get urlMusic => _urlMusic;
  double? get currentPage => _currentPage;
  Color? get buttonColor => _sendButtonColor;
  PageController? get pageController => _pageController;
  List<ContentData> get dataUserStories => _dataUserStories;
  List<StoriesGroup> get groupUserStories => _groupUserStories;
  TextEditingController get textEditingController => _textEditingController;

  int _currentIndex = -1;
  int get currentIndex => _currentIndex;
  int _pageIndex = -1;
  int get pageIndex => _pageIndex;
  bool _hitApiMusic = false;
  bool get hitApiMusic => _hitApiMusic;

  List<Future<void>> emojiActions = [];

  // set result(List<StoryItem> val) {
  //   _result = val;
  //   notifyListeners();
  // }

  set reaction(String? val) {
    _reaction = val;
    notifyListeners();
  }

  // set fadeReaction(bool newValue) {
  //   _fadeReaction = newValue;
  //   notifyListeners();
  // }

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

  set isLoadMusic(bool state) {
    _isLoadMusic = state;
  }

  set urlMusic(MusicUrl? val) {
    _urlMusic = val;
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

  set groupUserStories(List<StoriesGroup> maps) {
    _groupUserStories = maps;
    notifyListeners();
  }

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set pageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  set hitApiMusic(bool state) {
    _hitApiMusic = state;
    notifyListeners();
  }

  setCurrentStory(int val) => _currentStory = val;

  set isShareAction(bool val) {
    _isShareAction = val;
    notifyListeners();
  }

  bool _isPreventedEmoji = false;
  bool get isPreventedEmoji => _isPreventedEmoji;
  set isPreventedEmoji(bool state) {
    _isPreventedEmoji = state;
    notifyListeners();
  }

  setIsPreventedEmoji(bool state) {
    _isPreventedEmoji = state;
  }

  setIsKeyboardActive(bool val) => _isKeyboardActive = val;

  nextPage() {
    if (_pageController?.page == dataUserStories.length - 1) {
      return;
    }
    _pageController?.nextPage(
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  degreeToRadian(double deg) {
    return deg * pi / 180;
  }

  initialCurrentPage(double? page) {
    _currentPage = page;
    notifyListeners();
  }

  setViewed(int index, int indexItem) {
    if (groupUserStories.isNotEmpty) {
      groupUserStories[index].story?[indexItem].isViewed = true;
    }
    notifyListeners();
  }

  void onUpdate() => notifyListeners();

  onChangeHandler(BuildContext context, String value) {
    print(value);
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

  void makeItems(AnimationController animationController, ContentData? data,
      ReactionInteractive? reaction) {
    items.clear();
    for (int i = 0; i < 100; i++) {
      items.add(Item());
      // notifyListeners();
    }

    print("ini print $items");

    // notifyListeners();
    animationController.reset();
    animationController.forward().whenComplete(() {});
  }

  Future<MusicUrl?> getMusicApsara(
      BuildContext context, String apsaraId) async {
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

  // Future initializeUserStories(BuildContext context, StoryController storyController, List<ContentData> stories) async {
  //   _result = [];
  //   for (final story in stories) {
  //     if (story.mediaType?.translateType() == ContentType.image) {
  //       if (story.music?.apsaraMusic != null) {
  //         story.music?.apsaraMusicUrl = await getMusicApsara(context, story.music!.apsaraMusic!);
  //         final duration = story.music?.apsaraMusicUrl?.duration?.toInt();
  //         _result.add(
  //           StoryItem.pageImage(
  //             url: (story.isApsara ?? false) ? (story.media?.imageInfo?[0].url ?? (story.mediaEndpoint ?? '')) : story.fullThumbPath ?? '',
  //             controller: storyController,
  //             imageFit: BoxFit.contain,
  //             isImages: true,
  //             id: story.postID ?? ' ',
  //             duration: Duration(seconds: (duration ?? 3) > 5 ? 5 : 3),
  //             requestHeaders: {
  //               'post-id': story.postID ?? '',
  //               'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //               'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //             },
  //           ),
  //         );
  //       } else {
  //         _result.add(
  //           StoryItem.pageImage(
  //             url: (story.isApsara ?? false) ? (story.media?.imageInfo?[0].url ?? (story.mediaEndpoint ?? '')) : story.fullThumbPath ?? '',
  //             controller: storyController,
  //             imageFit: BoxFit.contain,
  //             isImages: true,
  //             id: story.postID ?? '',
  //             requestHeaders: {
  //               'post-id': story.postID ?? '',
  //               'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //               'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //             },
  //           ),
  //         );
  //       }
  //     }
  //     if (story.mediaType?.translateType() == ContentType.video) {
  //       String urlApsara = '';
  //       if (story.isApsara ?? false) {
  //         await getVideoApsara(context, story.apsaraId ?? '').then((value) {
  //           urlApsara = value;
  //         });
  //       }
  //       Size? videoSize;
  //       final width = story.metadata?.width?.toDouble();
  //       final height = story.metadata?.height?.toDouble();
  //       if (width != null && height != null) {
  //         videoSize = Size(width, height);
  //         videoSize = videoSize.getFixSize(context);
  //       }
  //       print('StoryItem.pageVideo ${story.postID} : $urlApsara, ${story.fullContentPath}, ${story.metadata?.duration}');
  //       _result.add(
  //         StoryItem.pageVideo(
  //           urlApsara != '' ? urlApsara : story.fullContentPath ?? '',
  //           controller: storyController,
  //           id: story.postID ?? '',
  //           size: videoSize,
  //           requestHeaders: {
  //             'post-id': story.postID ?? '',
  //             'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //             'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //           },
  //           duration: Duration(seconds: story.metadata?.duration ?? 15),
  //         ),
  //       );
  //     }
  //   }
  //
  //   notifyListeners();
  // }

  // List<StoryItem> initializeData(BuildContext context, StoryController storyController, ContentData data) {
  // Future initializeData(BuildContext context, StoryController storyController, ContentData data) async {
  //   // List<StoryItem> _result = [];
  //   print('pageImage ${data.postID} : ${data.isApsara}, ${data.mediaEndpoint}, ${data.fullThumbPath}');
  //   _result = [];
  //   if (data.mediaType?.translateType() == ContentType.image) {
  //     if (data.music?.apsaraMusic != null) {
  //       data.music?.apsaraMusicUrl = await getMusicApsara(context, data.music!.apsaraMusic!);
  //       final duration = data.music?.apsaraMusicUrl?.duration?.toInt();
  //       _result.add(
  //         StoryItem.pageImage(
  //           url: (data.isApsara ?? false) ? (data.media?.imageInfo?[0].url ?? (data.mediaEndpoint ?? '')) : data.fullThumbPath ?? '',
  //           controller: storyController,
  //           imageFit: BoxFit.contain,
  //           isImages: true,
  //           id: data.postID ?? '',
  //           duration: Duration(seconds: (duration ?? 3) > 5 ? 5 : 3),
  //           requestHeaders: {
  //             'post-id': data.postID ?? '',
  //             'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //             'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //           },
  //         ),
  //       );
  //     } else {
  //       _result.add(
  //         StoryItem.pageImage(
  //           url: (data.isApsara ?? false) ? (data.media?.imageInfo?[0].url ?? (data.mediaEndpoint ?? '')) : data.fullThumbPath ?? '',
  //           controller: storyController,
  //           imageFit: BoxFit.contain,
  //           isImages: true,
  //           id: data.postID ?? '',
  //           requestHeaders: {
  //             'post-id': data.postID ?? '',
  //             'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //             'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //           },
  //         ),
  //       );
  //     }
  //   }
  //   if (data.mediaType?.translateType() == ContentType.video) {
  //     String urlApsara = '';
  //     if (data.isApsara ?? false) {
  //       await getVideoApsara(context, data.apsaraId ?? '').then((value) {
  //         urlApsara = value;
  //       });
  //     }
  //     Size? videoSize;
  //     final width = data.metadata?.width?.toDouble();
  //     final height = data.metadata?.height?.toDouble();
  //     if (width != null && height != null) {
  //       videoSize = Size(width, height);
  //       videoSize = videoSize.getFixSize(context);
  //     }
  //     print('StoryItem.pageVideo ${data.postID} : $urlApsara, ${data.fullContentPath}, ${data.metadata?.duration}');
  //     _result.add(
  //       StoryItem.pageVideo(
  //         urlApsara != '' ? urlApsara : data.fullContentPath ?? '',
  //         controller: storyController,
  //         id: data.postID ?? '',
  //         requestHeaders: {
  //           'post-id': data.postID ?? '',
  //           'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
  //           'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
  //         },
  //         size: videoSize,
  //         duration: Duration(seconds: data.metadata?.duration ?? 15),
  //       ),
  //     );
  //   }
  //   notifyListeners();
  // }

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

  void navigateToOtherProfile(BuildContext context, ContentData data) {
    Provider.of<OtherProfileNotifier>(context, listen: false).userEmail =
        data.email;
    _routing.move(Routes.otherProfile,
        argument: OtherProfileArgument(senderEmail: data.email));
  }

  void initState(
      BuildContext context, StoryDetailScreenArgument routeArgument) {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index;

    if (_routeArgument?.postID != null) {
      _initialStory(context);
    } else {
      _dataUserStories = _routeArgument?.storyData ?? [];
      notifyListeners();
    }
  }

  Future initialStoryId(BuildContext context, String postID) async {
    contentsQuery.postID = postID;

    try {
      // final String myEmail = SharedPreference().readStorage(SpKeys.email);
      final res = await contentsQuery.reload(context);
      var data = res.firstOrNull;
      if (data != null) {
        List<ContentData>? story = [];
        story.add(data);
        var storys = StoriesGroup(
            email: data.email, username: data.username, story: story);
        List<StoriesGroup> groupUserStories = [];
        groupUserStories.add(storys);
        _groupUserStories = groupUserStories;
      } else {
        Routing().moveBack();
      }
    } catch (e) {
      'load vid: ERROR: $e'.logger();
    }
  }

  void initStateGroup(
      BuildContext context, StoryDetailScreenArgument routeArgument) {
    // final myEmail = _sharedPrefs.readStorage(SpKeys.email);
    _routeArgument = _routeArgument;
    String email = '';
    if (routeArgument.email == null) {
      email = SharedPreference().readStorage(SpKeys.email);
    } else {
      email = routeArgument.email ?? '';
    }

    _currentPage = routeArgument.peopleIndex.toDouble();
    _currentIndex = routeArgument.peopleIndex;
    final groups = routeArgument.groupStories;
    final myGroup = routeArgument.myStories;
    if (groups != null) {
      _groupUserStories = groups;
    } else if (myGroup != null) {
      _groupUserStories.add(StoriesGroup(
          email: myGroup[email]?[0].email,
          username: myGroup[email]?[0].username,
          story: myGroup[email]));
    }
  }

  Future<void> _initialStory(
    BuildContext context,
  ) async {
    Future<List<ContentData>> _resFuture;

    myContentsQuery.postID = _routeArgument?.postID;
    myContentsQuery.onlyMyData = false;

    try {
      print('reload contentsQuery : 12');
      _resFuture = myContentsQuery.reload(context);

      final res = await _resFuture;
      _dataUserStories = res;
      notifyListeners();
      final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
      if (!(isGuest ?? false)) {
        _followUser(context);
      }
    } catch (e) {
      'load story: ERROR: $e'.logger();
    }
  }

  Future<void> showMyReaction(
    BuildContext context,
    bool mounted,
    ContentData? data,
    // StoryController? storyController,
    AnimationController? animationController,
    final Function(bool)? selectedText,
    // Function play,
  ) async {
    print("ini data reaction ");
    // storyController?.pause();

    // _system.actionReqiredIdCard(
    //   context,
    //   action: () async {
    checkIfKeyboardIsFocus(context);
    Reaction? _data;

    _data = Provider.of<MainNotifier>(context, listen: false).reactionData;
    print("ini data reaction ${_data?.data[0].icon}");
    if (_data == null) {
      var _popupDialog = _system.createPopupDialog(
        Container(
          alignment: Alignment.center,
          color: const Color(0xff1D2124).withOpacity(0.8),
          child: const UnconstrainedBox(child: CustomLoading()),
        ),
      );
      Overlay.of(context).insert(_popupDialog);
      await context.read<MainNotifier>().getReaction(context).whenComplete(() {
        _data = context.read<MainNotifier>().reactionData;
        _popupDialog.remove();
      });
    }

    // flag reaction action
    _isReactAction = true;

    if (_data != null) {
      // storyController?.pause();
      if (!mounted) return;
      if (!loadReaction) {
        isPreventedEmoji = false;
        showGeneralDialog(
          barrierLabel: "Barrier",
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: const Duration(milliseconds: 500),
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            if (animationController != null) {
              return ShowReactionsIcon(
                  onTap: () {
                    _routing.moveBack();
                    selectedText!(false);
                  },
                  crossAxisCount: 3,
                  data: _data?.data ?? [],
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        reaction = _data?.data[index].icon;
                        _routing.moveBack();
                        // play(); //play story
                        selectedText!(false);
                        final emoji = _data?.data[index];
                        if (emoji != null) {
                          loadReaction = true;
                          // emojiActions.add(sendMessageReaction(
                          //   materialAppKey.currentContext!,
                          //   contentData: data,
                          //   reaction: _data?.data[index],
                          // ));
                          // final tempLength = emojiActions.length;
                          Future.delayed(const Duration(seconds: 3), () {
                            try {
                              sendMessageReaction(
                                materialAppKey.currentContext!,
                                contentData: data,
                                reaction: _data?.data[index],
                              );
                            } catch (e) {
                              e.logger();
                            }

                            // if(tempLength == emojiActions.length){
                            //   sendAllEmoji();
                            // }
                          });
                          makeItems(
                              animationController, data, _data?.data[index]);
                        }

                        // try {
                        //   sendMessageReaction(
                        //     materialAppKey.currentContext!,
                        //     contentData: data,
                        //     reaction: _data?.data[index],
                        //   );
                        // } catch (e) {
                        //   print(e);
                        // }

                        // Future.delayed(const Duration(seconds: 3), () => fadeReaction = true);
                        // Future.delayed(const Duration(seconds: 7), () => fadeReaction = false);
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: CustomTextWidget(
                          textToDisplay: _data?.data[index].icon ?? '',
                          textStyle: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.apply(color: null),
                        ),
                      ),
                    );
                  });
            } else {
              return Container();
            }
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            animation =
                CurvedAnimation(curve: Curves.elasticOut, parent: animation);

            return ScaleTransition(
                child: child, scale: animation, alignment: Alignment.center);
          },
        ).whenComplete(() => Future.delayed(const Duration(seconds: 3), () {
              isReactAction = false;
            }));
      }
    }
    //   },
    //   uploadContentAction: false,
    // );
  }

  Future sendAllEmoji() async {
    for (final emoji in emojiActions) {
      await emoji;
    }
  }

  Future<void> createdDynamicLink(
    context,
    ContentData? data,
  ) async {
    _isShareAction = true;

    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.showStories,
        postID: data?.postID,
        fullName: data?.username,
        description: 'Hyppe Story',
        thumb: '${data?.fullThumbPath}',
      ),
      copiedToClipboard: false,
    ).whenComplete(() => _isShareAction = false);
  }

  bool loadSend = false;

  void sendMessage(BuildContext context, ContentData? data) async {
    // _system.actionReqiredIdCard(
    //   context,
    //   action: () async {
    if (_textEditingController.text.isNotEmpty && !loadSend) {
      loadSend = true;
      notifyListeners();
      try {
        textEditingController.text.logger();

        final param = DiscussArgument(
          receiverParty: data?.email ?? '',
          email: _sharedPrefs.readStorage(SpKeys.email),
        )
          ..postID = data?.postID ?? ''
          ..txtMessages = textEditingController.text;

        final notifier = MessageBlocV2();
        await notifier
            .createDiscussionBloc(context, disqusArgument: param)
            .then((value) {
          'Your message was sent'.logger();
        });
      } finally {
        loadSend = false;
        notifyListeners();
        _textEditingController.clear();
        // Future.delayed(const Duration(milliseconds: 500), (){
        //   // FocusScopeNode currentFocus = FocusScope.of(context);
        //   if (!chatNode.hasPrimaryFocus) {
        //     chatNode.unfocus();
        //     _forceStop = false;
        //   }
        // });
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

  String onProfilePicShow(String? urlPic) =>
      _system.showUserPicture(urlPic) ?? '';

  List<Widget> buildItems(AnimationController animationController) {
    // print('isPreventedEmoji: $isPreventedEmoji');
    final animatedOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear));
    return items.map((item) {
      var tween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: const Offset(0, -1.7),
      ).chain(CurveTween(curve: Curves.linear));
      return SlideTransition(
        position: animationController.drive(tween),
        child: AnimatedAlign(
            alignment: item.alignment,
            duration: const Duration(seconds: 10),
            child: FadeTransition(
              opacity: animatedOpacity,
              child: Material(
                color: Colors.transparent,
                child: isPreventedEmoji
                    ? const SizedBox.shrink()
                    : Text(
                        reaction ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: item.size),
                      ),
              ),
            )),
      );
    }).toList();
    // return items.map((item) {
    //   // return Text(reaction ?? '');
    //   // var tween = Tween<Offset>(
    //   //   begin: Offset(0, Random().nextDouble() * 1 + 1),
    //   //   end: Offset(Random().nextDouble() * 0.5, -2),
    //   // ).chain(CurveTween(curve: Curves.linear));
    //   var tween = Tween<Offset>(
    //     begin: Offset(0, 0),
    //     end: Offset(0, -2),
    //   ).chain(CurveTween(curve: Curves.linear));
    //   return SlideTransition(
    //     position: animationController.drive(tween),
    //     child: AnimatedAlign(
    //       alignment: item.alignment,
    //       duration: const Duration(seconds: 10),
    //       child:
    //       AnimatedOpacity(
    //         opacity: fadeReaction ? 0.0 : 1.0,
    //         duration: const Duration(seconds: 2),
    //         child: Material(
    //           color: Colors.transparent,
    //           child: Text(
    //             reaction ?? '',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: item.size),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }).toList();
  }

  bool _loadReaction = false;
  bool get loadReaction => _loadReaction;
  set loadReaction(bool state) {
    _loadReaction = state;
    notifyListeners();
  }

  setLoadReaction(bool state) {
    _loadReaction = state;
  }

  Future sendMessageReaction(
    BuildContext context, {
    ContentData? contentData,
    ReactionInteractive? reaction,
  }) async {
    try {
      loadReaction = true;
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
          userView: contentData?.userView,
          userLike: contentData?.userLike,
          saleAmount: contentData?.saleAmount,
          createdAt: contentData?.createdAt,
          mediaSource: contentData?.mediaSource,
          description: contentData?.description,
          active: contentData?.active,
        ),
      );
      loadReaction = false;
    } catch (e) {
      loadReaction = false;
      e.toString().logger();
    }
  }

  bool _ableClose = true;
  void onCloseStory(BuildContext context, bool mounted, bool isFromProfile,
      bool isOther) async {
    if (mounted) {
      if (_ableClose) {
        _textEditingController.clear();
        if (isOther) {
          _routing.moveBack();
        } else if (_routeArgument?.postID != null) {
          print('onCloseStory moveAndPop ');
          await _routing.moveAndPop(Routes.lobby,
              argument:
                  MainArgument(canShowAds: false, page: isFromProfile ? 4 : 0));
        } else {
          print('onCloseStory moveBack');
          await Routing().moveAndRemoveUntil(Routes.lobby, Routes.root,
              argument:
                  MainArgument(canShowAds: false, page: isFromProfile ? 4 : 0));
        }
        _ableClose = false;
      }
      Future.delayed(const Duration(milliseconds: 700), () {
        _ableClose = true;
      });
    }
  }

  bool isUserLoggedIn(String? email) =>
      _sharedPrefs.readStorage(SpKeys.email) == email;

  Future _followUser(BuildContext context) async {
    if (_sharedPrefs.readStorage(SpKeys.email) !=
        _dataUserStories.single.email) {
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

  void reportContent(BuildContext context, ContentData data) {
    ShowBottomSheet()
        .onReportContent(context, postData: data, type: hyppeStory);
  }
}
