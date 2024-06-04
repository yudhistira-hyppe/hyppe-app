
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/saldo_coin/bloc.dart';
import 'package:hyppe/core/bloc/saldo_coin/state.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/bloc/withdrawal/detail/bloc.dart';
import 'package:hyppe/core/bloc/withdrawal/detail/state.dart';
import 'package:hyppe/core/bloc/withdrawal/transaction/bloc.dart';
import 'package:hyppe/core/bloc/withdrawal/transaction/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawaltransaction.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawtransactiondetail.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/debouncer.dart';
import 'package:hyppe/ux/routing.dart';

import 'pages/finish_page.dart';
import 'widgets/info_dialog.dart';
import 'widgets/text_info.dart';

class WithdrawalCoinNotifier with ChangeNotifier {
  Map _param = {};
  Map _paramTransaction = {};
  final TextEditingController textController = TextEditingController();

  TextEditingController pinController = TextEditingController();
  String _errorPinWithdrawMsg = '';
  String get errorPinWithdrawMsg => _errorPinWithdrawMsg;
  set errorPinWithdrawMsg(String val) {
    _errorPinWithdrawMsg = val;
    notifyListeners();
  }

  List<GroupBankAccountModel> dataAcccount = [];
  int totalCoin = 0;
  // int typingValue = 0;
  // int resultValue = 0;

  // loading bank account
  bool isLoading = false;
  String selectedBankAccount = '';

  final debouncer = Debouncer(milliseconds: 1000);
  //Modal List Coins
  List<GroupCoinModel> groupsCoins = [
    GroupCoinModel(index: 1, value: 500, valueLabel: 50000, selected: false),
    GroupCoinModel(index: 2, value: 1000, valueLabel: 100000, selected: false),
    GroupCoinModel(index: 3, value: 1500, valueLabel: 150000, selected: false),
    GroupCoinModel(index: 4, value: 2000, valueLabel: 200000, selected: false),
    GroupCoinModel(index: 5, value: 2500, valueLabel: 250000, selected: false)
  ];

  Future<void> initialExchange() async {
    // typingValue = 0;
    // resultValue = 0;
    withdrawaltransactionDetail = WithdrawtransactiondetailModel();
    selectedBankAccount = '';
    notifyListeners();
  }

  WithdrawtransactiondetailModel _withdrawaltransactionDetail = WithdrawtransactiondetailModel();
  WithdrawtransactiondetailModel get withdrawaltransactionDetail => _withdrawaltransactionDetail;
  set withdrawaltransactionDetail(WithdrawtransactiondetailModel value) {
    _withdrawaltransactionDetail = value;
    notifyListeners();
  }

  void convertCoin(BuildContext context) async {
    if (textController.text.isEmpty){
      // typingValue = 0;
      // resultValue = 0;
    }else{
      final bloc = WithdrawalTransactionDetailBloc();
      _param = {};
      try{
        _param.addAll({
          'coinAmount':textController.text
        });
        await bloc.getWithdrawalTransactionDetail(context, data: _param);
        if (bloc.dataFetch.dataState == WithdrawalTransactionDetailState.getcBlocSuccess) {
          withdrawaltransactionDetail = bloc.dataFetch.data;
        }else{
          withdrawaltransactionDetail = WithdrawtransactiondetailModel();
        }
        notifyListeners();
      }catch(_){
        debugPrint(_.toString());
      }
    }
    notifyListeners();
  }

  Future initSaldo(BuildContext context) async {
    final bloc = SaldoCoinDataBloc();
    try{
      await bloc.getSaldoCoin(context);
      if (bloc.dataFetch.dataState == SaldoCoinState.getBlocSuccess) {
        totalCoin = bloc.dataFetch.data??0;
      }
      
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future<void> initBankAccount(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      if (dataAcccount.isEmpty) isLoading = true;
      dataAcccount = [];
      final notifier = TransactionBloc();
      // ignore: use_build_context_synchronously
      await notifier.getMyBankAccount(context);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getBankAccontSuccess) {
        
        fetch.data.forEach((v) => dataAcccount.add(GroupBankAccountModel.fromJSON(v)));
      }

      if (fetch.postsState == TransactionState.getBankAccontError) {
        if (fetch.data != null) {
          // ignore: use_build_context_synchronously
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      isLoading = false;
      notifyListeners();
    } else {
      // ignore: use_build_context_synchronously
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initBankAccount(context);
      });
    }
  }

