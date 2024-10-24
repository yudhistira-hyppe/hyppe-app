
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/monetization/disc/bloc.dart';
import 'package:hyppe/core/bloc/monetization/disc/state.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

import 'widgets/dialog_info.dart';

class DiscNotifier extends ChangeNotifier {
  
  List<DiscountModel> _result = [];
  List<DiscountModel> get result => _result;
  set result(List<DiscountModel> val) {
    _result = val;
    notifyListeners();
  }

  final bloc = DiscDataBloc();

  int _totalPayment=0;
  int get totalPayment => _totalPayment;
  set totalPayment(int val){
    _totalPayment = val;
    notifyListeners();
  }

  String _productType = '';
  String get productType => _productType;
  set productType(String val){
    _productType = val;
    notifyListeners();
  }

  bool _isView = false;
  bool get isView => _isView;
  set isView(bool val){
    _isView = val;
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

  Future<void> initDisc(BuildContext context) async {
    try{
      page = 0;

      await bloc.getDisc(context, page: page, productType: productType);
      if (bloc.dataFetch.dataState == DiscState.getDiscBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result = bloc.dataFetch.data;
        // ignore: use_build_context_synchronously
        Map res = ModalRoute.of(context)!.settings.arguments as Map;
        if (res['discount'] != null){
          DiscountModel disc = res['discount'] as DiscountModel;
          result[result.indexWhere((e) => e.id == disc.id)].checked = true;
        }
      } else {
        isLastPage = true;
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future<void> loadMore(BuildContext context) async {
    try{
      await bloc.getDisc(context, page: page, productType: productType);
      if (bloc.dataFetch.dataState == DiscState.getDiscBlocSuccess && bloc.dataFetch.data.isNotEmpty) {
        result.addAll(bloc.dataFetch.data);
      } else {
        isLastPage = true;
        Fluttertoast.showToast(msg: 'Already on the last ');
      }
      
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future<void> selectedDisc(DiscountModel? data) async {
    if (data?.checked==false){
      for (var i = 0; i < result.length; i++) {
        result[i].checked = false;
      }
      data?.checked = true;
      notifyListeners();
    }
  }

  void showButtomSheetInfo(BuildContext context, LocalizationModelV2 lang, DiscountModel? data) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DialogInfoWidget(lang: lang, data: data,);
        }
    );
  }

}