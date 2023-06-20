import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/ads_popup_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/ads_popup_image_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/ads_reward_popup.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/banner_pop.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/delete_tag_user_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/general_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/loading_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/new_account_language_content.dart';
import 'package:hyppe/core/models/collection/comment/comments.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/account_preferences_birth_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/delete_content_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/old_version_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/permanently_denied_permisson_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/pick_file_error_alert.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/reaction_comment_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/remark_withdrawal_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/toast_alert.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_city_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_country_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_province_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_overview_gender_content.dart';
// import 'package:hyppe/ui/inner/home/content/diary/playlist/notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';

import '../../../../core/models/collection/advertising/ads_video_data.dart';

class ShowGeneralDialog {
  ShowGeneralDialog._private();

  static final ShowGeneralDialog _instance = ShowGeneralDialog._private();

  factory ShowGeneralDialog() {
    return _instance;
  }

  Future reactionComment(_, Comments? comment) async {
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      context: _,
      pageBuilder: (context, animation, secondaryAnimation) => ReactionCommentContent(comment: comment ?? Comments()),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static permanentlyDeniedPermission(_, {String permissions = 'Permission Camera, Microphone and Storage'}) {
    showCupertinoDialog(context: _, barrierLabel: 'Barrier', barrierDismissible: true, builder: (context) => PermanentlyDeniedPermissionContent(permissions: permissions));
  }

  static generalDialog(_,
      {String? titleText,
      String? bodyText,
      int? maxLineTitle,
      int? maxLineBody,
      required Function functionPrimary,
      Function? functionSecondary,
      String? titleButtonPrimary,
      String? titleButtonSecondary,
      bool? barrierDismissible = false}) {
    showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: Routing.navigatorKey.currentState!.overlay!.context,
      barrierLabel: 'Barrier',
      barrierDismissible: barrierDismissible ?? false,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(
        // insetPadding: EdgeInsets.only(top: 30),
        alignment: Alignment.center,
        content: GeneralAlertDialog(
          titleText: titleText,
          bodyText: bodyText,
          maxLineTitle: maxLineTitle,
          maxLineBody: maxLineBody,
          functionPrimary: functionPrimary,
          functionSecondary: functionSecondary,
          titleButtonPrimary: titleButtonPrimary,
          titleButtonSecondary: titleButtonSecondary,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static pickFileErrorAlert(_, String message) {
    showCupertinoDialog(context: _, barrierLabel: 'Barrier', barrierDismissible: true, builder: (context) => PickFileErrorAlertContent(message: message));
  }

  static newAccountLanguageDropDown(_) {
    showGeneralDialog(
      context: _,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(actions: [NewAccountLanguageContent()]),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }
  //
  // static completeProfileDocumentDropDown(_) {
  //   showGeneralDialog(
  //     context: _,
  //     barrierLabel: 'Barrier',
  //     barrierDismissible: true,
  //     transitionDuration: Duration(milliseconds: 500),
  //     barrierColor: Colors.transparent,
  //     pageBuilder: (context, animation, secondAnimation) => AlertDialog(
  //       content: SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         child: CompleteProfileDocumentContent(),
  //       ),
  //     ),
  //     transitionBuilder: (context, animation, secondaryAnimation, child) {
  //       animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
  //       return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
  //     },
  //   );
  // }

  static userCompleteProfileLocationCountryDropDown(
    _, {
    required Function(String) onSelected,
  }) {
    showGeneralDialog(
      context: _,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(actions: [UserCompleteProfileLocationCountryContent(onSelected: onSelected)]),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static userCompleteProfileLocationProvinceDropDown(
    _, {
    required String country,
    required Function(String) onSelected,
  }) {
    showGeneralDialog(
      context: _,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(actions: [
        UserCompleteProfileLocationProvinceContent(country: country, onSelected: onSelected),
      ]),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static userCompleteProfileLocationCityDropDown(
    _, {
    required String province,
    required Function(String) onSelected,
  }) {
    showGeneralDialog(
      context: _,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(actions: [
        UserCompleteProfileLocationCityContent(province: province, onSelected: onSelected),
      ]),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static accountPreferencesBirthDropDown(_) {
    showGeneralDialog(
      context: _,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(actions: [AccountPreferencesBirthContent()]),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static userOverviewGenderDropDown(
    BuildContext context, {
    required String value,
    required Function() onSave,
    required Function() onCancel,
    required Future<dynamic> initFuture,
    required Function(String value) onChange,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(
        actions: [
          UserOverviewGenderContent(
            value: value,
            onSave: onSave,
            onChange: onChange,
            onCancel: onCancel,
            initFuture: initFuture,
          ),
        ],
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future deleteContentDialog(BuildContext context, String contentTitle, Function function) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(
        content: DeleteContentDialog(contentTitle: contentTitle, function: function),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future deleteTagUserContentDialog(BuildContext context, String contentTitle, Function function, String postId) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => AlertDialog(
        content: DeleteTagUserContentDialog(
          contentTitle: contentTitle,
          function: function,
          postId: postId,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future oldVersion(BuildContext context) async {
    await showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: Routing.navigatorKey.currentState!.overlay!.context,
      barrierLabel: 'Barrier',
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: OldVersionDialog(),
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future adsPopUp(BuildContext context, AdsData data, String auth, {bool isSponsored = false, bool isInAppAds = false}) async {
    if (isInAppAds) {
      SharedPreference().writeStorage(SpKeys.datetimeLastShowAds, context.getCurrentDate());
    }
    try {
      await showGeneralDialog(
        //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
        context: Routing.navigatorKey.currentState!.overlay!.context,
        barrierLabel: 'Barrier',
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondAnimation) => AdsPopUpDialog(
          data: data,
          auth: auth,
          isSponsored: isSponsored,
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
          return ScaleTransition(scale: animation, alignment: Alignment.center, child: child);
        },
      );
    } catch (e) {
      print('Error Pop Ads: $e');
    }
  }

  static Future adsPopUpImage(BuildContext context) async {
    try {
      await showGeneralDialog(
        //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
        context: Routing.navigatorKey.currentState?.overlay?.context ?? context,
        barrierLabel: 'Barrier',
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondAnimation) => const AdsPopupImageDialog(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
          return ScaleTransition(scale: animation, alignment: Alignment.center, child: child);
        },
      );
    } catch (e) {
      print('Error Pop Ads: $e');
    }
  }

  static Future remarkWidthdrawal(BuildContext context) async {
    await showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: context,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondAnimation) => const AlertDialog(
        content: RemarkWithdrawalDialog(),
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future loadingDialog(BuildContext context, {bool? uploadProses}) async {
    await showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: Routing.navigatorKey.currentState!.overlay!.context,
      barrierLabel: 'Barrier',
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: LoadingDialog(uploadProses: uploadProses ?? false),
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static Future adsRewardPop(BuildContext context) async {
    print("masuk ke pop up");
    showGeneralDialog(
      context: Routing.navigatorKey.currentState!.overlay!.context,
      barrierLabel: 'Barrier',
      barrierDismissible: false,
      pageBuilder: (context, animation, secondAnimation_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AdsRewardPopupDialog(),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    ).then((value) => true);
  }

  static Future showBannerPop(BuildContext context, {bool? uploadProses}) async {
    await showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: Routing.navigatorKey.currentState!.overlay!.context,
      barrierLabel: 'Barrier',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            content: BannerPop(uploadProses: uploadProses ?? false),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth! * 0.08),
            // static showToastAlert(BuildContext context, String message, Future<dynamic> Function() onDismiss) async {
            //   await showGeneralDialog(
            //     context: context,
            //     barrierLabel: 'Barrier',
            //     barrierDismissible: true,
            //     barrierColor: Colors.white.withOpacity(0),
            //     transitionDuration: const Duration(milliseconds: 500),
            //     pageBuilder: (context, animation, secondAnimation) => ToastAlert(
            //       message: message,
            //       onTap: onDismiss,
            //     ),
            //     transitionBuilder: (context, animation, secondaryAnimation, child) {
            //       animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
            //       return ScaleTransition(scale: animation, alignment: Alignment.center, child: child);
            //     },
            //   );
            // }
          )),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.ease, parent: animation);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
    );
  }

  static Future showToastAlert(BuildContext context, String message, Future<dynamic> Function() onDismiss) async {
    await showGeneralDialog(
      //Routing.navigatorKey.currentState.overlay.context    ini untuk bisa menjalankan diluar MaterialApp
      context: context,
      barrierLabel: 'Barrier',
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondAnimation) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: ToastAlert(
            message: message,
            onTap: onDismiss,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.ease, parent: animation);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
    );
  }
}
