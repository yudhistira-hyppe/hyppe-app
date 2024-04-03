import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';

class PaymentCoinNotifier with ChangeNotifier {

  //Selected VA
  int selectedva = 0;

  //Modal List Virtual Account
  List<GroupVAModel> groupsVA = [
    GroupVAModel(index: 1, text: 'BCA Virtual Account', icon: '${AssetPath.pngPath}ic-bca.png', selected: false),
    GroupVAModel(index: 2, text: 'BRI Virtual Account', icon: '${AssetPath.pngPath}ic-bri.png', selected: false),
    GroupVAModel(index: 3, text: 'Mandiri Virtual Account', icon: '${AssetPath.pngPath}ic-mandiri.png', selected: false),
    GroupVAModel(index: 4, text: 'BNI Virtual Account', icon: '${AssetPath.pngPath}ic-bni.png', selected: false),
  ];

  Future<void> initialPayment() async {
    for (int i = 0; i < groupsVA.length; i++) {
      groupsVA[i].selected = false;
    }
    selectedva = 0;
    notifyListeners();
  }

  void changeSelectedva(int? selected) {
    for (int i = 0; i < groupsVA.length; i++) {
      groupsVA[i].selected = false;
    }
    groupsVA[groupsVA.indexWhere((element) => element.index==selected)].selected = true;
    notifyListeners();
  }
}

class GroupVAModel {
  int index;
  String text;
  String icon;
  bool selected;
  GroupVAModel({required this.text, required this.index, required this.selected, required this.icon});
}
