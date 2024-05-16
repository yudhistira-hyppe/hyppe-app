
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/coin/bloc.dart';
import 'package:hyppe/core/bloc/monetization/coin/state.dart';
import 'package:hyppe/core/models/collection/coins/coinmodel.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

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
}