  void changeSelectedbankaccount(val){
    for (int i = 0; i < dataAcccount.length; i++) {
      dataAcccount[i].selected = false;
    }
    dataAcccount[dataAcccount.indexWhere((element) => element.id==val)].selected = true;
    notifyListeners();
  }

  void showButtomSheetFilters(BuildContext context, lang, mounted) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return InfoDialog(lang: lang, mounted: mounted,);
        }
    );
  }

  void showButtomSheetInfo(BuildContext context,{LocalizationModelV2? lang}) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return TextInfo(lang: lang,);
        }
    );
  }

  WithdrawalTransactionModel _withdrawalTransaction = WithdrawalTransactionModel();
  WithdrawalTransactionModel get withdrawalTransaction => _withdrawalTransaction;
  set withdrawalTransaction(WithdrawalTransactionModel value) {
    _withdrawalTransaction = value;
    notifyListeners();
  }

  Future<void> createWithdrawal(BuildContext context, mounted, TranslateNotifierV2 lang)async {
    try{
      bool connect = await System().checkConnections();
      if (connect) {
        final bloc = WithdrawalTransactionBloc();
        _paramTransaction = {};
        if (!mounted) return;
        ShowGeneralDialog.loadingDialog(context);
        try{
          String email = SharedPreference().readStorage(SpKeys.email);
          _paramTransaction.addAll({
            "pin": pinController.text,
            "recipient_bank": dataAcccount.firstWhere((e) => e.selected==true).bankCode,
            "recipient_account": dataAcccount.firstWhere((e) => e.selected==true).noRek,
            "amount": withdrawaltransactionDetail.amount,
            "note": "",
            "email": email,
          });
          if (!mounted) return;
          await bloc.postWithdrawalTransaction(context, data: _paramTransaction);
          if (bloc.dataFetch.dataState == WithdrawalTransactionState.getcBlocSuccess) {
            Routing().moveBack();
            withdrawalTransaction = bloc.dataFetch.data;
            if (!mounted) return;
            Routing().moveBack();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FinishTrxPage()));
            pinController.clear();
            _errorPinWithdrawMsg = '';
          }

          if (bloc.dataFetch.dataState == WithdrawalTransactionState.getBlocError) {
            Routing().moveBack();
            // notifyListeners();
            if (bloc.dataFetch.data != null) {
                if (!mounted) return;
                pinController.clear();
                _errorPinWithdrawMsg = '';
                if (lang.translate.localeDatetime == 'id'){
                  ShowBottomSheet().onShowColouredSheet(context, bloc.dataFetch.data['message'][0]['info']['ID'], color: Theme.of(context).colorScheme.error);
                }else{
                  ShowBottomSheet().onShowColouredSheet(context, bloc.dataFetch.data['message'][0]['info']['EN'], color: Theme.of(context).colorScheme.error);
                }
            }
          }
          // notifyListeners();
        }catch(_){
          Routing().moveBack();
          debugPrint(_.toString());
        }
      }else{
        if (!mounted) return;
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
        });
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }
}

class GroupBankAccountModel {
  String? id;
  String? idBank;
  String? userId;
  String? noRek;
  String? nama;
  String? bankName;
  String? bankCode;
  bool? selected;
  GroupBankAccountModel({
    required this.id, 
    required this.idBank, 
    required this.selected, 
    required this.userId, 
    required this.noRek,
    required this.nama,
    required this.bankName,
    required this.bankCode});
  GroupBankAccountModel.fromJSON(dynamic json) {
    id = json['_id'];
    idBank = json['idBank'];
    userId = json['userId'];
    noRek = json['noRek'];
    nama = json['nama'];
    bankName = json['bankname'];
    bankCode = json['bankcode'];
    selected = false;
  }
}



class GroupCoinModel {
  int index;
  int value;
  int valueLabel;
  bool selected;
  GroupCoinModel({required this.value, required this.index, required this.selected, required this.valueLabel});
}
