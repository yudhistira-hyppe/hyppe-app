import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy_request.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy_response.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PaymentMethodNotifier extends ChangeNotifier {
  late ReviewBuyNotifier reviewBuyNotifier;
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  BuyResponse? _postResponse;
  String _bankSelected = '014';

  String get bankSelected => _bankSelected;

  set bankSelected(String val) {
    _bankSelected = val;

    notifyListeners();
  }

  List<BankData>? _data;
  List<BankData>? get data => _data;
  set data(List<BankData>? value) {
    _data = value;
    print(value);
    notifyListeners();
  }

  BuyResponse? get postResponse => _postResponse;
  set postResponse(BuyResponse? value) {
    _postResponse = value;
    print(value);
    notifyListeners();
  }

  void initState(BuildContext context) {
    reviewBuyNotifier = Provider.of<ReviewBuyNotifier>(context, listen: false);
    _getAllBank(context);
  }

  Future<void> _getAllBank(BuildContext context) async {
    final notifier = BuyBloc();
    await notifier.getBank(context);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.getContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data);
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');

      Future.delayed(const Duration(seconds: 3), () {
        Routing().moveBack();
      });
    } else if (fetch.postsState == BuyState.getContentsSuccess) {
      //List<BankData>? res = BankData.fromJson(fetch.data);
      List<BankData>? res = (fetch.data as List<dynamic>?)
          ?.map((e) => BankData.fromJson(e as Map<String, dynamic>))
          .toList();
      data = res;
      notifyListeners();
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

  void submitPay(BuildContext context) {
    _postSubmitBuy(context);
  }

  Future<void> _postSubmitBuy(BuildContext context) async {
    var params = BuyRequest(
        postid: reviewBuyNotifier.data!.postId,
        amount: reviewBuyNotifier.data!.totalAmount,
        bankcode: _bankSelected,
        paymentmethod: 'VA', //TO DO : Other payment method
        salelike: reviewBuyNotifier.data!.saleLike,
        saleview: reviewBuyNotifier.data!.saleView);

    final notifier = BuyBloc();
    await notifier.postContentBuy(context, params: params);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.postContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data);
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');
    } else if (fetch.postsState == BuyState.postContentsSuccess) {
      BuyResponse? res = BuyResponse.fromJson(fetch.data);
      postResponse = res;

      _showSnackBar(kHyppeTextSuccess, 'Success',
          "Request buy conten success, please complete payment");

      Future.delayed(const Duration(seconds: 2), () {
        Routing().move(Routes.paymentSummaryScreen);
      });
    }
  }
}
