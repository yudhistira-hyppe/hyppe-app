import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/query_request/tickets_data_query.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/arguments/ticket_argument.dart';
import '../../../../../../core/bloc/support_ticket/bloc.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../../../../core/models/collection/support_ticket/appeal_model.dart';
import '../../../../../../core/models/collection/support_ticket/ticket_model.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';

class TicketHistoryNotifier extends ChangeNotifier{

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool _isHelpTab = true;
  bool get isHelpTab => _isHelpTab;
  set isHelpTab(bool state){
    _isHelpTab = state;
    notifyListeners();
  }

  bool _isLoadingInit = true;
  bool get isLoadingInit => _isLoadingInit;

  startLoad(){
    _showAllTickets = false;
    _isLoadingInit = true;
  }

  startOpenHistory(List<TicketModel> values){
    _onProgressTickets = values;
    _isHelpTab = true;
  }

  List<TicketModel> _onProgressTickets = [];
  List<TicketModel> get onProgressTicket => _onProgressTickets;
  set onProgressTicket(List<TicketModel> values){
    _onProgressTickets = values;
    notifyListeners();
  }

  List<TicketModel> _listTickets = [];
  List<TicketModel> get listTickets => _listTickets;
  set listTickets(List<TicketModel> values){
    _listTickets = values;
    notifyListeners();
  }

  List<AppealModel> _listAppeals = [];
  List<AppealModel> get listAppeals => _listAppeals;
  set listAppeals(List<AppealModel> values){
    _listAppeals = values;
    notifyListeners();
  }

  bool _showAllTickets = true;
  bool get showAllTickets => _showAllTickets;
  set showAllTickets(bool state){
    _showAllTickets = state;
    notifyListeners();
  }

  TicketsDataQuery ticketsDataQuery = TicketsDataQuery()..page = 0..limit = 10;
  TicketsDataQuery appealsDataQuery =  TicketsDataQuery()..page = 0..limit = 10;

  bool get hasNextTicket => ticketsDataQuery.hasNext;
  int get ticketLenght => ticketsDataQuery.hasNext ? (_listTickets.length + 1) : _listTickets.length;

  bool get hasNextAppeal => appealsDataQuery.hasNext;
  int get appealLength => appealsDataQuery.hasNext ? (_listAppeals.length + 1) : _listAppeals.length;



  Future initHelpTicket(BuildContext context, {isRefresh = false}) async{
    if(isRefresh){
      _isLoadingInit = true;
      notifyListeners();
    }
    _listTickets = await ticketsDataQuery.reload(context);
    await getOnProgressTickets(context);
    _isLoadingInit = false;
    notifyListeners();
  }

  Future initContentAppeal(BuildContext context, {isRefresh = false}) async{
    if(isRefresh){
      _isLoadingInit = true;
      notifyListeners();
    }
    _listAppeals = await appealsDataQuery.reloadReport(context);
    _isLoadingInit = false;
    notifyListeners();
  }

  Future getOnProgressTickets(BuildContext context) async{
    final idUser = SharedPreference().readStorage(SpKeys.userID);
    try{
      final bloc = SupportTicketBloc();
      await bloc.getTicketHistories(context, TicketArgument(page: 0, limit: 10, descending: true, iduser: idUser, close: false));
      final fetch = bloc.supportTicketFetch;
      final notifier = context.read<TranslateNotifierV2>();
      onProgressTicket = (fetch.data as List<dynamic>?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      notifier.onProgressTicket = onProgressTicket;
    }catch(e){
      'TicketsDataQuery Reload Error : $e'.logger();
    }
  }

  Future onLoadList(BuildContext context)async{
    var res = await ticketsDataQuery.loadNext(context);
    _listTickets = [...(_listTickets)] + res;
    notifyListeners();
  }

  Future onLoadAppealList(BuildContext context)async{
    var res = await appealsDataQuery.loadReportNext(context);
    _listAppeals = [...(_listAppeals)] + res;
    notifyListeners();
  }
}