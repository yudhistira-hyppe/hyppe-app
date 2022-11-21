import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class ListBoostNotifier with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _pageNumber = 0;
  int get pageNumber => _pageNumber;

  List<ContentData>? boostData = [];

  Future getInitBoost(BuildContext context) async {
    _isLoading = true;
    bool connect = await System().checkConnections();
    if (connect) {
      String param = '?pageNumber=$_pageNumber&pageRow=10';

      final notifier = UtilsBlocV2();
      await notifier.getListBoost(context, param);
      final fetch = notifier.utilsFetch;

      if (fetch.utilsState == UtilsState.getMasterBoostSuccess) {
        boostData = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

        _isLoading = false;
        notifyListeners();
      } else if (fetch.utilsState == UtilsState.getMasterBoostError) {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getInitBoost(context);
      });
    }
    notifyListeners();
  }
}
