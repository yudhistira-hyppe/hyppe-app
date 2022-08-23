import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/view/bloc.dart';
import 'package:hyppe/core/bloc/view/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart' as v2;
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/services/locations.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/file_extension.dart';
import 'package:hyppe/core/constants/post_follow_user.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_view/story_view.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' as intl;

class System {
  System._private();

  static final System _instance = System._private();

  factory System() {
    return _instance;
  }

  Future<bool> checkConnections() async {
    bool connection = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = true;
      }
    } on SocketException catch (_) {
      connection = false;
    }
    return connection;
  }

  String? showUserPicture(String? url) {
    if (url != null) {
      return Env.data.baseUrl + "/" + url + "?x-auth-token=" + SharedPreference().readStorage(SpKeys.userToken) + "&x-auth-user=" + SharedPreference().readStorage(SpKeys.email);

      // return Env.data.baseUrl + url +
      //     "?x-auth-token=" +
      //     SharedPreference().readStorage(SpKeys.userToken) +
      //     "&x-auth-user=" +
      //     SharedPreference().readStorage(SpKeys.email);

    } else {
      return null;
    }
  }

  String capitalizeFirstLetter(String letter) => letter[0].toUpperCase() + letter.substring(1).toLowerCase();

  bool validateUrl(String url) {
    try {
      return Uri.tryParse(url)!.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  validateEmail(String email) {
    return email.contains(RegExp(r"^(([^<>()[\]\\.,;:\s@\”]+(\.[^<>()[\]\\.,;:\s@\”]+)*)|(\”.+\”))@((\[[0–9]{1,3}\.[0–9]{1,3}\.[0–9]{1,3}\.[0–9]{1,3}\])|(([a-zA-Z\-0–9]+\.)+[a-zA-Z]{2,}))$"))
        ? true
        : false;
  }

  validateUsername(String username, {bool withCapitalUtility = false}) {
    if (!withCapitalUtility) {
      return username.contains(RegExp(r"^(?!.\.\.)(?!.\.$)[^\W][\w.]{4,29}$", caseSensitive: false, multiLine: true)) ? true : false;
    } else {
      return username.contains(RegExp(r"[A-Z]"))
          ? false
          : username.contains(RegExp(r"^(?!.\.\.)(?!.\.$)[^\W][\w.]{4,29}$", caseSensitive: false, multiLine: true))
              ? true
              : false;
    }
  }

  validatePhoneNumber(String phoneNumber) {
    return phoneNumber.contains(RegExp(r"(^(?:[+0]9)?[0-9]{10,20}$)")) ? true : false;
  }

  Future openSetting() async {
    openAppSettings().then((bool hasOpened) => debugPrint('App Settings opened: ' + hasOpened.toString()));
  }

  Future<PermissionStatus> checkPermission({required Permission permission}) async {
    PermissionStatus _status = await permission.status;
    return _status;
  }

  basenameFiles(String filePath) {
    return path.basename(filePath);
  }

  String? extensionFiles(String filePath) {
    return path.extension(filePath);
  }

  String? lookupContentMimeType(String content) {
    return lookupMimeType(content);
  }

  String validatePostTypeV2(FeatureType? t) {
    switch (t) {
      case FeatureType.pic:
        return "pict";
      case FeatureType.vid:
        return "vid";
      case FeatureType.diary:
        return "diary";
      case FeatureType.story:
        return "story";
      case FeatureType.txtMsg:
        return "txt_msg";
      default:
        return "";
    }
  }

  FeatureType getPostType(String t) {
    switch (t) {
      case "pict":
        return FeatureType.pic;
      case "vid":
        return FeatureType.vid;
      case "diary":
        return FeatureType.diary;
      case "story":
        return FeatureType.story;
      case "txt_msg":
        return FeatureType.txtMsg;
      default:
        return FeatureType.other;
    }
  }

  ErrorType getErrorTypeV2(FeatureType t) {
    // ignore: missing_enum_constant_in_switch
    switch (t) {
      case FeatureType.pic:
        return ErrorType.pic;
      case FeatureType.vid:
        return ErrorType.vid;
      case FeatureType.diary:
        return ErrorType.diary;
      case FeatureType.story:
        return ErrorType.peopleStory;
      default:
        return ErrorType.unknown;
    }
  }

  FeatureType getFeatureTypeV2(String t) {
    // ignore: missing_enum_constant_in_switch
    switch (t) {
      case 'pict':
        return FeatureType.pic;
      case 'vid':
        return FeatureType.vid;
      case 'diary':
        return FeatureType.diary;
      case 'story':
        return FeatureType.story;
      default:
        return FeatureType.other;
    }
  }

  validateType(String? type) {
    String _contentType = '';
    if (type == 'image') {
      _contentType = 'pic,$_contentType';
    }
    _contentType = 'vid,$_contentType';
    return _contentType;
  }

  OverlayEntry createPopupDialog(Widget widgetToOverlay) {
    return OverlayEntry(builder: (context) => widgetToOverlay);
  }

  dateFormatter(String dateParams, int displayOption) {
    String? value;
    if (displayOption == 0) {
      value = DateFormat.yMMMd().format(DateTime.parse(dateParams));
    } else if (displayOption == 1) {
      value = DateFormat('hh:mm a').format(DateTime.parse(dateParams));
    } else if (displayOption == 2) {
      value = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(dateParams));
    }
    return value;
  }

  Future<String> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.androidId ?? 'unknown';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor ?? 'unknown';
    } else if (kIsWeb) {
      // The web doesnt have a device UID, so use a combination fingerprint as an example
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = (webInfo.vendor ?? '') + (webInfo.userAgent ?? '') + webInfo.hardwareConcurrency.toString();
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId ?? 'unknown';
    }
    return deviceIdentifier;
  }

  Future<IosDeviceInfo> getIosInfo() async {
    var deviceInfo = DeviceInfoPlugin();
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo;
  }

  Future<VideoData?> getVideoMetadata(String file) async {
    final videoInfo = FlutterVideoInfo();
    var info = await videoInfo.getVideoInfo(file);
    return info;
  }

  Future<void> shareText({required String dynamicLink, required BuildContext context}) async {
    await Share.share(dynamicLink);
  }

  String postStatusFollow(StatusFollowing? sts) {
    // ignore: missing_enum_constant_in_switch
    switch (sts) {
      case StatusFollowing.rejected:
        return P_FOLLOW;
      case StatusFollowing.requested:
        return P_UNFOLLOW;
      case StatusFollowing.following:
        return P_UNFOLLOW;
      default:
        return '';
    }
  }

  StatusFollowing getStatusFollow(String? sts) {
    switch (sts) {
      case P_FOLLOW:
        return StatusFollowing.requested;
      case P_ACCEPTED:
        return StatusFollowing.following;
      case P_REJECTED:
        return StatusFollowing.rejected;
      default:
        return StatusFollowing.none;
    }
  }

  InteractiveEventType convertEventType(String? eventType) {
    switch (eventType) {
      case "UNFOLLOW":
        return InteractiveEventType.unfollow;
      case "FOLLOWER":
        return InteractiveEventType.follower;
      case "FOLLOWING":
        return InteractiveEventType.following;
      case "VIEW":
        return InteractiveEventType.view;
      case "REACTION":
        return InteractiveEventType.reaction;
      default:
        return InteractiveEventType.none;
    }
  }

  InteractiveEvent convertEvent(String? event) {
    switch (event) {
      case "INITIAL":
        return InteractiveEvent.initial;
      case "ACCEPT":
        return InteractiveEvent.accept;
      case "REQUEST":
        return InteractiveEvent.request;
      case "DONE":
        return InteractiveEvent.done;
      case "REVOKE":
        return InteractiveEvent.revoke;
      default:
        return InteractiveEvent.none;
    }
  }

  String convertEventTypeToString(InteractiveEventType? eventType) {
    switch (eventType) {
      case InteractiveEventType.unfollow:
        return "UNFOLLOW";
      case InteractiveEventType.follower:
        return "FOLLOWER";
      case InteractiveEventType.following:
        return "FOLLOWING";
      case InteractiveEventType.view:
        return "VIEW";
      case InteractiveEventType.reaction:
        return "REACTION";
      default:
        return "";
    }
  }

  String convertEventToString(InteractiveEvent? event) {
    switch (event) {
      case InteractiveEvent.initial:
        return "INITIAL";
      case InteractiveEvent.accept:
        return "ACCEPT";
      case InteractiveEvent.request:
        return "REQUEST";
      case InteractiveEvent.done:
        return "DONE";
      case InteractiveEvent.revoke:
        return "REVOKE";
      default:
        return "";
    }
  }

  String convertMessageEventTypeToString(DiscussEventType? eventType) {
    switch (eventType) {
      case DiscussEventType.directMsg:
        return "DIRECT_MSG";
      case DiscussEventType.comment:
        return "COMMENT";
      default:
        return "";
    }
  }

  Future<Map<String, List<File>?>> getLocalMedia({
    FeatureType? featureType,
    required BuildContext context,
  }) async {
    final ImagePicker _imagePicker = ImagePicker();

    final notifier = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    Duration _duration;
    String _errorMsg = '';
    List<File>? _filePickerResult;

    bool _validateCountPost(int count) {
      if (count > 10) {
        _errorMsg = notifier.pleaseSelectMax10Items!;
        return true;
      }
      return false;
    }

    if (featureType == null) {
      // used for change profile picture only
      final _pickerResult = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (_pickerResult != null) {
        _filePickerResult = [File(_pickerResult.path)];
      }
    } else {
      // used for picking content posts
      if (featureType == FeatureType.vid) {
        await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false).then((result) {
          if (result != null) {
            if (result.files.single.extension!.toLowerCase() == MP4 || result.files.single.extension!.toLowerCase() == MOV) {
              _filePickerResult = [File(result.files.single.path!)];
            } else {
              _errorMsg = '${notifier.weCurrentlySupportOnlyMP4andMOVformat!} ${result.names.single}';
            }
          }
        });
      }

      if (featureType == FeatureType.pic) {
        final _pickerResult = await _imagePicker.pickImage(source: ImageSource.gallery);

        if (_pickerResult != null) {
          // TODO: Future implementation, user will be able to select multiple images
          _filePickerResult = [File(_pickerResult.path)];
        }
      }

      if (featureType == FeatureType.diary) {
        final _pickerResult = await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false);

        // validasi durasi
        if (_pickerResult != null) {
          // untuk menampung file yang failed di validasi
          String _failFile = '';

          // validasi count post
          if (_validateCountPost(_pickerResult.files.length) == false) {
            for (int element = 0; element < _pickerResult.files.length; element++) {
              if (_pickerResult.files[element].extension!.toLowerCase() == MP4 || _pickerResult.files[element].extension!.toLowerCase() == MOV) {
                await getVideoMetadata(_pickerResult.files[element].path!).then((value) {
                  _duration = Duration(milliseconds: int.parse(value!.duration!.toInt().toString()));

                  // hapus file yang durasinya lebih dari 60 detik
                  if (_duration.inSeconds > 60) {
                    _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                    _pickerResult.files.removeAt(element);
                  }
                });
              }
            }

            // show toast if there is fail file
            if (_failFile.isNotEmpty) {
              _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature!} :\n$_failFile';
            }

            if (_pickerResult.files.isNotEmpty) {
              _filePickerResult = _pickerResult.files.map((file) => File(file.path!)).toList();
            }
          }
        }
      }

      if (featureType == FeatureType.story) {
        final _pickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.media, allowCompression: false);

        // validasi durasi
        if (_pickerResult != null) {
          // untuk menampung file yang failed di validasi
          String _failFile = '';

          // validasi count post
          if (_validateCountPost(_pickerResult.files.length) == false) {
            for (int element = 0; element < _pickerResult.files.length; element++) {
              // validasi content type
              if (_pickerResult.files[element].extension!.toLowerCase() == MP4 || _pickerResult.files[element].extension!.toLowerCase() == MOV) {
                await getVideoMetadata(_pickerResult.files[element].path!).then((value) {
                  _duration = Duration(milliseconds: int.parse(value!.duration!.toInt().toString()));

                  // hapus file yang durasinya lebih dari 15 detik
                  if (_duration.inSeconds > 15) {
                    _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                    _pickerResult.files.removeAt(element);
                  }
                });
              }
            }

            // show toast if there is fail file
            if (_failFile.isNotEmpty) {
              _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature!} :\n$_failFile';
            }

            if (_pickerResult.files.isNotEmpty) {
              _filePickerResult = _pickerResult.files.map((file) => File(file.path!)).toList();
            }
          }
        }
      }
    }

    return {_errorMsg: _filePickerResult};
  }

  void actionReqiredIdCard(
    BuildContext context, {
    required Function() action,
    bool uploadContentAction = true,
  }) async {
    bool _permissionStatus = true;

    if (uploadContentAction) {
      // request permission
      _permissionStatus = await requestPrimaryPermission(context);
    }

    if (!_permissionStatus) {
      ShowGeneralDialog.permanentlyDeniedPermission(context);
    } else {
      final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);
      if (notifier.user.profile != null) {
        // debugPrint(notifier.user.profile!.isComplete.toString());
        // debugPrint(notifier.user.profile!.isIdVerified.toString());
        // if (!notifier.user.profile!.isComplete!) {
        //   ShowBottomSheet.onShowCompleteProfile(context);
        // } else if (!notifier.user.profile!.isIdVerified!) {
        if (!notifier.user.profile!.isIdVerified!) {
          ShowBottomSheet.onShowIDVerification(context);
        } else {
          action();
        }
      } else {
        ShowBottomSheet.onShowSomethingWhenWrong(context);
      }
    }
  }

  Future<bool> requestPermission(BuildContext context, {required List<Permission> permissions}) async {
    // request permission
    final permissionsStatus = await permissions.request();

    return !permissionsStatus.values.toList().contains(PermissionStatus.denied);
  }

  Future<bool> requestPrimaryPermission(BuildContext context) async {
    // request permission
    return requestPermission(context, permissions: [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.mediaLibrary,
      Permission.photos,
    ]);

    // await [
    //   Permission.camera,
    //   Permission.microphone,
    //   Permission.storage,
    //   Permission.mediaLibrary,
    //   Permission.photos,
    // ].request();

    // // check permission
    // var cameraPermission = await checkPermission(permission: Permission.camera);
    // var microphonePermission = await checkPermission(permission: Permission.microphone);
    // var storagePermission = await checkPermission(permission: Permission.storage);

    // return cameraPermission.isGranted && microphonePermission.isGranted && storagePermission.isGranted;
  }

  String searchCategory(SearchCategory searchCategory) {
    switch (searchCategory) {
      case SearchCategory.vid:
        return 'vid';
      case SearchCategory.diary:
        return 'diary';
      case SearchCategory.pic:
        return 'pic';
      case SearchCategory.account:
        return 'account';
      case SearchCategory.htags:
        return 'htags';
    }
  }

  reactionLike(dynamic data) {
    switch (data) {
      case true:
        return 1;
      default:
        return 0;
    }
  }

  String postNotificationCategory(NotificationCategory notificationCategory) {
    switch (notificationCategory) {
      case NotificationCategory.all:
        return '';
      case NotificationCategory.like:
        return 'LIKE';
      case NotificationCategory.comment:
        return 'COMMENT';
      case NotificationCategory.follower:
        return 'FOLLOWER';
      case NotificationCategory.following:
        return 'FOLLOWING';
      case NotificationCategory.mention:
        return 'REACTION';
      case NotificationCategory.general:
        return 'GENERAL';
    }
  }

  NotificationCategory getNotificationCategory(String category) {
    switch (category) {
      case 'LIKE':
        return NotificationCategory.like;
      case 'COMMENT':
        return NotificationCategory.comment;
      case 'FOLLOWER':
        return NotificationCategory.follower;
      case 'FOLLOWING':
        return NotificationCategory.following;
      case 'REACTION':
        return NotificationCategory.mention;
      case 'GENERAL':
        return NotificationCategory.general;
      default:
        return NotificationCategory.all;
    }
  }

  readTimestamp(int timestamp, BuildContext context, {required bool fullCaption}) {
    final translate = context.read<TranslateNotifierV2>().translate;
    String time = '';
    int seconds = (DateTime.now().millisecondsSinceEpoch - timestamp) ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = seconds ~/ 3600;
    int days = seconds ~/ 86400;
    int weeks = seconds ~/ 604800;
    if (weeks > 0) {
      time = weeks.toString() +
          (fullCaption
              ? weeks > 1
                  ? " ${translate.weeksAgo}"
                  : " ${translate.weekAgo}"
              : translate.w!);
    } else if (days > 0) {
      time = days.toString() +
          (fullCaption
              ? days > 1
                  ? " ${translate.daysAgo}"
                  : " ${translate.dayAgo}"
              : translate.d!);
    } else if (hours > 0) {
      time = hours.toString() +
          (fullCaption
              ? hours > 1
                  ? " ${translate.hoursAgo}"
                  : " ${translate.hourAgo}"
              : translate.h!);
    } else if (minutes > 0) {
      time = minutes.toString() +
          (fullCaption
              ? minutes > 1
                  ? " ${translate.minutesAgo}"
                  : " ${translate.minuteAgo}"
              : translate.m!);
    } else {
      time = fullCaption ? translate.justNow! : translate.now!;
    }
    return time;
  }

  Future<Uri> createdDynamicLink(
    BuildContext context, {
    bool shareImmediately = true,
    bool copiedToClipboard = false,
    required DynamicLinkData dynamicLinkData,
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Env.data.deeplinkBaseUrl,
      link: Uri.parse('${Env.data.deeplinkBaseUrl}${dynamicLinkData.routes}?postID=${dynamicLinkData.postID}&sender_email=${dynamicLinkData.email}'),
      androidParameters: AndroidParameters(
        minimumVersion: 0,
        packageName: Env.data.appID,
      ),
      iosParameters: IOSParameters(
        bundleId: Env.data.appID,
        minimumVersion: '1.0.0',
        appStoreId: Env.data.appStoreID,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        description: dynamicLinkData.description,
        imageUrl: Uri.parse('${dynamicLinkData.thumb}'),
        title: 'Hyppe App | ${dynamicLinkData.fullName}',
      ),
    );

    var _linkResult = await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    if (copiedToClipboard) {
      copyToClipboard(_linkResult.shortUrl.toString());
    }

    if (shareImmediately && !copiedToClipboard) {
      await shareText(dynamicLink: _linkResult.shortUrl.toString(), context: context);
    }

    return _linkResult.shortUrl;
  }

  Future<Uri> createdReferralLink(BuildContext context) async {
    final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Env.data.deeplinkBaseUrl,
      link: Uri.parse('${Env.data.deeplinkBaseUrl}${Routes.otherProfile}?referral=1&sender_email=${notifier.user.profile!.email}'),
      androidParameters: AndroidParameters(
        minimumVersion: 0,
        packageName: Env.data.appID,
      ),
      iosParameters: IOSParameters(
        bundleId: Env.data.appID,
        minimumVersion: '1.0.0',
        appStoreId: Env.data.appStoreID,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        description: "Referral",
        imageUrl: Uri.parse('${notifier.user.profile!.avatar}'),
        title: 'Hyppe App | ${notifier.user.profile!.fullName}',
      ),
    );

    var _linkResult = await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    return _linkResult.shortUrl;
  }

  Future copyToClipboard(String data) async => await Clipboard.setData(ClipboardData(text: data));

  String formatDuration(int positionInMs) {
    final ms = positionInMs;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    final minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
            ? '00'
            : '0$hours';

    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
            ? '00'
            : '0$minutes';

    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
            ? '00'
            : '0$seconds';

    final formattedTime = '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
    return formattedTime;
  }

  Future<String> convertWidgetToImage(GlobalKey globalKey) async {
    RenderRepaintBoundary repaintBoundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 3);
    ByteData? byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData!.buffer.asUint8List();
    final String _pathFile = path.join(await getSystemPath(params: 'editedImg'), '${DateTime.now().toIso8601String()}.png');
    File imgFile = File(_pathFile);
    await imgFile.writeAsBytes(uint8list);
    return imgFile.absolute.path;
  }

  Future<String> getSystemPath({String params = ''}) async {
    var _directory = await getTemporaryDirectory();
    var _result = await Directory('${_directory.path}/$params').create(recursive: true);
    return _result.absolute.path;
  }

  Future<PackageInfo> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  String generateUUID() => const Uuid().v4();

  String formatterNumber(int? number, {String? locale}) => NumberFormat.compact(locale: locale ?? Platform.localeName).format(number ?? 0);

  bool mustNotContainYourNameOrEmail({
    required String text,
    required String name,
    required String email,
  }) {
    return text.contains(name) || text.contains(email);
  }

  bool atLeastEightCharacter({required String text}) {
    return text.length >= 8;
  }

  bool atLeastThreeThreetyCharacter(String text) {
    return text.length >= 3 && text.length <= 30;
  }

  bool canOnlyContainLettersNumbersPeriodsAndUnderscores(String text) {
    return text.contains(RegExp(r'^[a-zA-Z0-9._]+$'));
  }

  bool atLeastContainOneCharacterAndOneNumber({required String text}) {
    return text.length > 1 && text.contains(RegExp(r'[0-9]'));
  }

  bool passwordMatch({required String password, required String confirmPassword}) {
    return password == confirmPassword;
  }

  bool isLoggedInUser({required String email}) {
    return SharedPreference().readStorage(SpKeys.email) == email;
  }

  Future<void> increaseViewCount(BuildContext context, v2.ContentData data) async {
    final notifier = ViewBloc();
    await notifier.viewPostUserBloc(context, postId: data.postID!, emailOwner: data.email!);
    final fetch = notifier.viewFetch;
    if (!data.insight!.isView) {
      if (fetch.viewState == ViewState.viewUserPostSuccess) {
        data.insight?.views = (data.insight?.views ?? 0) + 1;
        data.insight!.isView = true;
      }
    }
  }

  Future<void> navigateToProfile(BuildContext context, String email, {StoryController? storyController}) async {
    final connect = await checkConnections();
    if (connect) {
      String myEmail = SharedPreference().readStorage(SpKeys.email) ?? "";
      if (email != myEmail) {
        context.read<OtherProfileNotifier>().checkFollowingToUser(context, email);
        if (storyController != null) {
          storyController.pause();
          Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email)).whenComplete(() => storyController.play());
        } else {
          Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
        }
      } else {
        storyController != null
            ? context.read<HomeNotifier>().navigateToProfilePage(context, whenComplete: true, onWhenComplete: () => storyController.play())
            : context.read<HomeNotifier>().navigateToProfilePage(context);
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  int? convertOrientation(NativeDeviceOrientation? orientation) {
    switch (orientation) {
      case NativeDeviceOrientation.landscapeRight:
        return 90;
      case NativeDeviceOrientation.portraitDown:
        return Platform.isIOS ? 270 : 180;
      case NativeDeviceOrientation.landscapeLeft:
        return Platform.isIOS ? 180 : 270;
      case NativeDeviceOrientation.portraitUp:
        return 0;
      default:
        return null;
    }
  }

  void systemUIOverlayTheme() {
    bool theme = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: theme ? Brightness.light : Brightness.dark,
      statusBarColor: theme ? kHyppeSurface : kHyppeLightSurface,
      systemNavigationBarIconBrightness: theme ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: theme ? kHyppeSurface : kHyppeLightSurface,
    ));
  }

  String? bodyMultiLang({required String? bodyEn, required String? bodyId}) {
    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);
    if (_isoCodeCache == "id") {
      return bodyId ?? bodyEn;
    }
    return bodyEn;
  }

  Future<bool> getLocation(BuildContext context) async {
    final notifier = Provider.of<WelcomeLoginNotifier>(context, listen: false);
    await Locations().permissionLocation();

    try {
      final check = await Locations().getLocation().then((value) async {
        if (value['latitude'] == 0.0) {
          return false;
        } else {
          notifier.latitude = value['latitude'];
          notifier.longitude = value['longitude'];
          return true;
        }
      }).timeout(const Duration(seconds: 3));
      if (check) {
        return true;
      } else {
        if (Platform.isIOS) {
          notifier.latitude = 0.0;
          notifier.longitude = 0.0;
          return true;
        } else {
          await ShowBottomSheet().onShowColouredSheet(
            context,
            'Please Allow Permission for Location',
            maxLines: 2,
            enableDrag: false,
            dismissible: false,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
          );
          openAppSettings();
          return false;
        }
      }
    } on TimeoutException catch (e) {
      notifier.latitude = 0.0;
      notifier.longitude = 0.0;
      return true;
    } on Error catch (e) {
      return false;
    }
  }

  String currencyFormat({required int? amount}) {
    return intl.NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(amount);
  }
}
