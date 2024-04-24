
import 'package:flutter/material.dart';

class TopUpCoinNotifier with ChangeNotifier {

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

  Future<void> initialCoin() async {
    for (int i = 0; i < groupsCoins.length; i++) {
      groupsCoins[i].selected = false;
    }
    notifyListeners();
  }

  void changeSelectedCoin(int? selected) {
    for (int i = 0; i < groupsCoins.length; i++) {
      groupsCoins[i].selected = false;
    }
    groupsCoins[groupsCoins.indexWhere((element) => element.index==selected)].selected = true;
    notifyListeners();
  }
}

class GroupCoinModel {
  int index;
  int value;
  int valueLabel;
  bool selected;
  GroupCoinModel({required this.value, required this.index, required this.selected, required this.valueLabel});
}
