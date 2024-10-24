import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/support_ticket/bloc.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/support_ticket/category_model.dart';
import 'package:hyppe/core/models/collection/support_ticket/level_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';

class SupportTicketNotifier with ChangeNotifier {
  bool _isLoadingCategory = false;
  bool get isLoadingCategory => _isLoadingCategory;

  bool _isLoadingCreate = false;
  bool get isLoadingCreate => _isLoadingCreate;

  bool _isLoadingLevel = false;
  bool get isLoadingLevel => _isLoadingLevel;

  String _nameCategory = '';
  String get nameCategory => _nameCategory;

  String _idCategory = '';
  String get idCategory => _idCategory;

  String _idLevelTicket = '';
  String get idLevelTicket => _idLevelTicket;

  String _nameLevel = '';
  String get nameLevel => _nameLevel;

  List<CategoryTicketModel> categoryData = [];
  List<LevelTicketModel> levelData = [];
  List<File>? _pickedSupportingDocs = [];
  List<File>? get pickedSupportingDocs => _pickedSupportingDocs;

  TextEditingController descriptionController = TextEditingController();

  set pickedSupportingDocs(List<File>? val) {
    _pickedSupportingDocs = val;
    notifyListeners();
  }

  set idCategory(String val) {
    _idCategory = val;
    notifyListeners();
  }

  set idLevelTicket(String val) {
    _idLevelTicket = val;
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
    _getLevelTickets(context);
    descriptionController.clear();
    _idCategory = '';
    _idLevelTicket = '';
    _pickedSupportingDocs = [];
    _nameCategory = '';
    _nameLevel = '';
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
        levelData = [];
        fetch.data.forEach((v) => levelData.add(LevelTicketModel.fromJson(v)));
        levelData.sort((a, b) => (a.nameLevel ?? '0').compareTo(b.nameLevel ?? '0'));
      }else if (fetch.postsState == SupportTicketState.getLevelError) {
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

  void onPickSupportedDocument(BuildContext context, mounted, {bool pdf = false}) async {
    // isLoading = true;
    isHomeScreen = false;
    print('isOnHomeScreen $isHomeScreen');
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    try {
      await System().getLocalMedia(featureType: FeatureType.other, context: context, pdf: pdf, maxFile: 4).then((value) async {
        debugPrint('Pick => ' + value.toString());
        if (value.values.single != null) {
          // pickedSupportingDocs = value.values.single;
          for (var element in value.values.single!) {
            if ((pickedSupportingDocs?.length ?? 0) < 4) {
              pickedSupportingDocs!.add(element);
            }
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

  bool enableButton() {
    if (idCategory == '' || idLevelTicket == '') {
      return false;
    } else {
      return true;
    }
  }

  Future createTicket(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      _isLoadingCreate = true;
      notifyListeners();
      final notifier = SupportTicketBloc();
      Map<String, dynamic> data = {
        'subject': 'pengaduan',
        'body': descriptionController.text,
        'categoryTicket': idCategory,
        'levelTicket': idLevelTicket,
        'sourceTicket': '631176cc9e2f00002c0050c8',
        'status': 'new',
      };
      print(data);
      await notifier.postTicketBloc(
        context,
        data: data,
        docFiles: pickedSupportingDocs,
      );
      final fetch = notifier.supportTicketFetch;
      if (fetch.postsState == SupportTicketState.postTicketSuccess) {
        Routing().moveBack();
        final translate = context.read<TranslateNotifierV2>().translate;
        ShowBottomSheet().onShowColouredSheet(context, translate.ticketIssueSuccessfullySubmitted ?? '',
            subCaption: translate.yourTicketIssuehasbeensuccessfullysubmittedtoHyppeCustomerCare, color: kHyppeTextSuccess);
      }

      if (fetch.postsState == SupportTicketState.postTicketError) {}
      _isLoadingCreate = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getInitSupportTicket(context);
      });
    }
  }
}
