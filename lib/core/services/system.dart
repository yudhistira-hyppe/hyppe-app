import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/view/bloc.dart';
import 'package:hyppe/core/bloc/view/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/database/local_thumbnail.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
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
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
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
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' as intl;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../app.dart';
import '../arguments/general_argument.dart';
import '../bloc/ads_video/bloc.dart';
import '../bloc/ads_video/state.dart';
import '../models/collection/advertising/ads_video_data.dart';
import 'package:exif/exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/collection/advertising/view_ads_request.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String? showUserPicture(String? url) {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);
    if (url != null && email != null && token != null) {
      if (url.isNotEmpty) {
        if (url != 'null') {
          print("show image not apsara: ${Env.data.baseUrl}${Env.data.versionApi}$url?x-auth-token=$token&x-auth-user=$email&rundom=");
          return '${Env.data.baseUrl}${Env.data.versionApi}$url?x-auth-token=$token&x-auth-user=$email&rundom=';
        } else {
          return '';
        }

        // return Env.data.baseUrl +
        //     "/${Env.data.versionApi}/" +
        //     url +
        //     "?x-auth-token=" +
        //     token +
        //     "&x-auth-user=" +
        //     email;
      } else {
        return '';
      }

      // return Env.data.baseUrl + url +
      //     "?x-auth-token=" +
      //     SharedPreference().readStorage(SpKeys.userToken) +
      //     "&x-auth-user=" +
      //     SharedPreference().readStorage(SpKeys.email);
    } else {
      return '';
    }
  }

  String getTitleHyppe(HyppeType type) {
    switch (type) {
      case HyppeType.HyppeVid:
        return 'Vid';
      case HyppeType.HyppeDiary:
        return 'Diary';
      case HyppeType.HyppePic:
        return 'Pic';
    }
  }

  String capitalizeFirstLetter(String letter) => letter[0].toUpperCase() + letter.substring(1).toLowerCase();

  bool validateUrl(String url) {
    try {
      return Uri.tryParse(url)?.isAbsolute ?? false;
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

  removeSpecialChar(String str) {
    String result = str.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    return result;
  }

  basenameFiles(String filePath) {
    return removeSpecialChar(path.basename(filePath));
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

  dateFormatter(String dateParams, int displayOption, {String lang = "id"}) {
    String? value;
    if (displayOption == 0) {
      value = DateFormat.yMMMd().format(DateTime.parse(dateParams));
    } else if (displayOption == 1) {
      value = DateFormat('hh:mm a').format(DateTime.parse(dateParams));
    } else if (displayOption == 2) {
      value = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(dateParams));
    } else if (displayOption == 3) {
      value = DateFormat('d MMM yyyy').format(DateTime.parse(dateParams));
    } else if (displayOption == 4) {
      value = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateParams));
    } else if (displayOption == 5) {
      value = DateFormat('dd/MM/yyyy').format(DateTime.parse(dateParams));
    } else if (displayOption == 6) {
      value = DateFormat('HH:mm').format(DateTime.parse(dateParams));
    } else if (displayOption == 7) {
      value = DateFormat('d MMMM yyyy', lang).format(DateTime.parse(dateParams));
    } else if (displayOption == 8) {
      value = DateFormat('MMMM yyyy', lang).format(DateTime.parse(dateParams));
    }
    return value;
  }

  Future<String> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final deviceID = SharedPreference().readStorage(SpKeys.fcmToken);

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = "${androidInfo.id}-${androidInfo.hardware}-${androidInfo.serialNumber}-${androidInfo.board}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor ?? deviceID;
    } else if (kIsWeb) {
      // The web doesnt have a device UID, so use a combination fingerprint as an example
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = (webInfo.vendor ?? '') + (webInfo.userAgent ?? '') + webInfo.hardwareConcurrency.toString();
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId ?? deviceID;
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
    try {
      await Share.share(dynamicLink);
    } catch (e) {
      print("error log $e");
    }
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

  String getValueStringFollow(StatusFollowing state, LocalizationModelV2 locale) {
    switch (state) {
      case StatusFollowing.none:
        return locale.follow ?? 'Follow';
      case StatusFollowing.following:
        return locale.following ?? 'Following';
      case StatusFollowing.requested:
        return locale.requested ?? 'Requested';
      default:
        return locale.unverified ?? 'Follow';
    }
  }

  StatusFollowing getEnumFollowStatus(String status) {
    switch (status) {
      case 'TOFOLLOW':
        return StatusFollowing.none;
      case 'FOLLOWING':
        return StatusFollowing.following;
      case 'UNLINK':
        return StatusFollowing.requested;
      default:
        return StatusFollowing.rejected;
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
      case "VERIFICATIONID":
        return InteractiveEventType.verificationid;
      case "TRANSACTIONS":
        return InteractiveEventType.transactions;
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

  String convertTypeContent(String type) {
    switch (type) {
      case 'pict':
        return 'HyppePic';
      case 'vid':
        return 'HyppeVid';
      case 'diary':
        return 'HyppeDiary';
      default:
        return "";
    }
  }

  String getTimeWIB(String hour, String minute) {
    return '$hour:$minute WIB';
  }

  TransactionType convertTransactionType(String? type) {
    switch (type) {
      case "Sell":
        return TransactionType.sell;
      case "Buy":
        return TransactionType.buy;
      case "Withdraws":
        return TransactionType.withdrawal;
      case "BOOST_CONTENT":
        return TransactionType.boost;
      case "Rewards":
        return TransactionType.reward;
      default:
        return TransactionType.none;
    }
  }

  String convertTransactionTypeToString(TransactionType? event) {
    switch (event) {
      case TransactionType.sell:
        return "Sell";
      case TransactionType.buy:
        return "Buy";
      case TransactionType.withdrawal:
        return "Withdraws";
      case TransactionType.reward:
        return "Rewards";
      case TransactionType.none:
        return "";
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

  Future<void> _getStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await plugin.androidInfo;
      if (android.version.sdkInt < 33) {
        if (await Permission.storage.request().isGranted) {
          // permissionGranted = true;
        } else if (await Permission.storage.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.audio.request().isDenied) {
          // permissionGranted = false;
        }
      } else {
        if (await Permission.photos.request().isGranted) {
          // permissionGranted = true;
        } else if (await Permission.photos.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.photos.request().isDenied) {
          // permissionGranted = false;
        }
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        // permissionGranted = true;
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
        // permissionGranted = false;
      }
    }
  }

  Future<Map<String, List<File>?>> getLocalMedia({
    FeatureType? featureType,
    required BuildContext context,
    bool pdf = false,
    LocalizationModelV2? model,
    bool isVideo = false,
    int maxFile = 3,
    Function()? onException,
  }) async {
    final ImagePicker _imagePicker = ImagePicker();

    final notifier = context.read<TranslateNotifierV2>().translate;
    Duration _duration;
    String _errorMsg = '';
    List<File>? _filePickerResult;

    bool _validateCountPost(int count) {
      if (count > 10) {
        _errorMsg = notifier.pleaseSelectMax10Items ?? '';
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
      // used for KYC pick multi image
      if (featureType == FeatureType.other) {
        debugPrint("Masuk KYC");
        List<File>? imageFileList = [];
        List<File>? convertImageFile = [];
        if (pdf) {
          final _pickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
          // validasi durasi
          if (_pickerResult != null) {
            // untuk menampung file yang failed di validasi
            String _failFile = '';

            // validasi count post
            if (_validateCountPost(_pickerResult.files.length) == false) {
              for (int element = 0; element < _pickerResult.files.length; element++) {
                // validasi content type
                if (_pickerResult.files[element].extension?.toLowerCase() == MP4 || _pickerResult.files[element].extension?.toLowerCase() == MOV) {
                  await getVideoMetadata(_pickerResult.files[element].path ?? '').then((value) {
                    _duration = Duration(milliseconds: int.parse(value?.duration?.toInt().toString() ?? ''));

                    // hapus file yang durasinya lebih dari 15 detik
                    if (_duration.inSeconds > 15) {
                      _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                      _pickerResult.files.removeAt(element);
                    }
                  });
                }
              }

              // show toast if there is fail file
              // if (_failFile.isNotEmpty) {
              //   _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature} :\n$_failFile';
              // }

              if (_pickerResult.files.isNotEmpty) {
                _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
              }
            }
          }
        } else {
          var permsiion = await System().checkPermission(permission: Permission.storage);
          if (permsiion == PermissionStatus.denied) {
            try {
              await Permission.storage.request();
              await Permission.storage.status.isGranted;
              await Permission.photos.status.isGranted;
            } catch (e) {
              print(e);
            }
          }
          try {
            final List<XFile>? selectedImages = await _imagePicker.pickMultiImage(imageQuality: 90);
            if ((selectedImages?.isNotEmpty ?? false) && (selectedImages?.length ?? 0) <= maxFile) {
              for (XFile file in selectedImages ?? []) {
                debugPrint(file.path);
                imageFileList.add(File(file.path));
              }
              if (imageFileList.contains('heic') || imageFileList.contains('heif')) {
                final tmpDir = (await getTemporaryDirectory()).path;
                final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.jpg';
                final result = await FlutterImageCompress.compressAndGetFile(
                  imageFileList.first.path,
                  target,
                  format: CompressFormat.png,
                );

                if (result == null) {
                  // error handling here
                  print('error result');
                } else {
                  convertImageFile.add(File(result.path));
                }
                print('Path ${convertImageFile.first.path}');
                _filePickerResult = convertImageFile;
              } else {
                _filePickerResult = imageFileList;
              }
            } else {
              _errorMsg = "${notifier.pleaseSelectOneortheMaxFileis} $maxFile";
            }
          } catch (e) {
            print(e);
          }
        }
      }

      // used for picking content posts
      if (featureType == FeatureType.vid) {
        var permsiion = await System().checkPermission(permission: Permission.storage);
        print("------------------request permsiion-------------");
        print(permsiion);
        if (permsiion == PermissionStatus.denied) {
          try {
            await Permission.storage.request();
            await Permission.storage.status.isGranted;
            await Permission.videos.status.isGranted;
            await Permission.photos.status.isGranted;

            // I noticed that sometimes popup won't show after user press deny
            // so I do the check once again but now go straight to appSettings
            // if (permsiion == PermissionStatus.denied) {
            //   await openAppSettings();
            // }
          } catch (e) {
            print(e);
          }
        }
        print(permsiion);
        await _getStoragePermission();
        await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false).then((result) async {
          if (result != null) {
            for (int element = 0; element < result.files.length; element++) {
              if (result.files[element].extension?.toLowerCase() == MP4 || result.files[element].extension?.toLowerCase() == MOV) {
                await getVideoMetadata(result.files[element].path ?? '').then((value) {
                  _duration = Duration(milliseconds: int.parse(value?.duration?.toInt().toString() ?? ''));

                  // hapus file yang durasinya lebih dari 60 detik
                  if (_duration.inSeconds < 15) {
                    // _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                    if (onException != null) {
                      onException();
                    }
                    result.files.removeAt(element);
                  }
                });
              } else {
                _errorMsg = '${notifier.weCurrentlySupportOnlyMP4andMOVformat} ${result.names.single}';
              }
            }

            if (result.files.isNotEmpty) {
              _filePickerResult = result.files.map((file) => File(file.path ?? '')).toList();
            }
          }
        });
      }

      if (featureType == FeatureType.pic) {
        // await FilePicker.platform.pickFiles(type: FileType.image, allowCompression: false).then((result) {
        //   if (result != null) {
        //     _filePickerResult = [File(result.files.single.path ?? '')];
        //   }
        // });

        final pickerResult = await _imagePicker.pickImage(source: ImageSource.gallery);

        if (pickerResult != null) {
          _filePickerResult = [File(pickerResult.path)];
        }
      }

      if (featureType == FeatureType.diary) {
        final _pickerResult = await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: false);

        // validasi durasi
        if (_pickerResult != null) {
          // untuk menampung file yang failed di validasi
          // String _failFile = '';

          // validasi count post
          if (_validateCountPost(_pickerResult.files.length) == false) {
            for (int element = 0; element < _pickerResult.files.length; element++) {
              if (_pickerResult.files[element].extension?.toLowerCase() == MP4 || _pickerResult.files[element].extension?.toLowerCase() == MOV) {
                await getVideoMetadata(_pickerResult.files[element].path ?? '').then((value) {
                  _duration = Duration(milliseconds: int.parse(value?.duration?.toInt().toString() ?? ''));

                  // hapus file yang durasinya lebih dari 60 detik
                  if (_duration.inSeconds < 15) {
                    if (onException != null) {
                      onException();
                    }
                    // _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                    _pickerResult.files.removeAt(element);
                  }
                });
              }
            }

            // show toast if there is fail file
            // if (_failFile.isNotEmpty) {
            //   _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature} :\n$_failFile';
            // }

            if (_pickerResult.files.isNotEmpty) {
              _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
            }
          }
        }
      }

      if (featureType == FeatureType.story) {
        final _pickerResult = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.media, allowCompression: false);
        if (_pickerResult != null) {
          // untuk menampung file yang failed di validasi
          // String _failFile = '';

          // validasi count post
          if (_validateCountPost(_pickerResult.files.length) == false) {
            for (int element = 0; element < _pickerResult.files.length; element++) {
              // validasi content type

              print('path directory: ${_pickerResult.files[element].extension}');
              // if (_pickerResult.files[element].extension?.toLowerCase() == PVT) {
              //   final tmpDir = (await getTemporaryDirectory()).path;
              //   final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.heic';
              //   final result = await FlutterImageCompress.compressAndGetFile(
              //     _pickerResult.files[element].path ?? '',
              //     target,
              //     format: CompressFormat.heic,
              //     quality: 90,
              //   );
              //   if (result != null) {
              //     if (_filePickerResult == null) {
              //       _filePickerResult = [];
              //     }
              //     if (_pickerResult.files.isNotEmpty) {
              //       _filePickerResult?.add((File(result.path)));
              //     }
              //   }
              // } else if (_pickerResult.files[element].extension?.toLowerCase() == HEIF) {
              //   // // final tmpDir = (await getTemporaryDirectory()).path;
              //   // // final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.HEIC';
              //   // // final result = await FlutterImageCompress.compressAndGetFile(
              //   // //   _pickerResult.files[element].path ?? '',
              //   // //   target,
              //   // //   format: CompressFormat.heic,
              //   // //   quality: 90,
              //   // // );
              //   // ///
              //   // String outputPath = await System().getSystemPath(params: 'postVideo');
              //   // outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.heif';
              //   // String command = '-i "${_pickerResult.files[element].path}" -c copy $outputPath';
              //   // print('encode video: $command');
              //   // final session = await FFmpegKit.executeAsync(
              //   //   command,
              //   //       (session) async {
              //   //
              //   //   },
              //   //       (log) {
              //   //     print('FFmpegKit ${log.getMessage()}');
              //   //   },
              //   // );
              //   // final codeSession = await session.getReturnCode();
              //   // File? resultFirst;
              //   // if (ReturnCode.isSuccess(codeSession)) {
              //   //   print('ReturnCode = Success');
              //   //   resultFirst = File(outputPath);
              //   // } else if (ReturnCode.isCancel(codeSession)) {
              //   //   print('ReturnCode = Cancel');
              //   //
              //   //   throw 'Merge video is canceled';
              //   //   // Cancel
              //   // } else {
              //   //   print('ReturnCode = Error');
              //   //   throw 'Merge video is Error';
              //   //   // Error
              //   // }
              //   // ///
              //   // // String dir = path.dirname(_pickerResult.files[element].path ?? '');
              //   // // String newPath = path.join(dir, '${DateTime.now().millisecondsSinceEpoch}.heic');
              //   // // print('NewPath: ${newPath}');
              //   // // final result = await File(_pickerResult.files[element].path ?? '').rename(newPath);
              //   //
              //   // final tmpDir = (await getTemporaryDirectory()).path;
              //   // final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.jpg';
              //   // final result = await FlutterImageCompress.compressAndGetFile(
              //   //   resultFirst ?? '',
              //   //   target,
              //   //   format: CompressFormat.jpg,
              //   //   quality: 90,
              //   // );
              //   String? jpgPath = await HeifConverter.convert(_pickerResult.files[element].path ?? '', format: 'jpg');
              //   final result = File(jpgPath ?? '');
              //   if (_filePickerResult == null) {
              //     _filePickerResult = [];
              //   }
              //   if (_pickerResult.files.isNotEmpty) {
              //     _filePickerResult?.add(result);
              //   }
              // } else
              if (_pickerResult.files[element].extension?.toLowerCase() == MP4 || _pickerResult.files[element].extension?.toLowerCase() == MOV) {
                await getVideoMetadata(_pickerResult.files[element].path ?? '').then((value) {
                  _duration = Duration(milliseconds: int.parse(value?.duration?.toInt().toString() ?? ''));

                  // hapus file yang durasinya lebih dari 15 detik
                  if (_duration.inSeconds < 4) {
                    if (onException != null) {
                      onException();
                    }
                    // _failFile = '$_failFile, ${_pickerResult.files[element].name}\n';
                    _pickerResult.files.removeAt(element);
                  }
                });

                // show toast if there is fail file
                // if (_failFile.isNotEmpty) {
                //   _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature} :\n$_failFile';
                // }

                if (_pickerResult.files.isNotEmpty) {
                  _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
                }
              } else {
                if (_pickerResult.files.isNotEmpty) {
                  _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
                }
              }

              // show toast if there is fail file
              // if (_failFile.isNotEmpty) {
              //   _errorMsg = '${notifier.theFileDurationExceedsTheMaximumLimitForThisFeature} :\n$_failFile';
              // }

              if (_pickerResult.files.isNotEmpty) {
                switch (_pickerResult.files[element].extension?.toLowerCase()) {
                  case 'jpg':
                  case 'jpeg':
                    File? pathPicker = File(_pickerResult.files.first.path ?? '');
                    int fs = pathPicker.lengthSync();
                    var resfs = (log(fs) / log(1024)).floor();
                    var mb = (fs / pow(1024, resfs)).toStringAsFixed(0);
                    if (int.parse(mb) >= 2) {
                      List<String> naming = pathPicker.path.split('.');
                      final tmpDir = (await getTemporaryDirectory()).path;
                      final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.${naming.last}';
                      final result = await FlutterImageCompress.compressAndGetFile(pathPicker.path, target, quality: 75);

                      if (result == null) {
                        // error handling here
                        print('error result');
                      } else {
                        _filePickerResult = [File(result.path)];
                      }
                    } else {
                      _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
                    }
                    break;
                  case 'gif':
                    File image22 = await convertGifToJpeg(_pickerResult.files[element].path ?? '');
                    print("======ini gif jadi imageeee ${image22.path}");
                    _filePickerResult = [image22];
                    break;
                  default:
                    _filePickerResult = _pickerResult.files.map((file) => File(file.path ?? '')).toList();
                    break;
                }
              }
            }
          }
          // validasi durasi
        }
      }
    }
    return {_errorMsg: _filePickerResult};
  }

  Future convertGifToJpeg(String gifPath) async {
    // Read the GIF file
    Uint8List gifBytes = await File(gifPath).readAsBytes();

    // Decode GIF into frames

    img.Image? frames = img.decodeGif(gifBytes);

    // We'll just take the first frame for simplicity
    // img.Image firstFrame = frames[0];

    // Convert to JPEG format
    Uint8List jpegBytes = img.encodeJpg(frames!);

    // Write the JPEG data to a file
    final tmpDir = (await getTemporaryDirectory()).path;
    final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(target).writeAsBytes(jpegBytes);
  }

  Future<Uint8List?> createThumbnail(String path, {int quality = 25}) async {
    return await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: quality,
    );
  }

  saveThumbnail(String url, String id, {bool isCheck = false}) async {
    final byte = await url.getThumbBlob();
    if (byte != null) {
      'result saveThumbnail'.logger();
      if (isCheck) {
        final data = await globalDB.getThumbnail(id);
        if (data == null) {
          globalDB.insertThumbnail(LocalThumbnail(id: id, thumbnail: byte));
        }
      } else {
        globalDB.insertThumbnail(LocalThumbnail(id: id, thumbnail: byte));
      }
    }
  }

  Future<File> rotateAndCompressAndSaveImage(File image) async {
    int rotate = 0;
    // List<int> imageBytes = await image.readAsBytes();

    Uint8List imageBytes = await image.readAsBytes();
    Map<String, IfdTag> exifData = await readExifFromBytes(imageBytes);

    if (exifData.isNotEmpty && exifData.containsKey("Image Orientation")) {
      IfdTag orientation = exifData["Image Orientation"]!;
      int orientationValue = orientation.tag;

      if (orientationValue == 3) {
        print("dirotate 180");
        rotate = 180;
      }

      if (orientationValue == 6) {
        print("dirotate -90");

        rotate = -90;
      }

      if (orientationValue == 8) {
        print("dirotate 90");

        rotate = 90;
      }
    }

    List<int> result = await FlutterImageCompress.compressWithList(imageBytes, quality: 100, rotate: rotate);

    await image.writeAsBytes(result);

    return image;
  }

  void actionReqiredIdCard(
    BuildContext context, {
    required Function() action,
    bool uploadContentAction = true,
  }) async {
    // bool _permissionStatus = true;

    final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);

    if (notifier.user.profile != null) {
      final _status = SharedPreference().readStorage(SpKeys.statusVerificationId);

      if (_status == REVIEW) {
        ShowBottomSheet().onShowColouredSheet(
          context,
          'Harap Menunggu Sedang Proses Pemeriksaan',
          maxLines: 2,
          enableDrag: false,
          dismissible: false,
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
        );
      } else if (_status == UNVERIFIED) {
        ShowBottomSheet.onShowIDVerification(context);
      } else {
        action();
      }
    }

    // if (uploadContentAction) {
    //   // request permission
    //   _permissionStatus = await requestPrimaryPermission(context);
    // }

    // if (!_permissionStatus) {
    //   ShowGeneralDialog.permanentlyDeniedPermission(context);
    // } else {
    //   final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);

    //   if (notifier.user.profile != null) {
    //     // debugPrint(notifier.user.profile.isComplete.toString());
    //     // debugPrint(notifier.user.profile.isIdVerified.toString());
    //     // if (!notifier.user.profile.isComplete) {
    //     //   ShowBottomSheet.onShowCompleteProfile(context);
    //     // } else if (!notifier.user.profile.isIdVerified) {
    //     if (!notifier.user.profile.isIdVerified) {
    //       ShowBottomSheet.onShowIDVerification(context);
    //     } else {
    //       action();
    //     }
    //   } else {
    //     ShowBottomSheet.onShowSomethingWhenWrong(context);
    //   }
    // }
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
      case NotificationCategory.verificationid:
        return 'VERIFICATIONID';
      case NotificationCategory.transactions:
        return 'TRANSACTIONS';
      case NotificationCategory.adsClick:
        return 'ADS CLICK';
      case NotificationCategory.adsView:
        return 'ADS VIEW';
      case NotificationCategory.challange:
        return 'CHALLENGE';
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
      case 'TRANSACTION':
        return NotificationCategory.transactions;
      case 'ADS CLICK':
        return NotificationCategory.adsClick;
      case 'ADS VIEW':
        return NotificationCategory.adsView;
      case 'CHALLENGE':
        return NotificationCategory.challange;
      default:
        return NotificationCategory.all;
    }
  }

  String getStatusBoost(BuildContext context, String status) {
    final translate = context.read<TranslateNotifierV2>().translate;
    switch (status) {
      case 'BERLANGSUNG':
        return translate.ongoing ?? '';
      case 'AKAN DATANG':
        return translate.scheduled ?? '';
      default:
        return translate.finish ?? '';
    }
  }

  double menghitungJumlahHari(DateTime from, DateTime to) {
    Duration diff = to.difference(from);
    return (diff.inHours / 24);
  }

  double menghitungJumlahMenit(DateTime from, DateTime to) {
    Duration diff = to.difference(from);
    return (diff.inMinutes % 60);
  }

  readTimestamp(int timestamp, BuildContext context, {required bool fullCaption}) {
    final translate = context.read<TranslateNotifierV2>().translate;
    String time = '';
    int seconds = (DateTime.now().millisecondsSinceEpoch - timestamp) ~/ 1000;
    final duration = Duration(seconds: seconds);
    int minutes = duration.inMinutes;
    int hours = duration.inHours;
    int days = duration.inDays;
    int weeks = seconds ~/ 604800;
    if (weeks > 0) {
      time = weeks.toString() +
          (fullCaption
              ? weeks > 1
                  ? " ${translate.weeksAgo}"
                  : " ${translate.weekAgo}"
              : translate.w ?? '');
    } else if (days > 0) {
      time = days.toString() +
          (fullCaption
              ? days > 1
                  ? " ${translate.daysAgo}"
                  : " ${translate.dayAgo}"
              : translate.d ?? '');
    } else if (hours > 0) {
      time = hours.toString() +
          (fullCaption
              ? hours > 1
                  ? " ${translate.hoursAgo}"
                  : " ${translate.hourAgo}"
              : translate.h ?? '');
    } else if (minutes > 0) {
      time = minutes.toString() +
          (fullCaption
              ? minutes > 1
                  ? " ${translate.minutesAgo}"
                  : " ${translate.minuteAgo}"
              : translate.m ?? '');
    } else {
      time = fullCaption ? translate.justNow ?? '' : translate.now ?? '';
    }
    return time;
  }

  dateTimeRemoveT(String? date) {
    if (date?.contains('T') ?? false) {
      return date?.replaceAll('T', ' ').substring(0, 19);
    } else {
      return date;
    }
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
    // final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);
    final notifier = context.read<SelfProfileNotifier>();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Env.data.deeplinkBaseUrl,
      link: Uri.parse('${Env.data.deeplinkBaseUrl}${Routes.otherProfile}?referral=1&sender_email=${notifier.user.profile?.email}'),
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
        imageUrl: Uri.parse('${notifier.user.profile?.avatar}'),
        title: 'Hyppe App | ${notifier.user.profile?.fullName}',
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
    RenderRepaintBoundary repaintBoundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 3);
    ByteData? byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
    var uint8list = byteData?.buffer.asUint8List();
    final String _pathFile = path.join(await getSystemPath(params: 'editedImg'), '${DateTime.now().toIso8601String()}.png');
    File imgFile = File(_pathFile);
    if (uint8list != null) {
      await imgFile.writeAsBytes(uint8list);
    }
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

  bool atLeastEightUntilTwentyCharacter({required String text}) {
    return text.length >= 8 && text.length <= 20;
  }

  bool atLeastEightCharacter({required String text}) {
    return text.length >= 8;
  }

  bool atLeastThreeThreetyCharacter(String text) {
    return text.length >= 3 && text.length <= 30;
  }

  bool canOnlyContainLettersNumbersDotAndUnderscores(String text) {
    return text.contains(RegExp(r'^[a-zA-Z0-9._]+$'));
  }

  bool specialCharPass(String text) {
    final result = text.contains(RegExp(r'[!@#$%^&*_<>"()/?-]'));
    'specialCharPass:  $result'.logger();
    return result;
  }

  bool charForTag(String text) {
    final result = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
    return result;
  }

  bool canSpecialCharPass(String text) {
    return text.contains(RegExp(r'[a-zA-Z0-9!@#$%^&*_]+$'));
  }

  bool atLeastContainOneCharacterAndOneNumber({required String text}) {
    final isOneNumber = text.contains(RegExp(r'[0-9]'));
    final isOneChar = text.contains(RegExp(r'[a-zA-Z]'));
    return text.length > 1 && isOneNumber && isOneChar;
  }

  bool passwordMatch({required String password, required String confirmPassword}) {
    return password == confirmPassword;
  }

  bool isLoggedInUser({required String email}) {
    return SharedPreference().readStorage(SpKeys.email) == email;
  }

  Future<void> increaseViewCount(BuildContext context, v2.ContentData data) async {
    String myEmail = SharedPreference().readStorage(SpKeys.email) ?? "";
    print("??!!!!!!!!!!!!!!!!!!!!kirim data");
    if (myEmail != data.email) {
      try {
        print("!!!!!!!!!!!!!!!!!!!!kirim data");
        final notifier = ViewBloc();
        await notifier.viewPostUserBloc(context, postId: data.postID ?? '', emailOwner: data.email ?? '');
        final fetch = notifier.viewFetch;

        if (!(data.insight?.isView ?? true)) {
          if (fetch.viewState == ViewState.viewUserPostSuccess) {
            data.insight?.views = (data.insight?.views ?? 0) + 1;
            data.insight?.isView = true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Interactive error with $e');
        }
      }
    }
  }

  Future<void> increaseViewCount2(BuildContext context, v2.ContentData data, {bool check = true}) async {
    print("??!!!!!!!!!!!!!!!!!!!!kirim data");
    try {
      print("!!!!!!!!!!!!!!!!!!!!kirim data2");
      final notifier = ViewBloc();
      await notifier.viewPostUserBloc(context, postId: data.postID ?? '', emailOwner: data.email ?? '', check: check);
      final fetch = notifier.viewFetch;

      if (!(data.insight?.isView ?? true)) {
        if (fetch.viewState == ViewState.viewUserPostSuccess) {
          data.insight?.isView = true;
          if (!System().isMy(data.email)) {
            data.insight?.views = (data.insight?.views ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Interactive error with $e');
      }
    }
  }

  Future<void> navigateToProfile(BuildContext context, String email) async {
    // final connect = await checkConnections();
    // if (connect) {
    String myEmail = SharedPreference().readStorage(SpKeys.email) ?? "";
    if (email != myEmail) {
      context.read<OtherProfileNotifier>().checkFollowingToUser(context, email);
      // if (storyController != null) {
      //   storyController.pause();
      //   Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email)).whenComplete(() => storyController.play());
      // } else {
      //   if (globalAliPlayer != null) {
      //     globalAliPlayer?.pause();
      //   }
      //   if (globalAudioPlayer != null) {
      //     globalAudioPlayer?.pause();
      //   }
      //   await Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
      //   if (globalAliPlayer != null) {
      //     // globalAliPlayer?.play();
      //   }
      //   if (globalAudioPlayer != null) {
      //     globalAudioPlayer?.resume();
      //   }
      // }
      if (globalAliPlayer != null) {
        globalAliPlayer?.pause();
      }
      if (globalAudioPlayer != null) {
        globalAudioPlayer?.pause();
      }
      await Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
      if (globalAliPlayer != null) {
        // globalAliPlayer?.play();
      }
      if (globalAudioPlayer != null) {
        globalAudioPlayer?.resume();
      }
    } else {
      // if (storyController != null) {
      //   context.read<HomeNotifier>().navigateToProfilePage(context, whenComplete: true, onWhenComplete: () => storyController.play());
      // } else {
      //   if (globalAliPlayer != null) {
      //     globalAliPlayer?.pause();
      //   }
      //   if (globalAudioPlayer != null) {
      //     globalAudioPlayer?.pause();
      //   }
      //   await Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true));
      //   if (globalAudioPlayer != null) {
      //     globalAudioPlayer?.resume();
      //   }
      // }
      if (globalAliPlayer != null) {
        globalAliPlayer?.pause();
      }
      if (globalAudioPlayer != null) {
        globalAudioPlayer?.pause();
      }
      await Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true));
      if (globalAudioPlayer != null) {
        globalAudioPlayer?.resume();
      }
    }
    // } else {
    //   ShowBottomSheet.onNoInternetConnection(context);
    // }
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
      'getLocation Error : $e'.logger();
      notifier.latitude = 0.0;
      notifier.longitude = 0.0;
      return true;
    } on Error catch (e) {
      'getLocation Error : $e'.logger();
      return false;
    }
  }

  String currencyFormat({required int? amount}) {
    return intl.NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String numberFormat({required int? amount}) {
    return intl.NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(amount);
  }

  Future adsPopUp(BuildContext context, AdsData data, String auth, {bool isSponsored = false, bool isInAppAds = false}) async {
    print("========== $isInAppAds)");
    if (!isInAppAds) {
      await ShowGeneralDialog.adsPopUp(context, data, auth, isSponsored: isSponsored);
    } else {
      String lastTimeAds = SharedPreference().readStorage(SpKeys.datetimeLastShowAds) ?? '';
      print("tanggall ======== $lastTimeAds");

      if (lastTimeAds == '') {
        await ShowGeneralDialog.adsPopUp(context, data, auth, isSponsored: isSponsored, isInAppAds: isInAppAds);
      } else {
        DateTime now = DateTime.now();
        DateTime menitCache = DateTime.parse(lastTimeAds);
        var jumlahMenit = System().menghitungJumlahMenit(menitCache, now);
        print(jumlahMenit);
        if (jumlahMenit >= 14) {
          // if (lastTimeAds.canShowAds()) {
          await ShowGeneralDialog.adsPopUp(context, data, auth, isSponsored: isSponsored, isInAppAds: isInAppAds);
        }
      }
    }
  }

  Future adsPopUpV2(BuildContext context, AdsData data, String auth) async {
    String lastTimeAds = SharedPreference().readStorage(SpKeys.datetimeLastShowAds) ?? '';
    print("tanggall ======== $lastTimeAds");
    if (!isShowingDialog) {
      isShowingDialog = true;
      if (lastTimeAds == '') {
        if (data.mediaType?.toLowerCase() == 'video') {
          await ShowGeneralDialog.adsPopUpVideo(context, data, auth);
        } else {
          await ShowGeneralDialog.adsPopUpImage(context, data);
        }
      } else {
        DateTime now = DateTime.now();
        DateTime menitCache = DateTime.parse(lastTimeAds);
        var jumlahMenit = System().menghitungJumlahMenit(menitCache, now);
        print(jumlahMenit);
        if (jumlahMenit >= 14) {
          // if (lastTimeAds.canShowAds()) {
          if (data.mediaType?.toLowerCase() == 'video') {
            await ShowGeneralDialog.adsPopUpVideo(context, data, auth);
          } else {
            await ShowGeneralDialog.adsPopUpImage(context, data);
          }
        }
      }
      isShowingDialog = false;
    }
  }

  Future<bool> checkAdsTime() async {
    bool check = false;
    String lastTimeAds = SharedPreference().readStorage(SpKeys.datetimeLastShowAds) ?? '';
    print("===-=-=-=-=-= $lastTimeAds");
    print("===-=-=-=-=-= $isShowingDialog");
    if (!isShowingDialog) {
      if (lastTimeAds == '') {
        check = true;
      } else {
        DateTime now = DateTime.now();
        DateTime menitCache = DateTime.parse(lastTimeAds);
        var jumlahMenit = System().menghitungJumlahMenit(menitCache, now);

        if (jumlahMenit >= 14) {
          check = true;
        }
      }
    }
    return check;
  }

  Future adsView(AdsData data, int time, {bool isClick = false}) async {
    try {
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(
        watchingTime: time,
        adsId: data.adsId,
        useradsId: data.useradsId,
      );
      await notifier.viewAdsBloc(Routing.navigatorKey.currentContext!, request, isClick: isClick);

      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print("ini hasil ${fetch.data['rewards']}");
        if (fetch.data['rewards'] == true) {
          ShowGeneralDialog.adsRewardPop(Routing.navigatorKey.currentContext!).whenComplete(() => null);
          Timer(const Duration(milliseconds: 800), () {
            Routing().moveBack();
            // Routing().moveBack();
            // Timer(const Duration(milliseconds: 800), () {
            //   Routing().moveBack();
            // });
          });
        }
      }
    } catch (e) {
      'Failed hit view ads $e'.logger();
    }
  }

  Future popUpChallange(BuildContext context) async {
    String lastTime = SharedPreference().readStorage(SpKeys.datetimeLastShowChallange) ?? '';
    var challange = context.read<ChallangeNotifier>();

    if (lastTime == '') {
      await challange.getBannerLanding(context, ispopUp: true);
      SharedPreference().writeStorage(SpKeys.datetimeLastShowChallange, DateTime.now().toString());
      return ShowGeneralDialog.showBannerPop(context);
    } else {
      var temp = DateTime.now();
      // var temp = DateTime.parse("2023-07-29 08:02:10");
      // print(lastTime);
      var startDate = DateTime.parse(lastTime);
      // var startDate = DateTime.parse("2023-10-19 02:31:44.014886");
      var d1 = DateTime.utc(temp.year, temp.month, temp.day, temp.hour, temp.minute, temp.second);
      var startDay = DateTime.utc(startDate.year, startDate.month, startDate.day, startDate.hour, startDate.minute, startDate.second);

      final difference = startDay.difference(d1);
      print("===============222222 ---- ${difference.inDays}");
      print("===============222222 ---- ${difference.inHours}");
      print("===============222222 ---- ${difference.inMinutes}");
      // if (difference.inHours >= 24) {
      if (difference.inHours <= -24) {
        await challange.getBannerLanding(context, ispopUp: true);
        SharedPreference().writeStorage(SpKeys.datetimeLastShowChallange, DateTime.now().toString());
        globalChallengePopUp = true;
        return ShowGeneralDialog.showBannerPop(context);
      }
    }
  }

  Future userVerified(status) async {
    switch (status) {
      case VERIFIED:
        print('1');
        SharedPreference().writeStorage(SpKeys.statusVerificationId, VERIFIED);
        break;
      case UNVERIFIED:
        print('2');
        SharedPreference().writeStorage(SpKeys.statusVerificationId, UNVERIFIED);
        break;
      case REVIEW:
        print('3');
        SharedPreference().writeStorage(SpKeys.statusVerificationId, REVIEW);
        break;
      case 'true':
        print('4');
        SharedPreference().writeStorage(SpKeys.statusVerificationId, VERIFIED);
        break;
      default:
        print('5');
        SharedPreference().writeStorage(SpKeys.statusVerificationId, UNVERIFIED);
    }
  }

  String statusWithdrwal(context, String status) {
    final notifier = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    switch (status) {
      case 'Success':
        return notifier.transferredSuccessfully ?? '';
      default:
        return notifier.waitingtoTransfer ?? '';
    }
  }

  Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }

  Future block(BuildContext context) async {
    // if (!kDebugMode) {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
    // }
  }

  Future disposeBlock() async {
    // if (!kDebugMode) {
    await ScreenProtector.preventScreenshotOff();
    // }
  }

  void _addListenerPreventScreenshot(BuildContext context) async {
    bool isrecord = await ScreenProtector.isRecording();

    print("isrecord $isrecord");
  }

  String getFullTime(int seconds) {
    return '${getFormatMinutes(seconds)}:${getFormatSeconds(seconds)}';
  }

  String getFormatSeconds(int values) {
    int stateSeconds = values % 60;
    return stateSeconds < 10 ? '0$stateSeconds' : '$stateSeconds';
  }

  String getFormatMinutes(int values) {
    int stateMinutes = Duration(seconds: values).inMinutes;
    return stateMinutes < 10 ? '0$stateMinutes' : '$stateMinutes';
  }

  static String getFileSizeDescription(int size) {
    StringBuffer bytes = new StringBuffer();
    if (size >= 1024 * 1024 * 1024) {
      double i = (size / (1024.00 * 1024.00 * 1024.00));
      bytes
        ..write(i.toStringAsFixed(2))
        ..write("G");
    } else if (size >= 1024 * 1024) {
      double i = (size / (1024.00 * 1024.00));
      bytes
        ..write(i.toStringAsFixed(2))
        ..write("M");
    } else if (size >= 1024) {
      double i = (size / (1024.00));
      bytes
        ..write(i.toStringAsFixed(2))
        ..write("K");
    } else if (size < 1024) {
      if (size <= 0) {
        bytes.write("0B");
      } else {
        bytes
          ..write(size)
          ..write("B");
      }
    }
    return bytes.toString();
  }

  ///格式化毫秒数为 xx:xx:xx这样的时间格式。
  static String getTimeformatByMs(int ms) {
    if (ms == 0) {
      return "00:00";
    }
    int seconds = (ms / 1000).round();
    int finalSec = seconds % 60;
    int finalMin = (seconds / 60 % 60).floor();
    int finalHour = (seconds / 3600).round();

    StringBuffer msBuilder = StringBuffer("");
    if (finalHour > 9) {
      msBuilder
        ..write(finalHour)
        ..write(":");
    } else if (finalHour > 0) {
      msBuilder
        ..write("0")
        ..write(finalHour)
        ..write(":");
    } else {
      msBuilder
        ..write("")
        ..write("");
    }

    if (finalMin > 9) {
      msBuilder
        ..write(finalMin)
        ..write(":");
    } else if (finalMin > 0) {
      msBuilder
        ..write("0")
        ..write(finalMin)
        ..write(":");
    } else {
      msBuilder
        ..write("00")
        ..write(":");
    }

    if (finalSec > 9) {
      msBuilder..write(finalSec);
    } else if (finalSec > 0) {
      msBuilder
        ..write("0")
        ..write(finalSec);
    } else {
      msBuilder.write("00");
    }

    return msBuilder.toString();
  }

  String getPathByInterest(String idInterest) {
    switch (idInterest) {
      case '613bc4da9ec319617aa6c396':
        return '${AssetPath.pngPath}in_animal.png';
      case '613bc4da9ec319617aa6c399':
        return '${AssetPath.pngPath}in_automotive.png';
      case '613bc4da9ec319617aa6c393':
        return '${AssetPath.pngPath}in_beauty.png';
      case '613bc4da9ec319617aa6c394':
        return '${AssetPath.pngPath}in_celeb_account.png';
      case '613bc4da9ec319617aa6c392':
        return '${AssetPath.pngPath}in_comedy.png';
      case '613bc4da9ec319617aa6c400':
        return '${AssetPath.pngPath}in_daily.png';
      case '613bc4da9ec319617aa6c38e':
        return '${AssetPath.pngPath}in_entertainment.png';
      case '613bc4da9ec319617aa6c398':
        return '${AssetPath.pngPath}in_fashion.png';
      case '613bc4da9ec319617aa6c40a':
        return '${AssetPath.pngPath}in_fnb.png';
      case '613bc4da9ec319617aa6c38f':
        return '${AssetPath.pngPath}in_gaming.png';
      case '613bc4da9ec319617aa6c40b':
        return '${AssetPath.pngPath}in_healthy.png';
      case '613bc4da9ec319617aa6c397':
        return '${AssetPath.pngPath}in_hobby.png';
      case '613bc4da9ec319617aa6c390':
        return '${AssetPath.pngPath}in_film.png';
      case '613bc4da9ec319617aa6c38c':
        return '${AssetPath.pngPath}in_music.png';
      case '613bc4da9ec319617aa6c391':
        return '${AssetPath.pngPath}in_news.png';
      case '613bc4da9ec319617aa6c40c':
        return '${AssetPath.pngPath}in_knowledge.png';
      case '613bc4da9ec319617aa6c395':
        return '${AssetPath.pngPath}in_sport.png';
      case '613bc4da9ec319617aa6c39a':
        return '${AssetPath.pngPath}in_technology.png';
      case '613bc4da9ec319617aa6c38d':
        return '${AssetPath.pngPath}in_travel.png';
      case '613bc4da9ec319617aa6c39b':
        return '${AssetPath.pngPath}in_tutorial.png';
      default:
        return '${AssetPath.pngPath}in_animal.png';
    }
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  void goToWebScreen(String url, {bool isPop = false}) async {
    if (isPop) {
      Routing().moveBack();
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      Routing().move(Routes.webView, argument: url);
    });
  }

  void checkMemory() {
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.liveImageCount >= 50) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }

  double scrollAuto(int index, double heightProfileCard, int heightBox) {
    print("============= index $index =================");
    var indexHei = index + 1;
    var hasilBagi = indexHei / 3;
    print("============= index $hasilBagi =================");
    var heightIndex = 0;
    if (isInteger(hasilBagi)) {
      hasilBagi = hasilBagi;
    } else {
      hasilBagi += 1;
    }
    heightIndex = (heightBox * hasilBagi.toInt() - heightBox);

    double jumpTo = heightProfileCard + heightIndex;
    return jumpTo;
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  Future<List> compareDate(String startDateString, String endtDateString, {String? dari}) async {
    //get difrent date
    // print("???????? $startDateString");
    // print("???????? $endtDateString");
    // startDateString = "2023-01-08 13:52:15";
    var temp = DateTime.now();
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endtDateString);
    var d1 = DateTime.utc(temp.year, temp.month, temp.day, temp.hour, temp.minute, temp.second);
    var startDay = DateTime.utc(startDate.year, startDate.month, startDate.day, startDate.hour, startDate.minute, startDate.second);
    var endDay = DateTime.utc(endDate.year, endDate.month, endDate.day, endDate.hour, endDate.minute, endDate.second);
    // print("======= compare ${startDay.compareTo(d1)}");
    if (startDay.compareTo(d1) <= -1) {
      //tanggal lewat ("berakhir dalam");
      final difference = endDay.difference(d1);
      return [true, difference];
    } else {
      //tanggal akan datang ("Mulai dalam");
      final difference = startDay.difference(d1);
      return [false, difference];
    }
  }

  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Widget showWidgetForGuest(Widget forUser, Widget forGuest) {
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    if (isGuest ?? false) {
      return forGuest;
    } else {
      return forUser;
    }
  }

  void analyticSetUser({String name = ''}) async {
    await FirebaseAnalytics.instance.setUserId(id: SharedPreference().readStorage(SpKeys.userID));
    // await FirebaseAnalytics.instance.setUserProperty(
    //   name: SharedPreference().readStorage(SpKeys.email).toString().substring(0, 24),
    //   value: '',
    // );
  }

  void analyticSetScreen(String screenName, {String? subScreenName}) async {
    await FirebaseAnalytics.instance.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: subScreenName ?? '',
    );
  }

  void analyticLogEvent(String nameLog, Map<String, Object> data) async {
    await FirebaseAnalytics.instance
        .logEvent(
      name: nameLog,
      parameters: data,
    )
        .whenComplete(() {
      print("sudah kirim analitic");
    });
  }

  bool isMy(email) {
    if (email == SharedPreference().readStorage(SpKeys.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool isGuest(){
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    return isGuest ?? false;
  }
}
