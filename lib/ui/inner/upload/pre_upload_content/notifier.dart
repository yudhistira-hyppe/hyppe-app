import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:hyppe/core/arguments/transaction_argument.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/google_map_place/bloc.dart';
import 'package:hyppe/core/bloc/google_map_place/state.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/google_map_place/model_google_map_place.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/music/music.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/boost_response.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/boost/boost_content_model.dart';
import 'package:hyppe/core/models/collection/utils/boost/boost_master_model.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/models/collection/utils/setting/setting.dart';
import 'package:hyppe/core/models/collection/utils/user/user_data.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path_provider/path_provider.dart' as path;

import '../../../../core/bloc/challange/bloc.dart';
import '../../../../core/bloc/challange/state.dart';
import '../../../../core/models/collection/search/search_content.dart';

class PreUploadContentNotifier with ChangeNotifier {
  final eventService = EventService();
  final socketService = SocketService();
  // UpdateContentsArgument? _arguments;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  //final priceController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  bool _canSale = false;
  bool get canSale => _canSale;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _ownershipEULA = false;
  bool get ownershipEULA => _ownershipEULA;

  bool _isLoadingLoadMore = false;
  bool get isLoadingLoadMore => _isLoadingLoadMore;
  bool _isShowAutoComplete = false;
  bool get isShowAutoComplete => _isShowAutoComplete;

  String _temporarySearch = '';
  String get temporarySearch => _temporarySearch;

  int _videoSize = 0;
  int get videoSize => _videoSize;

  // late Subscription subscription;
  double _progressCompress = 100.0;
  double get progressCompress => _progressCompress;

  String? _desFile;
  String? get desFile => _desFile;

  ModelGoogleMapPlace? _modelGoogleMapPlace;
  ModelGoogleMapPlace? get modelGoogleMapPlace => _modelGoogleMapPlace;
  List<SearchPeolpleData> _searchPeolpleData = [];
  List<SearchPeolpleData> get searchPeolpleData => _searchPeolpleData;
  List<SearchPeolpleData> _searchTagPeolpleData = [];
  List<SearchPeolpleData> get searchTagPeolpleData => _searchTagPeolpleData;
  List<Map<String, dynamic>> _searchPeopleACData = [];
  List<Map<String, dynamic>> get searchPeopleACData => _searchPeopleACData;
  BoostMasterModel? boostMasterData;
  BoostContent? _boostContent;
  BoostContent? get boostContent => _boostContent;

  TextEditingController _priceController = TextEditingController();
  TextEditingController _captionController = TextEditingController();
  TextEditingController _location = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  String _privacyTitle = '';
  String privacyValue = 'PUBLIC';
  String _locationName = '';
  bool _updateContent = false;
  FeatureType? _featureType;
  List<String?>? _fileContent;
  String _selectedLocation = '';
  bool _allowComment = true;
  bool _isShared = true;
  bool _certified = false;
  bool _certifiedTmp = false;
  dynamic _uploadSuccess;
  List<String>? _tags;
  String _visibility = "PUBLIC";
  dynamic _thumbNail;
  Music? _musicSelected;

  String? urlLink;
  String? judulLink;

  List<String> _interestData = [];
  List<Interest> _interest = [];
  List<Interest> _interestList = [];
  List<String> _tempinterestData = [];
  List<UserData> _userList = [];
  List<String> _userTagData = [];
  List<TagPeople> _userTagDataReal = [];
  int _startSearch = 0;

  bool _toSell = false;
  bool _includeTotalViews = false;
  bool _includeTotalLikes = false;
  bool _priceIsFilled = false;
  bool _isSavedPrice = false;
  bool _isUpdate = false;

  TextEditingController get priceController => _priceController;
  TextEditingController get captionController => _captionController;
  TextEditingController get location => _location;

  String get privacyTitle => _privacyTitle;
  bool get updateContent => _updateContent;
  FeatureType? get featureType => _featureType;
  List<String?>? get fileContent => _fileContent;
  String get selectedLocation => _selectedLocation;
  bool get allowComment => _allowComment;
  bool get isShared => _isShared;
  bool get certified => _certified;
  bool get certifiedTmp => _certifiedTmp;
  List<String>? get tags => _tags;
  String get visibility => _visibility;
  dynamic get thumbNail => _thumbNail;
  Music? get musicSelected => _musicSelected;
  List<Interest> get interest => _interest;
  List<Interest> get interestList => _interestList;
  List<UserData> get userList => _userList;
  List<String> get userTagData => _userTagData;
  String get locationName => _locationName;
  List<String> get interestData => _interestData;
  List<TagPeople> get userTagDataReal => _userTagDataReal;
  int get startSearch => _startSearch;

  bool get toSell => _toSell;
  bool get includeTotalViews => _includeTotalViews;
  bool get includeTotalLikes => _includeTotalLikes;
  bool get priceIsFilled => _priceIsFilled;
  bool get isSavedPrice => _isSavedPrice;
  bool get isUpdate => _isUpdate;
  bool isLoadMorePage = false;

  DateTime _tmpstartDate = DateTime(1000);
  DateTime _tmpfinsihDate = DateTime(1000);
  String _tmpBoost = '';
  String get tmpBoost => _tmpBoost;
  String _tmpBoostTime = '';
  String get tmpBoostTime => _tmpBoostTime;
  String _tmpBoostInterval = '';
  String get tmpBoostInterval => _tmpBoostInterval;
  String _tmpBoostTimeId = '';
  String get tmpBoostTimeId => _tmpBoostTimeId;
  String _tmpBoostIntervalId = '';
  String get tmpBoostIntervalId => _tmpBoostIntervalId;
  String inputCaption = '';

  String _postIdPanding = '';
  String get postIdPanding => _postIdPanding;
  // UpdateContentsArgument get updateArguments => _arguments!;
  ContentData? _editData;
  ContentData? get editData => _editData;

  BoostResponse? _boostPaymentResponse;
  BoostResponse? get boostPaymentResponse => _boostPaymentResponse;

  bool _isCompress = false;
  bool get isCompress => _isCompress;

  String _hastagChallange = '';
  String get hastagChallange => _hastagChallange;

