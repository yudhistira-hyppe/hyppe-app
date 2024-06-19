
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/transaction/updatevafield/bloc.dart';
import 'package:hyppe/core/bloc/transaction/updatevafield/state.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';

class PaymentWaitingNotifier with ChangeNotifier {
  final bloc  = UpdateVaFieldDataBloc();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
  
  BankData _bankData = BankData();
  BankData get bankData => _bankData;
  set bankData(BankData val){
    _bankData = val;
    notifyListeners();
  }

  TransactionCoinModel _transactionCoinDetail = TransactionCoinModel();
  TransactionCoinModel get transactionCoinDetail => _transactionCoinDetail;
  set transactionCoinDetail(TransactionCoinModel value) {
    _transactionCoinDetail = value;
    notifyListeners();
  }

  Map _param = {};
  bool _isLoadingupdateva = true;
  bool get isLoadingupdateva => _isLoadingupdateva;
  set isLoadingupdateva(bool val) {
    _isLoadingupdateva = val;
    notifyListeners();
  }

  Future<void> updatevafield(BuildContext context) async {
    try{
      _isLoadingupdateva = true;
      _param.addAll({
        'nova': transactionCoinDetail.nova??''
      });
      
      
      await bloc.getUpdateVaField(context, data: _param);
      if (bloc.dataFetch.dataState == UpdateVaFieldState.getUpdateVaBlocSuccess) {
        
      }
      _isLoadingupdateva = false;
    }catch(_){
      _isLoadingupdateva = false;
      debugPrint(_.toString());
    }
  }

}