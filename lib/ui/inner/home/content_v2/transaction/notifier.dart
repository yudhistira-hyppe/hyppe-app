import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/account_balance.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/bank_account_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/models/collection/transaction/withdrawal_summary_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class TransactionNotifier extends ChangeNotifier {
  int _skip = 0;
  int get skip => _skip;
  int _limit = 5;
  List<BankAccount>? dataAcccount = [];
  List<TransactionHistoryModel>? dataTransaction = [];
  List<TransactionHistoryModel>? dataAllTransaction = [];
  List<TransactionHistoryModel>? dataTransactionInProgress = [];
  TransactionHistoryModel? dataTransactionDetail;
  int? countTransactionProgress = 0;

  WithdrawalSummaryModel? withdarawalSummarymodel;

  AccountBalanceModel? _accountBalance;
  AccountBalanceModel? get accountBalance => _accountBalance;

  String? bankcode;
  TextEditingController pinController = TextEditingController();
  TextEditingController _nameAccount = TextEditingController();
  TextEditingController _noBankAccount = TextEditingController();
  TextEditingController _accountOwnerName = TextEditingController();
  TextEditingController _amountWithdrawalController = TextEditingController();

  TextEditingController get nameAccount => _nameAccount;
  TextEditingController get noBankAccount => _noBankAccount;
  TextEditingController get accountOwnerName => _accountOwnerName;
  TextEditingController get amountWithdrawalController => _amountWithdrawalController;

  String? _amountWithDrawal = '';
  String? get amountWithDrawal => _amountWithDrawal;

  String _amount = '';
  String get amount => _amount;

  bool _isChecking = false;
  bool get isCheking => _isChecking;

  String _bankSelected = '';
  String get bankSelected => _bankSelected;

  String _messageAddBankError = '';
  String get messageAddBankError => _messageAddBankError;
  String _noBank = "";
  String get noBank => _noBank;

  String _accountOwner = "";
  String get accountOwner => _accountOwner;

  BankData? _bankDataSelected;
  BankData? get bankDataSelected => _bankDataSelected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingInProgress = false;
  bool get isLoadingInProgress => _isLoadingInProgress;
  bool _isScrollLoading = false;
  bool get isScrollLoading => _isScrollLoading;
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  set amountWithDrawal(String? val) {
    _amountWithDrawal = val;
    notifyListeners();
  }

  set amount(String val) {
    _amount = val;
    notifyListeners();
  }

  set amountWithdrawalController(TextEditingController val) {
    _amountWithdrawalController = val;
    notifyListeners();
  }

  set bankSelected(String val) {
    _bankSelected = val;
    notifyListeners();
  }

  set accountBalance(AccountBalanceModel? val) {
    _accountBalance = val;
    notifyListeners();
  }

  set messageAddBankError(String val) {
    _messageAddBankError = val;
    notifyListeners();
  }

  set skip(int val) {
    _skip = val;
    notifyListeners();
  }

  set isDetailLoading(bool val) {
    _isDetailLoading = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set isLoadingInProgress(bool val) {
    _isLoadingInProgress = val;
    notifyListeners();
  }

  set isScrollLoading(bool val) {
    _isScrollLoading = val;
    notifyListeners();
  }

  set accountOwner(String val) {
    _accountOwner = val;
    notifyListeners();
  }

  set noBank(String val) {
    _noBank = val;
    notifyListeners();
  }

  set bankDataSelected(BankData? val) {
    _bankDataSelected = val;
    notifyListeners();
  }

  set nameAccount(TextEditingController val) {
    _nameAccount = val;
    notifyListeners();
  }

  set noBankAccount(TextEditingController val) {
    _noBankAccount = val;
    notifyListeners();
  }

  set accountOwnerName(TextEditingController val) {
    _accountOwnerName = val;
    notifyListeners();
  }

  navigateToBankAccount() => Routing().move(Routes.bankAccount);
  navigateToAddBankAccount() => Routing().move(Routes.addBankAccount);
  navigateToDetailTransaction() => Routing().move(Routes.detailTransaction);
  navigateToWithDrawal() => Routing().move(Routes.withdrawal);

  showDialogHelp(BuildContext context) {
    ShowBottomSheet().onShowHelpBankAccount(context);
  }

  showDialogAllBank(BuildContext context) {
    Provider.of<PaymentMethodNotifier>(context, listen: false).initState(context);
    ShowBottomSheet().onShowAllBank(context);
  }

  void bankInsert(BankData data) {
    bankDataSelected = data;
    nameAccount.text = data.bankname!;
    bankcode = data.bankcode;
    Routing().moveBack();
    navigateToAddBankAccount();
  }

  Future initTransactionHistory(BuildContext context) async {
    if (dataTransaction!.isEmpty) isLoading = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        getAccountBalance(context);
        DateTime dateToday = DateTime.now();
        String date = dateToday.toString().substring(0, 10);
        // String email = 'freeman27@getnada.com';
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, "skip": _skip, "limit": _limit};
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          // if (_skip == 0) dataTransaction = [];
          // if (dataAllTransaction!.isEmpty) {
          //   fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));
          //   context.read<FilterTransactionNotifier>().dataAllTransaction = dataAllTransaction;
          // }
          fetch.data['data'].forEach((v) => dataTransaction?.add(TransactionHistoryModel.fromJSON(v)));
          countTransactionProgress = fetch.data['datacount'];
        }
        if (fetch.postsState == TransactionState.getHistoryError) {
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          } else {
            // ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
          }
        }
      } catch (e) {
        print(e);
      }
      isLoading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        initBankAccount(context);
      });
    }
  }

  Future initTransactionHistoryInProgress(BuildContext context) async {
    if (dataTransactionInProgress!.isEmpty) isLoadingInProgress = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, "status": "WAITING_PAYMENT", "skip": _skip, "limit": _limit};
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          if (_skip == 0) dataTransactionInProgress = [];
          fetch.data['data'].forEach((v) => dataTransactionInProgress?.add(TransactionHistoryModel.fromJSON(v)));
        }
        if (fetch.postsState == TransactionState.getHistoryError) {
          if (fetch.data != null) {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          }
        }
      } catch (e) {
        print(e);
      }
      isLoadingInProgress = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initTransactionHistoryInProgress(context);
      });
    }
  }

  Future getAccountBalance(BuildContext context) async {
    if (dataTransaction!.isEmpty) isLoading = true;

    bool connect = await System().checkConnections();
    if (connect) {
      String email = SharedPreference().readStorage(SpKeys.email);
      final param = {"email": email};
      final notifier = TransactionBloc();
      await notifier.getAccountBalance(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getAccountBalanceSuccess) {
        if (fetch.data.length > 0) {
          fetch.data.forEach((v) => accountBalance = AccountBalanceModel.fromJSON(v));
        } else {
          _accountBalance = AccountBalanceModel.fromJSON({"totalpenarikan": 0});
        }
      }

      if (fetch.postsState == TransactionState.getAccountBalanceError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        getAccountBalance(context);
      });
    }
  }

  Future initBankAccount(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      if (dataAcccount!.isEmpty) isLoading = true;
      dataAcccount = [];
      final notifier = TransactionBloc();
      await notifier.getMyBankAccount(context);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getBankAccontSuccess) {
        fetch.data.forEach((v) => dataAcccount?.add(BankAccount.fromJSON(v)));
      }

      if (fetch.postsState == TransactionState.getBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      isLoading = false;
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initBankAccount(context);
      });
    }
  }

  Future getDetailTransactionHistory(BuildContext context, {required String id, type, jenis}) async {
    bool connect = await System().checkConnections();
    isDetailLoading = true;
    String email = SharedPreference().readStorage(SpKeys.email);
    if (connect) {
      final param = {
        "id": id,
        "type": type,
        "jenis": jenis,
        "email": email,
      };
      final notifier = TransactionBloc();
      await notifier.getDetailHistoryTransaction(context, params: param);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getDetailHistorySuccess) {
        dataTransactionDetail = TransactionHistoryModel.fromJSON(fetch.data);
      }

      if (fetch.postsState == TransactionState.getDetailHistoryError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initBankAccount(context);
      });
    }
    isDetailLoading = false;
    notifyListeners();
  }

  bool checkSave() => noBank.isNotEmpty && accountOwner.isNotEmpty ? true : false;

  Future createBankAccount(BuildContext context) async {
    final language = context.read<TranslateNotifierV2>().translate;
    final langIso = SharedPreference().readStorage(SpKeys.isoCode);
    bool connect = await System().checkConnections();
    if (connect) {
      final email = SharedPreference().readStorage(SpKeys.email);
      final Map params = {"email": email, "noRek": noBankAccount.text, "bankcode": bankcode, "nama": accountOwnerName.text, "language": langIso};

      final notifier = TransactionBloc();
      await notifier.createBankAccount(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.addBankAccontSuccess) {
        if (fetch.data == null) {
          messageAddBankError = fetch.message;
          Routing().moveBack();
        } else {
          dataAcccount?.add(BankAccount.fromJSON(fetch.data));
          dataAcccount!.last.bankName = _nameAccount.text;
          Routing().moveBack();
          Routing().moveBack();
          ShowBottomSheet().onShowColouredSheet(context, language.successfully!, color: kHyppeLightSuccess);
          _nameAccount.clear();
          noBankAccount.clear();
          accountOwnerName.clear();
          bankcode = '';
        }
      }

      if (fetch.postsState == TransactionState.addBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  Future deleteBankAccount(BuildContext context, String id, index) async {
    bool connect = await System().checkConnections();
    if (connect) {
      final email = SharedPreference().readStorage(SpKeys.email);
      final Map params = {
        "id": id,
      };
      final notifier = TransactionBloc();
      await notifier.deleteBankAccount(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.deleteBankAccontSuccess) {
        dataAcccount!.removeAt(index);
        print('delete berhasil');
        Routing().moveBack();
      }
      if (fetch.postsState == TransactionState.deleteBankAccontError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  void confirmAddBankAccount(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    ShowGeneralDialog.generalDialog(
      context,
      titleText: language.keepThisAccount,
      bodyText: "${language.youWillAdd} ${nameAccount.text} ${language.accountWithAccountNumber} ${noBankAccount.text} ${language.ownedBy} ${accountOwnerName.text}",
      maxLineTitle: 1,
      maxLineBody: 10,
      functionPrimary: () async {
        await createBankAccount(context);
      },
      functionSecondary: () {
        Routing().moveBack();
      },
      titleButtonPrimary: "${language.yes}, ${language.save}",
      titleButtonSecondary: "${language.cancel}",
      barrierDismissible: false,
    );
  }

  void confirmDeleteBankAccount(BuildContext context, bankName, accountNumber, ownerName, id, index) {
    final language = context.read<TranslateNotifierV2>().translate;
    ShowGeneralDialog.generalDialog(
      context,
      titleText: language.deletedBankAccount,
      bodyText: "${language.youWillDelete} $bankName ${language.accountWithAccountNumber} $accountNumber ${language.ownedBy} $ownerName",
      maxLineTitle: 1,
      maxLineBody: 10,
      functionPrimary: () async {
        await deleteBankAccount(context, id, index);
      },
      functionSecondary: () {
        Routing().moveBack();
      },
      titleButtonPrimary: "${language.delete}",
      titleButtonSecondary: "${language.cancel}",
      barrierDismissible: false,
    );
  }

  void scrollList(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += _limit;
      isScrollLoading = true;
      await initTransactionHistory(context);
      isScrollLoading = false;
    }
  }

  void scrollListInProgress(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += _limit;
      isScrollLoading = true;
      await initTransactionHistoryInProgress(context);
      isScrollLoading = false;
    }
  }

  Future bankChecked(int index) async {
    _isChecking = true;
    bankSelected = dataAcccount![index].noRek!;
    _accountOwner = dataAcccount![index].nama!;
    bankcode = dataAcccount![index].bankCode!;
    notifyListeners();
    _checkingAccount();
  }

  Future _checkingAccount() async {
    // bool connect = await System().checkConnections();
    // if (connect) {
    //   final email = SharedPreference().readStorage(SpKeys.email);
    //   final Map params = {
    //     // "id": id,
    //   };
    //   final notifier = TransactionBloc();
    //   await notifier.deleteBankAccount(context, params: params);
    //   final fetch = notifier.transactionFetch;

    //   if (fetch.postsState == TransactionState.deleteBankAccontSuccess) {
    //     dataAcccount!.removeAt(index);
    //     print('delete berhasil');
    //     Routing().moveBack();
    //   }
    //   if (fetch.postsState == TransactionState.deleteBankAccontError) {
    //     if (fetch.data != null) {
    //       ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
    //     }
    //   }
    //   notifyListeners();
    // } else {
    //   ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
    //     Routing().moveBack();
    //     createBankAccount(context);
    //   });
    // }
  }

  void showRemarkWithdraw(BuildContext context) {
    ShowGeneralDialog.remarkWidthdrawal(context);
  }

  Future summaryWithdrawal(BuildContext context) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final Map params = {
      "email": email,
      "bankcode": bankcode,
      "norek": bankSelected,
      "amount": int.parse(amountWithDrawal!),
    };

    if (accountBalance!.totalsaldo! < 50000 || int.parse(amountWithDrawal!) < 50000) {
      return ShowBottomSheet().onShowColouredSheet(
        context,
        'Minimum Withdrawal Rp. 50.000',
        maxLines: 2,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );
    }

    for (var e in dataAcccount!) {
      if (e.noRek == params['norek']) {
        if (!e.statusInquiry!) {
          return ShowBottomSheet().onShowColouredSheet(
            context,
            'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 4,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              print('asdasd');
            },
          );
        }
      }
    }

    _summaryWithdrawal(context, params);
  }

  Future _summaryWithdrawal(BuildContext context, params) async {
    bool connect = await System().checkConnections();
    if (connect) {
      final notifier = TransactionBloc();
      await notifier.summaryWithdrawal(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.summaryWithdrawalSuccess) {
        withdarawalSummarymodel = WithdrawalSummaryModel.fromJson(fetch.data);
        for (var e in dataAcccount!) {
          if (e.noRek == params['norek']) {
            e.statusInquiry = withdarawalSummarymodel!.statusInquiry;
          }
        }
        if (withdarawalSummarymodel!.statusInquiry!) {
          Routing().move(Routes.withdrawalSummary);
        } else {
          ShowBottomSheet().onShowColouredSheet(
            context,
            'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 2,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              print('asdasd');
            },
          );
        }
      }
      if (fetch.postsState == TransactionState.summaryWithdrawalError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createBankAccount(context);
      });
    }
  }

  bool withdrawalButton() => amountWithDrawal != '' && bankSelected != '' ? true : false;

  void navigateToPin() => Routing().move(Routes.pinWithdrawal);

  Future createWithdraw(BuildContext context, String pin) async {
    print(pin);
    if (pin.length > 5) {
      _createWithdraw(context);
    }
  }

  Future _createWithdraw(BuildContext context) async {
    ShowGeneralDialog.loadingDialog(context).then((value) => null);
    bool connect = await System().checkConnections();
    if (connect) {
      final email = SharedPreference().readStorage(SpKeys.email);
      Map params = {
        "recipient_bank": bankcode,
        "recipient_account": withdarawalSummarymodel!.bankAccount,
        "amount": withdarawalSummarymodel!.amount,
        "note": "Withdraw",
        "email": email,
      };

      final notifier = TransactionBloc();
      await notifier.createWithdraw(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.createWithdrawalSuccess) {
        withdarawalSummarymodel = WithdrawalSummaryModel.fromJson(fetch.data);

        if (withdarawalSummarymodel!.statusInquiry!) {
          // Routing().move(Routes.withdrawalSummary);
        } else {}
      }
      if (fetch.postsState == TransactionState.createWithdrawalError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
      }
      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createWithdraw(context, pinController.text);
      });
    }
  }

  void exitPageWithdrawal(BuildContext context) {
    bankcode = '';
    bankSelected = '';
    amountWithdrawalController.clear();
    amountWithDrawal = '';
    Routing().moveBack();
  }
}
