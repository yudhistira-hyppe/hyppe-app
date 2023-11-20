import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/hyppe_version.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';

class CheckVersion {
  Future check(BuildContext context, onlineVersion, onlineVersionIos) async {
    if (onlineVersion != null) {
      var deviceVersion = Platform.isAndroid ? version : versionIos;
      var versionOnline = Platform.isAndroid ? onlineVersion : onlineVersionIos;
      print("version $versionOnline");
      print("version $onlineVersionIos");
      if (int.parse(versionOnline) > deviceVersion) {
        return ShowGeneralDialog.oldVersion(context);
      }
    }
  }
}
