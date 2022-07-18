import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/google_map_place/bloc.dart';
import 'package:hyppe/core/bloc/google_map_place/state.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/google_map_place/model_google_map_place.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/interest/interest_data.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/models/collection/utils/user/user_data.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/arguments/progress_upload_argument.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:hyppe/core/extension/log_extension.dart';

class PreUploadContentNotifier with ChangeNotifier {
  final _eventService = EventService();
  final _socketService = SocketService();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingLoadMore = false;
  bool get isLoadingLoadMore => _isLoadingLoadMore;

  ModelGoogleMapPlace? _modelGoogleMapPlace;
  ModelGoogleMapPlace? get modelGoogleMapPlace => _modelGoogleMapPlace;
  List<SearchPeolpleData> _searchPeolpleData = [];
  List<SearchPeolpleData> get searchPeolpleData => _searchPeolpleData;

  TextEditingController _captionController = TextEditingController();
  TextEditingController _location = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  String _privacyTitle = 'Public';
  String privacyValue = 'PUBLIC';
  String _locationName = 'Add Location';
  bool _updateContent = false;
  FeatureType? _featureType;
  List<String?>? _fileContent;
  String _selectedLocation = '';
  bool _allowComment = true;
  bool _certified = false;
  bool _certifiedTmp = false;
  dynamic _uploadSuccess;
  List<String>? _tags;
  String _visibility = "PUBLIC";
  dynamic _thumbNail;
  List<String> _interestData = [];
  List<InterestData> _interest = [];
  List<InterestData> _interestList = [];
  List<UserData> _userList = [];
  List<String> _userTagData = [];
  int _startSearch = 0;

  TextEditingController get captionController => _captionController;
  TextEditingController get location => _location;

  String get privacyTitle => _privacyTitle;
  bool get updateContent => _updateContent;
  FeatureType? get featureType => _featureType;
  List<String?>? get fileContent => _fileContent;
  String get selectedLocation => _selectedLocation;
  bool get allowComment => _allowComment;
  bool get certified => _certified;
  bool get certifiedTmp => _certifiedTmp;
  List<String>? get tags => _tags;
  String get visibility => _visibility;
  dynamic get thumbNail => _thumbNail;
  List<InterestData> get interest => _interest;
  List<InterestData> get interestList => _interestList;
  List<UserData> get userList => _userList;
  List<String> get userTagData => _userTagData;
  String get locationName => _locationName;
  List<String> get interestData => _interestData;
  int get startSearch => _startSearch;

  set interestData(List<String> val) {
    _interestData = [];
    notifyListeners();
  }

  set locationName(String val) {
    _locationName = val;
    notifyListeners();
  }

  set captionController(TextEditingController val) {
    _captionController = val;
    notifyListeners();
  }

  set location(TextEditingController val) {
    _location = val;
    notifyListeners();
  }

  set userTagData(List<String> val) {
    _userTagData = val;
    notifyListeners();
  }

  set privacyTitle(String val) {
    _privacyTitle = val;
    notifyListeners();
  }

  set thumbNail(val) {
    _thumbNail = val;
    notifyListeners();
  }

  set tags(List<String>? val) {
    _tags = val;
    notifyListeners();
  }

  set visibility(String val) {
    _visibility = val;
    notifyListeners();
  }

  set updateContent(bool val) {
    _updateContent = val;
    notifyListeners();
  }

  set allowComment(bool val) {
    _allowComment = val;
    notifyListeners();
  }

  set certified(bool val) {
    _certified = val;
    notifyListeners();
  }

