import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/bank_account/widget/list_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:provider/provider.dart';

class BankAccount extends StatefulWidget {
  const BankAccount({Key? key}) : super(key: key);

  @override
  State<BankAccount> createState() => _BankAccountState();
}

class _BankAccountState extends State<BankAccount> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BankAccount');
    final _notifier = context.read<TransactionNotifier>();
    _notifier.initBankAccount(context);
    // _scrollController.addListener(() => _notifier.onScrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: theme.textTheme.titleMedium,
            textToDisplay: '${notifier2.translate.bankAccount}',
          ),
          actions: [
            IconButton(onPressed: ()=>notifier.showDialogHelp(context), icon: const Icon(Icons.info_outline)),
            // CustomTextButton(
            //   onPressed: () {
            //     notifier.showDialogHelp(context);
            //   },
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       CustomTextWidget(
            //         textToDisplay: notifier2.translate.help ?? 'help',
            //         textStyle: theme.textTheme.bodySmall,
            //       ),
            //       fourPx,
            //       const CustomIconWidget(
            //         defaultColor: false,
            //         iconData: '${AssetPath.vectorPath}question-mark.svg',
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        body: notifier.isLoading
            ? Center(child: CustomLoading())
            : notifier.dataAcccount?.isEmpty ?? false
                ? EmptyBankAccount(
                    textWidget: Column(
                    children: [
                      CustomTextWidget(
                          textToDisplay: notifier2.translate.noSavedAccountYet ?? '', textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                      eightPx,
                      CustomTextWidget(
                        textToDisplay: notifier2.translate.addYourBankAccountForAnEasierWithdraw ?? '',
                        maxLines: 4,
                      ),
                    ],
                  ))
                : ListDataBankAccount(
                    refreshIndicatorKey: _refreshIndicatorKey,
                    dataAcccount: notifier.dataAcccount,
                    textRemove: notifier2.translate.remove,
                    textUpTo: notifier2.translate.infolimitbankaccount,
                    textsubtitleUpto: notifier2.translate.withdrawnsaldotobank,
                  ),

        // Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       children: [
        //         RefreshIndicator(
        //           key: _refreshIndicatorKey,
        //           color: kHyppePrimary,
        //           backgroundColor: kHyppeLightBackground,
        //           strokeWidth: 4.0,
        //           onRefresh: () async {
        //             // Replace this delay with the code to be executed during refresh
        //             // and return a Future when code finishs execution.
        //             return Future<void>.delayed(const Duration(seconds: 3));
        //           },
        //           child: ListView.builder(
        //               shrinkWrap: true,
        //               itemCount: notifier.dataAcccount.length,
        //               itemBuilder: (context, index) {
        //                 return Container(
        //                   margin: const EdgeInsets.only(bottom: 20),
        //                   padding: const EdgeInsets.only(bottom: 10),
        //                   decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kHyppeLightSurface))),
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: [
        //                       Column(
        //                         crossAxisAlignment: CrossAxisAlignment.start,
        //                         children: [
        //                           // CustomTextWidget(textToDisplay: notifier.dataAcccount[index].idBank )
        //                           CustomTextWidget(
        //                             textToDisplay: notifier.dataAcccount[index].bankName,
        //                             textStyle: Theme.of(context).textTheme.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
        //                           ),
        //                           sixPx,
        //                           CustomTextWidget(
        //                             textToDisplay: '${notifier.dataAcccount[index].noRek} - ${notifier.dataAcccount[index].nama}',
        //                             textStyle: Theme.of(context).textTheme.bodySmall,
        //                           ),
        //                         ],
        //                       ),
        //                       SizedBox(
        //                         height: 30,
        //                         child: CustomTextButton(
        //                             onPressed: () {},
        //                             style: OutlinedButton.styleFrom(
        //                               side: BorderSide(width: 1.0, color: kHyppePrimary),
        //                             ),
        //                             child: CustomTextWidget(
        //                               textToDisplay: notifier2.translate.remove,
        //                               textStyle: Theme.of(context).textTheme.bodySmall.copyWith(
        //                                     color: kHyppePrimary,
        //                                     fontWeight: FontWeight.bold,
        //                                   ),
        //                             )),
        //                       )
        //                     ],
        //                   ),
        //                 );
        //               }),
        //         ),
        //         infoMaxAccount(title: notifier2.translate.youCanAddUpTo)
        //       ],
        //     ),
        //   ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: (notifier.dataAcccount?.length ?? 0) >= 3
                ? null
                : () {
                    notifier.showButtomSheetAllBankList(context, notifier2.translate, false);
                  },
            style: ButtonStyle(backgroundColor: (notifier.dataAcccount?.length ?? 0) >= 3 ? MaterialStateProperty.all(kHyppeDisabled) : MaterialStateProperty.all(kHyppePrimary)),
            child: CustomTextWidget(
              textToDisplay: notifier2.translate.addBankAccount ?? '',
              textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
