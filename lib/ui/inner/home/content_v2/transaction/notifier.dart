import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/saldo_coin/bloc.dart';
import 'package:hyppe/core/bloc/saldo_coin/state.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/state.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/coins/history_transaction.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/account_balance.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/bank_account_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/models/collection/transaction/withdrawal_model.dart';
import 'package:hyppe/core/models/collection/transaction/withdrawal_summary_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/add_bank_account/preview_doc_appeal.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/dialog_filters.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'bank_account/widget/bank_account.dart';
import 'widget/dialog_date.dart';
import 'widget/dialog_datepicker.dart';

class TransactionNotifier extends ChangeNotifier {
  Map _param = {};

  int _skip = 0;
  int get skip => _skip;
  int _limit = 5;

  int _saldoCoin = 0;
  int get saldoCoin => _saldoCoin;
  set saldoCoin(int val) {
    _saldoCoin = val;
    notifyListeners();
  }

  List<BankAccount>? dataAcccount = [];
  List<TransactionHistoryModel>? dataTransaction = [];
  List<TransactionHistoryModel>? dataAllTransaction = [];
  List<TransactionHistoryModel>? dataTransactionInProgress = [];
  TransactionHistoryModel? dataTransactionDetail;
  int? countTransactionProgress = 0;

  WithdrawalSummaryModel? withdarawalSummarymodel;
  WithdrawalModel? withdarawalmodel;

  AccountBalanceModel? _accountBalance;
  AccountBalanceModel? get accountBalance => _accountBalance;

  String _errorNoBalance = '';
  String get errorNoBalance => _errorNoBalance;

  String? bankcode;
  TextEditingController pinController = TextEditingController();
  TextEditingController _nameAccount = TextEditingController();
  TextEditingController _noBankAccount = TextEditingController();
  TextEditingController _accountOwnerName = TextEditingController();
  TextEditingController _amountWithdrawalController = TextEditingController();

  TextEditingController get nameAccount => _nameAccount;
  TextEditingController get noBankAccount => _noBankAccount;
  TextEditingController get accountOwnerName => _accountOwnerName;
  TextEditingController get amountWithdrawalController => _amountWithdrawalController;

  String _errorPinWithdrawMsg = '';
  String get errorPinWithdrawMsg => _errorPinWithdrawMsg;

  String? _amountWithDrawal = '';
  String? get amountWithDrawal => _amountWithDrawal;

  String _amount = '';
  String get amount => _amount;

  bool _isChecking = false;
  bool get isCheking => _isChecking;

  String _bankSelected = '';
  String get bankSelected => _bankSelected;

  String _messageAddBankError = '';
  String get messageAddBankError => _messageAddBankError;
  String _noBank = "";
  String get noBank => _noBank;

  String _accountOwner = "";
  String get accountOwner => _accountOwner;

  String _accountNumber = "";
  String get accountNumber => _accountNumber;

  BankData? _bankDataSelected;
  BankData? get bankDataSelected => _bankDataSelected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingInProgress = false;
  bool get isLoadingInProgress => _isLoadingInProgress;
  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;
  bool _isLoadingSummaryWithdraw = false;
  bool get isLoadingSummaryWithdraw => _isLoadingSummaryWithdraw;
  bool _isLoadingSaldo = false;
  bool get isLoadingSaldo => _isLoadingSaldo;

  DateTime _timeVA = DateTime.now();
  DateTime get timeVA => _timeVA;

  int _minuteVa = 0;
  int get minuteVa => _minuteVa;
  int _secondVa = 0;
  int get secondVa => _secondVa;

  Future initSaldo(BuildContext context) async {
    try {
      final bloc = SaldoCoinDataBloc();
      await bloc.getSaldoCoin(context);
      if (bloc.dataFetch.dataState == SaldoCoinState.getBlocSuccess) {
        saldoCoin = bloc.dataFetch.data ?? 0;
      } else {
        saldoCoin = 0;
      }
    } catch (_) {
      debugPrint(_.toString());
    }
  }

