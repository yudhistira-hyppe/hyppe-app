import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/saldo_coin/bloc.dart';
import 'package:hyppe/core/bloc/saldo_coin/state.dart';

class SaldoCoinNotifier with ChangeNotifier {
  final bloc = SaldoCoinDataBloc();

  int _saldoCoin = 0;
  int get saldoCoin => _saldoCoin;
  set saldoCoin(int val) {
    _saldoCoin = val;
    notifyListeners();
  }

  int _transactionCoin = 0;
  int get transactionCoin => _transactionCoin;
  set transactionCoin(int val) {
    _transactionCoin = val;
    // notifyListeners();
  }

  bool _visibilityTransaction = false;
  bool get visibilityTransaction => _visibilityTransaction;
  set visibilityTransaction(bool val) {
    _visibilityTransaction = val;
    // notifyListeners();
  }

  Future initSaldo(BuildContext context) async {
    try {
      await bloc.getSaldoCoin(context);
      if (bloc.dataFetch.dataState == SaldoCoinState.getBlocSuccess) {
        saldoCoin = bloc.dataFetch.data ?? 0;
      }
      await checkSaldoCoin();
    } catch (_) {
      debugPrint(_.toString());
    }
  }

  Future<void> checkSaldoCoin() async {
    try {
      int check = saldoCoin - transactionCoin;
      print('========== $saldoCoin $transactionCoin $check');
      if (check > 0) {
        visibilityTransaction = true;
      } else {
        visibilityTransaction = false;
      }
      // notifyListeners();
    } catch (_) {
      visibilityTransaction = false;
    }
  }
}
