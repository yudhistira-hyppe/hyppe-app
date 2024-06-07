
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/historyordercoin/bloc.dart';
import 'package:hyppe/core/bloc/monetization/historyordercoin/state.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/coins/history_transaction.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'widgets/dialog_date.dart';
import 'widgets/dialog_datepicker.dart';
import 'widgets/dialog_info.dart';
class HistoryOrderCoinNotifier with ChangeNotifier {
  final bloc = HistoryTransactionDataBloc();
  Map? _paramsHistory = {};

  List<TransactionHistoryCoinModel> _result = [];
  List<TransactionHistoryCoinModel> get result => _result;
  set result(List<TransactionHistoryCoinModel> val) {
    _result = val;
    notifyListeners();
  }

  //Selected Value Date
  int selectedDateValue = 1;
  String selectedDateLabel = 'Semua Tanggal';
  String tempSelectedDateStart = DateTime.now().toString();
  String tempSelectedDateEnd = DateTime.now().toString();

  //TextEdit Date 
  final TextEditingController textStartDateController = TextEditingController();
  final TextEditingController textEndDateController = TextEditingController();

  //Modal List Date
  List<GroupModel> groupsDate = [];

  void getTypeFilter(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    groupsDate = [
      GroupModel(text: "${language.all}", index: 1, selected: true),
      GroupModel(text: language.localeDatetime =='id'?'30 Hari Terakhir':'Last 30 Days', index: 2, selected: false),
      GroupModel(text: language.localeDatetime =='id'?'90 Hari Terakhir':'Last 90 Days', index: 3, selected: false),
      GroupModel(text: language.localeDatetime =='id'?'Pilih Rentang Tanggal':'Select Date', index: 4, selected: false, 
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString(),
        ),
    ];
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  int _page = 0;
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

  Future<void> initHistory(BuildContext context, mounted) async {
    try{
      result.clear();
      page = 0;
      
      String email = SharedPreference().readStorage(SpKeys.email);
      _paramsHistory?.addAll({
        "email": email,
        "status": ["PENDING","IN PROGRESS","FAILED"],
        "type": ["Pembelian Coin"],
        "page": page
      });

      DateTime dateToday = DateTime.now();
      String date = dateToday.toString().substring(0, 10);
      int groupDate = groupsDate.firstWhere((element) => element.selected == true).index;
      switch (groupDate) {
        case 2:
            var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 30);
            final newStartDate = startDate.toString().substring(0, 10);
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": date
            });
          break;
        case 3:
            var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 90);
            final newStartDate = startDate.toString().substring(0, 10);
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": date
            });
          break;
        case 4:
            var res = groupsDate.firstWhere((element) => element.selected == true);
            final newStartDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(res.startDate??''));
            final enddate = DateFormat('yyyy-MM-dd').format(DateTime.parse(res.endDate??''));
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": enddate
            });
          break;
        default:
          break;
      }

      await bloc.getHistoryTransaction(context, data: _paramsHistory);
      
      if (bloc.dataFetch.dataState == HistoryTransactionState.getBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result = bloc.dataFetch.data;
        isLastPage = false;
      } else {
        isLastPage = true;
      }
      notifyListeners();
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future<void> loadMore(BuildContext context, mounted) async {
    _paramsHistory = {};
    try{
      DateTime dateToday = DateTime.now();
      String date = dateToday.toString().substring(0, 10);
      page = page+1;

      String email = SharedPreference().readStorage(SpKeys.email);
      _paramsHistory?.addAll({
        "email": email,
        "status": ["PENDING", "IN PROGRESS", "FAILED"],
        "type": ["Pembelian Coin"],
        "page": page
      });
      
      int groupDate = groupsDate.firstWhere((element) => element.selected == true).index;
      switch (groupDate) {
        case 2:
            var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 30);
            final newStartDate = startDate.toString().substring(0, 10);
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": date
            });
          break;
        case 3:
            var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 90);
            final newStartDate = startDate.toString().substring(0, 10);
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": date
            });
          break;
        case 4:
            var res = groupsDate.firstWhere((element) => element.selected == true);
            final newStartDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(res.startDate??''));
            final enddate = DateFormat('yyyy-MM-dd').format(DateTime.parse(res.endDate??''));
            _paramsHistory?.addAll({
               "startdate": newStartDate,
                "enddate": enddate
            });
          break;
        default:
          break;
      }

      await bloc.getHistoryTransaction(context, data: _paramsHistory);
      
      if (bloc.dataFetch.dataState == HistoryTransactionState.getBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result.addAll(bloc.dataFetch.data);
      } else {
        isLastPage = true;
        page = page-1;
        // Fluttertoast.showToast(msg: 'Already on the last ');
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }

  void resetSelected(BuildContext context, mounted) async {
    final language = context.read<TranslateNotifierV2>().translate;
    selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    for (int i = 0; i < groupsDate.length; i++) {
      groupsDate[i].selected = false;
    }
    groupsDate[0].selected = true;
    selectedDateValue = 1;
    await initHistory(context, mounted);
    notifyListeners();
  }

  void showButtomSheetDate(BuildContext context) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const DialogDate();
        }
    ).whenComplete(() {
      if (!groupsDate.firstWhere((e) => e.index == selectedDateValue).selected){
        selectedDateValue = groupsDate.firstWhere((element) => element.selected==true).index;
      }
    });
  }
  
  void changeSelectedDate(BuildContext context, mounted) async {
    final language = context.read<TranslateNotifierV2>().translate;
    
    for (int i = 0; i < groupsDate.length; i++) {
      groupsDate[i].selected = false;
    }
    groupsDate[groupsDate.indexWhere((element) => element.index == selectedDateValue)].selected = true;
    if (selectedDateValue == 1){
      selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    }else{
      if (groupsDate.firstWhere((element) => element.selected == true).index == 4){
        var res = groupsDate.firstWhere((element) => element.selected == true);
        selectedDateLabel = '${DateFormat('dd MMM yyyy').format(DateTime.parse(res.startDate??''))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(res.endDate??''))}';

      }else{
        selectedDateLabel = groupsDate.firstWhere((element) => element.selected == true).text;
      }
    }
    await initHistory(context, mounted);
    
    notifyListeners();
  }


  void showButtomSheetInfoDialog(BuildContext context, LocalizationModelV2? lang) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return InfoDialog(lang: lang,);
        }
    );
  }

  void showButtomSheetDatePicker(BuildContext context,{bool isStartDate = false}) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DialogDatePicker(isStartDate: isStartDate,);
        }
    );
  }

  void selectedDatePicker({bool isStartDate = false}) {
    if (isStartDate){
      groupsDate[3].startDate = tempSelectedDateStart;
      textStartDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(tempSelectedDateStart));
      notifyListeners();
    }else{
      groupsDate[3].endDate = tempSelectedDateEnd;
      textEndDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(tempSelectedDateEnd));
      notifyListeners();
    }
  }
}

class GroupModel {
  String text;
  int index;
  bool selected;
  String? startDate;
  String? endDate;
  GroupModel({required this.text, required this.index, required this.selected, this.startDate, this.endDate});
}