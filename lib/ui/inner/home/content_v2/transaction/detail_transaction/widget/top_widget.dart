import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';

class TopDetailWidget extends StatelessWidget {
  TransactionHistoryModel? data;
  LocalizationModelV2? language;

  TopDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data!.type == TransactionType.withdrawal) {
      return withdrawWidget(context);
    } else {
      return buySellWidget(context);
    }
  }

  Widget withdrawWidget(context) {
    return Column(
      children: [
        TwoColumnWidget('Status', text2: data!.status),
        TwoColumnWidget(language!.time, text2: System().dateFormatter(data!.timestamp!, 4)),
        TwoColumnWidget('Order ID', text2: data!.id),
      ],
    );
  }

  Widget buySellWidget(context) {
    return Column(
      children: [
        TwoColumnWidget(
          data!.noinvoice,
          text2: 'See Invoice',
          textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget(
          language!.forr,
          text2: data!.namapembeli,
          textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
        ),
        TwoColumnWidget('Status', text2: data!.status),
        TwoColumnWidget(language!.time, text2: System().dateFormatter(data!.time!, 4)),
        TwoColumnWidget('Order ID', text2: data!.id),
      ],
    );
  }
}
