import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/coins/history_transaction.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailReport extends StatefulWidget {
  final TransactionHistoryCoinModel detail;
  const DetailReport({super.key, required this.detail});

  @override
  State<DetailReport> createState() => _DetailReportState();
}

class _DetailReportState extends State<DetailReport> {

  LocalizationModelV2? lang;
  late TransactionCoinDetailNotifier notifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CoinDetail');
    lang = context.read<TranslateNotifierV2>().translate;
    initializeDateFormatting('id', null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifier = Provider.of<TransactionCoinDetailNotifier>(context, listen: false);
      notifier.detailData(context, invoiceId: widget.detail.noInvoice);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Routing().moveBack(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: 'Detail Coins',
        ),
      ),
      body: Consumer<TransactionCoinDetailNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isloading){
            return const Center(child: CustomLoading(),);
          }
          String? textTitle;
          if (notifier.transactionDetail.code =='BP'){
            textTitle = lang?.localeDatetime == 'id' ? 'Berlangganan Boost Post' : 'Subscribe to Boost Post';
            return detailBoostContent(textTitle: textTitle);
          }else if (notifier.transactionDetail.coa == 'Conten Ownership'){
            textTitle = lang?.localeDatetime == 'id' ? 'Kepemilikan Konten' : 'Content Ownership';
            return detailOwnershipContent(textTitle: textTitle);
          }else if (notifier.transactionDetail.coa == 'Content Gift'){
            if (notifier.transactionDetail.coaDetailStatus =='debit'){
              textTitle = lang?.localeDatetime == 'id' ? 'Menerima Gift' : 'Received Content Gift';
            }else{
              textTitle = lang?.localeDatetime == 'id' ? 'Mengirim Gift' : 'Sent Content Gift';
            }
            return detail(textTitle: textTitle);
          }else if (notifier.transactionDetail.idStream != '-'){
            if (notifier.transactionDetail.coaDetailStatus =='debit'){
              textTitle = lang?.localeDatetime == 'id' ? 'Menerima Gift' : 'Received LIVE Gift';
            }else{
              textTitle = lang?.localeDatetime == 'id' ? 'Mengirim Gift' : 'Sent LIVE Gift';
            }
            
            return detailLive(textTitle: textTitle);
          }else if (notifier.transactionDetail.coa =='Penjualan Konten'){
            textTitle = lang?.localeDatetime == 'id' ? 'Penjualan Konten' : 'Content Sold';
            return detailJualContent(textTitle: textTitle);
          }else if (notifier.transactionDetail.coa =='Pembelian Konten'){
            textTitle = lang?.localeDatetime == 'id' ? 'Pembelian Konten ${widget.detail.package}' : 'Coin Purchase ${widget.detail.package}';
            return detailBeliContent(textTitle: textTitle);
          }else if (notifier.transactionDetail.code == 'AD'){
            textTitle = lang?.localeDatetime == 'id' ? 'Menonton Iklan' : 'Ads Reward';
            return detailAds(textTitle: textTitle);
          }else{
            Routing().moveBack();
            return Container();
          }
        }
      ),
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

  Widget detail({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.contentid??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', notifier.transactionDetail.postType??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Nama Gift' : 'Gift Name', notifier.transactionDetail.productName??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Dari' : 'From', notifier.transactionDetail.usernamebuyer??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Hadiah' : 'Reward Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Hadiah Gift' : 'Reward Gift', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Coins Received', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailLive({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.idStream??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', 'HyppeLive'),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Nama Gift' : 'Gift Name', notifier.transactionDetail.productName??''),
                    sixteenPx,
                    if (notifier.transactionDetail.coaDetailStatus =='debit' )
                      detailText(lang?.localeDatetime == 'id' ? 'Dari' : 'From', notifier.transactionDetail.usernameseller??'')
                    else detailText(lang?.localeDatetime == 'id' ? 'Untuk' : 'To', notifier.transactionDetail.usernamebuyer??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Hadiah' : 'Reward Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Hadiah Gift' : 'Reward Gift', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Coins Received', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailJualContent({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.contentid??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', notifier.transactionDetail.postType??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Pembeli' : 'Buyer', notifier.transactionDetail.usernamebuyer??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Hadiah' : 'Reward Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Harga Konten' : 'Item Price', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin??0)} coins'),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Biaya Layanan' : 'Admin Fee', '${System().numberFormat(amount: notifier.transactionDetail.coinadminfee??0)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Coins Received', System().numberFormat(amount: notifier.transactionDetail.totalCoin??0), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailBeliContent({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.contentid??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', notifier.transactionDetail.postType??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Pembeli' : 'Buyer', notifier.transactionDetail.usernamebuyer??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Hadiah' : 'Reward Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Harga Konten' : 'Item Price', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Biaya Layanan' : 'Admin Fee', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Coins Received', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailAds({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Tipe Iklan' : 'Ad Type', notifier.transactionDetail.adType??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Hadiah' : 'Reward Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Hadiah Iklan' : 'Ad Reward', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Coins Received', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailBoostContent({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.contentid??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', notifier.transactionDetail.postType??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Boost Post' : 'Boost Post Type', notifier.transactionDetail.boostType??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jadwal Boost Post' : 'Boost Post Schedule', DateFormat('MMMM dd, yyyy', lang?.localeDatetime).format(DateTime.parse(notifier.transactionDetail.boostStart??''))),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Pembayaran' : 'Payment Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Harga' : 'Price', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Total Pembayaran' : 'Total Payment', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget detailOwnershipContent({String? textTitle}){
    return SingleChildScrollView(
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
                        textToDisplay: textTitle??'',
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      fivePx,
                      fivePx,
                      CustomTextWidget(
                        textToDisplay: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(
                      notifier.transactionDetail.createdAt ??
                          DateTime.now().toString())),
                        textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            fifteenPx,
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
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Konten ID' : 'Content ID', notifier.transactionDetail.contentid??''),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', notifier.transactionDetail.postType??''),
                    const Divider(
                      thickness: .1,
                    ),
                    CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Pembayaran' : 'Payment Details',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(lang?.localeDatetime == 'id' ? 'Biaya Admin' : 'Admin Fee', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} coins'),
                    const Divider(
                      thickness: .1,
                    ),
                    detailText(lang?.localeDatetime == 'id' ? 'Total Tagihan' : 'Total Charge', System().numberFormat(amount: notifier.transactionDetail.totalCoin), showicon: true),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}