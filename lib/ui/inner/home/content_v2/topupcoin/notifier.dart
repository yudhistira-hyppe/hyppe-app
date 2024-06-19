
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/coin/bloc.dart';
import 'package:hyppe/core/bloc/monetization/coin/state.dart';
import 'package:hyppe/core/bloc/monetization/maxmin/bloc.dart';
import 'package:hyppe/core/bloc/monetization/maxmin/state.dart';
import 'package:hyppe/core/bloc/saldo_coin/state.dart';
import 'package:hyppe/core/models/collection/coins/coinmodel.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

import '../../../../../core/bloc/saldo_coin/bloc.dart';

class TopUpCoinNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List<CointModel> _result = [];
  List<CointModel> get result => _result;
  set result(List<CointModel> val) {
    _result = val;
    notifyListeners();
  }

  final bloc = CoinDataBloc();
  final blocMaxmin = MaxminDataBloc();
  
  int _saldoCoin = 0;
  int get saldoCoin => _saldoCoin;
  set saldoCoin(int val){
    _saldoCoin = val;
    notifyListeners();
  }

  Future initSaldo(BuildContext context) async {
    try{
      final bloc = SaldoCoinDataBloc();
      await bloc.getSaldoCoin(context);
      if (bloc.dataFetch.dataState == SaldoCoinState.getBlocSuccess) {
        saldoCoin = bloc.dataFetch.data??0;
      }
      
    }catch(_){
      debugPrint(_.toString());
    }
  }

  int _page = 1;
  int get page => _page;
  set page(int val){
    _page = val;
    notifyListeners();
  }

  bool isLastPage = false;

  bool _isLoadMore = false;
  bool get isLoadMore => _isLoadMore;
  set isLoadMore(bool val){
    _isLoadMore = val;
    notifyListeners();
  }

  Map _params={};
  bool _isLoadMaxmin = false;
  bool get isLoadMaxmin => _isLoadMaxmin;
  set isLoadMaxmin(bool val){
    _isLoadMaxmin = val;
    notifyListeners();
  }

  bool _isValidateMaxmin = false;
  bool get isValidateMaxmin => _isValidateMaxmin;
  set isValidateMaxmin(bool val){
    _isValidateMaxmin = val;
    notifyListeners();
  }

  int _isValueMaxmin = 0;
  int get isValueMaxmin => _isValueMaxmin;
  set isValueMaxmin(int val){
    _isValueMaxmin = val;
    notifyListeners();
  }

  Future<void> initCoin(BuildContext context) async {
    try{
      page = 0;

      await bloc.getCoin(context, page: page);
      if (bloc.dataFetch.dataState == CoinState.getCoinBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result = bloc.dataFetch.data;
        // result.sort((a, b) => a.amount!.compareTo(b.amount!));
      } else {
        isLastPage = true;
      }
      
      await initSaldo(context);
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future<void> loadMore(BuildContext context, {int? page, bool desc = true}) async {
    try{
      if (isLoadMore) return;

      isLoadMore = true;

      await bloc.getCoin(context, page: page);
      if (bloc.dataFetch.dataState == CoinState.getCoinBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result = [...(result), ...bloc.dataFetch.data];
      } else {
        isLastPage = true;
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }


  void changeSelectedCoin(String? selected) {
    for (int i = 0; i < result.length; i++) {
      result[i].checked = false;
    }
    result[result.indexWhere((element) => element.id == selected)].checked = true;
    notifyListeners();
  }

  Future<void> checkmaxmin(BuildContext context) async {
    _params = {};
    try{
      isLoadMaxmin = true;
      _params = {
        'amount': result[result.indexWhere((element) => element.checked==true)].price
      };

      await blocMaxmin.getMaxmin(context, data: _params);
      if (blocMaxmin.dataFetch.dataState == MaxminCoinState.getBlocSuccess) {
        isValidateMaxmin = blocMaxmin.dataFetch.data['valid'];
        isValueMaxmin = blocMaxmin.dataFetch.data['dailyMax'];
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }
}