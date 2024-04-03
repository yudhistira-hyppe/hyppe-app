import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/exchangecoins/notifier.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FinishTrxPage extends StatefulWidget {
  const FinishTrxPage({super.key});

  @override
  State<FinishTrxPage> createState() => _FinishTrxPageState();
}

class _FinishTrxPageState extends State<FinishTrxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Consumer<ExchangeCoinNotifier>(builder: (context, notifier, child) {
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

  Widget _buildDetail(ExchangeCoinNotifier notifier) {
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
          _buildTitleCaption(text: 'Rincian Transaksi'),
          _buildValueText(
              title: 'Transaksi ID',
              value: '2023/APP/PTC/CN/000011',
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Status',
              value: 'Dalam Proses',
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Tanggal',
              value: DateFormat('dd MMM yyyy').format(DateTime.now()),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Waktu',
              value: '${DateFormat('hh:mm').format(DateTime.now())} WIB',
              styleValue: styleValue,
              styleTitle: styleTitle),
          const Divider(
            thickness: .1,
          ),
          _buildValueText(
              title: 'Jumlah',
              value: System().currencyFormat(amount: notifier.typingValue),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Biaya Transaksi',
              value: System().currencyFormat(amount: withdrawalfree),
              styleValue: styleValue,
              styleTitle: styleTitle),
          _buildValueText(
              title: 'Biaya Konversi Coins',
              value: System().currencyFormat(
                  amount: int.parse((notifier.typingValue * withdrawalfeecoin)
                      .toStringAsFixed(0))),
              styleValue: styleValue,
              styleTitle: styleTitle),
          const Divider(
            thickness: .1,
          ),
          _buildValueText(
            title: 'Saldo Diterima',
            value: System().currencyFormat(amount: notifier.resultValue),
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
          Text('Pusat Bantuan', style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: kHyppePrimary
          ),)
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

  Widget _buildTextNominal(ExchangeCoinNotifier notifier) {
    return Column(
      children: [
        fivePx,
        Text(
          System().currencyFormat(amount: notifier.resultValue),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        fivePx,
        Text(
          'Transfer ke ${notifier.dataAcccount.firstWhere((e) => e.selected == true).nama}',
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
