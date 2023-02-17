import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../../../../core/arguments/ticket_argument.dart';
import '../../../../../../core/bloc/support_ticket/bloc.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../../../../core/models/collection/support_ticket/ticket_model.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../constant/overlay/general_dialog/show_general_dialog.dart';
class DetailTicketNotifier extends ChangeNotifier{
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  FocusNode _inputNode = FocusNode();
  FocusNode get inputNode => _inputNode;

  TextEditingController _commentController = TextEditingController();
  TextEditingController get commentController => _commentController;

  TicketModel? _ticketModel;
  TicketModel? get ticketModel => _ticketModel;
  set ticketModel(TicketModel? data){
    _ticketModel = data;
    notifyListeners();
  }

  bool _isLoadNavigate = false;
  bool get isLoadNavigate => _isLoadNavigate;
  set isLoadNavigate(bool state){
    _isLoadNavigate = state;
    notifyListeners();
  }

  List<File>? _files = [];
  List<File>? get files => _files;
  set files(List<File>? data){
    _files = data;
    notifyListeners();
  }

  removeFiles(int index){
    files?.removeAt(index);
    notifyListeners();
  }

  removeAllFiles(){
    files = [];
    notifyListeners();
  }


  initStateDetailTicket(TicketModel model){
    _commentController = TextEditingController();
    _inputNode = FocusNode();
    _ticketModel = model;
  }

  disposeState(){
    try{
      _ticketModel = null;
      _files = [];
      _commentController.dispose();
      _inputNode.dispose();
    }catch(e){
      e.logger();
    }
  }


  Future getDetailTicket(BuildContext context, {isRefresh = false}) async{
    List<TicketModel>? res;
    try{
      if(isRefresh){
        _ticketModel?.detail = null;
        notifyListeners();
      }
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
      return res ?? [];
    }
  }

  Future sendComment(BuildContext context, String message) async{
    final ticketID = _ticketModel?.id;
    final status = _ticketModel?.status;
    try{
      if(ticketID != null){
        if(status != null){
          final bloc = SupportTicketBloc();
          await bloc.sendComment(context, TicketArgument(idUserTicket: ticketID, body: message, status: status,), files: _files, onSuccess: () async{
            commentController.text = '';
            removeAllFiles();
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

  void onTapOnFrameLocalMedia(BuildContext context, {isPdf = false}) async {
    final filesLenght = files?.length ?? 0;
    try {
      if(filesLenght >= 4){
        ShowGeneralDialog.pickFileErrorAlert(context, language.max4Images ?? 'Max 4 images');
      }else{
        await System().getLocalMedia(featureType: FeatureType.other, context: context, pdf: isPdf, model: language).then((value) async {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            if (value.values.single != null) {
              final fixFiles = value.values.single?.map((e) => e).toList() ?? [];
              final totalLenght = fixFiles.length + filesLenght;
              if(totalLenght > 4){
                ShowGeneralDialog.pickFileErrorAlert(context, language.max4Images ?? 'Max 4 images');
              }else{
                files ??= [];
                files?.addAll(fixFiles);
                notifyListeners();
                if(files != null){
                  for(var file in files!){
                    'onTapOnFrameLocalMedia files : ${System().lookupContentMimeType(file.path)} => ${file.path.split('/').last}'.logger();
                  }
                }
              }
            } else {
              if (value.keys.single.isNotEmpty) ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
            }
          });
        });
      }

    } catch (e) {
      ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred ?? '');
    }
  }
}
