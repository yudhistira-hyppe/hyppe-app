import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/arguments/ticket_argument.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/support_ticket/appeal_model.dart';
import 'package:hyppe/core/models/collection/support_ticket/ticket_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import '../bloc/support_ticket/bloc.dart';
import '../interface/pagination_query_interface.dart';

class TicketsDataQuery extends PaginationQueryInterface{

  final userId = SharedPreference().readStorage(SpKeys.userID);

  TicketsDataQuery();

  @override
  Future<List<TicketModel>> loadNext(BuildContext context) async {
    List<TicketModel>? res;
    final idUser = SharedPreference().readStorage(SpKeys.userID);

    loading = true;

    try{
      final bloc = SupportTicketBloc();

      await bloc.getTicketHistories(context, TicketArgument(page: page, limit: limit, descending: true, iduser: idUser));
      final fetch = bloc.supportTicketFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();


      hasNext = res?.length == limit;
      if(res != null) page++;
    }catch(e){
      'TicketsDataQuery Load Next Error : $e'.logger();
    }

    return res ?? [];
  }

  @override
  Future<List<TicketModel>> reload(BuildContext context) async {
    List<TicketModel>? res;
    final idUser = SharedPreference().readStorage(SpKeys.userID);
    try{
      hasNext = true;
      loading = true;
      page = 0;

      final bloc = SupportTicketBloc();
      await bloc.getTicketHistories(context, TicketArgument(page: page, limit: limit, descending: true, iduser: idUser));
      final fetch = bloc.supportTicketFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.length == limit;
      if(res != null) page++;
    }catch(e){
      'TicketsDataQuery Reload Error : $e'.logger();
    }finally{
      loading = false;
    }

    return res ?? [];
  }


  @override
  Future<List<AppealModel>> loadReportNext(BuildContext context) async {
    List<AppealModel>? res;

    final email = SharedPreference().readStorage(SpKeys.email);
    loading = true;

    try{
      final bloc = SupportTicketBloc();

      await bloc.getReportHistories(context, TicketArgument(page: page, limit: limit, descending: true, email: email)..type = 'content'..category = 'appeal');
      final fetch = bloc.supportTicketFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => AppealModel.fromJson(e as Map<String, dynamic>)).toList();


      hasNext = res?.length == limit;
      if(res != null) page++;
    }catch(e){
      'TicketsDataQuery Load Next Error : $e'.logger();
    }

    return res ?? [];
  }

  @override
  Future<List<AppealModel>> reloadReport(BuildContext context) async {
    List<AppealModel>? res;

    final email = SharedPreference().readStorage(SpKeys.email);
    try{
      hasNext = true;
      loading = true;
      page = 0;

      final bloc = SupportTicketBloc();
      await bloc.getReportHistories(context, TicketArgument(page: page, limit: limit, descending: true, email: email)..type = 'content'..category = 'appeal');
      final fetch = bloc.supportTicketFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => AppealModel.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.length == limit;
      if(res != null) page++;
    }catch(e){
      'TicketsDataQuery Reload Error : $e '.logger();
    }finally{
      loading = false;
    }

    return res ?? [];
  }

}

