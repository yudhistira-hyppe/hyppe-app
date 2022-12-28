import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../../../../core/arguments/ticket_argument.dart';
import '../../../../../../core/bloc/support_ticket/bloc.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../../../../core/models/collection/support_ticket/ticket_model.dart';

class DetailTicketNotifier extends ChangeNotifier{
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final FocusNode _inputNode = FocusNode();
  FocusNode get inputNode => _inputNode;

  TextEditingController _commentController = TextEditingController();
  TextEditingController get commentController => _commentController;

  TicketModel? _ticketModel;
  TicketModel? get ticketModel => _ticketModel;
  set ticketModel(TicketModel? data){
    _ticketModel = data;
    notifyListeners();
  }

  initState(TicketModel model){
    _ticketModel = model;
  }


  Future getDetailTicket(BuildContext context) async{
    List<TicketModel>? res;
    try{
      final bloc = SupportTicketBloc();
      await bloc.getTicketHistories(context, TicketArgument(id: _ticketModel?.id, type: 'comment'), isDetail: true);
      final fetch = bloc.supportTicketFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
      if(res != null){
        if(res.isNotEmpty){
          ticketModel = res[0];
        }
      }
    }catch(e){
      'TicketsDataQuery Reload Error : $e'.logger();
    }

    return res ?? [];
  }

  Future sendComment(BuildContext context, String message) async{
    final ticketID = _ticketModel?.id;
    final status = _ticketModel?.status;
    try{
      if(ticketID != null){
        if(status != null){
          final bloc = SupportTicketBloc();
          await bloc.sendComment(context, TicketArgument(idUserTicket: ticketID, body: message, status: status ), onSuccess: () async{
            commentController.text = '';
            await getDetailTicket(context);
          });
        }else{
          throw 'Ticket Status is null';
        }
      }else{
        throw 'Ticket ID is null';
      }

    }catch(e){
      'sendComment Error : $e'.logger();
    }
  }
}
