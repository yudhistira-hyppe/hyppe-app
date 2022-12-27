import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/bottom_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/middle_buysell_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/middle_withdrawal_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/shimmer_t_detail_history.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/top_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class DetailTransaction extends StatelessWidget {
  const DetailTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) {
        String title = '';

        Color? titleColor;
        Color? blockColor;
        Widget? bodyWidget = Container();
        if (notifier.dataTransactionDetail != null) {
          switch (notifier.dataTransactionDetail?.type) {
            case TransactionType.buy:
              titleColor = kHyppeRed;
              blockColor = kHyppeRedLight;
              title = notifier2.translate.purchased ?? 'Purchased';
              bodyWidget = MiddleBuySellDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate);
              if (notifier.dataTransactionDetail?.jenis == 'BOOST_CONTENT') {
                titleColor = kHyppeJingga;
                blockColor = kHyppeJinggaLight;
                title = notifier2.translate.postBoost ?? 'Post Boost';
              }
              break;
            case TransactionType.reward:
              titleColor = kHyppeGrey;
              blockColor = kHyppeGreyLight;
              title = notifier2.translate.reward ?? '';
              bodyWidget = MiddleBuySellDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate);
              break;
            case TransactionType.withdrawal:
              titleColor = kHyppeCyan;
              blockColor = kHyppeCyanLight;
              title = notifier2.translate.withdrawal ?? '';
              bodyWidget = MiddleWithdrawalDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate);
              break;
            default:
              titleColor = kHyppeGreen;
              blockColor = kHyppeGreenLight;
              title = notifier2.translate.soldOut ?? 'Sold Out';
              bodyWidget = MiddleBuySellDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate);
              if (notifier.dataTransactionDetail?.jenis == 'BOOST_CONTENT') {
                titleColor = kHyppeJingga;
                blockColor = kHyppeJinggaLight;
                title = notifier2.translate.postBoost ?? 'Post Boost';
              }
          }
        }
        return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: CustomTextWidget(
                textStyle: Theme.of(context).textTheme.subtitle1,
                textToDisplay: '${notifier2.translate.detailTransaction}',
              ),
            ),
            body: SingleChildScrollView(
              child: notifier.isDetailLoading
                  ? const ShimmerDetailTransactionHistory()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            twelvePx,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: blockColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                              ),
                              child: CustomTextWidget(
                                textToDisplay: title,
                                textStyle: Theme.of(context).textTheme.button?.copyWith(color: titleColor),
                              ),
                            ),
                            TopDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate),
                            bodyWidget,
                            BottomDetailWidget(data: notifier.dataTransactionDetail, language: notifier2.translate),
                          ],
                        ),
                      ),
                    ),
            ));
      },
    );
  }
}
