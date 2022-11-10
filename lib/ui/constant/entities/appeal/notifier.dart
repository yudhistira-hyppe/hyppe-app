import 'dart:async';
import 'package:hyppe/core/bloc/report/bloc.dart';
import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppealNotifier with ChangeNotifier {
  bool _loadingAppel = false;
  bool get loadingAppel => _loadingAppel;

  String _appealReason = '';
  String get appealReason => _appealReason;

  List appealReaseonData = [];

  TextEditingController noteAppealController = TextEditingController();

  set appealReason(String val) {
    _appealReason = val;
    notifyListeners();
  }

  Future initializeData(BuildContext context) async {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    appealReaseonData = [
      {'title': translate.thisContentDoesntHaveSensitiveContent, 'desc': translate.thisContentDoesntHaveAnyNuditySexualContentViolenceGoreOrHatefulSymbols},
      {'title': translate.thisContentHasAdditionalContext, 'desc': translate.thisContentShowsGraphicViolenceForDocumentaryOrEducationalContent},
      {'title': translate.other, 'desc': translate.theReasonDoesntFitIntoTheseCategories},
    ];
  }

  Future appealPost(BuildContext context, String postId) async {
    _loadingAppel = true;
    notifyListeners();
    final data = {
      "postID": postId,
      "type": "content",
      "reportedUserHandle": [
        {"remark": noteAppealController.text, "reason": _appealReason, "status": "BARU"}
      ]
    };
    final notifier = ReportBloc();
    await notifier.appealPost(context, data: data);
    final fetch = notifier.reportFetch;
    if (fetch.reportState == ReportState.appealSuccess) {
      _loadingAppel = false;
      noteAppealController.clear();
      Routing().moveBack();
      ShowBottomSheet().onShowColouredSheet(context, 'Appeal Success', color: kHyppeTextSuccess);
    } else {
      _loadingAppel = false;
      ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Colors.red);
    }

    notifyListeners();
  }

  String getCategory(List<Cats>? cats) {
    List interest = [];
    String category = '';
    var a = cats?.map((e) {
      interest.add(e.interestName);
    }).toList();
    if (interest.isNotEmpty) category = interest.join(', ');
    return category;
  }
}
