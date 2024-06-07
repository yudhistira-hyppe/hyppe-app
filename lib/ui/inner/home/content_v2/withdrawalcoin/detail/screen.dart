import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawaldetail.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'notifier.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String? invoiceid;
  const TransactionDetailScreen({super.key, required this.invoiceid});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  LocalizationModelV2? lang;
  late WithdrawalDetailNotifier notifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance
        .setCustomKey('layout', 'TransactionCoinDetail');
    lang = context.read<TranslateNotifierV2>().translate;
    initializeDateFormatting('id', null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifier = Provider.of<WithdrawalDetailNotifier>(context, listen: false);
      notifier.detailData(context, invoiceId: widget.invoiceid);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? titleColor;
    String? textTitle;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Routing().moveBack(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: lang?.localeDatetime == 'id'
              ? 'Detail Transaksi'
              : 'Transaction Detail',
        ),
      ),
      body: Consumer<WithdrawalDetailNotifier>(builder: (context, notifier, _) {
        if (notifier.isloading) {
          return const Center(
            child: CustomLoading(),
          );
        }

        switch (notifier.transactionDetail.status ?? '') {
          case 'FAILED':
            titleColor = kHyppeRed;
            textTitle = lang!.localeDatetime == 'id' ? 'Batal' : 'Cancel';
            break;
          case 'PENDING':
          case 'IN PROGRESS':
            titleColor = kHyppeRed;
            textTitle = lang!.localeDatetime == 'id'
                ? 'Menunggu Pembayaran'
                : 'Awating Payment';
            break;
          default:
            titleColor = kHyppeGreen;
            textTitle = lang!.localeDatetime == 'id' ? 'Berhasil' : 'Success';
        }
        return RefreshIndicator(
          onRefresh: () async {
            await context
                .read<WithdrawalDetailNotifier>()
                .detailData(context, invoiceId: widget.invoiceid);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: lang?.localeDatetime == 'id'
                                  ? 'Penukaran Coins'
                                  : 'Withrawal',
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            fivePx,
                            CustomTextWidget(
                              textToDisplay: DateFormat('dd MMM yyyy, HH:mm',
                                      lang?.localeDatetime ?? 'id')
                                  .format(DateTime.parse(
                                      notifier.transactionDetail.createdAt ??
                                          DateTime.now().toString())),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: kHyppeBurem),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: titleColor!.withOpacity(.2),
                            borderRadius: BorderRadius.circular(18.0)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        child: CustomTextWidget(
                          textToDisplay: textTitle ?? '',
                          textStyle: TextStyle(color: titleColor),
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    thickness: .2,
                  ),
                  fifteenPx,
                  const CustomTextWidget(
                    textToDisplay: 'Penarikan Saldo Coin',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  fifteenPx,
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(width: .2, color: kHyppeBurem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay: lang?.localeDatetime == 'id'
                              ? 'Rincian Pesanan'
                              : 'Detail Order',
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Transaksi ID'
                                : 'ID Transaction',
                            notifier.transactionDetail.noInvoice),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Alamat Email'
                                : 'Email Address',
                            notifier.transactionDetail.email),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Nama Bank'
                                : 'Bank Name',
                            '${notifier.transactionDetail.bankName}'),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Rekening Tujuan'
                                : 'Destination Account',
                            '${notifier.transactionDetail.accNo} - ${notifier.transactionDetail.accName}'),
                        sixteenPx,
                        const Divider(
                          thickness: .1,
                        ),
                        CustomTextWidget(
                          textToDisplay: lang?.localeDatetime == 'id'
                              ? 'Rincian Saldo Diterima'
                              : 'Received Balance Details',
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Saldo Ditarik'
                                : 'Withdrawal Amount',
                            System().currencyFormat(
                                amount: notifier.transactionDetail.amount)),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Biaya Layanan'
                                : 'Transaction Fee',
                            System().currencyFormat(
                                amount:
                                    notifier.transactionDetail.transactionFee ??
                                        0)),
                        sixteenPx,
                        detailText(
                            lang?.localeDatetime == 'id'
                                ? 'Biaya Converensi Coins'
                                : 'Coin Conversion Fee',
                            System().currencyFormat(
                                amount:
                                    notifier.transactionDetail.transactionFee ??
                                        0)),
                        const Divider(
                          thickness: .1,
                        ),
                        CustomTextWidget(
                          textToDisplay: lang?.localeDatetime == 'id'
                              ? 'Status Penarikan'
                              : 'Withdrawal',
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                constraints: const BoxConstraints(maxHeight: 100),
                color: Colors.white,
                child: Column(
                  children: [
                    TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: true,
                  indicatorStyle: const IndicatorStyle(
                    width: 20,
                    color: Colors.purple,
                  ),
                  beforeLineStyle: const LineStyle(
                    color: Colors.purple,
                    thickness: 6,
                  ),
                ),
                const TimelineDivider(
                  begin: 0.1,
                  end: 0.9,
                  thickness: 6,
                  color: Colors.purple,
                ),
                TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.9,
                  beforeLineStyle: const LineStyle(
                    color: Colors.purple,
                    thickness: 6,
                  ),
                  afterLineStyle: const LineStyle(
                    color: Colors.deepOrange,
                    thickness: 6,
                  ),
                  indicatorStyle: const IndicatorStyle(
                    width: 20,
                    color: Colors.cyan,
                  ),
                ),
                  ],
                ),
                    
                        ),
                        sixteenPx,
                        const CustomTextWidget(
                          textToDisplay: 'Total',
                          textStyle: TextStyle(color: kHyppeBurem),
                        ),
                        CustomTextWidget(
                          textToDisplay: System().currencyFormat(
                              amount:
                                  notifier.transactionDetail.totalAmount ?? 0),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget detailText(text1, text2, {bool showicon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          textToDisplay: text1,
          textStyle: const TextStyle(color: kHyppeBurem),
        ),
        Row(
          children: [
            Visibility(
              visible: showicon,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}ic-coin.svg",
                  height: 18,
                  defaultColor: false,
                ),
              ),
            ),
            CustomTextWidget(textToDisplay: text2)
          ],
        )
      ],
    );
  }

  Widget _content(Tracking? tracking, LocalizationModelV2? lang) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, top: 42),
      height: kToolbarHeight * 2,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        // color: Colors.red,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextWidget(
            textToDisplay: lang?.localeDatetime == 'id'
                ? tracking?.titleId ?? ''
                : tracking?.titleEn ?? '',
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          CustomTextWidget(
            textToDisplay:
                DateFormat('MMM dd, yyyy, HH:mm', lang?.localeDatetime ?? 'id')
                    .format(DateTime.parse(
                        tracking?.timestamp ?? DateTime.now().toString())),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * .7,
              height: kToolbarHeight,
              child: Text(
                lang?.localeDatetime == 'id'
                    ? tracking?.descriptionId ?? ''
                    : tracking?.descriptionEn ?? '',
                maxLines: 3,
              ))
        ],
      ),
    );
  }
}
