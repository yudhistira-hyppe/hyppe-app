import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/withdrawalcoin/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FinishTrxPage extends StatefulWidget {
  const FinishTrxPage({super.key});

  @override
  State<FinishTrxPage> createState() => _FinishTrxPageState();
}

class _FinishTrxPageState extends State<FinishTrxPage> {
  LocalizationModelV2? lang;

  @override
  void initState() {
    lang = context.read<TranslateNotifierV2>().translate;
    initializeDateFormatting('id', null);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Consumer<WithdrawalCoinNotifier>(builder: (context, notifier, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                  const Expanded(
                    child: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}detail-trx-icon.svg",
                      defaultColor: false,
                    ),
                  ),
                ],
              ),
              fifteenPx,
              _buildTextNominal(notifier),
              fifteenPx,
              _buildDetail(notifier),
              fifteenPx,
              _buildHelp(),
              fifteenPx,
              fifteenPx,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: ElevatedButton(
                  onPressed: ()=> Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: kHyppePrimary),
                  child: const SizedBox(
                    width: double.infinity,
                    height: kToolbarHeight,
                    child: Center(
                      child: Text('Selesai', textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetail(WithdrawalCoinNotifier notifier) {
    TextStyle styleTitle =
        Theme.of(context).textTheme.bodyLarge!.copyWith(color: kHyppeBurem);

    TextStyle styleValue = Theme.of(context).textTheme.bodyLarge!.copyWith();
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: kHyppeBurem, width: .3),
          borderRadius: BorderRadius.circular(12.0),
          color: kHyppeBurem.withOpacity(.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleCaption(text: lang?.localeDatetime == 'id' ? 'Rincian Transaksi' : 'Transaction Details'),
          _buildValueText(
              title: 'Transaksi ID',
              value: notifier.withdrawalTransaction.noInvoice,
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Status',
              value: notifier.withdrawalTransaction.status =='PENDING' ? lang?.localeDatetime == 'id' ? 'Dalam Proses' : 'In Process' :'Done',
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: lang?.localeDatetime == 'id' ? 'Tanggal' : 'Date',
              value: DateFormat('dd MMM yyyy', lang?.localeDatetime).format(DateTime.now()),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: lang?.localeDatetime == 'id' ? 'Waktu': 'Time',
              value: '${DateFormat('hh:mm', lang?.localeDatetime).format(DateTime.now())} WIB',
              styleValue: styleValue,
              styleTitle: styleTitle),
          const Divider(
            thickness: .1,
          ),
          _buildValueText(
              title: lang?.localeDatetime == 'id' ? 'Jumlah' : 'Withdrawal Amount',
              value: System().currencyFormat(amount: notifier.withdrawaltransactionDetail.amount),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: lang?.localeDatetime == 'id' ? 'Biaya Transaksi' : 'Transaction Fee',
              value: System().currencyFormat(amount: notifier.withdrawaltransactionDetail.bankCharge),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: lang?.localeDatetime == 'id' ? 'Biaya Konversi Coins' : 'Coin Conversion Fee',
              value: System().currencyFormat(
                  amount: notifier.withdrawaltransactionDetail.convertFee),
              styleValue: styleValue,
              styleTitle: styleTitle),
          const Divider(
            thickness: .1,
          ),
          _buildValueText(
            title: lang?.localeDatetime == 'id' ? 'Saldo Diterima' : 'Balance Received',
            value: System().currencyFormat(amount: notifier.withdrawaltransactionDetail.totalAmount),
            styleValue: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
            styleTitle: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHelp(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () => Routing().move(Routes.help),
            child: Text(lang?.localeDatetime == 'id' ? 'Pusat Bantuan' : 'Help Center', style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: kHyppePrimary
            ),),
          )
        ],
      ),
    );
  }

  Widget _buildValueText(
      {String? title,
      String? value,
      TextStyle? styleTitle,
      TextStyle? styleValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Row(
        children: [
          Text(
            title ?? '',
            style: styleTitle,
          ),
          const Spacer(),
          Text(
            value ?? '',
            style: styleValue,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCaption({String? text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
      child: Text(
        text ?? '',
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextNominal(WithdrawalCoinNotifier notifier) {
    return Column(
      children: [
        fivePx,
        Text(
          System().currencyFormat(amount: notifier.withdrawaltransactionDetail.totalAmount),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        fivePx,
        Text(
          '${lang?.localeDatetime == 'id' ? 'Transfer ke ' : 'Transfer to '} ${notifier.dataAcccount.firstWhere((e) => e.selected == true).nama}',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        fivePx,
        Text(
          '${notifier.dataAcccount.firstWhere((e) => e.selected == true).bankName} • ${notifier.dataAcccount.firstWhere((e) => e.selected == true).noRek}',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        )
      ],
    );
  }
}
