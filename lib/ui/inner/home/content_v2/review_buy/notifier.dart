import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/new/bloc.dart';
import 'package:hyppe/core/bloc/buy/new/state.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/bloc/monetization/transaction/bloc.dart';
import 'package:hyppe/core/bloc/monetization/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy/buy_data_new.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/transaction/transaction_buy_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ux/routing.dart';

import 'screen_pay.dart';

enum IntialBankSelect { vaBca, hyppeWallet }

class ReviewBuyNotifier extends ChangeNotifier {
  ContentData? _routeArgument;
  Map _paramTransaction = {};

  BuyData? _data;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  BuyData? get data => _data;
  set data(BuyData? value) {
    _data = value;
    notifyListeners();
  }

  //Discount
  DiscountModel? _discount;
  DiscountModel? get discount => _discount;
  set discount(DiscountModel? val){
    _discount = val;
    notifyListeners();
  }

  void initState(BuildContext context, ContentData? routeArgument) async {
    _routeArgument = routeArgument;
    _paramTransaction = {};
    if (_routeArgument?.postID != null) {
      discount = null;
      await _initFetchBuyDetail(context);
      await detailBuyData(context);
    }
  }

  Future<void> _initFetchBuyDetail(BuildContext context) async {
    final notifier = BuyBloc();
    await notifier.getBuyContent(context, postId: _routeArgument?.postID);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.getContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data);
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');

      Future.delayed(const Duration(seconds: 3), () {
        Routing().moveBack();
      });
    } else if (fetch.postsState == BuyState.getContentsSuccess) {
      BuyData? res = BuyData.fromJson(fetch.data);
      data = res;
      notifyListeners();
    }
  }
  
  BuyDataNew _buyDataNew = BuyDataNew();
  BuyDataNew get buyDataNew => _buyDataNew;
  set buyDataNew(BuyDataNew value) {
    _buyDataNew = value;
    notifyListeners();
  }

  final Map _param = {};
  Future<void> detailBuyData(BuildContext context) async {
    final notifier = BuyDataNewBloc();
    if (discount != null){
        _param.addAll({
          'postID': _routeArgument?.postID,
          'price': (data!.price??0) / 1000,
          "typeTransaction":'CONTENT',
          'discount_id': discount?.id??'',
        });
      }else{
        _param.addAll({
          'postID': _routeArgument?.postID,
          'price': (data!.price??0) / 1000,
          "typeTransaction":'CONTENT',
        });
      }

    await notifier.getBuyDataNew(context, data: _param);
    final fetch = notifier.dataFetch;
    if (fetch.dataState == BuyDataNewState.getBlocError) {
      Future.delayed(const Duration(seconds: 3), () {
        Routing().moveBack();
      });
    } else if (fetch.dataState == BuyDataNewState.getBlocSuccess) {
      buyDataNew = fetch.data;
      // notifyListeners();
    }
  }

  TextEditingController pinController = TextEditingController();
  String _errorPinWithdrawMsg = '';
  String get errorPinWithdrawMsg => _errorPinWithdrawMsg;
  set errorPinWithdrawMsg(String val) {
    _errorPinWithdrawMsg = val;
    notifyListeners();
  }

  TransactionBuyContentModel _transactionDetail = TransactionBuyContentModel();
  TransactionBuyContentModel get transactionDetail => _transactionDetail;
  set transactionDetail(TransactionBuyContentModel value) {
    _transactionDetail = value;
    notifyListeners();
  }

  Future buyContent(BuildContext context, mounted) async {
    _buyContent(context, mounted);
  }

  Future<void> _buyContent(BuildContext context, mounted) async {
    try{
      bool connect = await System().checkConnections();
      if (!mounted) return;
      ShowGeneralDialog.loadingDialog(context);
      var postcontent = {
        'id': _routeArgument?.postID,
        "qty": 1,
        "price": buyDataNew.price,
        "totalAmount": buyDataNew.price
      };
      if (discount != null){
        _paramTransaction.addAll({
          "pin": pinController.text,
          "postid": [postcontent],
          "idDiscount":discount?.id??'',
          "salelike": buyDataNew.like??false,
          'saleview': buyDataNew.view??false,
          "type": 'CONTENT',
          "paymentmethod": 'COIN',
          "productCode": 'CM',
          "platform":"APP"
        });
      }else{
        _paramTransaction.addAll({
          "pin": pinController.text,
          "postid": [postcontent],
          "idDiscount":discount?.id??'',
          "salelike": buyDataNew.like??false,
          'saleview': buyDataNew.view??false,
          "type": 'CONTENT',
          "paymentmethod": 'COIN',
          "productCode": 'CM',
          "platform":"APP"
        });
      }
      if (connect){
        final blocPayNow = TransactionCoinBloc();
        await blocPayNow.postPayNow(context, data: _paramTransaction);
        if (blocPayNow.dataFetch.dataState == TransactionCoinState.getcBlocSuccess) {
          transactionDetail = TransactionBuyContentModel.fromJson(blocPayNow.dataFetch.data);
          if (!mounted) return;
          
          Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessBuyContentCcreen(data: transactionDetail, lang: language,)));
          pinController.clear();
          _errorPinWithdrawMsg = '';
        }
        if (blocPayNow.dataFetch.dataState == TransactionCoinState.getNotInternet){
          Fluttertoast.showToast(msg: language.noInternetConnection??'');
        }
        if (blocPayNow.dataFetch.dataState == TransactionCoinState.getBlocError){
          Routing().moveBack();
          // notifyListeners();
          if (blocPayNow.dataFetch.data != null) {
            if (!mounted) return;
            // print(blocPayNow.dataFetch.data);
            ShowBottomSheet().onShowColouredSheet(context, blocPayNow.dataFetch.data['message'], color: Theme.of(context).colorScheme.error);
          }
        }
      }else{
         ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          buyContent(context, mounted);
        });
      }
      
      print(pinController.text);
    }catch(_){
      debugPrint(_.toString());
    }
  }

  void _showSnackBar(Color color, String message, String desc,
      {Function? function}) {
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
}