  Map? _paramsHistory = {};
  final bloc = HistoryTransactionDataBloc();
  bool _isLoadingHistory = true;
  bool get isLoadingHistory => _isLoadingHistory;
  set isLoadingHistory(bool val) {
    _isLoadingHistory = val;
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

  //TextEdit Date 
  final TextEditingController textStartDateController = TextEditingController();
  final TextEditingController textEndDateController = TextEditingController();

  List<TransactionHistoryCoinModel> _result = [];
  List<TransactionHistoryCoinModel> get result => _result;
  set result(List<TransactionHistoryCoinModel> val) {
    _result = val;
    notifyListeners();
  }

  //Selected Value Transaction
  int selectedFiltersValue = 1;
  String selectedFiltersLabel = 'Semua Transaksi';
  List<GroupModel> filterList = [];
  //Selected Value Date
  int selectedDateValue = 1;
  String selectedDateLabel = 'Semua Tanggal';
  String tempSelectedDateStart = DateTime.now().toString();
  String tempSelectedDateEnd = DateTime.now().toString();
  List<GroupModel> filterDate = [];

  void getTypeFilter(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    filterList = [
      GroupModel(text: "${language.all}", index: 1, selected: true),
      GroupModel(text: language.localeDatetime == 'id' ? 'Pembelian Coins' : 'Coin Purchase', index: 2, selected: false),
      GroupModel(text: language.localeDatetime == 'id' ? 'Penukaran Coins' : 'Exchanged Coins', index: 3, selected: false),
    ];
  }

  void getDateFilter(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    filterDate = [
      GroupModel(text: "${language.all}", index: 1, selected: true),
      GroupModel(text: language.localeDatetime =='id'?'30 Hari Terakhir':'Last 30 Days', index: 2, selected: false),
      GroupModel(text: language.localeDatetime =='id'?'90 Hari Terakhir':'Last 90 Days', index: 3, selected: false),
      GroupModel(text: language.localeDatetime =='id'?'Pilih Rentang Tanggal':'Select Date', index: 4, selected: false, 
        startDate: DateTime.now().toString(),
        endDate: DateTime.now().toString(),
        ),
    ];
  }

  void resetSelected(BuildContext context, mounted) async {
    final language = context.read<TranslateNotifierV2>().translate;
    _paramsHistory = {};
    selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    selectedFiltersLabel = language.localeDatetime == 'id' ? 'Semua Transaksi': 'All';
    for (int i = 0; i < filterDate.length; i++) {
      filterDate[i].selected = false;
    }

    for (int i = 0; i < filterList.length; i++) {
      filterList[i].selected = false;
    }

    filterDate[0].selected = true;
    filterList[0].selected = true;
    selectedDateValue = 1;
    selectedFiltersValue = 1;
    _paramsHistory?.addAll({
      "type": ["Pembelian Coin", "Penukaran Coin"],
    });
    notifyListeners();
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
      filterDate[3].startDate = tempSelectedDateStart;
      textStartDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(tempSelectedDateStart));
      notifyListeners();
    }else{
      filterDate[3].endDate = tempSelectedDateEnd;
      textEndDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(tempSelectedDateEnd));
      notifyListeners();
    }
  }

  void changeSelectedTransaction(BuildContext context, mounted) async {
    final language = context.read<TranslateNotifierV2>().translate;
    for (int i = 0; i < filterList.length; i++) {
      filterList[i].selected = false;
    }
    filterList[filterList.indexWhere((element) => element.index == selectedFiltersValue)].selected = true;
    if (selectedFiltersValue == 1){
      selectedFiltersLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    }else{
      selectedFiltersLabel = filterList.firstWhere((element) => element.selected == true).text;
    }
    await initHistory(context, mounted);

    notifyListeners();
  }
  
  // void pickType(int? index) {
  //   if (selectedFiltersValue.contains(filterList[index ?? 0].text)) {
  //     selectedFiltersValue.removeWhere((v) => v == filterList[index ?? 0].text);
  //     filterList[index ?? 0].selected = false;
  //   } else {
  //     filterList[index ?? 0].selected = true;
  //     selectedFiltersValue.add(filterList[index ?? 0].text);
  //   }
  //   notifyListeners();
  // }

  // void loadpickType() {
  //   for (var i = 0; i < selectedFiltersValue.length; i++) {
  //     int idx = filterList.indexWhere((e) => e.text == selectedFiltersValue[i]);
  //     // print(idx);
  //     if (idx != -1) {
  //       filterList[idx].selected = true;
  //     }
  //   }
  //   notifyListeners();
  // }

  void changeSelectedDate(BuildContext context, mounted) async {
    final language = context.read<TranslateNotifierV2>().translate;
    
    for (int i = 0; i < filterDate.length; i++) {
      filterDate[i].selected = false;
    }
    filterDate[filterDate.indexWhere((element) => element.index == selectedDateValue)].selected = true;
    if (selectedDateValue == 1){
      selectedDateLabel = language.localeDatetime == 'id' ? 'Semua Tanggal': 'All Date';
    }else{
      if (filterDate.firstWhere((element) => element.selected == true).index == 4){
        var res = filterDate.firstWhere((element) => element.selected == true);
        selectedDateLabel = '${DateFormat('dd MMM yyyy').format(DateTime.parse(res.startDate??''))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(res.endDate??''))}';

      }else{
        selectedDateLabel = filterDate.firstWhere((element) => element.selected == true).text;
      }
    }

    await initHistory(context,mounted);
    notifyListeners();
  }

  bool _selectedTransaksi = false;
  bool get selectedTransaksi => _selectedTransaksi;
  set selectedTransaksi(bool val) {
    _selectedTransaksi = val;
    notifyListeners();
  }

  void showButtomSheetFilters(BuildContext context) {
    getTypeFilter(context);
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const DialogFilters();
        }).whenComplete(() {
      if (!selectedTransaksi) {
        
      }
    });
  }

  void showButtomSheetDate(BuildContext context) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const DialogDate();
        });
  }

  Future<void> initHistory(BuildContext context, mounted) async {
    _paramsHistory = {};
    try{
      result.clear();
      page = 0;

      String email = SharedPreference().readStorage(SpKeys.email);
      _paramsHistory?.addAll({
        "email": email,
        "page": page,
        "descending": true
      });
      
      if (filterList.firstWhere((element) => element.selected == true).index == 2){
          _paramsHistory?.addAll({
            "type": ["Pembelian Coin"],
          });
        }else if (filterList.firstWhere((element) => element.selected == true).index == 3){
          _paramsHistory?.addAll({
            "type": ["Penukaran Coin"],
          });
        }else{
          _paramsHistory?.addAll({
            "type": ["Pembelian Coin", "Penukaran Coin"],
          });
        }
      DateTime dateToday = DateTime.now();
      String date = dateToday.toString().substring(0, 10);
      int groupDate = filterDate.firstWhere((element) => element.selected == true).index;
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
            var res = filterDate.firstWhere((element) => element.selected == true);
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

      await bloc.getHistoryTransaction(context, data: _paramsHistory, historyTransaksi: true);
      
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
        "page": page,
        "descending": true,
      });
      if (filterList.firstWhere((element) => element.selected == true).index == 2){
          _paramsHistory?.addAll({
            "type": ["Pembelian Coin"],
          });
        }else if (filterList.firstWhere((element) => element.selected == true).index == 3){
          _paramsHistory?.addAll({
            "type": ["Penukaran Coin"],
          });
        }else{
          _paramsHistory?.addAll({
            "type": ["Pembelian Coin", "Penukaran Coin"],
          });
        }
      int groupDate = filterDate.firstWhere((element) => element.selected == true).index;
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
            var res = filterDate.firstWhere((element) => element.selected == true);
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

      await bloc.getHistoryTransaction(context, data: _paramsHistory, historyTransaksi: true);
      
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

  // void resetSelected() {
  //   for (var i = 0; i < filterDate.length; i++) {
  //     filterDate[i].selected = false;
  //   }
  //   selectedTransaksi = false;
  //   selectedDateValue = 1;
  //   filterDate[0].selected = true;
  //   selectedFiltersValue.clear();
  //   selectedFiltersLabel = 'Semua Transaksi';
  //   selectedDateLabel = 'Semua Tanggal';
  //   notifyListeners();
  // }

  set amountWithDrawal(String? val) {
    _amountWithDrawal = val;
    notifyListeners();
  }

  set errorPinWithdrawMsg(String val) {
    _errorPinWithdrawMsg = val;
    notifyListeners();
  }

  set amount(String val) {
    _amount = val;
    notifyListeners();
  }

  set amountWithdrawalController(TextEditingController val) {
    _amountWithdrawalController = val;
    notifyListeners();
  }

  set bankSelected(String val) {
    _bankSelected = val;
    notifyListeners();
  }

  set accountBalance(AccountBalanceModel? val) {
    _accountBalance = val;
    notifyListeners();
  }

  set messageAddBankError(String val) {
    _messageAddBankError = val;
    notifyListeners();
  }

  set skip(int val) {
    _skip = val;
    notifyListeners();
  }

  setSkip(int val) {
    _skip = val;
  }

  set isDetailLoading(bool val) {
    _isDetailLoading = val;
    notifyListeners();
  }

  set isLoadingSummaryWithdraw(bool val) {
    _isLoadingSummaryWithdraw = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  setIsLoading(bool val) {
    _isLoading = val;
  }

  set isLoadingSaldo(bool val) {
    _isLoadingSaldo = val;
    notifyListeners();
  }

  set isLoadingInProgress(bool val) {
    _isLoadingInProgress = val;
    notifyListeners();
  }

  set isScrollLoading(bool val) {
    _isScrollLoading = val;
    notifyListeners();
  }

  set accountOwner(String val) {
    _accountOwner = val;
    notifyListeners();
  }

  set noBank(String val) {
    _noBank = val;
    notifyListeners();
  }

  set bankDataSelected(BankData? val) {
    _bankDataSelected = val;
    notifyListeners();
  }

  set nameAccount(TextEditingController val) {
    _nameAccount = val;
    notifyListeners();
  }

  set noBankAccount(TextEditingController val) {
    _noBankAccount = val;
    notifyListeners();
  }

  set accountOwnerName(TextEditingController val) {
    _accountOwnerName = val;
    notifyListeners();
  }

  navigateToBankAccount() => Routing().move(Routes.bankAccount);
  navigateToAddBankAccount() => Routing().move(Routes.addBankAccount);
  navigateToDetailTransaction() => Routing().move(Routes.detailTransaction);
  navigateToWithDrawal() => Routing().move(Routes.withdrawal);

  showDialogHelp(BuildContext context) {
    ShowBottomSheet().onShowHelpBankAccount(context);
  }

  showDialogAllBank(BuildContext context) {
    Provider.of<PaymentMethodNotifier>(context, listen: false).initState(context);
    ShowBottomSheet().onShowAllBank(context);
  }

  void showButtomSheetAllBankList(BuildContext context, lang, bool position) {
    Provider.of<PaymentMethodNotifier>(context, listen: false).initState(context);
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return ListBankAccountWidget(
            lang: lang,
            position: position,
          );
        });
  }

  void bankInsert(BankData data, {bool? position}) {
    bankDataSelected = data;
    nameAccount.text = data.bankname ?? '';
    bankcode = data.bankcode;
    if (!(position ?? false)) {
      Routing().moveBack();
      navigateToAddBankAccount();
    }
  }

  Future initTransactionHistory(BuildContext context) async {
    print('dataTransaction?.isEmpty ${dataTransaction?.isEmpty}');
    if (dataTransaction?.isEmpty ?? false) isLoading = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        await getAccountBalance(context);
        // DateTime dateToday = DateTime.now();
        // String date = dateToday.toString().substring(0, 10);
        // String email = 'freeman27@getnada.com';
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, 'boost': false, "rewards": false, "skip": _skip, "limit": _limit};
        debugPrint("${param}");
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          if (_skip == 0) dataTransaction = [];
          print("===hihihi ${fetch.data['data'].length}}");
          try {
            fetch.data['data'].forEach((v) => dataTransaction?.add(TransactionHistoryModel.fromJSON(v)));
          } catch (e) {
            print("===hihihi $e");
          }

          if (dataAllTransaction?.isEmpty ?? false) {
            fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));
            context.read<FilterTransactionNotifier>().dataAllTransaction = dataAllTransaction;
          }

          // countTransactionProgress = fetch.data['datacount'];
        }
        if (fetch.postsState == TransactionState.getHistoryError) {
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          } else {
            // ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
          }
        }
      } catch (e) {
        print(e);
      }
      _isLoading = false;
      Future.delayed(const Duration(milliseconds: 250), () {
        notifyListeners();
      });
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        initBankAccount(context);
      });
    }
  }

  void filter(BuildContext context) {
    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0, 10);
    _param = {};
    for (var i = 0; i < filterDate.length; i++) {
      if (filterDate[i].selected == true) {
        if (filterDate[i].index == 2) {
          var start = DateTime(dateToday.year, dateToday.month, dateToday.day - 7);
          final newStartDate = start.toString().substring(0, 10);
          _param.addAll({"startdate": newStartDate, "enddate": date});
        }
        if (filterDate[i].index == 3) {
          var startDate = DateTime(dateToday.year, dateToday.month, dateToday.day - 30);
          final newStartDate = startDate.toString().substring(0, 10);
          _param.addAll({"startdate": newStartDate, "enddate": date});
        }
      }
    }

    for (var i = 0; i < filterList.length; i++) {
      if (filterList[i].index == 1) {
        _param.addAll({"buy": filterList[i].selected});
      }
      if (filterList[i].index == 2) {
        _param.addAll({"sell": filterList[i].selected});
      }
      if (filterList[i].index == 3) {
        _param.addAll({"withdrawal": filterList[i].selected});
      }
      if (filterList[i].index == 4) {
        _param.addAll({"boost": filterList[i].selected});
      }
      if (filterList[i].index == 5) {
        _param.addAll({"rewards": filterList[i].selected});
      }
      if (filterList[i].index == 6) {
        _param.addAll({"voucher": filterList[i].selected});
      }
    }
    print(_param);

    final email = SharedPreference().readStorage(SpKeys.email);
    _skip = 0;
    _param.addAll({"skip": _skip, "limit": _limit, "email": email});
    dataAllTransaction = [];
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
          if (fromNewFilter) dataTransaction = [];
          fetch.data['data'].forEach((v) => dataTransaction?.add(TransactionHistoryModel.fromJSON(v)));
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

  Future initTransactionHistoryInProgress(BuildContext context) async {
    if (dataTransactionInProgress?.isEmpty ?? false) isLoadingInProgress = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, "status": "WAITING_PAYMENT", "boost": false, "skip": _skip, "limit": _limit};
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          if (_skip == 0) dataTransactionInProgress = [];
          fetch.data['data'].forEach((v) => dataTransactionInProgress?.add(TransactionHistoryModel.fromJSON(v)));
        }
        if (fetch.postsState == TransactionState.getHistoryError) {
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          }
        }
      } catch (e) {
        print(e);
      }
      isLoadingInProgress = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initTransactionHistoryInProgress(context);
      });
    }
  }

  Future getAccountBalance(BuildContext context) async {
    isLoadingSaldo = true;

    bool connect = await System().checkConnections();
    if (connect) {
      String email = SharedPreference().readStorage(SpKeys.email);
      final param = {"email": email};
      final notifier = TransactionBloc();
      await notifier.getAccountBalance(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getAccountBalanceSuccess) {
        if (fetch.data.length > 0) {
          fetch.data.forEach((v) => accountBalance = AccountBalanceModel.fromJSON(v));
        } else {
          _accountBalance = AccountBalanceModel.fromJSON({"totalpenarikan": 0});
        }
        isLoadingSaldo = false;
      }

      if (fetch.postsState == TransactionState.getAccountBalanceError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getAccountBalance(context);
      });
    }
  }

  Future initBankAccount(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      if (dataAcccount?.isEmpty ?? false) isLoading = true;
      dataAcccount = [];
      final notifier = TransactionBloc();
      await notifier.getMyBankAccount(context);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getBankAccontSuccess) {
        fetch.data.forEach((v) => dataAcccount?.add(BankAccount.fromJSON(v)));
      }

      if (fetch.postsState == TransactionState.getBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      isLoading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initBankAccount(context);
      });
    }
  }

  Future getDetailTransactionHistory(BuildContext context, {required String id, type, jenis, bool isReward = false}) async {
    bool connect = await System().checkConnections();
    isDetailLoading = true;
    String email = SharedPreference().readStorage(SpKeys.email);
    if (connect) {
      final param = {
        "id": id,
        "type": type,
        "jenis": jenis,
        "email": email,
      };
      final notifier = TransactionBloc();
      await notifier.getDetailHistoryTransaction(context, params: param, isReward: isReward);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getDetailHistorySuccess) {
        _timeVA = DateTime.now();
        print(fetch.data[0]);
        dataTransactionDetail = isReward ? TransactionHistoryModel.fromJSON(fetch.data[0]) : TransactionHistoryModel.fromJSON(fetch.data);
        print("ini detail ${dataTransactionDetail?.time}");
        if (!isReward) {
          var _hourVa = _timeVA.hour - DateTime.parse(dataTransactionDetail!.time!).hour;
          _minuteVa = _timeVA.minute - DateTime.parse(dataTransactionDetail!.time!).minute;
          _secondVa = _timeVA.second - DateTime.parse(dataTransactionDetail!.time!).second;
          print(_minuteVa);
          if (_hourVa > 0) {
            _minuteVa = 14 - _minuteVa - 60;
          } else {
            _minuteVa = 14 - _minuteVa;
          }
          _secondVa = 60 - _secondVa;
        } else {
          dataTransactionDetail?.type = TransactionType.reward;
        }
      }

      if (fetch.postsState == TransactionState.getDetailHistoryError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initBankAccount(context);
      });
    }
    isDetailLoading = false;
    notifyListeners();
  }

  bool checkSave() => noBank.isNotEmpty && accountOwner.isNotEmpty ? true : false;

  Future createBankAccount(BuildContext context) async {
    final language = context.read<TranslateNotifierV2>().translate;
    final langIso = SharedPreference().readStorage(SpKeys.isoCode);
    bool connect = await System().checkConnections();
    if (connect) {
      final email = SharedPreference().readStorage(SpKeys.email);
      final Map params = {"email": email, "noRek": noBankAccount.text, "bankcode": bankcode, "nama": accountOwnerName.text, "language": langIso};

      final notifier = TransactionBloc();
      if (context.mounted) await notifier.createBankAccount(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.addBankAccontSuccess) {
        if (fetch.data == null) {
          messageAddBankError = fetch.message;
          Routing().moveBack();
          if (context.mounted) {
            ShowGeneralDialog.generalDialog(
              context,
              functionPrimary: () {
                Routing().moveAndPop(Routes.cameraAppealBank);
              },
              functionSecondary: () {
                Routing().moveBack();
              },
              titleText: language.failedToAddBankAccount,
              barrierDismissible: true,
              bodyText: '',
              titleButtonPrimary: language.uploadSupportDoc,
              titleButtonSecondary: language.cancel,
              isHorizontal: false,
              bodyWidget: Container(
                margin: EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                      text: language.desc1FailedToAddBankAccount,
                      children: [
                        TextSpan(
                            text: language.desc2FailedToAddBankAccount,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                      style: TextStyle(color: kHyppeTextLightPrimary)),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Routing().moveBack();
        } else {
          dataAcccount?.add(BankAccount.fromJSON(fetch.data));
          dataAcccount?.last.bankName = _nameAccount.text;
          Routing().moveBack();
          Routing().moveBack();
          ShowBottomSheet().onShowColouredSheet(context, language.successfullyAdded ?? '', color: kHyppeLightSuccess);
          _nameAccount.clear();
          noBankAccount.clear();
          accountOwnerName.clear();
          bankcode = '';
          messageAddBankError = '';
        }
      }

      if (fetch.postsState == TransactionState.addBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  Future deleteBankAccount(BuildContext context, String id, index) async {
    bool connect = await System().checkConnections();
    if (connect) {
      // final email = SharedPreference().readStorage(SpKeys.email);
      final Map params = {
        "id": id,
      };
      final notifier = TransactionBloc();
      await notifier.deleteBankAccount(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.deleteBankAccontSuccess) {
        dataAcccount?.removeAt(index);
        print('delete berhasil');
        Routing().moveBack();
      }
      if (fetch.postsState == TransactionState.deleteBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  void confirmAddBankAccount(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    ShowGeneralDialog.generalDialog(
      context,
      titleText: language.keepThisAccount,
      // bodyText: "${language.youWillAdd} ${nameAccount.text} ${language.accountWithAccountNumber} ${noBankAccount.text} ${language.ownedBy} ${accountOwnerName.text}",
      bodyText: "${language.addingtoYourAccount} ${nameAccount.text} ${noBankAccount.text} ${language.atasNama} ${accountOwnerName.text}",
      maxLineTitle: 1,
      maxLineBody: 10,
      functionPrimary: () async {
        await createBankAccount(context);
      },
      functionSecondary: () {
        Routing().moveBack();
      },
      titleButtonPrimary: "${language.yes}, ${language.save}",
      titleButtonSecondary: "${language.cancel}",
      barrierDismissible: false,
    );
  }

  void confirmDeleteBankAccount(BuildContext context, bankName, accountNumber, ownerName, id, index) {
    final language = context.read<TranslateNotifierV2>().translate;
    ShowGeneralDialog.generalDialog(
      context,
      titleText: language.deletedBankAccount,
      bodyText: "${language.youWillDelete} $bankName ${language.accountWithAccountNumber} $accountNumber ${language.an} ${ownerName.toUpperCase()}",
      maxLineTitle: 1,
      maxLineBody: 10,
      functionPrimary: () async {
        await deleteBankAccount(context, id, index);
      },
      functionSecondary: () {
        Routing().moveBack();
      },
      titleButtonPrimary: "${language.delete}",
      titleButtonSecondary: "${language.cancel}",
      barrierDismissible: false,
    );
  }

  void scrollList(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += _limit;
      isScrollLoading = true;
      await initTransactionHistory(context);
      isScrollLoading = false;
    }
  }

  void scrollListInProgress(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += _limit;
      isScrollLoading = true;
      await initTransactionHistoryInProgress(context);
      isScrollLoading = false;
    }
  }

  Future bankChecked(int index) async {
    _isChecking = true;
    bankSelected = dataAcccount?[index].id ?? '';
    _accountNumber = dataAcccount?[index].noRek ?? '';
    _accountOwner = dataAcccount?[index].nama ?? '';
    bankcode = dataAcccount?[index].bankCode ?? '';
    notifyListeners();
    _checkingAccount();
  }

  Future _checkingAccount() async {
    // bool connect = await System().checkConnections();
    // if (connect) {
    //   final email = SharedPreference().readStorage(SpKeys.email);
    //   final Map params = {
    //     // "id": id,
    //   };
    //   final notifier = TransactionBloc();
    //   await notifier.deleteBankAccount(context, params: params);
    //   final fetch = notifier.transactionFetch;

    //   if (fetch.postsState == TransactionState.deleteBankAccontSuccess) {
    //     dataAcccount.removeAt(index);
    //     print('delete berhasil');
    //     Routing().moveBack();
    //   }
    //   if (fetch.postsState == TransactionState.deleteBankAccontError) {
    //     if (fetch.data != null) {
    //       ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
    //     }
    //   }
    //   notifyListeners();
    // } else {
    //   ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
    //     Routing().moveBack();
    //     createBankAccount(context);
    //   });
    // }
  }

  void showRemarkWithdraw(BuildContext context) {
    // ShowGeneralDialog.remarkWidthdrawal(context);
    ShowBottomSheet.onShowStatementPin(
      context,
      onCancel: () {},
      onSave: null,
      title: '',
      bodyText: context.read<TranslateNotifierV2>().translate.inTheWithdrawalProcessYouCannotTakeAllTheBalanceYouHave ?? '',
    );
  }

  Future summaryWithdrawal(BuildContext context) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final language = context.read<TranslateNotifierV2>().translate;
    if ((accountBalance?.totalsaldo ?? 0) < int.parse(amountWithDrawal ?? '0')) {
      _errorNoBalance = "Insufficient balance";
      notifyListeners();
      return false;
    }
    final Map params = {
      "email": email,
      "bankcode": bankcode,
      "norek": _accountNumber,
      "amount": int.parse(amountWithDrawal ?? '0'),
    };

    if ((accountBalance?.totalsaldo ?? 0) < 50000 || int.parse(amountWithDrawal ?? '0') < 50000) {
      return ShowBottomSheet().onShowColouredSheet(
        context,
        'Minimum Withdrawal Rp. 50.000',
        maxLines: 2,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );
    }
    for (var e in dataAcccount ?? []) {
      if (e.noRek == params['norek']) {
        if (e.statusInquiry != null && !e.statusInquiry) {
          return ShowBottomSheet().onShowColouredSheet(
            context,
            language.messageBankNotMatched ?? 'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 4,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              Routing().move(Routes.help);
            },
          );
        }
      }
    }
    _summaryWithdrawal(context, params);
  }

  Future _summaryWithdrawal(BuildContext context, params) async {
    bool connect = await System().checkConnections();
    final language = context.read<TranslateNotifierV2>().translate;
    if (connect) {
      isLoadingSummaryWithdraw = true;
      _errorNoBalance = '';
      final notifier = TransactionBloc();
      await notifier.summaryWithdrawal(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.summaryWithdrawalSuccess) {
        withdarawalSummarymodel = WithdrawalSummaryModel.fromJson(fetch.data);
        for (var e in dataAcccount ?? []) {
          if (e.noRek == params['norek']) {
            e.statusInquiry = withdarawalSummarymodel?.statusInquiry;
          }
        }
        if (withdarawalSummarymodel?.statusInquiry ?? false) {
          Routing().move(Routes.withdrawalSummary);
        } else {
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.messageBankNotMatched ?? 'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 2,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              Routing().move(Routes.help);
            },
          );
        }
        isLoadingSummaryWithdraw = false;
        notifyListeners();
      }
      if (fetch.postsState == TransactionState.summaryWithdrawalError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
        isLoadingSummaryWithdraw = false;
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  bool withdrawalButton() => amountWithDrawal != '' && bankSelected != '' ? true : false;

  void navigateToPin() => Routing().move(Routes.pinWithdrawal);

  Future createWithdraw(BuildContext context, String pin) async {
    _createWithdraw(context);
  }

  Future _createWithdraw(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      ShowGeneralDialog.loadingDialog(context);
      final email = SharedPreference().readStorage(SpKeys.email);
      Map params = {
        "recipient_bank": bankcode,
        "recipient_account": withdarawalSummarymodel?.bankAccount,
        "amount": withdarawalSummarymodel?.amount,
        "note": "Withdraw",
        "email": email,
        "pin": pinController.text,
      };

      final notifier = TransactionBloc();
      await notifier.createWithdraw(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.createWithdrawalSuccess) {
        Routing().moveBack();
        withdarawalmodel = WithdrawalModel.fromJson(fetch.data);
        Routing().moveReplacement(Routes.successWithdrawal);
        pinController.clear();
        _errorPinWithdrawMsg = '';
      }
      if (fetch.postsState == TransactionState.createWithdrawalError) {
        Routing().moveBack();
        notifyListeners();
        if (fetch.data != null) {
          if (fetch.message != null && fetch.message['messages'] != null && fetch.message['messages']['info'] != null && fetch.message['messages']['info'][0] != null) {
            _errorPinWithdrawMsg = fetch.message['messages']['info'][0];
          }
          if (_errorPinWithdrawMsg == 'Unabled to proceed, Pin not Match') {
            _errorPinWithdrawMsg = context.read<TranslateNotifierV2>().translate.incorrectPINPleasetryAgain ?? '';
            ShowBottomSheet().onShowColouredSheet(context, _errorPinWithdrawMsg, color: Theme.of(context).colorScheme.error);
          } else {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          }
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createWithdraw(context, pinController.text);
      });
    }
  }

  void backtransaction() {
    Routing().moveBack();
    Routing().moveBack();
    exitPageWithdrawal();
  }

  void exitPageWithdrawal() {
    _errorNoBalance = '';
    bankcode = '';
    bankSelected = '';
    amountWithdrawalController.clear();
    amountWithDrawal = '';
    Routing().moveBack();
  }

  Future<bool> checkTransPanding(BuildContext context) async {
    bool connect = await System().checkConnections();
    bool pandingTransaction = false;
    if (connect) {
      final notifier = TransactionBloc();
      await notifier.transPanding(context);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.checkPandingSuccess) {
        if (fetch.data['waitingCount'] == 0) {
          pandingTransaction = false;
        } else {
          pandingTransaction = true;
        }
      }
      if (fetch.postsState == TransactionState.checkPandingError) {
        pandingTransaction = false;
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createWithdraw(context, pinController.text);
      });
    }
    return pandingTransaction;
  }

  List<File>? _pickedSupportingDocs = [];
  List<File>? get pickedSupportingDocs => _pickedSupportingDocs;
  set pickedSupportingDocs(List<File>? val) {
    _pickedSupportingDocs = val;
    notifyListeners();
  }

  void takePictSupport(BuildContext context) {
    CameraDevicesNotifier cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    final language = context.read<TranslateNotifierV2>().translate;
    cameraNotifier.takePicture(context).then((value) async {
      print("hasil $value");
      if (value != null) {
        if (pickedSupportingDocs != null) {
          if (pickedSupportingDocs!.length < 3) {
            pickedSupportingDocs!.add(File(value.path));
            // Routing().moveAndPop(Routes.verificationIDStepSupportingDocsPreview);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PreviewDocAppeal()));
          } else {
            ShowGeneralDialog.pickFileErrorAlert(context, language.max3Images ?? 'Max 3 images');
            isLoading = false;
          }
        }
      }

      ///////
    });
  }

  void onPickSupportedDocument(BuildContext context, mounted) async {
    isLoading = true;
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    final language = context.read<TranslateNotifierV2>().translate;
    try {
      await System().getLocalMedia(featureType: FeatureType.other, context: context).then((value) async {
        debugPrint('Pick => ' + value.toString());
        debugPrint('Pick =>  ${value.values.length}');
        if (pickedSupportingDocs != null) {
          if (pickedSupportingDocs!.length < 3) {
            if (value.values.single != null) {
              // pickedSupportingDocs = value.values.single;
              for (var element in value.values.single!) {
                if (pickedSupportingDocs!.length < 3) {
                  pickedSupportingDocs!.add(element);
                } else {
                  ShowGeneralDialog.pickFileErrorAlert(context, language.max3Images ?? 'Max 3 images');
                }
              }
              // fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));

              isLoading = false;
              if (pickedSupportingDocs?.length == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PreviewDocAppeal()));
              } else {
                // Routing().moveBack();
              }
            } else {
              isLoading = false;
              if (value.keys.single.isNotEmpty) {
                ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
              }
            }
          } else {
            ShowGeneralDialog.pickFileErrorAlert(context, language.max3Images ?? 'Max 3 images');
            isLoading = false;
          }
        }
      });
    } catch (e) {
      isLoading = false;
      ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred ?? '');
    }
  }

  Future submitAppealBank(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (context.mounted) ShowGeneralDialog.loadingKycDialog(context);
    if (connect) {
      final notifier = TransactionBloc();
      final language = context.read<TranslateNotifierV2>().translate;
      final langIso = SharedPreference().readStorage(SpKeys.isoCode);
      final email = SharedPreference().readStorage(SpKeys.email);

      if (context.mounted) {
        await notifier.postAppealBloc(context, docFiles: pickedSupportingDocs, bankcode: bankcode, email: email, language: langIso, nama: accountOwnerName.text, noRek: noBankAccount.text);
      }
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.checkPandingSuccess) {
        Routing().moveAndPop(Routes.successAppealBank);
      }
      if (fetch.postsState == TransactionState.checkPandingError) {
        Routing().moveBack();
      }
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          createWithdraw(context, pinController.text);
        });
      }
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