  set hastagChallange(String val) {
    _hastagChallange = val;
    notifyListeners();
  }

  set isCompress(bool val) {
    _isCompress = val;
    notifyListeners();
  }

  set boostPaymentResponse(BoostResponse? value) {
    _boostPaymentResponse = value;
    notifyListeners();
  }

  set editData(ContentData? val) {
    _editData = val;
    notifyListeners();
  }

  set ownershipEULA(bool val) {
    _ownershipEULA = val;
    notifyListeners();
  }

  set interestList(List<Interest> val) {
    _interestList = val;
    notifyListeners();
  }

  set isEdit(bool val) {
    _isEdit = val;
    notifyListeners();
  }

  set progressCompress(double val) {
    _progressCompress = val;
    notifyListeners();
  }

  set interestData(List<String> val) {
    _interestData = val;
    notifyListeners();
  }

  set interest(List<Interest> val) {
    _interest = val;
    notifyListeners();
  }

  set userTagDataReal(List<TagPeople> val) {
    _userTagDataReal = val;
    notifyListeners();
  }

  set locationName(String val) {
    _locationName = val;
    notifyListeners();
  }

  set priceController(TextEditingController val) {
    _priceController = val;
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

  set temporarySearch(String val) {
    _temporarySearch = val;
    notifyListeners();
  }

  set thumbNail(val) {
    _thumbNail = val;
    notifyListeners();
  }

  set musicSelected(Music? music) {
    _musicSelected = music;
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

  set isShared(bool val) {
    _isShared = val;
    notifyListeners();
  }

  set certified(bool val) {
    _certified = val;
    if (!val) {
      _toSell = false;
    }
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

  set isShowAutoComplete(bool val) {
    _isShowAutoComplete = val;
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

  initThumbnail() async {
    final isImage = ((fileContent?[0] ?? '').isImageFormat());
    print('My Thumbnail: $isImage');
    if (!isImage) {
      thumbNail = await System().createThumbnail(fileContent?[0] ?? '');
      print('My Thumbnail: $thumbNail');
    }
  }

  void setDefaultFileContent(BuildContext context) {
    final notifierPre = context.read<PreviewContentNotifier>();
    final isPic = _fileContent?[0]?.isImageFormat();
    if (isPic ?? false) {
      _musicSelected = null;
      notifierPre.fixSelectedMusic = null;
    } else {
      _musicSelected = null;
      notifierPre.fixSelectedMusic = null;
      final index = notifierPre.indexView;
      notifierPre.fileContent?[index] = notifierPre.defaultPath;
      _fileContent?[0] = notifierPre.defaultPath;
    }
    notifyListeners();
  }

  void setDefaultExternalLink(BuildContext context) {
    urlLink = null;
    judulLink = null;
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

  set searchPeopleACData(List<Map<String, dynamic>> val) {
    _searchPeopleACData = val;
    notifyListeners();
  }

  set toSell(bool val) {
    _toSell = val;
    notifyListeners();
  }

  set includeTotalViews(bool val) {
    _includeTotalViews = val;
    notifyListeners();
  }

  set includeTotalLikes(bool val) {
    _includeTotalLikes = val;
    notifyListeners();
  }

  set priceIsFilled(bool val) {
    _priceIsFilled = val;
    notifyListeners();
  }

  set isSavedPrice(bool val) {
    _isSavedPrice = val;
    notifyListeners();
  }

  DateTime get tmpstartDate => _tmpstartDate;
  set tmpstartDate(DateTime val) {
    _tmpstartDate = val;
    notifyListeners();
  }

  DateTime get tmpfinsihDate => _tmpfinsihDate;
  set tmpfinsihDate(DateTime val) {
    _tmpfinsihDate = val;
    notifyListeners();
  }

  set tmpBoost(String val) {
    _tmpBoost = val;
    notifyListeners();
  }

  set tmpBoostTime(String val) {
    _tmpBoostTime = val;
    notifyListeners();
  }

  set tmpBoostInterval(String val) {
    _tmpBoostInterval = val;
    notifyListeners();
  }

  set tmpBoostTimeId(String val) {
    _tmpBoostTimeId = val;
    notifyListeners();
  }

  set tmpBoostIntervalId(String val) {
    _tmpBoostIntervalId = val;
    notifyListeners();
  }

  // set setUpdateArguments(UpdateContentsArgument args) {
  //   _arguments = args;
  //   notifyListeners();
  // }

  set isUpdate(bool val) {
    _isUpdate = val;
    notifyListeners();
  }

  void onWillPop(BuildContext context) => ShowBottomSheet.onShowCancelPost(context, onCancel: () => _onExit(isDisposeVid: false));

  void handleTapOnLocation(String value) => selectedLocation = value;

  void handleDeleteOnLocation() => selectedLocation = '';

  bool _validateDescription() => captionController.text.length >= 5;

  bool _validateCategory() => _interestData.isNotEmpty;

  bool _validatePrice() => priceController.text.isNotEmpty;

  void checkKeyboardFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  // void _connectAndListenToSocket(BuildContext context) async {
  //   final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
  //   String? token = SharedPreference().readStorage(SpKeys.userToken);
  //   String? email = SharedPreference().readStorage(SpKeys.email);
  //   if (socketService.isRunning) socketService.closeSocket();
  //   socketService.connectToSocket(
  //     () {
  //       socketService.events(SocketService.eventNotif, (result) {
  //         '$result'.logger();
  //         homeNotifier.onRefresh(context, _visibility);
  //         // homeNotifier.isHaveSomethingNew = true;
  //         socketService.closeSocket();
  //       });
  //     },
  //     host: Env.data.baseUrl,
  //     options: OptionBuilder()
  //         .setAuth({
  //           "x-auth-user": "$email",
  //           "x-auth-token": "$token",
  //         })
  //         .setTransports(
  //           ['websocket'],
  //         )
  //         .disableAutoConnect()
  //         .build(),
  //   );
  // }

  void _onExit({bool isDisposeVid = true}) {
    print('ini exit');
    _progressCompress = 0;
    // if (featureType == FeatureType.diary || featureType == FeatureType.vid) {
    //   LightCompressor.cancelCompression();
    // }
    // VideoCompress.cancelCompression();
    // tagsController.clear();
    // _interestList = [];
    /////////////
    selectedLocation = '';
    allowComment = true;
    isShared = true;
    certified = false;
    captionController.clear();
    _selectedLocation = '';
    _interestData = [];
    _locationName = '';
    _userTagData = [];
    _privacyTitle = '';
    privacyValue = 'PUBLIC';
    interestData = [];
    userTagDataReal = [];
    priceController.clear();
    toSell = false;
    includeTotalViews = false;
    includeTotalLikes = false;
    isUpdate = false;
    _postIdPanding = '';
    _boostContent = null;
    _tmpstartDate = DateTime(1000);
    _tmpfinsihDate = DateTime(1000);
    _tmpBoost = '';
    _tmpBoostTime = '';
    tmpBoostInterval = '';
    editData = null;
    // _isCompress = false;

    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    if (isDisposeVid) {
      notifier.height = null;
      notifier.width = null;
      try {
        notifier.audioPreviewPlayer.stop();
        notifier.audioPreviewPlayer.dispose();
      } catch (e) {
        'Error dispose AudioPreviewPlayer : $e'.logger();
      }

      musicSelected = null;
      notifier.defaultPath = null;
      if (notifier.betterPlayerController != null) {
        // notifier.betterPlayerController!.dispose();
        notifier.betterPlayerController!.pause();
      }
    } else {
      notifier.fixSelectedMusic = _musicSelected;
    }
  }

  bool _isLoadVideo = false;
  bool get isLoadVideo => _isLoadVideo;
  set isLoadVideo(bool state) {
    _isLoadVideo = state;
    notifyListeners();
  }

  Future _createPostContentV2(BuildContext context, bool mounted) async {
    final BuildContext context = Routing.navigatorKey.currentContext!;
    final orientation = context.read<CameraNotifier>().orientation;
    certifiedTmp = _certified;
    double progress = 0;

    final tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9\.-_!$%^&*()]+\w*", caseSensitive: false);
    final tagHastagRegex = RegExp(r"\B#\w*[a-zA-Z-1-9\.-_!$%^&*()]+\w*", caseSensitive: false);

    List<String> userTagCaption = [];
    List<String> hastagCaption = [];
    tagRegex.allMatches(captionController.text).map((z) {
      final val = z.group(0)?.substring(1);
      if (val != null) {
        userTagCaption.add(val);
      }
    }).toList();

    tagHastagRegex.allMatches(captionController.text).map((z) {
      final val = z.group(0)?.substring(1);
      if (val != null) {
        hastagCaption.add(val);
      }
    }).toList();

    // if (featureType == FeatureType.vid && progressCompress != 100) {
    //   showSnackBar(
    //     icon: "info-icon.svg",
    //     color: kHyppeDanger,
    //     message: "Compressing Video",
    //   );
    //   return;
    // }

    try {
      // _connectAndListenToSocket(context);
      final notifier = PostsBloc();
      final previewContentNotifier = context.read<PreviewContentNotifier>();
      final width = previewContentNotifier.width;
      final height = previewContentNotifier.height;

      print('featureType : $featureType');
      if (_boostContent == null) {
        context.read<HomeNotifier>().preventReloadAfterUploadPost = true;
        context.read<HomeNotifier>().uploadedPostType = featureType ?? FeatureType.pic;
        clearUpAndBackToHome(context);
      }
      // await eventService.notifyUploadSendProgress(ProgressUploadArgument(count: _progressCompress, total: 100));
      if (featureType == FeatureType.diary || featureType == FeatureType.vid) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.prepareYourContent ?? '',
          subCaption: language.pleaseWaitThisProcessWillTakeSomeTime,
          color: kHyppeTextLightPrimary,
          iconSvg: "${AssetPath.vectorPath}info_white.svg",
          milisecond: 2000,
          dismissible: false,
          enableDrag: false,
        );
      }
      if (_isCompress) {
        await compressVideo();
      }

      if (!mounted) return false;

      notifier.postContentsBlocV2(
        context,
        width: width,
        height: height,
        type: featureType ?? FeatureType.other,
        visibility: privacyValue,
        tags: hastagCaption,
        tagDescription: userTagCaption,
        allowComment: allowComment,
        certified: certified,
        fileContents: fileContent ?? [],
        description: captionController.text,
        cats: _interestData,
        tagPeople: userTagData,
        idMusic: _musicSelected?.id,
        saleAmount: _toSell ? priceController.text.replaceAll(',', '').replaceAll('.', '') : "0",
        saleLike: _includeTotalLikes,
        saleView: _includeTotalViews,
        isShared: isShared,
        rotate: orientation ?? NativeDeviceOrientation.portraitUp,
        location: locationName == language.addLocation ? '' : locationName,
        stickers: previewContentNotifier.stickers,
        onReceiveProgress: (count, total) async {
          await eventService.notifyUploadReceiveProgress(ProgressUploadArgument(count: count.toDouble(), total: total.toDouble()));
        },
        onSendProgress: (received, total) async {
          if (_isCompress) {
            // old progress counting
            // var progress = 50 + ((received / 2) / 1000000);
            // if (progress < 80) {
            //   _progressCompress = progress;
            // } else {
            //   progress + 2;
            // }
            // var total2 = 100.0;
            // var total2 = (total / 2) / 100000;
            // var total2 = 50 + ((total / 2) / 100000);

            // new progress counting
            var uploadProgress = ((received / total) * 100) * 0.45; // when compress is done, uploading bar should be in 95% (50% compress + 45% upload)
            _progressCompress = 50 + uploadProgress;
            await eventService.notifyUploadSendProgress(ProgressUploadArgument(count: _progressCompress, total: 100));
          } else {
            // old progress counting
            // if (received < total - total * 5 / 100) {
            //   progress = received.toDouble();
            // }

            // new progress counting
            progress = received * 0.95; // when compress is done, uploading bar should be in 95%
            await eventService.notifyUploadSendProgress(ProgressUploadArgument(count: progress, total: total.toDouble()));
          }
          if (received == total) {
            eventService.notifyUploadFinishingUp(true);
          }
        },
      ).then((value) async {
        _uploadSuccess = value;
        SharedPreference().removeValue(SpKeys.uploadContent);
        'Create post content with value $value'.logger();
        // _eventService.notifyUploadFinishingUp(_uploadSuccess);
        if (_uploadSuccess != null) {
          eventService.notifyUploadSuccess(_uploadSuccess);
        }

        // final decode = json.decode(_uploadSuccess.toString());
        // _postIdPanding = decode['data']['postID'];

        if (value is dio.Response) {
          dio.Response res = value;
          "return data ${jsonEncode(res.data['data'])}".loggerV2();
          ContentData uploadedData = ContentData.fromJson(res.data['data']);
          SharedPreference().removeValue(SpKeys.uploadContent);
          if (mounted) (Routing.navigatorKey.currentContext ?? context).read<SelfProfileNotifier>().updateProfilePost(featureType ?? FeatureType.pic, uploadedData);
          if (mounted) (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().onUploadedSelfUserContent(context: context, contentData: uploadedData);
        }
        if (_boostContent != null) _boostContentBuy(context);
        context.read<PreviewVidNotifier>().canPlayOpenApps = true;
      });
    } catch (e) {
      print('Error create post : $e');
      SharedPreference().removeValue(SpKeys.uploadContent);
      eventService.notifyUploadFailed(
        dio.DioError(
          requestOptions: dio.RequestOptions(
            path: UrlConstants.createuserposts,
          ),
          error: e,
        ),
      );
      'e'.logger();
    } finally {
      if (_boostContent == null) _onExit();
    }
  }

  Future _updatePostContentV2(BuildContext context, {required String postID, required String content}) async {
    updateContent = true;
    certifiedTmp = false;

    final tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9\.-_!$%^&*()]+\w*", caseSensitive: false);
    final tagHastagRegex = RegExp(r"\B#\w*[a-zA-Z-1-9\.-_!$%^&*()]+\w*", caseSensitive: false);

    List userTagCaption = [];
    List hastagCaption = [];
    tagRegex.allMatches(captionController.text).map((z) {
      userTagCaption.add(z.group(0)?.substring(1));
    }).toList();

    tagHastagRegex.allMatches(captionController.text).map((z) {
      hastagCaption.add(z.group(0)?.substring(1));
    }).toList();

    final price = priceController.text.replaceAll(',', '').replaceAll('.', '');
    final oldPrice = _editData?.saleAmount;

    final notifier = PostsBloc();
    await notifier.updateContentBlocV2(
      context,
      postId: postID,
      type: featureType ?? FeatureType.other,
      visibility: privacyValue,
      tags: hastagCaption.join(','),
      allowComment: allowComment,
      certified: certified,
      description: captionController.text,
      cats: _interestData,
      tagPeople: userTagData,
      saleAmount: _toSell ? price : "0",
      saleLike: _includeTotalLikes,
      saleView: _includeTotalViews,
      isShared: isShared,
      location: locationName == language.addLocation ? '' : locationName,
    );
    final fetch = notifier.postsFetch;

    print('update dong ${fetch.postsState}');

    if (fetch.postsState == PostsState.updateContentsSuccess) {
      SharedPreference().removeValue(SpKeys.uploadContent);
      await context.read<SelfProfileNotifier>().onUpdateSelfPostContent(
            context,
            postID: postID,
            content: content,
            visibility: privacyValue,
            allowComment: allowComment,
            certified: certified,
            description: captionController.text,
            tags: tagsController.text.split(','),
            location: locationName == language.addLocation ? '' : locationName,
            tagPeople: userTagDataReal,
            cats: _interestData,
            saleAmount: _toSell ? price : "0",
            saleLike: _includeTotalLikes,
            saleView: _includeTotalViews,
            isShared: isShared,
          );
      notifyListeners();

      context.read<SelfProfileNotifier>().onUpdate();

      context.read<HomeNotifier>().onUpdateSelfPostContent(
            context,
            postID: postID,
            content: content,
            visibility: privacyValue,
            allowComment: allowComment,
            certified: certified,
            description: captionController.text,
            tags: tagsController.text.split(','),
            location: locationName == language.addLocation ? '' : locationName,
            tagPeople: userTagDataReal,
            cats: _interestData,
            saleAmount: _toSell ? price : "0",
            saleLike: _includeTotalLikes,
            saleView: _includeTotalViews,
            isShared: isShared,
          );

      // print("ini kategori $_interestData");

      updateContent = false;
      Routing().moveBack();

      var isoCode = SharedPreference().readStorage(SpKeys.isoCode);

      if (oldPrice != 0 && oldPrice != num.parse(price)) {
        showSnackBar(
          color: kHyppeTextSuccess,
          message: "${language.priceChangesSavedSuccessfully}",
        );
      } else {
        showSnackBar(
          color: kHyppeTextSuccess,
          message: isoCode == 'id' ? "$content ${language.your} ${language.successfullySave}" : "${language.your} $content ${language.successfullySave}",
        );
      }

      _onExit();
    } else {
      SharedPreference().removeValue(SpKeys.uploadContent);
      updateContent = false;
      notifyListeners();
      final message = json.decode(fetch.data.toString());
      if (message['messages']['info'][0] != '' || message['messages']['info'][0] != null) {
        return ShowBottomSheet().onShowColouredSheet(context, message['messages']['info'][0], color: kHyppeDanger, iconSvg: "${AssetPath.vectorPath}remove.svg", maxLines: 4);
      }
    }
  }

  void checkForCompress() async {
    if (isEdit == false && (featureType == FeatureType.diary || featureType == FeatureType.vid)) {
      await getVideoSize();
      Duration? duration;
      int? size;
      final value = await System().getVideoMetadata(File(fileContent?[0] ?? '').path);
      size = value?.filesize ?? 0;
      print('sebelum di bagi $size');
      var inMB = size / 1024 / 1024;
      size = inMB.toInt();
      duration = Duration(milliseconds: int.parse(value?.duration?.toInt().toString() ?? ''));
      print("size video ini $size");
      print(duration.inSeconds);
      var normalSize = duration.inSeconds * 0.91;
      if (size >= normalSize) {
        _isCompress = true;
      } else {
        _isCompress = false;
      }
    } else {
      _isCompress = false;
    }
    print('My Result Compress: $_isCompress');
  }

  Future<void> compressVideo() async {
    try {
      final LightCompressor _lightCompressor = LightCompressor();
      _desFile = await _destinationFile;
      _lightCompressor.onProgressUpdated.listen((val) {
        _progressCompress = val * 0.5; // when compress is done, uploading bar should be in 50%
        "+++++++++++++++compress : $_progressCompress".logger();
        eventService.notifyUploadSendProgress(ProgressUploadArgument(count: _progressCompress, total: 100, isCompressing: true));
        notifyListeners();
      });

      final dynamic response = await _lightCompressor.compressVideo(
        path: File(fileContent?[0] ?? '').path,
        destinationPath: _desFile ?? '',
        videoQuality: VideoQuality.high,
        isMinBitrateCheckEnabled: false,
        iosSaveInGallery: false,
        // frameRate: 24, /* or ignore it */
      );

      if (response is OnSuccess) {
        _desFile = response.destinationPath;
        _fileContent = [response.destinationPath];
        getVideoSize();
        _progressCompress = 100;
        notifyListeners();
      } else if (response is OnFailure) {
        // print('failed');
        // print(response.message);
      } else if (response is OnCancelled) {
        // print('cancel');
        // print(response.isCancelled);
      }
    } catch (e) {
      // VideoCompress.cancelCompression();
    }
  }

  void showSnackBar({
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

    // context.read<CameraNotifier>().disposeCamera(context);
    context.read<PreviewContentNotifier>().isForcePaused = false;
    // Routing().move(Routes.lobby);
    if (_boostContent != null) _onExit();
    Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
  }

  Future<void> onClickPost(BuildContext context, bool mounted, {required bool onEdit, ContentData? data, String? content}) async {
    checkKeyboardFocus(context);
    if (_toSell) {
      if (!_validatePrice()) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.priceIsNotEmpty ?? '',
          color: Theme.of(context).colorScheme.error,
          maxLines: 2,
        );
        return;
      }
    }
    final connection = await System().checkConnections();
    if (_validateDescription() && _validateCategory()) {
      if (connection) {
        SharedPreference().writeStorage(SpKeys.uploadContent, true);
        checkKeyboardFocus(context);
        if (onEdit) {
          if (!mounted) return;
          await _updatePostContentV2(
            context,
            postID: data?.postID ?? '',
            content: content ?? '',
          );
        } else {
          await _createPostContentV2(context, mounted);
        }
      } else {
        if (!mounted) return;
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          onClickPost(context, mounted, onEdit: onEdit, data: data, content: content);
        });
      }
    } else {
      final fixContext = Routing.navigatorKey.currentContext;
      if (!mounted) return;
      ShowBottomSheet().onShowColouredSheet(
        fixContext ?? context,
        _validateDescription() ? language.categoryCanOnlyWithMin1Characters ?? '' : language.descriptionCanOnlyWithMin5Characters ?? '',
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
    }
  }

