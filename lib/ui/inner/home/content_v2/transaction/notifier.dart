import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/transaction/bloc.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/account_balance.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/bank_account_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/models/collection/transaction/withdrawal_model.dart';
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

import 'bank_account/widget/bank_account.dart';

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
  WithdrawalModel? withdarawalmodel;

  AccountBalanceModel? _accountBalance;
  AccountBalanceModel? get accountBalance => _accountBalance;

  String _errorNoBalance = '';
  String get errorNoBalance => _errorNoBalance;

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

  String _errorPinWithdrawMsg = '';
  String get errorPinWithdrawMsg => _errorPinWithdrawMsg;

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

  String _accountNumber = "";
  String get accountNumber => _accountNumber;

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
  bool _isLoadingSummaryWithdraw = false;
  bool get isLoadingSummaryWithdraw => _isLoadingSummaryWithdraw;

  DateTime _timeVA = DateTime.now();
  DateTime get timeVA => _timeVA;

  int _minuteVa = 0;
  int get minuteVa => _minuteVa;
  int _secondVa = 0;
  int get secondVa => _secondVa;

  set amountWithDrawal(String? val) {
    _amountWithDrawal = val;
    notifyListeners();
  }

  set errorPinWithdrawMsg(String val) {
    _errorPinWithdrawMsg = val;
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

  setSkip(int val) {
    _skip = val;
  }

  set isDetailLoading(bool val) {
    _isDetailLoading = val;
    notifyListeners();
  }

  set isLoadingSummaryWithdraw(bool val) {
    _isLoadingSummaryWithdraw = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  setIsLoading(bool val) {
    _isLoading = val;
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

  void showButtomSheetAllBankList(BuildContext context, lang, bool position) {
    Provider.of<PaymentMethodNotifier>(context, listen: false).initState(context);
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return ListBankAccountWidget(lang: lang, position: position,);
        }
    );
  }

  void bankInsert(BankData data, {bool? position}) {
    bankDataSelected = data;
    nameAccount.text = data.bankname ?? '';
    bankcode = data.bankcode;
    if (!(position??false)){
      Routing().moveBack();
      navigateToAddBankAccount();
    }
    
  }

  Future initTransactionHistory(BuildContext context) async {
    print('dataTransaction?.isEmpty ${dataTransaction?.isEmpty}');
    if (dataTransaction?.isEmpty ?? false) isLoading = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        await getAccountBalance(context);
        // DateTime dateToday = DateTime.now();
        // String date = dateToday.toString().substring(0, 10);
        // String email = 'freeman27@getnada.com';
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, 'boost': false, "rewards": false, "skip": _skip, "limit": _limit};
        debugPrint("${param}");
        final notifier = TransactionBloc();
        await notifier.getHistoryTransaction(context, params: param);
        final fetch = notifier.transactionFetch;

        if (fetch.postsState == TransactionState.getHistorySuccess) {
          if (_skip == 0) dataTransaction = [];
          print("===hihihi ${fetch.data['data'].length}}");
          try {
            fetch.data['data'].forEach((v) => dataTransaction?.add(TransactionHistoryModel.fromJSON(v)));
          } catch (e) {
            print("===hihihi $e");
          }

          if (dataAllTransaction?.isEmpty ?? false) {
            fetch.data['data'].forEach((v) => dataAllTransaction?.add(TransactionHistoryModel.fromJSON(v)));
            context.read<FilterTransactionNotifier>().dataAllTransaction = dataAllTransaction;
          }

          // countTransactionProgress = fetch.data['datacount'];
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
      _isLoading = false;
      Future.delayed(const Duration(milliseconds: 250), () {
        notifyListeners();
      });
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        initBankAccount(context);
      });
    }
  }

  Future initTransactionHistoryInProgress(BuildContext context) async {
    if (dataTransactionInProgress?.isEmpty ?? false) isLoadingInProgress = true;

    bool connect = await System().checkConnections();
    if (connect) {
      try {
        String email = SharedPreference().readStorage(SpKeys.email);
        final param = {"email": email, "sell": false, "buy": false, "withdrawal": false, "status": "WAITING_PAYMENT", "boost": false, "skip": _skip, "limit": _limit};
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
    if (dataTransaction?.isEmpty ?? false) isLoading = true;

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
      if (dataAcccount?.isEmpty ?? false) isLoading = true;
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

  Future getDetailTransactionHistory(BuildContext context, {required String id, type, jenis, bool isReward = false}) async {
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
      await notifier.getDetailHistoryTransaction(context, params: param, isReward: isReward);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.getDetailHistorySuccess) {
        _timeVA = DateTime.now();
        print(fetch.data[0]);
        dataTransactionDetail = isReward ? TransactionHistoryModel.fromJSON(fetch.data[0]) : TransactionHistoryModel.fromJSON(fetch.data);
        print("ini detail ${dataTransactionDetail?.time}");
        if (!isReward) {
          var _hourVa = _timeVA.hour - DateTime.parse(dataTransactionDetail!.time!).hour;
          _minuteVa = _timeVA.minute - DateTime.parse(dataTransactionDetail!.time!).minute;
          _secondVa = _timeVA.second - DateTime.parse(dataTransactionDetail!.time!).second;
          print(_minuteVa);
          if (_hourVa > 0) {
            _minuteVa = 14 - _minuteVa - 60;
          } else {
            _minuteVa = 14 - _minuteVa;
          }
          _secondVa = 60 - _secondVa;
        } else {
          dataTransactionDetail?.type = TransactionType.reward;
        }
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
          dataAcccount?.last.bankName = _nameAccount.text;
          Routing().moveBack();
          Routing().moveBack();
          ShowBottomSheet().onShowColouredSheet(context, language.successfullyAdded ?? '', color: kHyppeLightSuccess);
          _nameAccount.clear();
          noBankAccount.clear();
          accountOwnerName.clear();
          bankcode = '';
          messageAddBankError = '';
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
      // final email = SharedPreference().readStorage(SpKeys.email);
      final Map params = {
        "id": id,
      };
      final notifier = TransactionBloc();
      await notifier.deleteBankAccount(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.deleteBankAccontSuccess) {
        dataAcccount?.removeAt(index);
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
      // bodyText: "${language.youWillAdd} ${nameAccount.text} ${language.accountWithAccountNumber} ${noBankAccount.text} ${language.ownedBy} ${accountOwnerName.text}",
      bodyText: "${language.addingtoYourAccount} ${nameAccount.text} ${noBankAccount.text} ${language.atasNama} ${accountOwnerName.text}",
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
      bodyText: "${language.youWillDelete} $bankName ${language.accountWithAccountNumber} $accountNumber ${language.an} ${ownerName.toUpperCase()}",
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
    bankSelected = dataAcccount?[index].id ?? '';
    _accountNumber = dataAcccount?[index].noRek ?? '';
    _accountOwner = dataAcccount?[index].nama ?? '';
    bankcode = dataAcccount?[index].bankCode ?? '';
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
    //     dataAcccount.removeAt(index);
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
    // ShowGeneralDialog.remarkWidthdrawal(context);
    ShowBottomSheet.onShowStatementPin(
      context,
      onCancel: () {},
      onSave: null,
      title: '',
      bodyText: context.read<TranslateNotifierV2>().translate.inTheWithdrawalProcessYouCannotTakeAllTheBalanceYouHave ?? '',
    );
  }

  Future summaryWithdrawal(BuildContext context) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final language = context.read<TranslateNotifierV2>().translate;
    if ((accountBalance?.totalsaldo ?? 0) < int.parse(amountWithDrawal ?? '0')) {
      _errorNoBalance = "Insufficient balance";
      notifyListeners();
      return false;
    }
    final Map params = {
      "email": email,
      "bankcode": bankcode,
      "norek": _accountNumber,
      "amount": int.parse(amountWithDrawal ?? '0'),
    };

    if ((accountBalance?.totalsaldo ?? 0) < 50000 || int.parse(amountWithDrawal ?? '0') < 50000) {
      return ShowBottomSheet().onShowColouredSheet(
        context,
        'Minimum Withdrawal Rp. 50.000',
        maxLines: 2,
        color: Theme.of(context).colorScheme.error,
        iconSvg: "${AssetPath.vectorPath}close.svg",
      );
    }
    for (var e in dataAcccount ?? []) {
      if (e.noRek == params['norek']) {
        if (e.statusInquiry != null && !e.statusInquiry) {
          return ShowBottomSheet().onShowColouredSheet(
            context,
            language.messageBankNotMatched ?? 'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 4,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              Routing().move(Routes.help);
            },
          );
        }
      }
    }
    _summaryWithdrawal(context, params);
  }

  Future _summaryWithdrawal(BuildContext context, params) async {
    bool connect = await System().checkConnections();
    final language = context.read<TranslateNotifierV2>().translate;
    if (connect) {
      isLoadingSummaryWithdraw = true;
      _errorNoBalance = '';
      final notifier = TransactionBloc();
      await notifier.summaryWithdrawal(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.summaryWithdrawalSuccess) {
        withdarawalSummarymodel = WithdrawalSummaryModel.fromJson(fetch.data);
        for (var e in dataAcccount ?? []) {
          if (e.noRek == params['norek']) {
            e.statusInquiry = withdarawalSummarymodel?.statusInquiry;
          }
        }
        if (withdarawalSummarymodel?.statusInquiry ?? false) {
          Routing().move(Routes.withdrawalSummary);
        } else {
          ShowBottomSheet().onShowColouredSheet(
            context,
            language.messageBankNotMatched ?? 'Bank account name and your ID did not matched. Click Here to visit our Help Center',
            maxLines: 2,
            color: Theme.of(context).colorScheme.error,
            iconSvg: "${AssetPath.vectorPath}close.svg",
            function: () {
              Routing().move(Routes.help);
            },
          );
        }
        isLoadingSummaryWithdraw = false;
        notifyListeners();
      }
      if (fetch.postsState == TransactionState.summaryWithdrawalError) {
        if (fetch.data != null) {
          ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
        }
        isLoadingSummaryWithdraw = false;
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
    _createWithdraw(context);
  }

  Future _createWithdraw(BuildContext context) async {
    bool connect = await System().checkConnections();
    if (connect) {
      ShowGeneralDialog.loadingDialog(context);
      final email = SharedPreference().readStorage(SpKeys.email);
      Map params = {
        "recipient_bank": bankcode,
        "recipient_account": withdarawalSummarymodel?.bankAccount,
        "amount": withdarawalSummarymodel?.amount,
        "note": "Withdraw",
        "email": email,
        "pin": pinController.text,
      };

      final notifier = TransactionBloc();
      await notifier.createWithdraw(context, params: params);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.createWithdrawalSuccess) {
        Routing().moveBack();
        withdarawalmodel = WithdrawalModel.fromJson(fetch.data);
        Routing().moveReplacement(Routes.successWithdrawal);
        pinController.clear();
        _errorPinWithdrawMsg = '';
      }
      if (fetch.postsState == TransactionState.createWithdrawalError) {
        Routing().moveBack();
        notifyListeners();
        if (fetch.data != null) {
          if (fetch.message != null && fetch.message['messages'] != null && fetch.message['messages']['info'] != null && fetch.message['messages']['info'][0] != null) {
            _errorPinWithdrawMsg = fetch.message['messages']['info'][0];
          }
          if (_errorPinWithdrawMsg == 'Unabled to proceed, Pin not Match') {
            _errorPinWithdrawMsg = context.read<TranslateNotifierV2>().translate.incorrectPINPleasetryAgain ?? '';
            ShowBottomSheet().onShowColouredSheet(context, _errorPinWithdrawMsg, color: Theme.of(context).colorScheme.error);
          } else {
            ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: Theme.of(context).colorScheme.error);
          }
        }
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createWithdraw(context, pinController.text);
      });
    }
  }

  void backtransaction() {
    Routing().moveBack();
    Routing().moveBack();
    exitPageWithdrawal();
  }

  void exitPageWithdrawal() {
    _errorNoBalance = '';
    bankcode = '';
    bankSelected = '';
    amountWithdrawalController.clear();
    amountWithDrawal = '';
    Routing().moveBack();
  }

  Future<bool> checkTransPanding(BuildContext context) async {
    bool connect = await System().checkConnections();
    bool pandingTransaction = false;
    if (connect) {
      final notifier = TransactionBloc();
      await notifier.transPanding(context);
      final fetch = notifier.transactionFetch;

      if (fetch.postsState == TransactionState.checkPandingSuccess) {
        if (fetch.data['waitingCount'] == 0) {
          pandingTransaction = false;
        } else {
          pandingTransaction = true;
        }
      }
      if (fetch.postsState == TransactionState.checkPandingError) {
        pandingTransaction = false;
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        createWithdraw(context, pinController.text);
      });
    }
    return pandingTransaction;
  }
}
