import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class TopDetailWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const TopDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'TopDetailWidget');
    if (data?.type == TransactionType.withdrawal) {
      return withdrawWidget(context);
    } else if (data?.type == TransactionType.reward) {
      return rewardWidget(context);
    } else if (data?.type == TransactionType.buy) {
      if (data?.jenis == "VOUCHER") {
        return voucherWidget(context);
      } else {
        return buyWidget(context);
      }
    } else {
      return sellWidget(context);
    }
  }

  Widget withdrawWidget(context) {
    return Column(
      children: [
        TwoColumnWidget('Status', text2: data?.status),
        data?.status == 'WAITING_PAYMENT'
            ? countDown(context)
            : TwoColumnWidget(
                language?.time,
                text2: System().dateFormatter(data?.time ?? '', 4),
              ),
        TwoColumnWidget('Order ID', text2: data?.id),
      ],
    );
  }

  Widget voucherWidget(context) {
    return Column(
      children: [
        // TwoColumnWidget(
        //   data?.noinvoice ?? '',
        //   // text2: 'See Invoice',
        //   textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        // ),

        TwoColumnWidget('Status', text2: data?.status),
        data?.status == 'WAITING_PAYMENT'
            ? countDown(context)
            : TwoColumnWidget(
                language?.time,
                text2: System().dateFormatter(data?.time ?? '', 4),
              ),
        data?.status == 'WAITING_PAYMENT'
            ? TwoColumnWidget(
                'No Virtual Account',
                text2: data?.nova,
                widget: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}copy-link.svg",
                  defaultColor: false,
                  height: 15,
                ),
                function: () {
                  System().copyToClipboard(data?.nova ?? '');
                  ShowBottomSheet().onShowColouredSheet(
                      context, 'Copy to clipboard',
                      color: kHyppeLightSuccess);
                },
              )
            : Container(),
        TwoColumnWidget('Order ID', text2: data?.id),
      ],
    );
  }

  Widget buyWidget(context) {
    return Column(
      children: [
        TwoColumnWidget(
          data?.noinvoice ?? '',
          // text2: 'See Invoice',
          textStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        data?.jenis == 'BOOST_CONTENT'
            ? Container()
            : TwoColumnWidget(
                language?.from ?? 'from',
                text2: data?.namapenjual,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kHyppePrimary, fontWeight: FontWeight.bold),
              ),
        TwoColumnWidget('Status', text2: data?.status),
        // TwoColumnWidget(language?.time, text2: System().dateFormatter(data?.time ?? '', 4)),
        data?.status == 'WAITING_PAYMENT'
            ? countDown(context)
            : TwoColumnWidget(
                language?.time,
                text2: System().dateFormatter(data?.time ?? '', 4),
              ),
        data?.status == 'WAITING_PAYMENT'
            ? TwoColumnWidget(
                'No Virtual Account',
                text2: data?.nova,
                widget: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}copy-link.svg",
                  defaultColor: false,
                  height: 15,
                ),
                function: () {
                  System().copyToClipboard(data?.nova ?? '');
                  ShowBottomSheet().onShowColouredSheet(
                      context, 'Copy to clipboard',
                      color: kHyppeLightSuccess);
                },
              )
            : Container(),
        TwoColumnWidget('Order ID', text2: data?.id),
      ],
    );
  }

  Widget sellWidget(context) {
    return Column(
      children: [
        TwoColumnWidget(
          data?.noinvoice,
          // text2: 'See Invoice',
          textStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget(
          language?.forr ?? 'for',
          text2: data?.namapembeli,
          textStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget('Status', text2: data?.status),
        data?.status == 'WAITING_PAYMENT'
            ? countDown(context)
            : TwoColumnWidget(
                language?.time,
                text2: System().dateFormatter(data?.time ?? '', 4),
              ),
        TwoColumnWidget('Order ID', text2: data?.id),
      ],
    );
  }

  Widget countDown(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            textToDisplay: language?.time ?? '',
            textStyle:
                Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
            textAlign: TextAlign.start,
          ),
          Row(
            children: [
              CustomTextWidget(
                textToDisplay: System().dateFormatter(data?.time ?? '', 5),
                textStyle:
                    Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
                textAlign: TextAlign.start,
              ),
              Consumer<TransactionNotifier>(
                builder: (_, notifier, __) =>
                    notifier.minuteVa < 0 && notifier.secondVa < 0
                        ? CustomTextWidget(
                            textToDisplay:
                                System().dateFormatter(data?.time ?? '', 6),
                            textStyle: Theme.of(context).textTheme.bodySmall ??
                                const TextStyle(),
                            textAlign: TextAlign.start,
                          )
                        : TweenAnimationBuilder<Duration>(
                            duration: Duration(
                                minutes: notifier.minuteVa,
                                seconds: notifier.secondVa),
                            tween: Tween(
                                begin: Duration(
                                    minutes: notifier.minuteVa,
                                    seconds: notifier.secondVa),
                                end: Duration.zero),
                            onEnd: () {
                              Routing().moveBack();
                              notifier.initTransactionHistory(context);
                            },
                            builder: (BuildContext context, Duration value,
                                Widget? child) {
                              final minutes = value.inMinutes;
                              final seconds = value.inSeconds % 60;
                              return CustomTextWidget(
                                textToDisplay:
                                    ' 00 : ${minutes < 10 ? '0' : ''}$minutes : ${seconds < 10 ? '0' : ''}$seconds',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: kHyppeRed),
                              );
                            }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget rewardWidget(context) {
    return Column(
      children: [
        TwoColumnWidget(
          language?.forr ?? 'for',
          text2: data?.from,
          textStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget('Status', text2: data?.status),
        TwoColumnWidget(language?.time ?? 'Time', text2: data?.timestamp),
      ],
    );
  }
}
