import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PaymentBoostSummaryNotifier extends ChangeNotifier {
  late PreUploadContentNotifier paymentMethodNotifier;

  Timer? _countdownTimer;
  Duration _payDuration = const Duration(hours: 1);
  String _durationString = "";

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  Timer? get countdownTimer => _countdownTimer;
  set countdownTimer(Timer? value) {
    _countdownTimer = value;
    notifyListeners();
  }

  Duration get payDuration => _payDuration;
  set payDuration(Duration value) {
    _payDuration = value;
    notifyListeners();
  }

  BankData? _bankData;
  BankData? get bankData => _bankData;
  set bankData(BankData? value) {
    _bankData = value;
    notifyListeners();
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');
  String get hours => strDigits(payDuration.inHours.remainder(24)).toString();
  String get minutes => strDigits(payDuration.inMinutes.remainder(60)).toString();
  String get seconds => strDigits(payDuration.inSeconds.remainder(60)).toString();

  //String get durationString => '($hours:$minutes:$seconds)';
  String get durationString {
    durationString = '($hours:$minutes:$seconds)';
    return _durationString;
  }

  set durationString(String val) {
    _durationString = val;
    notifyListeners();
  }

  void initState(BuildContext context) {
    paymentMethodNotifier = Provider.of<PreUploadContentNotifier>(context, listen: false);
    _getBankDetail(context);

    DateTime dt1 = DateTime.now();
    DateTime dt2 = DateTime.parse(paymentMethodNotifier.boostPaymentResponse?.postid?.expiredtimeva ?? '2022-11-16');
    DateTime dt3 = dt2.subtract(const Duration(hours: 7)); //convert to utc+7
    payDuration = dt3.difference(dt1);
    durationString = '($hours:$minutes:$seconds)';

    startTimer();
  }

  Future<void> _getBankDetail(BuildContext context) async {
    final notifier = BuyBloc();
    await notifier.getBankByCode(context, codeBank: paymentMethodNotifier.boostPaymentResponse?.postid?.response?.bankCode);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.getContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data);
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');

      Future.delayed(const Duration(seconds: 2), () {});
    } else if (fetch.postsState == BuyState.getContentsSuccess) {
      BankData? res = BankData.fromJson(fetch.data);
      print("Bank response ${res.bankname}");
      bankData = res;
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

  void endCountdownTimer() {
    print("timer countdown end");
    stopTimer();

    durationString = '($language.expired)';
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  // Step 4
  void stopTimer() {
    countdownTimer?.cancel();
  }

  // Step 5
  void resetTimer() {
    stopTimer();

    DateTime dt1 = DateTime.now();
    DateTime dt2 = DateTime.parse(paymentMethodNotifier.boostPaymentResponse?.postid?.expiredtimeva ?? '');
    DateTime dt3 = dt2.subtract(const Duration(hours: 7));
    payDuration = dt3.difference(dt1);
    durationString = '($hours:$minutes:$seconds)';

    startTimer();

    //payDuration = const Duration(hours: 1);
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = payDuration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      countdownTimer?.cancel();
    } else {
      payDuration = Duration(seconds: seconds);
    }
  }

  @override
  void dispose() {
    resetTimer();
    super.dispose();
  }
}
