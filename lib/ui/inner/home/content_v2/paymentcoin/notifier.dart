import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/bloc/monetization/transaction/bloc.dart';
import 'package:hyppe/core/bloc/monetization/transaction/state.dart';
import 'package:hyppe/core/bloc/transaction/coinpurcasedetail/bloc.dart';
import 'package:hyppe/core/bloc/transaction/coinpurcasedetail/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/coins/coinmodel.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/coinpurchasedetail.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class PaymentCoinNotifier with ChangeNotifier {
  Map _param = {};
  Map _paramTransaction={};
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }
  
  CointModel selectedCoin = CointModel();
  
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

  final bloc = CoinPurchaseDetailDataBloc();
  bool _isLoadingDetail = true;
  bool get isLoadingDetail => _isLoadingDetail;
  set isLoadingDetail(bool val) {
    _isLoadingDetail = val;
    notifyListeners();
  }
  CointPurchaseDetailModel _cointPurchaseDetail = CointPurchaseDetailModel();
  CointPurchaseDetailModel get cointPurchaseDetail => _cointPurchaseDetail;
  set cointPurchaseDetail(CointPurchaseDetailModel value) {
    _cointPurchaseDetail = value;
    notifyListeners();
  }

  void initState(BuildContext context) {
    isLoading = true;
    _param = {};
    _paramTransaction = {};
    notifyListeners();
    _getAllBank(context);
  }

  Future<void> initCoinPurchaseDetail(BuildContext context) async {
    try{
      _isLoadingDetail = true;
      if (discount.id != null){
        _param.addAll({
          'price': selectedCoin.price ?? 0,
          "typeTransaction":'TOPUP',
          'discount_id': discount.id,
        });
      }else{
        _param.addAll({
          'price': selectedCoin.price ?? 0,
          "typeTransaction":'TOPUP',
        });
      }
      
      
      await bloc.getCoinPurchaseDetail(context, data: _param);
      if (bloc.dataFetch.dataState == CoinPurchaseDetailState.getCoinPurchaseDetailBlocSuccess) {
        cointPurchaseDetail = bloc.dataFetch.data;
      }
      _isLoadingDetail = false;
    }catch(_){
      _isLoadingDetail = false;
      debugPrint(_.toString());
    }
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
  

  DiscountModel _discount = DiscountModel();
  DiscountModel get discount => _discount;
  set discount(DiscountModel val){
    _discount = val;
    notifyListeners();
  }


  final blocPayNow = TransactionCoinBloc();
  bool _isLoadingPayNow = false;
  bool get isLoadingPayNow => _isLoadingPayNow;
  set isLoadingPayNow(bool val) {
    _isLoadingPayNow = val;
    notifyListeners();
  }


  
  TransactionCoinModel _transactionCoinDetail = TransactionCoinModel();
  TransactionCoinModel get transactionCoinDetail => _transactionCoinDetail;
  set transactionCoinDetail(TransactionCoinModel value) {
    _transactionCoinDetail = value;
    notifyListeners();
  }


  Future<void> payNow(BuildContext context) async {
    try{
      isLoadingPayNow = true;
      CoinTransModel coin = CoinTransModel(id: selectedCoin.id, price: selectedCoin.price, jmlcoin: selectedCoin.amount, qty: 1, totalAmount: 1 * (selectedCoin.price??0));
      if (discount.checked??false){
        _paramTransaction.addAll({
          "postid": [coin.toJson()],
          "idDiscount":discount.id,
          "bankcode": bankSelected,
          "product_id": selectedCoin.package_id,
          "type": 'COIN',
          "paymentmethod": 'Virtual Account',
          "productCode": 'CN',
          "platform":"APP"
        });
      }else{
        _paramTransaction.addAll({
          "postid": [coin.toJson()],
          "bankcode": bankSelected,
          "product_id": selectedCoin.package_id,
          "type": 'COIN',
          "paymentmethod": 'Virtual Account',
          "productCode": 'CN',
          "platform":"APP"
        });
      }
      await blocPayNow.postPayNow(context, data: _paramTransaction);
      if (blocPayNow.dataFetch.dataState == TransactionCoinState.getcBlocSuccess) {
        transactionCoinDetail = TransactionCoinModel.fromJson(blocPayNow.dataFetch.data);
        isLoadingPayNow = false;
      }else if (blocPayNow.dataFetch.dataState == TransactionCoinState.getNotInternet){
        Fluttertoast.showToast(msg: language.noInternetConnection??'');
        isLoadingPayNow = false;
      }
      isLoadingPayNow = false;
    }catch(_){
      isLoadingPayNow = false;
      debugPrint(_.toString());
    }
  }
}
