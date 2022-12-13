import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';

class TopDetailWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const TopDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data?.type == TransactionType.withdrawal) {
      return withdrawWidget(context);
    } else if (data?.type == TransactionType.buy) {
      return buyWidget(context);
    } else {
      return sellWidget(context);
    }
  }

  Widget withdrawWidget(context) {
    return Column(
      children: [
        TwoColumnWidget('Status', text2: data?.status),
        TwoColumnWidget(language?.time, text2: System().dateFormatter(data?.timestamp ?? '', 4)),
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
          textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        data?.jenis == 'BOOST_CONTENT'
            ? Container()
            : TwoColumnWidget(
                language?.from ?? 'from',
                text2: data?.namapenjual,
                textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
              ),
        TwoColumnWidget('Status', text2: data?.status),
        TwoColumnWidget(language?.time, text2: System().dateFormatter(data?.time ?? '', 4)),
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
                  ShowBottomSheet().onShowColouredSheet(context, 'Copy to clipboard', color: kHyppeLightSuccess);
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
          textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget(
          language?.forr ?? 'for',
          text2: data?.namapembeli,
          textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget('Status', text2: data?.status),
        TwoColumnWidget(language?.time, text2: System().dateFormatter(data?.time ?? '', 4)),
        TwoColumnWidget('Order ID', text2: data?.id),
      ],
    );
  }
}
