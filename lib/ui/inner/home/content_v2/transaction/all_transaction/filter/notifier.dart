import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FilterTransactionNotifier extends ChangeNotifier {
  bool _showDate = true;
  bool _showType = true;
  bool allSelect = false;
  bool last7DaysSelect = false;
  bool last30DaysSelect = false;
  List filterType = [];
  List filterList = [];
  List filterChecked = [];
  List newFilterList = [];
  List<TransactionHistoryModel>? dataAllTransaction = [];
  Map _param = {};
  bool _isLoading = false;
  bool _isScrollLoading = false;
  int _skip = 0;
  final int _limit = 6;

  bool get showDate => _showDate;
  bool get showType => _showType;
  bool get isLoading => _isLoading;
  bool get isScrollLoading => _isScrollLoading;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set isScrollLoading(bool val) {
    _isScrollLoading = val;
    notifyListeners();
  }

  set showDate(bool val) {
    _showDate = val;
    notifyListeners();
  }

  set showType(bool val) {
    _showType = val;
    notifyListeners();
  }

  bool pickDate(int? index) {
    allSelect = false;
    last7DaysSelect = false;
    last30DaysSelect = false;
    notifyListeners();
    switch (index) {
      case 0:
        return allSelect = true;
      case 1:
        return last7DaysSelect = true;
      default:
        return last30DaysSelect = true;
    }
  }

  void getTypeFilter(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    filterList = [
      {"id": 1, 'name': "${language.filter}", 'icon': 'filter.svg'},
      {"id": 2, 'name': "${language.buy}", 'icon': ''},
      {"id": 3, 'name': "${language.sell}", 'icon': ''},
      {"id": 4, 'name': "${language.withdrawal}", 'icon': ''},
      {"id": 5, 'name': "${language.postBoost}", 'icon': ''},
      {"id": 6, 'name': "${language.reward}", 'icon': ''},
    ];
  }

  void getListType(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    filterType = [
      {'id': 1, 'name': language.buy},
      {'id': 2, 'name': language.sell},
      {'id': 3, 'name': language.withdrawal},
      {'id': 4, 'name': language.postBoost},
      {'id': 5, 'name': language.reward},
      // {'id': 4, 'name': language.ownership},
    ];
  }

  void getListNewFilter(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    newFilterList = [
      {'id': 2, 'selected': false, 'name': language.buy},
      {'id': 3, 'selected': false, 'name': language.sell},
      {'id': 4, 'selected': false, 'name': language.withdrawal},
      {'id': 5, 'selected': false, 'name': language.postBoost},
      {'id': 6, 'selected': false, 'name': language.reward},
      // {'id': 5, 'selected': false, 'name': language.ownership},
    ];
  }

  bool checkType(int? index) => !filterChecked.contains(index) ? true : false;

  void pickType(int? index) {
    if (filterChecked.contains(index)) {
      filterChecked.removeWhere((v) => v == index);
    } else {
      filterChecked.add(index);
    }
    // notifyListeners();

    notifyListeners();
  }

  bool checkButton() => (filterChecked.isNotEmpty || allSelect || last7DaysSelect || last30DaysSelect) ? true : false;
  void filter(BuildContext context, int id) {
    if (id == 1) {
      getListType(context);
      ShowBottomSheet().onShowFilterAllTransaction(context);
    } else {
      (id == 2) ? _param.addAll({"buy": true}) : _param.addAll({"buy": false});
      (id == 3) ? _param.addAll({"sell": true}) : _param.addAll({"sell": false});
      (id == 4) ? _param.addAll({"withdrawal": true}) : _param.addAll({"withdrawal": false});
      (id == 5) ? _param.addAll({"boost": true}) : _param.addAll({"boost": false});
      (id == 6) ? _param.addAll({"rewards": true}) : _param.addAll({"rewards": false});
      final email = SharedPreference().readStorage(SpKeys.email);
      _skip = 0;
      _param.addAll({"skip": _skip, "limit": _limit, "email": email});
      dataAllTransaction = [];
      getAllTransaction(context, param2: _param, fromNewFilter: true);
    }
  }

  void filterSelected(BuildContext context, int id) {
    newFilterList.forEach((element) {
      if (element['id'] != 1) {
        element['selected'] = false;
      }

      if (element['id'] == id) element['selected'] = true;
    });

    notifyListeners();
  }

  void submitFilter(BuildContext context) {
    getListNewFilter(context);
    _param = {};
    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0, 10);
    if (last7DaysSelect) {
      var start = DateTime(dateToday.year, dateToday.month, dateToday.day - 7);
      final newStartDate = start.toString().substring(0, 10);
      _param.addAll({"startdate": newStartDate, "enddate": date});
      newFilterList.add(
        {'id': 1, 'selected': true, 'name': 'Last 7 Days'},
      );
    }

    if (last30DaysSelect) {
      var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 30);
      final newStartDate = startDate.toString().substring(0, 10);
      _param.addAll({"startdate": newStartDate, "enddate": date});
      newFilterList.add(
        {'id': 1, 'selected': true, 'name': 'Last 30 Days'},
      );
    }

    if (allSelect) {
      newFilterList.add(
        {'id': 1, 'selected': true, 'name': 'All'},
      );
    }

    if (filterChecked.contains(1)) {
      _param.addAll({"buy": true});
      final index = newFilterList.indexWhere((element) => element['id'] == 2);
      newFilterList[index]['selected'] = true;
    } else {
      _param.addAll({"buy": false});
    }

    if (filterChecked.contains(2)) {
      _param.addAll({"sell": true});
      final index = newFilterList.indexWhere((element) => element['id'] == 3);
      newFilterList[index]['selected'] = true;
    } else {
      _param.addAll({"sell": false});
    }

    if (filterChecked.contains(3)) {
      _param.addAll({"withdrawal": true});
      final index = newFilterList.indexWhere((element) => element['id'] == 4);
      newFilterList[index]['selected'] = true;
    } else {
      _param.addAll({"withdrawal": false});
    }

    if (filterChecked.contains(4)) {
      _param.addAll({"boost": true});
      final index = newFilterList.indexWhere((element) => element['id'] == 5);
      newFilterList[index]['selected'] = true;
    } else {
      _param.addAll({"boost": false});
    }

    if (filterChecked.contains(5)) {
      _param.addAll({"rewards": true});
      final index = newFilterList.indexWhere((element) => element['id'] == 6);
      newFilterList[index]['selected'] = true;
    } else {
      _param.addAll({"rewards": false});
    }
    // (filterChecked.contains(3)) ? _param.addAll({"withdrawal": true}) : _param.addAll({"withdrawal": false});
    final email = SharedPreference().readStorage(SpKeys.email);
    _param.addAll({"skip": 0, "limit": _limit, "email": email});
    newFilterList.sort((a, b) => a['id'].compareTo(b['id']));
    Routing().moveBack();

    getAllTransaction(context, param2: _param, fromNewFilter: true);
  }

  Future getAllTransaction(BuildContext context, {Map? param2, bool loading = true, bool fromNewFilter = false}) async {
    if (loading) isLoading = true;
    bool connect = await System().checkConnections();
    try {
      if (connect) {
        final email = SharedPreference().readStorage(SpKeys.email);
        DateTime dateToday = DateTime.now();
        String date = dateToday.toString().substring(0, 10);
        final param = {
          "email": email,
          "sell": false,
          "buy": false,
          "withdrawal": false,
          "boost": false,
          "rewards": false,
          "startdate": "2020-08-12",
          "enddate": date,
          "skip": _skip,
          "limit": _limit,
        };
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param2 ?? param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          if (fromNewFilter) dataAllTransaction = [];
          fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));
        }

        if (fetch.postsState == TransactionState.getHistoryError) {
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          }
        }
      } else {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
        });
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {}
  }

  void resetFilter(BuildContext context, {bool back = true}) {
    allSelect = false;
    last7DaysSelect = false;
    last30DaysSelect = false;
    dataAllTransaction = [];
    _skip = 0;
    newFilterList = [];
    filterChecked = [];
    // _param.clear();
    getAllTransaction(context);
    if (back) {
      Routing().moveBack();
    }
    notifyListeners();
  }

  void scrollList(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += _limit;
      isScrollLoading = true;
      if (_param.isEmpty) {
        final email = SharedPreference().readStorage(SpKeys.email);
        _param.addAll({"skip": _skip, "limit": _limit, "email": email, "buy": false, "sell": false, "withdrawal": false});
      }
      _param.addAll({"skip": _skip});
      await getAllTransaction(context, loading: false, param2: _param);
      isScrollLoading = false;
    }
  }
}
