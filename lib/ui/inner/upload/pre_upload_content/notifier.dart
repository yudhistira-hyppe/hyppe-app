import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
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
// import 'package:flutter_masked_text/flutter_masked_text.dart';

class PreUploadContentNotifier with ChangeNotifier {
  final _eventService = EventService();
  final _socketService = SocketService();
  late UpdateContentsArgument _arguments;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController captionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  //final priceController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');

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
  bool _toSell = false;
  bool _includeTotalViews = false;
  bool _includeTotalLikes = false;
  bool _priceIsFilled = false;
  bool _isSavedPrice = false;

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
  bool get toSell => _toSell;
  bool get includeTotalViews => _includeTotalViews;
  bool get includeTotalLikes => _includeTotalLikes;
  bool get priceIsFilled => _priceIsFilled;
  bool get isSavedPrice => _isSavedPrice;
  UpdateContentsArgument get updateArguments => _arguments;

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
    if (!val) {
      _toSell = false;
    }
    notifyListeners();
  }

  set certifiedTmp(bool val) {
    _certifiedTmp = val;
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

  set setUpdateArguments(UpdateContentsArgument args) {
    _arguments = args;
    notifyListeners();
  }

  void onWillPop(BuildContext context) =>
      ShowBottomSheet.onShowCancelPost(context, onCancel: () => _onExit());

  void handleTapOnLocation(String value) => selectedLocation = value;

  void handleDeleteOnLocation() => selectedLocation = '';

  bool _validateDescription() => captionController.text.length >= 5;

  bool _validatePrice() => priceController.text.isNotEmpty;

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
    selectedLocation = '';
    allowComment = true;
    certified = false;
    captionController.clear();
    tagsController.clear();
    priceController.clear();
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
        visibility: visibility,
        tags: tagsController.text,
        allowComment: allowComment,
        certified: certified,
        fileContents: fileContent!,
        description: captionController.text,
        saleAmount: _toSell ? priceController.text : "0",
        saleLike: _includeTotalLikes,
        saleView: _includeTotalViews,
        rotate: _orientation ?? NativeDeviceOrientation.portraitUp,
        onReceiveProgress: (count, total) {
          _eventService.notifyUploadReceiveProgress(
              ProgressUploadArgument(count: count, total: total));
        },
        onSendProgress: (received, total) {
          _eventService.notifyUploadSendProgress(
              ProgressUploadArgument(count: received, total: total));
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

  Future _updatePostContentV2(BuildContext context,
      {required String postID, required String content}) async {
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
    _selectedLocation = '';
    context.read<CameraNotifier>().orientation = null;
    context.read<PreviewContentNotifier>().isForcePaused = false;
    Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
  }

  Future<void> onClickPost(BuildContext context,
      {required bool onEdit, ContentData? data, String? content}) async {
    if (_toSell) {
      if (!_validatePrice()) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          language.priceIsNotEmpty!,
          color: Theme.of(context).colorScheme.error,
          maxLines: 2,
        );
        return;
      }
    }

    if (!_validateDescription()) {
      ShowBottomSheet().onShowColouredSheet(
        context,
        language.descriptionCanOnlyWithMin5Characters!,
        color: Theme.of(context).colorScheme.error,
        maxLines: 2,
      );
      return;
    }

    final connection = await System().checkConnections();
    if (!connection) {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onClickPost(context, onEdit: onEdit, data: data, content: content);
      });
      return;
    }

    checkKeyboardFocus(context);
    if (onEdit) {
      _updatePostContentV2(context, postID: data!.postID!, content: content!);
    } else {
      _createPostContentV2();
    }

    // if (_validateDescription()) {
    //   if (connection) {
    //     // if (_validatePrice()) {
    //     //   Routing().move(Routes.reviewSellContent, argument: _arguments);
    //     // } else {
    //     //   ShowBottomSheet().onShowColouredSheet(
    //     //     context,
    //     //     language.priceIsNotEmpty!,
    //     //     color: Theme.of(context).colorScheme.error,
    //     //     maxLines: 2,
    //     //   );
    //     // }

    //     checkKeyboardFocus(context);
    //     if (onEdit) {
    //       _updatePostContentV2(context,
    //           postID: data!.postID!, content: content!);
    //     } else {
    //       _createPostContentV2();
    //     }
    //   } else {
    //     ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
    //       Routing().moveBack();
    //       onClickPost(context, onEdit: onEdit, data: data, content: content);
    //     });
    //   }
    // } else {
    //   ShowBottomSheet().onShowColouredSheet(
    //     context,
    //     language.descriptionCanOnlyWithMin5Characters!,
    //     color: Theme.of(context).colorScheme.error,
    //     maxLines: 2,
    //   );
    // }
  }

  Future<Uint8List?> makeThumbnail() async {
    Uint8List? _thumbnails = await VideoThumbnail.thumbnailData(
      video: fileContent![0]!,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return _thumbnails;
  }

  validateIdCard() async {
    _onExit();

    final BuildContext context = Routing.navigatorKey.currentContext!;
    Provider.of<MainNotifier>(context, listen: false).openValidationIDCamera =
        true;
    notifyListeners();
    clearUpAndBackToHome(context);
  }
}
