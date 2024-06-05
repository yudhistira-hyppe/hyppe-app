import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/withdrawal/withdrawaldetail/bloc.dart';
import 'package:hyppe/core/bloc/withdrawal/withdrawaldetail/state.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawaldetail.dart';
import 'package:hyppe/ux/routing.dart';

class WithdrawalDetailNotifier with ChangeNotifier {
  Map _param = {};
  bool _isloading = false;
  bool get isloading => _isloading;
  set isloading(bool val){
    _isloading = val;
    notifyListeners();
  }

  DetailWithdrawalModel _transactionDetail = DetailWithdrawalModel();
  DetailWithdrawalModel get transactionDetail => _transactionDetail;
  set transactionDetail(DetailWithdrawalModel value) {
    _transactionDetail = value;
    notifyListeners();
  }

  final bloc = WithdrawalDetailBloc();
  Future<void> detailData(BuildContext context,{String? invoiceId}) async {
    isloading = true;
    notifyListeners();
    _param = {};
    try{
      
      _param.addAll({
        'noInvoice': invoiceId
      });
      

      await bloc.getWithdrawalDetail(context, data: _param);
      final fetch = bloc.dataFetch;
      if (fetch.dataState == WithdrawalDetailState.getBlocError) {
        Future.delayed(const Duration(seconds: 1), () {
          Routing().moveBack();
        });
      } else if (fetch.dataState == WithdrawalDetailState.getcBlocSuccess) {
        transactionDetail = fetch.data;
        isloading = false;
        notifyListeners();
      }
      
    }catch(_){
      isloading = false;
      notifyListeners();
      debugPrint(_.toString());
    }
  }

}