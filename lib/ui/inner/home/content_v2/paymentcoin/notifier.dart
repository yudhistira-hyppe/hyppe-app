import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class PaymentCoinNotifier with ChangeNotifier {

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _bankSelected = '0';
  String get bankSelected => _bankSelected;
  set bankSelected(String val) {
    _bankSelected = val;
    notifyListeners();
  }

  List<BankData>? _data;
  List<BankData>? get data => _data;
  set data(List<BankData>? value) {
    _data = value;
    notifyListeners();
  }

  //Selected VA
  String selectedbankdata = '';
  List<GroupBankData>? _groupdata;
  List<GroupBankData>? get groupdata => _groupdata;
  set groupdata(List<GroupBankData>? value) {
    _groupdata = value;
    notifyListeners();
  }

  void initState(BuildContext context) {
    isLoading = true;
    notifyListeners();
    // reviewBuyNotifier = Provider.of<ReviewBuyNotifier>(context, listen: false);
    _getAllBank(context);
  }

  void changeSelectedBank(String? selected) {
    for (int i = 0; i < groupdata!.length; i++) {
      groupdata![i].selected = false;
    }
    groupdata![groupdata!.indexWhere((element) => element.id == selected)].selected = true;
    notifyListeners();
  }
  
  Future<void> _getAllBank(BuildContext context) async {
    final notifier = BuyBloc();
    await notifier.getBank(context);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.getContentsSuccess) {
      List<BankData>? res = (fetch.data as List<dynamic>?)?.map((e) => BankData.fromJson(e as Map<String, dynamic>)).toList();
      data = res;

      List<GroupBankData>? resGroup = (fetch.data as List<dynamic>?)?.map((e) => GroupBankData.fromJSON(e as Map<String, dynamic>)).toList();
      groupdata = resGroup;
      isLoading = false;
      notifyListeners();
    }else if (fetch.postsState == BuyState.getContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data??'');
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');
      isLoading = false;
      Future.delayed(const Duration(seconds: 3), () {
        Routing().moveBack();
      });
    }
  }

  void _showSnackBar(Color color, String message, String desc, {Function? function}) {
    Routing().showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              subCaption: desc,
              fromSnackBar: true,
              iconSvg: "${AssetPath.vectorPath}remove.svg",
              function: function,
            ),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
  

  DiscountModel? _discount;
  DiscountModel get discount => _discount!;
  set discount(DiscountModel val){
    _discount = val;
    notifyListeners();
  }
}
