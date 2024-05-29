
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'widgets/dialog_date.dart';
import 'widgets/dialog_datepicker.dart';
import 'widgets/dialog_trans.dart';

class CoinNotifier with ChangeNotifier {

  //Selected Value Transaction
  int selectedTransValue = 1;
  String selectedTransLabel = 'Semua Transaksi';

  //Selected Value Date
  int selectedDateValue = 1;
  String selectedDateLabel = 'Semua Tanggal';
  String tempSelectedDate = DateTime.now().toString();

  //TextEdit Date 
  final TextEditingController textStartDateController = TextEditingController();
  final TextEditingController textEndDateController = TextEditingController();

  //Modal List Transaction
  List<GroupModel> groupsTrans = [
    GroupModel(text: "Semua Aktifitas", index: 1, selected: true),
    GroupModel(text: "Coins Ditambahkan", index: 2, selected: false),
    GroupModel(text: "Coin Digunakan", index: 3, selected: false),
    GroupModel(text: "Coins Ditukar", index: 4, selected: false),
    GroupModel(text: "Coins Dikembalikan", index: 5, selected: false),
  ];

  //Modal List Date
  List<GroupModel> groupsDate = [
    GroupModel(text: "Semua", index: 1, selected: true),
    GroupModel(text: "30 Hari Terakhir", index: 2, selected: false),
    GroupModel(text: "90 Hari Terakhir", index: 3, selected: false),
    GroupModel(text: "Pilih Rentang Tanggal", index: 4, selected: false, 
      startDate: DateTime.now().toString(),
      endDate: DateTime.now().toString(),
      ),
  ];

  Future<void> initialCoin() async {
    selectedDateValue = 1;
    selectedTransValue = 1;
    selectedTransLabel = 'Semua Transaksi';
    selectedDateLabel = 'Semua Tanggal';
    for (int i = 0; i < groupsTrans.length; i++) {
      groupsTrans[i].selected = false;
    }
    for (int i = 0; i < groupsDate.length; i++) {
      groupsDate[i].selected = false;
    }
    groupsTrans[0].selected = true;
    groupsDate[0].selected = true;
    notifyListeners();
  }

  void changeSelectedTransaction() {
    for (int i = 0; i < groupsTrans.length; i++) {
      groupsTrans[i].selected = false;
    }
    groupsTrans[groupsTrans.indexWhere((element) => element.index == selectedTransValue)].selected = true;
    if (selectedTransValue == 1){
      selectedTransLabel = 'Semua Transaksi';
    }else{
      selectedTransLabel = groupsTrans.firstWhere((element) => element.selected == true).text;
    }
    notifyListeners();
  }

  void changeSelectedDate() {
    for (int i = 0; i < groupsDate.length; i++) {
      groupsDate[i].selected = false;
    }
    groupsDate[groupsDate.indexWhere((element) => element.index == selectedDateValue)].selected = true;
    if (selectedDateValue == 1){
      selectedDateLabel = 'Semua Tanggal';
    }else{
      if (groupsDate.firstWhere((element) => element.selected == true).index == 4){
        var res = groupsDate.firstWhere((element) => element.selected == true);
        selectedDateLabel = '${DateFormat('dd/MM/yyy').format(DateTime.parse(res.startDate??''))} - ${DateFormat('dd/MM/yyy').format(DateTime.parse(res.endDate??''))}';
      }else{
        selectedDateLabel = groupsDate.firstWhere((element) => element.selected == true).text;
      }
    }
    notifyListeners();
  }

  void selectedDatePicker({bool isStartDate = false}) {
    int idx = groupsDate.indexWhere((element) => element.selected == true);
    if (isStartDate){
      if (idx != -1){
        groupsDate[idx].startDate = tempSelectedDate;
        textStartDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(groupsDate[idx].startDate!));
        notifyListeners();
      }
    }else{
      if (idx != -1){
        groupsDate[idx].endDate = tempSelectedDate;
        textEndDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(tempSelectedDate));
        notifyListeners();
      }
    }
  }

  void resetSelected(){
    for (int i = 0; i < groupsTrans.length; i++) {
      groupsTrans[i].selected = false;
    }
    for (int i = 0; i < groupsDate.length; i++) {
      groupsDate[i].selected = false;
    }
    groupsTrans[0].selected = true;
    groupsDate[0].selected = true;
    selectedDateValue = 1;
    selectedTransValue = 1;
    selectedTransLabel = 'Semua Transaksi';
    selectedDateLabel = 'Semua Tanggal';
    notifyListeners();
  }

  void showButtomSheetTransaction(BuildContext context) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const DialogTrans();
        }
    ).whenComplete(() {
      if (!groupsTrans.firstWhere((e) => e.index == selectedTransValue).selected){
        selectedTransValue = groupsTrans.firstWhere((element) => element.selected==true).index;
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
        }
    ).whenComplete(() {
      if (!groupsDate.firstWhere((e) => e.index == selectedDateValue).selected){
        selectedDateValue = groupsDate.firstWhere((element) => element.selected==true).index;
      }
    });
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
}

class GroupModel {
  String text;
  int index;
  bool selected;
  String? startDate;
  String? endDate;
  GroupModel({required this.text, required this.index, required this.selected, this.startDate, this.endDate});
}
