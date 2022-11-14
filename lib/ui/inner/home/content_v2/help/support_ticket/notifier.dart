import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/support_ticket/bloc.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/support_ticket/category_model.dart';
import 'package:hyppe/core/models/collection/support_ticket/level_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class SupportTicketNotifier with ChangeNotifier {
  bool _isLoadingCategory = false;
  bool get isLoadingCategory => _isLoadingCategory;

  bool _isLoadingLevel = false;
  bool get isLoadingLevel => _isLoadingLevel;

  String _nameCategory = '';
  String get nameCategory => _nameCategory;

  String _nameLevel = '';
  String get nameLevel => _nameLevel;

  List<CategoryTicketModel> categoryData = [];
  List<LevelTicketModel> levelData = [];
  List<File>? _pickedSupportingDocs = [];

  List<File>? get pickedSupportingDocs => _pickedSupportingDocs;
  set pickedSupportingDocs(List<File>? val) {
    _pickedSupportingDocs = val;
    notifyListeners();
  }

  set nameCategory(String val) {
    _nameCategory = val;
    notifyListeners();
  }

  set nameLevel(String val) {
    _nameLevel = val;
    notifyListeners();
  }

  Future getInitSupportTicket(BuildContext context) async {
    if (categoryData.isEmpty) _getCategoryTickets(context);
    if (levelData.isEmpty) _getLevelTickets(context);
  }

  Future _getCategoryTickets(BuildContext context) async {
    _isLoadingCategory = true;
    bool connect = await System().checkConnections();
    if (connect) {
      final notifier = SupportTicketBloc();
      await notifier.getCategory(context);
      final fetch = notifier.supportTicketFetch;

      if (fetch.postsState == SupportTicketState.getCategoryIssueSuccess) {
        fetch.data.forEach((v) => categoryData.add(CategoryTicketModel.fromJson(v)));
      }

      if (fetch.postsState == SupportTicketState.getCategoryIssueError) {
        categoryData = [];
      }
      _isLoadingCategory = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getInitSupportTicket(context);
      });
    }
  }

  Future _getLevelTickets(BuildContext context) async {
    _isLoadingLevel = true;

    bool connect = await System().checkConnections();
    if (connect) {
      final notifier = SupportTicketBloc();
      await notifier.getLevel(context);
      final fetch = notifier.supportTicketFetch;
      print(fetch.postsState);

      if (fetch.postsState == SupportTicketState.getLevelSuccess) {
        fetch.data.forEach((v) => levelData.add(LevelTicketModel.fromJson(v)));
      }

      if (fetch.postsState == SupportTicketState.getLevelError) {
        levelData = [];
      }
      _isLoadingLevel = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getInitSupportTicket(context);
      });
    }
  }

  void showCategoryTicket(BuildContext context) {
    ShowBottomSheet.onShowCategorySupportTicket(context);
  }

  void onPickSupportedDocument(BuildContext context, mounted) async {
    // isLoading = true;
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    try {
      await System().getLocalMedia(featureType: FeatureType.other, context: context).then((value) async {
        debugPrint('Pick => ' + value.toString());
        if (value.values.single != null) {
          // pickedSupportingDocs = value.values.single;
          for (var element in value.values.single!) {
            pickedSupportingDocs?.add(element);
          }
          notifyListeners();
        } else {
          // isLoading = false;
          if (value.keys.single.isNotEmpty) {
            ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
          }
        }
      });
    } catch (e) {
      // isLoading = false;
      // ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred);
    }
  }
}
