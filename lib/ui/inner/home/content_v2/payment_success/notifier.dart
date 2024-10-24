
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/detailtransaction/bloc.dart';
import 'package:hyppe/core/bloc/monetization/detailtransaction/state.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoindetail.dart';
import 'package:hyppe/ux/routing.dart';

class PaymentSuccessCoinNotifier with ChangeNotifier {
  Map _param = {};

  DetailTransactionCoin _transactionDetail = DetailTransactionCoin();
  DetailTransactionCoin get transactionDetail => _transactionDetail;
  set transactionDetail(DetailTransactionCoin value) {
    _transactionDetail = value;
    notifyListeners();
  }
  
  final bloc = TransactionCoinDetailBloc();
  Future<void> detailData(BuildContext context,{Map? map}) async {
    _param = {};
    try{
      // if (map?['type'] == 'FMC'){
      //   _param.addAll({
      //     'noinvoice': map?['postId']
      //   });
      // }else{
      //   _param.addAll({
      //     'idtransaksi': map?['postId']
      //   });
      // }
      _param.addAll({
          'noinvoice': map?['postId']
        });

      await bloc.getTransactionCoinDetail(context, data: _param);
      final fetch = bloc.dataFetch;
      if (fetch.dataState == TransactionCoinDetailState.getBlocError) {
        Future.delayed(const Duration(seconds: 3), () {
          Routing().moveBack();
        });
      } else if (fetch.dataState == TransactionCoinDetailState.getcBlocSuccess) {
        transactionDetail = DetailTransactionCoin.fromJson(fetch.data);
      }

      notifyListeners();
    }catch(_){
      debugPrint(_.toString());
    }
  }
}