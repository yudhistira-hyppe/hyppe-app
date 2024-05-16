
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/debouncer.dart';
import 'package:hyppe/ux/routing.dart';

import 'widgets/info_dialog.dart';
import 'widgets/text_info.dart';

class ExchangeCoinNotifier with ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  List<GroupBankAccountModel> dataAcccount = [];
  int totalCoin = 0;
  int typingValue = 0;
  int resultValue = 0;

  // loading bank account
  bool isLoading = false;
  String selectedBankAccount = '';

  final debouncer = Debouncer(milliseconds: 50);
  //Modal List Coins
  List<GroupCoinModel> groupsCoins = [
    GroupCoinModel(index: 1, value: 500, valueLabel: 50000, selected: false),
    GroupCoinModel(index: 2, value: 800, valueLabel: 80000, selected: false),
    GroupCoinModel(index: 3, value: 1000, valueLabel: 100000, selected: false),
    GroupCoinModel(index: 4, value: 1300, valueLabel: 130000, selected: false),
    GroupCoinModel(index: 5, value: 1500, valueLabel: 150000, selected: false),
    GroupCoinModel(index: 6, value: 2000, valueLabel: 200000, selected: false),
    GroupCoinModel(index: 7, value: 3000, valueLabel: 300000, selected: false),
    GroupCoinModel(index: 8, value: 5000, valueLabel: 500000, selected: false),
    GroupCoinModel(index: 9, value: 8000, valueLabel: 800000, selected: false),
    GroupCoinModel(index: 10, value: 10000, valueLabel: 1000000, selected: false),
  ];

  Future<void> initialExchange() async {
    typingValue = 0;
    resultValue = 0;
    selectedBankAccount = '';
    notifyListeners();
  }

  void convertCoin() {
    if (textController.text.isEmpty){
      typingValue = 0;
      resultValue = 0;
    }else{
      typingValue = int.parse(textController.text) * 100;
      resultValue = int.parse((typingValue - withdrawalfree - (typingValue * withdrawalfeecoin)).toStringAsFixed(0));
    }
    notifyListeners();
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

  void showButtomSheetFilters(BuildContext context, lang) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return InfoDialog(lang: lang,);
        }
    );
  }

  void showButtomSheetInfo(BuildContext context) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const TextInfo();
        }
    );
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
