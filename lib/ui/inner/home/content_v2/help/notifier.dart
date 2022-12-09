import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/support_ticket/bloc.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/services/system.dart';

class HelpNotifier with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future getInitSupportTicket(BuildContext context) async {
    if (categoryData.isEmpty) _getCategoryTickets(context);
    if (levelData.isEmpty) _getLevelTickets(context);
  }

  Future _getCategoryTickets(BuildContext context) async {
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getInitSupportTicket(context);
      });
    }
  }
}
