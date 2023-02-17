import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/hyppe_version.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';

class CheckVersion {
  Future check(BuildContext context, onlineVersion) async {
    if (onlineVersion != null) {
      print('cek version ${int.parse(onlineVersion) > version}');
      if (int.parse(onlineVersion) > version) {
        return ShowGeneralDialog.oldVersion(context);
      }
    }
  }
}