  set certifiedTmp(bool val) {
    _certifiedTmp = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set isLoadingLoadMore(bool val) {
    _isLoadingLoadMore = val;
    notifyListeners();
  }

  set selectedLocation(String val) {
    _selectedLocation = val;
    notifyListeners();
  }

  set featureType(FeatureType? val) {
    _featureType = val;
    notifyListeners();
  }

  set fileContent(List<String?>? val) {
    _fileContent = val;
    notifyListeners();
  }

  set startSearch(int val) {
    _startSearch = val;
    notifyListeners();
  }

  set modelGoogleMapPlace(val) {
    _modelGoogleMapPlace = val;
    notifyListeners();
  }

  set searchPeolpleData(List<SearchPeolpleData> val) {
    _searchPeolpleData = val;
    notifyListeners();
  }

  void onWillPop(BuildContext context) async {
    print('exitjuga');
    ShowBottomSheet.onShowCancelPost(context, onCancel: () => _onExit());
  }

  void handleTapOnLocation(String value) => selectedLocation = value;

  void handleDeleteOnLocation() => selectedLocation = '';

  bool _validateDescription() => captionController.text.length >= 5;

  void checkKeyboardFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _connectAndListenToSocket(BuildContext context) async {
    final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);
    if (_socketService.isRunning) _socketService.closeSocket();
    _socketService.connectToSocket(
      () {
        _socketService.events(SocketService.eventNotif, (result) {
          '$result'.logger();
          homeNotifier.onRefresh(context);
          // homeNotifier.isHaveSomethingNew = true;
          _socketService.closeSocket();
        });
      },
      host: Env.data.baseUrl,
      options: OptionBuilder()
          .setAuth({
            "x-auth-user": "$email",
            "x-auth-token": "$token",
          })
          .setTransports(
            ['websocket'],
          )
          .disableAutoConnect()
          .build(),
    );
  }

  void _onExit() {
    print('ini exit');
    selectedLocation = '';
    allowComment = true;
    certified = false;
    captionController.clear();
    tagsController.clear();
    _selectedLocation = '';
    _interestData = [];
    _locationName = 'Add Location';
    _interestList = [];
    _userTagData = [];
    _privacyTitle = 'Public';
    privacyValue = 'PUBLIC';
    interestData = [];
  }

