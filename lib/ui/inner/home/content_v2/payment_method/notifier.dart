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
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
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
  String _bankSelected = '0';

  String get bankSelected => _bankSelected;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

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

  BuyResponse? get postResponse => _postResponse;
  set postResponse(BuyResponse? value) {
    _postResponse = value;
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
      List<BankData>? res = (fetch.data as List<dynamic>?)?.map((e) => BankData.fromJson(e as Map<String, dynamic>)).toList();
      data = res;
      notifyListeners();
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

  void submitPay(BuildContext context, bool mounted, {num? price}) async {
    final cek = data?.where((element) => element.bankcode?.toLowerCase() == _bankSelected).isNotEmpty;
    if (price != null) {
      final notifier = context.read<PreUploadContentNotifier>();
      await notifier.uploadPanding(context, mounted);
    } else {
      if (cek ?? false) _postSubmitBuy(context);
    }
  }

  Color colorButton(context) {
    Color _color = Theme.of(context).colorScheme.primary;
    final cek = data?.where((element) => element.bankcode?.toLowerCase() == _bankSelected).isNotEmpty;
    if (cek ?? false) {
      _color = Theme.of(context).colorScheme.primary;
    } else {
      _color = Theme.of(context).colorScheme.surface;
    }
    return _color;
  }

  Future _postSubmitBuy(BuildContext context) async {
    isLoading = true;
    List<PostId> postId = [
      PostId(
        id: reviewBuyNotifier.data?.postId,
        qty: 1,
        totalAmount: reviewBuyNotifier.data?.price?.toInt(),
      ),
    ];
    var params = BuyRequest(
        postid: postId,
        amount: reviewBuyNotifier.data?.totalAmount?.toInt(),
        bankcode: _bankSelected,
        paymentmethod: 'VA', //TO DO : Other payment method
        type: 'CONTENT',
        salelike: reviewBuyNotifier.data?.saleLike,
        saleview: reviewBuyNotifier.data?.saleView);

    try {
      final notifier = BuyBloc();
      await notifier.postContentBuy(context, params: params);
      final fetch = notifier.buyFetch;
      if (fetch.postsState == BuyState.postContentsError) {
        isLoading = false;
        var errorData = ErrorModel.fromJson(fetch.data);

        ShowBottomSheet().onShowColouredSheet(
          context,
          errorData.message ?? '',
          maxLines: 2,
          iconSvg: "${AssetPath.vectorPath}remove.svg",
          color: kHyppeDanger,
          function: () {
            if (errorData.message == "Tidak dapat melanjutkan. Selesaikan pembayaran transaksi anda dahulu !") {
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
              return Routing().move(Routes.transaction);
            }
          },
        );
      } else if (fetch.postsState == BuyState.postContentsSuccess) {
        BuyResponse? res = BuyResponse.fromJson(fetch.data);
        postResponse = res;
        // _showSnackBar(kHyppeTextSuccess, 'Success', "Request buy conten success, please complete payment");
        Future.delayed(const Duration(seconds: 2), () {
          Routing().move(Routes.paymentSummaryScreen);
        });
        isLoading = false;
      }
    } catch (e) {
      print(e);
      _showSnackBar(kHyppeDanger, 'Error', 'Somethink Wrong');
    }
    notifyListeners();
  }
}
