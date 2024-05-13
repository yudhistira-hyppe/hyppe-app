
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';

class PaymentWaitingNotifier with ChangeNotifier {

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


}