  Future _createPostContentV2() async {
    final BuildContext context = Routing.navigatorKey.currentContext!;
    final _orientation = context.read<CameraNotifier>().orientation;
    certifiedTmp = _certified;

    try {
      _connectAndListenToSocket(context);
      final notifier = PostsBloc();
      notifier.postContentsBlocV2(
        context,
        type: featureType!,
        visibility: privacyValue,
        tags: tagsController.text,
        allowComment: allowComment,
        certified: certified,
        fileContents: fileContent!,
        description: captionController.text,
        cats: _interestData,
        tagPeople: userTagData,
        rotate: _orientation ?? NativeDeviceOrientation.portraitUp,
        location: locationName == 'Add Location' ? '' : locationName,
        onReceiveProgress: (count, total) {
          _eventService.notifyUploadReceiveProgress(ProgressUploadArgument(count: count, total: total));
        },
        onSendProgress: (received, total) {
          _eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received, total: total));
        },
      ).then((value) {
        _uploadSuccess = value;
        'Create post content with value $value'.logger();
        // _eventService.notifyUploadFinishingUp(_uploadSuccess);
        _eventService.notifyUploadSuccess(_uploadSuccess);
      });
      clearUpAndBackToHome(context);
    } catch (e) {
      _eventService.notifyUploadFailed(
        DioError(
          requestOptions: RequestOptions(
            path: UrlConstants.createuserposts,
          ),
          error: e,
        ),
      );
      'e'.logger();
    } finally {
      _onExit();
    }
  }

  Future _updatePostContentV2(BuildContext context, {required String postID, required String content}) async {
    updateContent = true;
    certifiedTmp = false;

    final notifier = PostsBloc();
    await notifier.updateContentBlocV2(
      context,
      postId: postID,
      type: featureType!,
      visibility: visibility,
      tags: tagsController.text,
      allowComment: allowComment,
      certified: certified,
      description: captionController.text,
      cats: _interestData,
      tagPeople: userTagData,
      location: locationName == 'Add Location' ? '' : locationName,
    );
    final fetch = notifier.postsFetch;
    if (fetch.postsState == PostsState.updateContentsSuccess) {
      context.read<SelfProfileNotifier>().onUpdateSelfPostContent(
            context,
            postID: postID,
            content: content,
            visibility: visibility,
            allowComment: allowComment,
            certified: certified,
            description: captionController.text,
            tags: tagsController.text.split(','),
          );

      context.read<HomeNotifier>().onUpdateSelfPostContent(
            context,
            postID: postID,
            content: content,
            visibility: visibility,
            allowComment: allowComment,
            certified: certified,
            description: captionController.text,
            tags: tagsController.text.split(','),
          );

      updateContent = false;
      Routing().moveBack();
      _showSnackBar(
        color: kHyppeTextSuccess,
        message: "${language.update} $content ${language.successfully}",
      );
      _onExit();
    }
  }

  void _showSnackBar({
    String? icon,
    required Color color,
    required String message,
  }) {
    Routing().showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              fromSnackBar: true,
              iconSvg: icon != null ? "${AssetPath.vectorPath}$icon" : null,
            ),
          ),
        ),
      ),
    );
  }

  void clearUpAndBackToHome(BuildContext context) {
    context.read<PreviewContentNotifier>().clearAdditionalItem();

    context.read<CameraNotifier>().orientation = null;
    context.read<PreviewContentNotifier>().isForcePaused = false;
    Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
  }

  Future<void> onClickPost(BuildContext context, {required bool onEdit, ContentData? data, String? content}) async {
    checkKeyboardFocus(context);
    final connection = await System().checkConnections();
    if (_validateDescription()) {
      if (connection) {
        checkKeyboardFocus(context);
        if (onEdit) {
          _updatePostContentV2(
            context,
            postID: data!.postID!,
            content: content!,
          );
        } else {
          _createPostContentV2();
        }
      } else {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          onClickPost(context, onEdit: onEdit, data: data, content: content);
        });
      }
    } else {
      ShowBottomSheet().onShowColouredSheet(
        context,
        language.descriptionCanOnlyWithMin5Characters!,
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
    }
  }

  Future<Uint8List?> makeThumbnail() async {
    Uint8List? _thumbnails = await VideoThumbnail.thumbnailData(
      video: fileContent![0]!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return _thumbnails;
  }

  validateIdCard() async {
    _onExit();
    final BuildContext context = Routing.navigatorKey.currentContext!;
    Provider.of<MainNotifier>(context, listen: false).openValidationIDCamera = true;
    notifyListeners();
    clearUpAndBackToHome(context);
  }

  void onClickPrivacyPost(BuildContext context) {
    ShowBottomSheet.onShowOptionPrivacyPost(
      context,
      onSave: () {
        Routing().moveBack();
        Provider.of<PreUploadContentNotifier>(context, listen: false)._privacyTitle = _privacyTitle;
        notifyListeners();
      },
      onCancel: () {
        Routing().moveBack();
        FocusScope.of(context).unfocus();
        checkKeyboardFocus(context);
      },
      onChange: (value) {
        _privacyTitle = value;
        final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);
        if (_isoCodeCache == 'id') {
          switch (value) {
            case 'Umum':
              privacyValue = 'PUBLIC';
              break;
            case 'Teman':
              privacyValue = 'FRIEND';
              break;
            case 'Hanya saya':
              privacyValue = 'PRIVATE';
              break;
            default:
          }
        } else {
          privacyValue = value;
        }
        // Routing().moveBack();
        checkKeyboardFocus(context);
        notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  void showLocation(BuildContext context) {
    ShowBottomSheet.onShowLocation(
      context,
      onSave: () {
        Routing().moveBack();
        Provider.of<PreUploadContentNotifier>(context, listen: false)._privacyTitle = _privacyTitle;
        notifyListeners();
      },
      onCancel: () {
        Routing().moveBack();
        FocusScope.of(context).unfocus();
      },
      onChange: (value) {
        Routing().moveBack();
        notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  void showInterest(BuildContext context) {
    ShowBottomSheet.onShowInteresList(
      context,
      onSave: () {
        Routing().moveBack();
        notifyListeners();
      },
      onCancel: () {
        Routing().moveBack();
        FocusScope.of(context).unfocus();
      },
      onChange: (value) {
        notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  void showPeopleSearch(BuildContext context) {
    ShowBottomSheet.onShowSearchPeople(
      context,
      onSave: () {
        Routing().moveBack();
        notifyListeners();
      },
      onCancel: () {
        Routing().moveBack();
        FocusScope.of(context).unfocus();
      },
      onChange: (value) {
        _startSearch = 0;
        searchPeople(context, input: value);
        notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  Future onGetInterest(BuildContext context) async {
    final notifier = UtilsBlocV2();
    await notifier.getInterestBloc(context);
    final fetch = notifier.utilsFetch;

    final Map<String, dynamic> seeMore = {"langIso": "alice", "cts": '2021-12-16 12:45:36', "icon": 'https://prod.hyppe.app/images/icon_interest/music.svg', 'interestName': 'See More'};
    if (fetch.utilsState == UtilsState.getInterestsSuccess) {
      _interest = [];
      fetch.data.forEach((v) {
        if (_interest.length <= 5) {
          _interest.add(InterestData.fromJson(v));
        }
        if (_interest.length == 6) {
          _interest.add(InterestData.fromJson(seeMore));
        }
        _interestList.add(InterestData.fromJson(v));
        _interestList.sort((a, b) {
          return a.interestName!.compareTo(b.interestName!);
        });
      });

      notifyListeners();
    }
    if (fetch.utilsState == UtilsState.getInterestsError) {
      ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
        // _routing.moveBack();
      }, backButton: () {
        // _routing.moveBack();
      });
    }
  }

  bool pickedInterest(String? tile) => _interestData.contains(tile) ? true : false;
  void insertInterest(BuildContext context, int index) {
    if (interest.isNotEmpty) {
      String tile = interest[index].interestName!;
      print(tile);
      if (tile == 'See More') {
        showInterest(context);
      } else {
        if (_interestData.contains(tile)) {
          _interestData.removeWhere((v) => v == tile);
        } else {
          _interestData.add(tile);
        }
        notifyListeners();
      }
    } else {
      return null;
    }
  }

  void insertInterestList(BuildContext context, int index) {
    if (interestList.isNotEmpty) {
      String tile = interestList[index].interestName!;
      if (tile == 'See More') {
        showLocation(context);
      } else {
        if (_interestData.contains(tile)) {
          _interestData.removeWhere((v) => v == tile);
        } else {
          _interestData.add(tile);
        }
        notifyListeners();
      }
    } else {
      return null;
    }
  }

  Future inserTagPeople(int index) async {
    if (_searchPeolpleData.isNotEmpty) {
      String tile = searchPeolpleData[index].username!;
      if (_userTagData.contains(tile)) {
        _showSnackBar(
          icon: "info-icon.svg",
          color: kHyppeDanger,
          message: "User sudah ditag",
        );
      } else {
        _userTagData.add(tile);
        notifyListeners();

        Routing().moveBack();
      }
      notifyListeners();
    } else {
      return false;
    }
  }

  void removeTagPeople(index) {
    if (_userTagData.isNotEmpty) {
      String tile = _userTagData[index];
      _userTagData.removeWhere((v) => v == tile);
      notifyListeners();
    }
  }

  Future searchLocation(BuildContext context, {input}) async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    final _language = SharedPreference().readStorage(SpKeys.isoCode);
    updateContent = true;
    certifiedTmp = false;

    final notifier = GoogleMapPlaceBloc();
    await notifier.getGoogleMapPlaceBloc(
      context,
      keyword: input,
      language: _language,
      sessiontoken: token,
    );
    final fetch = notifier.googleMapPlaceFetch;
    if (fetch.googleMapPlaceState == GoogleMapPlaceState.getGoogleMapPlaceBlocSuccess) {
      modelGoogleMapPlace = ModelGoogleMapPlace.fromJson(fetch.data);
    }
  }

  Future searchPeople(BuildContext context, {input}) async {
    final notifier = UtilsBlocV2();
    if (input.length > 2) {
      if (_startSearch == 0) {
        _searchPeolpleData = [];
        _isLoading = true;
      }
      await notifier.getSearchPeopleBloc(context, input, _startSearch * 10, 10);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.searchPeopleSuccess) {
        fetch.data.forEach((v) {
          _searchPeolpleData.add(SearchPeolpleData.fromJson(v));
        });
        print('_searchPeolpleData000');
        print(_searchPeolpleData);
        notifyListeners();
      }
      _isLoading = false;
      isLoadingLoadMore = false;
    }
  }

  Future scrollListPeopleListener(BuildContext context, ScrollController scrollController, input) async {
    if (input.length > 2) {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        isLoadingLoadMore = true;
        _startSearch++;
        searchPeople(context, input: input);
        notifyListeners();
      }
    }
  }
}