  Future<Uint8List?> makeThumbnail() async {
    Uint8List? _thumbnails = await VideoThumbnail.thumbnailData(
      video: fileContent?[0] ?? '',
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return _thumbnails;
  }

  validateIdCard() async {
    _onExit();
    // Routing().move(Routes.verificationIDStep1);
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
      onChange: (value, code) {
        _privacyTitle = value;
        privacyValue = code;
        if (code == 'PRIVATE') {
          allowComment = false;
        } else {
          allowComment = true;
        }
        // Routing().moveBack();
        checkKeyboardFocus(context);
        notifyListeners();
      },
      value: privacyValue,
    );
  }

  void showLocation(BuildContext context) {
    ShowBottomSheet.onShowLocation(
      context,
      onSave: () {
        // Routing().moveBack();
        // Provider.of<PreUploadContentNotifier>(context, listen: false)._privacyTitle = _privacyTitle;
        // notifyListeners();
      },
      onCancel: () {
        Routing().moveBack();
        FocusScope.of(context).unfocus();
      },
      onChange: (value) {
        // Routing().moveBack();
        // notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  void showInterest(BuildContext context) {
    print('kesini');
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

  void onShowStatement(
    BuildContext context, {
    required Function() onCancel,
  }) {
    ShowBottomSheet.onShowStatementOwnership(
      context,
      onSave: () {
        System().actionReqiredIdCard(context, action: () {
          Routing().moveBack();
          Routing().move(Routes.ownershipSelling);
        });
      },
      onCancel: onCancel,
    );
  }

  void onOwnershipEULA(BuildContext context) {
    if (!certified) {
      ShowBottomSheet.onShowOwnerEULA(
        context,
        onSave: () {
          Routing().moveBack();
          certified = !certified;
        },
        onCancel: () {
          Routing().moveBack();
        },
      );
    } else {
      certified = false;
    }
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
        searchPeople(context, input: value, tagPeople: true);
        notifyListeners();
      },
      value: _privacyTitle,
    );
  }

  Future getVideoSize() async {
    final size = await File(fileContent?[0] ?? '').length();
    _videoSize = size;
    notifyListeners();
  }

  Future<String> get _destinationFile async {
    String directory;
    final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    if (Platform.isAndroid) {
      // Handle this part the way you want to save it in any directory you wish.
      final List<Directory>? dir = await path.getExternalStorageDirectories(type: path.StorageDirectory.downloads);
      directory = dir?.first.path ?? '';
      return File('$directory/$videoName').path;
    } else {
      final Directory dir = await path.getLibraryDirectory();
      directory = dir.path;
      return File('$directory/$videoName').path;
    }
  }

  Future getInitialInterest(BuildContext context) async {
    _interestList.clear();
    if (_interestList.isEmpty) {
      final notifier = UtilsBlocV2();
      await notifier.getInterestBloc(context);
      final fetch = notifier.utilsFetch;

      final Interest seeMore = Interest(
        id: '11111',
        interestName: language.seeMore,
      );
      // {
      //   "id": "11111",
      //   "langIso": "alice",
      //   "cts": '2021-12-16 12:45:36',
      //   "icon": 'https://prod.hyppe.app/images/icon_interest/music.svg',
      //   'interestName': 'See More'
      // };
      if (fetch.utilsState == UtilsState.getInterestsSuccess) {
        _interest = [];
        fetch.data.forEach((v) {
          if (_interest.length <= 5) {
            _interest.add(Interest.fromJson(v));
          }
          if (_interest.length == 6) {
            _interest.add(seeMore);
          }
          _interestList.add(Interest.fromJson(v));
        });
        _interestList.sort((a, b) {
          return a.interestName?.compareTo(b.interestName ?? '') ?? 0;
        });

        notifyListeners();
      }
    }
  }

  Future onGetInterest(BuildContext context) async {
    if (_interestList.isEmpty) {
      final notifier = UtilsBlocV2();
      await notifier.getInterestBloc(context);
      final fetch = notifier.utilsFetch;

      final Interest seeMore = Interest(
        id: '11111',
        interestName: 'See More',
      );
      // {
      //   "id": "11111",
      //   "langIso": "alice",
      //   "cts": '2021-12-16 12:45:36',
      //   "icon": 'https://prod.hyppe.app/images/icon_interest/music.svg',
      //   'interestName': 'See More'
      // };
      if (fetch.utilsState == UtilsState.getInterestsSuccess) {
        _interest = [];
        fetch.data.forEach((v) {
          if (_interest.length <= 5) {
            _interest.add(Interest.fromJson(v));
          }
          if (_interest.length == 6) {
            _interest.add(seeMore);
          }
          _interestList.add(Interest.fromJson(v));
        });
        _interestList.sort((a, b) {
          return a.interestName?.compareTo(b.interestName ?? '') ?? 0;
        });

        notifyListeners();
      }
    }
  }

  bool pickedInterest(String? tile) => _interestData.contains(tile) ? true : false;
  bool pickedInterestList(String? tile) => _tempinterestData.contains(tile) ? true : false;
  void insertInterest(BuildContext context, int index) {
    if (interest.isNotEmpty) {
      String tile = interest[index].id ?? '';
      if (tile == '11111') {
        _tempinterestData.clear();
        showInterest(context);
        _tempinterestData.addAll(_interestData);
      } else {
        if (_interestData.contains(tile)) {
          _interestData.removeWhere((v) => v == tile);
        } else {
          _interestData.add(tile);
        }
        notifyListeners();
      }
    }
    // notifyListeners();
  }

  void insertInterestList(BuildContext context, int index) {
    print(index);
    if (interestList.isNotEmpty) {
      String tile = interestList[index].id ?? '';
      print('tile $tile');
      print(_interestData);

      if (tile == '11111') {
        showLocation(context);
      } else {
        // if (_interestData.contains(tile)) {
        //   _interestData.removeWhere((v) => v == tile);
        // } else {
        //   _interestData.add(tile);
        // }

        if (_tempinterestData.contains(tile)) {
          _tempinterestData.removeWhere((v) => v == tile);
        } else {
          _tempinterestData.add(tile);
        }

        notifyListeners();
      }
    } else {
      return null;
    }
  }

  void removeTempInterestList({bool isSaved = false}) {
    if (isSaved) {
      _interestData.clear();
      if (_tempinterestData.isNotEmpty) {
        _interestData.addAll(_tempinterestData);
        notifyListeners();
      }
      _tempinterestData.clear();
    } else {
      _tempinterestData.clear();
    }
  }

  Future inserTagPeople(int index) async {
    if (searchTagPeolpleData.isNotEmpty) {
      String tile = searchTagPeolpleData[index].username ?? '';
      if (_userTagData.contains(tile)) {
        showSnackBar(
          icon: "info-icon.svg",
          color: kHyppeDanger,
          message: "User sudah ditag",
        );
      } else {
        _userTagData.add(tile);
        _userTagDataReal.add(
          TagPeople(username: tile, avatar: searchTagPeolpleData[index].avatar, email: searchTagPeolpleData[index].email, status: 'FOLLOWING'),
        );

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
      _userTagDataReal.removeWhere((v) => v.username == tile);
      notifyListeners();
    }
  }

  Future searchLocation(BuildContext context, {input}) async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    final _language = SharedPreference().readStorage(SpKeys.isoCode);

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

  Future searchPeople(BuildContext context, {input, bool tagPeople = false}) async {
    final notifier = UtilsBlocV2();
    if (input.length > 2) {
      if (_startSearch == 0) {
        _isLoading = true;
      }
      print('getSearchPeopleBloc 3');
      await notifier.getSearchPeopleBloc(context, input, _startSearch * 12, 12);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.searchPeopleSuccess) {
        if (_startSearch == 0) {
          if (tagPeople) {
            _searchTagPeolpleData = [];
          } else {
            _searchPeolpleData = [];
          }
        }

        if (tagPeople) {
          fetch.data.forEach((v) {
            _searchTagPeolpleData.add(SearchPeolpleData.fromJson(v));
          });
        } else {
          fetch.data.forEach((v) {
            _searchPeolpleData.add(SearchPeolpleData.fromJson(v));
          });
        }

        notifyListeners();
      }
      _isLoading = false;
      isLoadingLoadMore = false;
    }
  }

  Future scrollListPeopleListener(
    BuildContext context,
    ScrollController scrollController,
    input, {
    bool tagPeople = false,
  }) async {
    if (input.length > 2) {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        isLoadingLoadMore = true;
        _startSearch++;
        searchPeople(context, input: input, tagPeople: tagPeople);
        notifyListeners();
      }
    }
  }

