import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/new_account_language_content.dart';
import 'package:hyppe/core/models/collection/comment/comments.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/account_preferences_birth_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/delete_content_dialog.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/permanently_denied_permisson_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/pick_file_error_alert.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/reaction_comment_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_city_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_country_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_complete_profile_location_province_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/v2/user_overview_gender_content.dart';
// import 'package:hyppe/ui/inner/home/content/diary/playlist/notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      pageBuilder: (context, animation, secondaryAnimation) => ReactionCommentContent(comment: comment!),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(curve: Curves.elasticOut, parent: animation);
        return ScaleTransition(child: child, scale: animation, alignment: Alignment.center);
      },
    );
  }

  static permanentlyDeniedPermission(_, {String permissions = 'Permission Camera, Microphone and Storage'}) {
    showCupertinoDialog(
        context: _,
        barrierLabel: 'Barrier',
        barrierDismissible: true,
        builder: (context) => PermanentlyDeniedPermissionContent(permissions: permissions));
  }

  static pickFileErrorAlert(_, String message) {
    showCupertinoDialog(
        context: _, barrierLabel: 'Barrier', barrierDismissible: true, builder: (context) => PickFileErrorAlertContent(message: message));
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

  static userCompleteProfileLocationCountryDropDown(_, {
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

  static userCompleteProfileLocationProvinceDropDown(_, {
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

  static userCompleteProfileLocationCityDropDown(_, {
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
}
