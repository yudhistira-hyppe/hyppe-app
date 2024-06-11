import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/detail/penjualan_konten.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/detail/title_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ActifityCoinDetail extends StatefulWidget {
  const ActifityCoinDetail({super.key});

  @override
  State<ActifityCoinDetail> createState() => _ActifityCoinDetailState();
}

class _ActifityCoinDetailState extends State<ActifityCoinDetail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(onPressed: () => Routing().moveBack(), icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: System().bodyMultiLang(bodyEn: 'Detail Transaksi', bodyId: 'Transaction Detail') ?? '',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionCoinDetailNotifier>().detailData(context, invoiceId: '');
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Column(
                children: [
                  TitleDetail(
                    title: 'Penjualan Konten',
                    subTitle: "${System().dateFormatter('2024-01-02', 3)} WIB",
                  ),
                  PenjualanKontenDetail(),
                ],
              )),
        ),
      ),
    );
  }
}
