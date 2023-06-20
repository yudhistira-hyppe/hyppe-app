import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class MiddleVoucherWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const MiddleVoucherWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MiddleVoucherWidget');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: language?.voucherDetail ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data?.detailTransaction?.length,
          itemBuilder: (context, index) {
            return detailVoucher(context, data?.detailTransaction?[index] ?? DetailTransaction(), data?.iconVoucher ?? '');
          },
        ),
      ],
    );
  }

  Widget detailVoucher(BuildContext context, DetailTransaction data, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: CustomCacheImage(
              imageUrl: icon,
              imageBuilder: (_, imageProvider) {
                return Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('${AssetPath.pngPath}content-error.png'),
                    ),
                  ),
                );
              },
              emptyWidget: Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  ),
                ),
              ),
            ),
          ),
          twelvePx,
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: "Voucher ${data.totalCredit} ${language?.adsCredit}",
                  textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  maxLines: 3,
                  textAlign: TextAlign.start,
                ),
                sixPx,
                CustomTextWidget(
                  textToDisplay: "${language?.from} Hyppe Business",
                  textStyle: Theme.of(context).textTheme.caption ?? const TextStyle(),
                ),
                twelvePx,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
