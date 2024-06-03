import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/detailtransaction/bloc.dart';
import 'package:hyppe/core/bloc/monetization/detailtransaction/state.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoindetail.dart';
import 'package:hyppe/ux/routing.dart';

class TransactionCoinDetailNotifier with ChangeNotifier {
  final Map _param = {};
  bool _isloading = false;
  bool get isloading => _isloading;
  set isloading(bool val){
    _isloading = val;
    notifyListeners();
  }

  DetailTransactionCoin _transactionDetail = DetailTransactionCoin();
  DetailTransactionCoin get transactionDetail => _transactionDetail;
  set transactionDetail(DetailTransactionCoin value) {
    _transactionDetail = value;
    notifyListeners();
  }

  final bloc = TransactionCoinDetailBloc();
  Future<void> detailData(BuildContext context,{String? invoiceId, String? status}) async {
    isloading = true;
    try{
      if (status == 'History'){
        _param.addAll({
          'noinvoice': invoiceId
        });
      }else{
        _param.addAll({
          'idtransaksi': invoiceId
        });
      }
      

      await bloc.getTransactionCoinDetail(context, data: _param);
      final fetch = bloc.dataFetch;
      if (fetch.dataState == TransactionCoinDetailState.getBlocError) {
        Future.delayed(const Duration(seconds: 3), () {
          Routing().moveBack();
        });
      } else if (fetch.dataState == TransactionCoinDetailState.getcBlocSuccess) {
        transactionDetail = DetailTransactionCoin.fromJson(fetch.data);
      }
      isloading = false;
      notifyListeners();
    }catch(_){
      isloading = false;
      notifyListeners();
      debugPrint(_.toString());
    }
  }

}