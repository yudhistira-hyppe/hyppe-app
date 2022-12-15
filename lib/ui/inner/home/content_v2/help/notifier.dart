import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/support_ticket/bloc.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/models/collection/support_ticket/faq_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class HelpNotifier with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<FaqModel> faqListData = [];

  Future getFaq(BuildContext context) async {
    if (faqListData.isEmpty) _getFaq(context);
  }

  Future _getFaq(BuildContext context) async {
    _isLoading = true;
    bool connect = await System().checkConnections();
    if (connect) {
      final notifier = SupportTicketBloc();
      await notifier.getListFaq(context);
      final fetch = notifier.supportTicketFetch;

      if (fetch.postsState == SupportTicketState.faqSuccess) {
        fetch.data.forEach((v) => faqListData.add(FaqModel.fromJson(v)));
      }

      if (fetch.postsState == SupportTicketState.faqError) {}
      _isLoading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        _getFaq(context);
      });
    }
  }
}