  void showAutoComplete(value, BuildContext context) {
    _searchPeolpleData = [];
    final selection = captionController.selection;
    String _text = value.toString().substring(0, selection.baseOffset);
    final _tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9]+\w*", caseSensitive: false);
    final sentences = _text.split('\n');

    for (var sentence in sentences) {
      final words = sentence.split(' ');
      String withat = words.last;

      if (_tagRegex.hasMatch(withat)) {
        String withoutat = withat.substring(1);
        inputCaption = withoutat;
        _startSearch = 0;
        if (withoutat.length > 2) {
          _isShowAutoComplete = true;
          searchPeople(context, input: withoutat);
          temporarySearch = withoutat;
          break;
        }
      } else {
        if (_isShowAutoComplete) {
          _isShowAutoComplete = false;
          Future.delayed(const Duration(milliseconds: 500), () {
            notifyListeners();
          });
        }
      }
    }
  }

  void insertAutoComplete(index) {
    final text = _captionController.text;
    final selection = _captionController.selection;
    int searchLength = _temporarySearch.length;
    _isShowAutoComplete = false;

    if (_searchPeolpleData.isNotEmpty) {
      final newText = text.replaceRange(selection.start - searchLength, selection.end, '${_searchPeolpleData[index].username} ');
      int length = _searchPeolpleData[index].username?.length ?? 0;
      _captionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.baseOffset + length - searchLength + 1),
      );
      notifyListeners();
    }
  }

  Future submitOwnership(BuildContext context, {bool withAlert = false}) async {
    if (priceController.text != '') {
      final harga = num.parse(priceController.text.replaceAll(',', '').replaceAll('.', ''));
      if (harga < 50000) {
        if (withAlert) {
          return ShowBottomSheet().onShowColouredSheet(context, language.minimumPrice ?? '', color: kHyppeDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
        } else {
          toSell = false;
          includeTotalViews = false;
          includeTotalLikes = false;
          priceController.clear();
        }
      }
      if (harga > 50000000) {
        if (withAlert) {
          return ShowBottomSheet().onShowColouredSheet(context, language.maximumPrice ?? '', color: kHyppeDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
        } else {
          toSell = false;
          includeTotalViews = false;
          includeTotalLikes = false;
          priceController.clear();
        }
      }
    }

    if (toSell && priceController.text == '') {
      toSell = false;
    } else {
      _privacyTitle = "${language.public}";
      privacyValue = 'PUBLIC';
    }
    notifyListeners();
    Routing().moveBack();
  }

  // void showDeleteMyTag(BuildContext context, postId) {
  //   Routing().moveBack();
  //   ShowGeneralDialog.deleteContentDialog(context, '', () async {
  //     deleteMyTag(context, postId);
  //   });
  // }

  // Future deleteMyTag(BuildContext context, postId) async {
  //   final connect = await System().checkConnections();
  //   final notifier = UtilsBlocV2();

  //   print('delete in updload');
  //   if (connect) {
  //     print(postId);
  //     await notifier.deleteTagUsersBloc(context, postId);

  //     final fetch = notifier.utilsFetch;
  //     print('fetch.followState');
  //     print(fetch.utilsState);
  //     if (fetch.utilsState == UtilsState.deleteUserTagSuccess) {
  //       showSnackBar(color: kHyppeLightSuccess, message: 'Your successfully removed from HyppeVid', icon: 'valid-invert.svg');
  //       Routing().moveBack();
  //     } else {
  //       showSnackBar(color: kHyppeDanger, message: 'Somethink wrong', icon: 'info-icon.svg');
  //       Routing().moveBack();
  //     }
  //   } else {
  //     ShowBottomSheet.onNoInternetConnection(context);
  //   }
  // }

  void navigateToOwnership(BuildContext context) {
    if (priceController.text == '0') {
      toSell = false;
    }
    Routing().move(Routes.ownershipSelling);
    _getSettingApps(context);
  }

  Future _getSettingApps(BuildContext context) async {
    _isLoading = true;
    print('setting apss');
    final notifier = UtilsBlocV2();
    await notifier.settingAppsBloc(context);

    final fetch = notifier.utilsFetch;
    if (fetch.utilsState == UtilsState.getSettingSuccess) {
      final SettingModel _result = SettingModel.fromJson(fetch.data);
      print(_result.settingMP);
      _canSale = _result.settingMP ?? false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getMasterBoost(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final notifier = UtilsBlocV2();
    await notifier.getMasterBoost(context);
    final fetch = notifier.utilsFetch;
    int toTransaktion = 1;

    if (fetch.utilsState == UtilsState.getMasterBoostSuccess) {
      boostMasterData = BoostMasterModel.fromJson(fetch.data);
      if (boostMasterData?.pendingTransaction == 1) {
        Routing().moveBack();

        await ShowBottomSheet().onShowColouredSheet(
          context,
          language.otherPostsInProcessOfPayment ?? '',
          subCaption: language.thePostisintheProcessofPayment,
          subCaptionButton: language.viewPaymentStatus,
          color: kHyppeRed,
          iconSvg: '${AssetPath.vectorPath}remove.svg',
          maxLines: 10,
          functionSubCaption: () {
            toTransaktion = 2;
            Routing().moveAndPop(Routes.transaction);
            // Routing().moveBack();
            // Routing().moveBack();
            // Routing().moveBack();
            // Routing().moveBack();
            // _onExit();
          },
        );
        if (toTransaktion == 1) Routing().move(Routes.transaction);
      }
      _isLoading = false;
      notifyListeners();
    } else if (fetch.utilsState == UtilsState.getMasterBoostError) {
      _isLoading = false;
      notifyListeners();
    }
  }

  navigateToBoost(BuildContext context) async {
    getMasterBoost(context);

    if (_boostContent != null) {
      tmpstartDate = DateTime.parse(_boostContent?.dateBoostStart ?? '');
      tmpfinsihDate = DateTime.parse(_boostContent?.dateBoostEnd ?? '');
      tmpBoost = _boostContent?.typeBoost ?? '';
      if (_boostContent?.typeBoost == 'manual') {
        tmpBoostTime =
            "${System().capitalizeFirstLetter(_boostContent?.sessionBoost?.name ?? '')} (${_boostContent?.sessionBoost?.start?.substring(0, 5)} - ${_boostContent?.sessionBoost?.end?.substring(0, 5)} WIB)";
        tmpBoostTimeId = _boostContent?.sessionBoost?.sId ?? '';
        tmpBoostInterval = "${_boostContent?.intervalBoost?.value} ${System().capitalizeFirstLetter(_boostContent?.intervalBoost?.remark ?? '')}";
        tmpBoostIntervalId = _boostContent?.intervalBoost?.sId ?? '';
      }
    }
    if (privacyValue != 'PUBLIC') {
      ShowBottomSheet.onWarningBottom(
        context,
        title: language.postPrivacyisNotAllowed,
        bodyText: language.toContinueTheBoostPostProcess,
        icon: "${AssetPath.vectorPath}warning.svg",
        buttonText: 'Oke',
        onSave: () {
          Routing().moveAndPop(Routes.boostUpload);
        },
      );
    } else {
      Routing().move(Routes.boostUpload);
    }
  }

  bool enableBoostConfirm() {
    if (_tmpstartDate != DateTime(1000) && (tmpBoost != '')) {
      if (tmpBoost == 'manual') {
        if (tmpBoostTime != '' && tmpBoostInterval != '') {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future boostButton(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      _isLoading = true;
      notifyListeners();
      Map data = {
        "dateStart": _tmpstartDate.toString().substring(0, 10),
        "dateEnd": _tmpfinsihDate.toString().substring(0, 10),
        "type": _tmpBoost,
      };
      if (_tmpBoost == 'manual') {
        data['interval'] = _tmpBoostIntervalId;
        data['session'] = _tmpBoostTimeId;
      }
      final notifier = UtilsBlocV2();
      await notifier.postBostContentPre(context, data: data);
      final fetch = notifier.utilsFetch;

      if (fetch.utilsState == UtilsState.getMasterBoostSuccess) {
        _boostContent = BoostContent.fromJson(fetch.data);
        _privacyTitle = language.public ?? 'PUBLIC';
        privacyValue = 'PUBLIC';
        exitBoostPage();
        _isLoading = false;
        notifyListeners();
      } else if (fetch.utilsState == UtilsState.getMasterBoostError) {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        boostButton(context);
      });
    }
  }

  Future paymentMethod(context) async {
    print('asdasdasdasdasd');
    // _createPostContentV2();
    // print(_boostContent);
    if (_validateDescription() && _validateCategory()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      Routing().move(Routes.paymentMethodScreen, argument: TransactionArgument(totalAmount: _boostContent?.priceTotal));
    } else {
      ShowBottomSheet().onShowColouredSheet(
        context,
        _validateDescription() ? language.categoryCanOnlyWithMin1Characters ?? '' : language.descriptionCanOnlyWithMin5Characters ?? '',
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
    }
  }

  Future uploadPanding(context, mounted) async {
    if (isEdit) {
      _postIdPanding = editData?.postID ?? '';
      _boostContentBuy(context);
    } else {
      ShowGeneralDialog.loadingDialog(context, uploadProses: true);
      _createPostContentV2(context, mounted);
    }
  }

  Future<void> _boostContentBuy(BuildContext context) async {
    final bankCode = context.read<PaymentMethodNotifier>().bankSelected;
    isLoading = true;
    bool ownership = false;
    if (isEdit && certified && ownershipEULA) {
      ownership = false;
    } else if (certified) {
      ownership = true;
    }
    Map data = {
      "dateStart": _boostContent?.dateBoostStart,
      "dateEnd": _boostContent?.dateBoostEnd,
      "type": _boostContent?.typeBoost,
      "bankcode": bankCode,
      "paymentmethod": "VA",
      "postID": postIdPanding,
      "ownership": ownership,
    };
    if (_boostContent?.typeBoost == 'manual') {
      data['interval'] = _boostContent?.intervalBoost?.sId;
      data['session'] = _boostContent?.sessionBoost?.sId;
    }
    try {
      final notifier = UtilsBlocV2();
      await notifier.postBostContentPre(context, data: data);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.getMasterBoostError) {
        isLoading = false;
        var errorData = ErrorModel.fromJson(fetch.data);
        Routing().moveBack();
        ShowBottomSheet().onShowColouredSheet(
          context,
          errorData.message ?? '',
          maxLines: 2,
          iconSvg: "${AssetPath.vectorPath}remove.svg",
          color: kHyppeDanger,
        );
      } else if (fetch.utilsState == UtilsState.getMasterBoostSuccess) {
        boostPaymentResponse = BoostResponse.fromJson(fetch.data);
        Future.delayed(const Duration(seconds: 0), () {
          Routing().moveAndPop(Routes.boostPaymentSummary);
          String message = '';
          if (certified) {
            message = "${System().convertTypeContent(
              System().validatePostTypeV2(featureType),
            )} ${language.hasBeenSuccessfullyRegisteredForOwnershipBoostedCheckYourProfileForDetails}";
          } else {
            message = "${System().convertTypeContent(
              System().validatePostTypeV2(featureType),
            )} ${language.hasBeenSuccessfullyRegisteredForBoostedCheckYourProfileForDetails}";
          }
          ShowBottomSheet().onShowColouredSheet(
            context,
            message,
            subCaption: '',
            maxLines: 3,
            color: kHyppeLightSuccess,
          );
          // context.read<MainNotifier>().startTimer();
        });
        _isLoading = false;
      }
    } catch (e) {
      print(e);
      ShowBottomSheet().onShowColouredSheet(context, 'Somethink Wrong', color: kHyppeDanger);
    }
    notifyListeners();
  }

  navigateToTransAndLoby(BuildContext context) {
    Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
    Routing().move(Routes.transaction);
    _onExit();
  }

  exitBoostPage() {
    tmpstartDate = DateTime(1000);
    tmpfinsihDate = DateTime(1000);
    tmpBoost = '';
    tmpBoostTime = '';
    tmpBoostInterval = '';
    tmpBoostIntervalId = '';
    tmpBoostTimeId = '';
    notifyListeners();
    Routing().moveBack();
  }

  bool _checkChallenge = true;
  bool get checkChallenge => _checkChallenge;
  set checkChallenge(bool state) {
    _checkChallenge = state;
    notifyListeners();
  }

  Future check(BuildContext context) async {
    try {
      final bannerNotifier = ChallangeBloc();
      await bannerNotifier.checkChallengeStatus(context);
      final fetch = bannerNotifier.userFetch;

      if (fetch.challengeState == ChallengeState.getPostSuccess) {
        checkChallenge = fetch.data['join_status'];
      } else {
        checkChallenge = false;
      }
    } catch (e) {
      e.logger();
      checkChallenge = false;
    }
  }
}
