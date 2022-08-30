import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class TransactionNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  TextEditingController noBankAccount = TextEditingController();

  BankData? _bankDataSelected;
  BankData? get bankDataSelected => _bankDataSelected;

  set bankDataSelected(BankData? val) {
    _bankDataSelected = val;
    notifyListeners();
  }

  navigateToBankAccount() => Routing().move(Routes.bankAccount);
  navigateToAddBankAccount() => Routing().move(Routes.addBankAccount);

  showDialogHelp(BuildContext context) {
    ShowBottomSheet().onShowHelpBankAccount(context);
  }

  showDialogAllBank(BuildContext context) {
    Provider.of<PaymentMethodNotifier>(context, listen: false).initState(context);

    ShowBottomSheet().onShowAllBank(context);
  }

  void bankInsert(BankData data) {
    bankDataSelected = data;
    navigateToAddBankAccount();
    print(bankDataSelected!.bankname);
  }
}
