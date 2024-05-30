import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/widget/loadmore.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notifier.dart';
import 'package:transparent_image/transparent_image.dart';

class PaymentWaiting extends StatefulWidget {
  const PaymentWaiting({super.key});

  @override
  State<PaymentWaiting> createState() => _PaymentWaitingState();
}

class _PaymentWaitingState extends State<PaymentWaiting> {
  LocalizationModelV2? lang;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'payment_waiting_coin');
    lang = context.read<TranslateNotifierV2>().translate;
    var notifier =
          Provider.of<PaymentWaitingNotifier>(context, listen: false);
    notifier.isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeDateFormatting('id', null);
      // var notifier =
      //     Provider.of<PaymentWaitingNotifier>(context, listen: false);
      Map res = ModalRoute.of(context)!.settings.arguments as Map;
      if (res['bank'] != null) {
        notifier.bankData = res['bank'] as BankData;
      }

      if (res['transaction'] != null){
        notifier.transactionCoinDetail = res['transaction'] as TransactionCoinModel;
      }

      notifier.isLoading = false;

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    // 
    return Consumer<PaymentWaitingNotifier>(
        builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
              onPressed: () => Routing().moveBack(),
              icon: const Icon(Icons.arrow_back_ios)),
          title: CustomTextWidget(
            textStyle: theme.textTheme.titleMedium,
            textToDisplay: '${lang?.awaitingpayment}',
          ),
        ),
        body: notifier.isLoading 
        ? const Center(child: LoadingWidget())
        : SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: lang?.paymentdeadline ?? 'Batas Pembayaran',
                  textStyle: const TextStyle(color: kHyppeBurem, fontSize: 14),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * .6,
                        child: CustomTextWidget(
                          textToDisplay: DateFormat('EEEE, dd MMM yyyy HH:mm', 'id')
                                  .format(DateTime.parse(notifier.transactionCoinDetail.expiredtimeva ?? '2024-03-02 11:02')),
                              textStyle: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(18.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: TweenAnimationBuilder<Duration>(
                        duration: const Duration(minutes: 15),
                        tween: Tween(begin: const Duration(minutes: 15), end: Duration.zero),
                        onEnd: () {
                          // notifier.backHome();
                        },
                        builder: (BuildContext context, Duration value, Widget? child) {
                          final minutes = value.inMinutes;
                          final seconds = value.inSeconds % 60;
                          return CustomTextWidget(
                            textToDisplay: '${minutes < 10 ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds',
                            textStyle: textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    )
                  ],
                ),
                const Divider(
                  thickness: .5,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 18.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      border: Border.all(width: .5, color: kHyppeBurem),
                      borderRadius: BorderRadius.circular(12.0),
                      color: kHyppeBurem.withOpacity(.05)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: 38,
                              child: FadeInImage.memoryNetwork(
                                image: notifier.bankData.bankIcon??'',
                                placeholder: kTransparentImage,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_outlined,
                                    size: 42,
                                  );
                                },
                              )),
                          tenPx,
                          Text(
                            ' ${notifier.bankData.bankname??''}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: .5,
                        color: kHyppeBurem,
                      ),
                      infoTransaction(
                          label: 'Transaksi ID',
                          text: notifier.transactionCoinDetail.noinvoice,
                          copied: false),
                      infoTransaction(
                          label: 'Nomor Virtual Account',
                          text: notifier.transactionCoinDetail.nova,
                          copied: true),
                      infoTransaction(
                          label: 'Total Pembayaran',
                          text: System().currencyFormat(amount: notifier.transactionCoinDetail.totalamount??0),
                          copied: false),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                            color: kHyppeBurem.withOpacity(.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(width: 1, color: kHyppeBurem)),
                        child: Row(
                          children: [
                            const CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}info-icon.svg",
                              // defaultColor: false,
                            ),
                            fourteenPx,
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .65,
                              child: CustomTextWidget(
                                textToDisplay: lang?.infopaymentcoin ?? "Tidak disarankan transfer virtual account dari bank selain yang dipilih",
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                CustomTextWidget(
                    textToDisplay: lang?.paymentMethods ?? 'Cara Pembayaran',
                    textStyle: textTheme.bodyMedium?.copyWith(
                        color: Colors.black87, fontWeight: FontWeight.bold)),
                expansionLists(
                    context, textTheme, 'Via ATM', notifier.bankData.atm ?? ''),
                expansionLists(context, textTheme, 'Via m-Banking',
                    notifier.bankData.mobileBanking ?? ''),
                expansionLists(context, textTheme, 'Via Internet Banking',
                    notifier.bankData.internetBanking ?? ''),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget infoTransaction({String? label, String? text, bool? copied}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: label ?? '',
            textStyle: const TextStyle(color: kHyppeBurem, fontSize: 14),
          ),
          tenPx,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                textToDisplay: text ?? '',
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (copied ?? false)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text??''));
                    Fluttertoast.showToast(msg: lang!.copyvirtualaccount??'Nomor virtual account berhasil disalin');
                  },
                  child: CustomTextWidget(
                    textToDisplay: lang!.copy ?? 'Salin',
                    textStyle: const TextStyle(
                        color: kHyppePrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget expansionLists(
      BuildContext context, TextTheme textTheme, String title, String body) {
    if (body == '') {
      return Container();
    } else {
      return ExpansionTile(
        childrenPadding: EdgeInsets.zero,
        tilePadding: EdgeInsets.zero,
        textColor: kHyppeTextLightPrimary,
        iconColor: kHyppeTextLightPrimary,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Html(
                data: body,
                style: {
                  "a": Style(
                      color: kHyppePrimary,
                      textDecoration: TextDecoration.underline,
                      textDecorationThickness: 0),
                  "ol": Style(
                    padding: HtmlPaddings.only(left: 4),
                  )
                },
                onLinkTap: (String? url, Map<String, String> attributes,
                    element) async {
                  try {
                    if (await canLaunchUrl(Uri.parse(url ?? ''))) {
                      await launchUrl(
                        Uri.parse(url ?? ''),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      throw "Could not launch $url";
                    }
                  } catch (e) {
                    System().goToWebScreen(url ?? '');
                  }
                }),
          )
        ],
      );
    }
  }
}