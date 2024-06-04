import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../notifier.dart';

class CouponWidget extends StatelessWidget {
  final DiscountModel? data;
  final LocalizationModelV2? lang;
  final bool allenable;
  const CouponWidget(
      {Key? key, required this.data, this.lang, this.allenable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool available =
        (data?.available ?? false) && (data?.available_to_choose ?? false);
    bool enabled = allenable == true
        ? allenable
        : context.read<DiscNotifier>().totalPayment >=
                (data?.min_use_disc ?? 0) &&
            available;
    // return discWidget(context, disabled: !enabled);
    return Stack(
      alignment: Alignment.center,
      children: [
        discWidget(context, disabled: !enabled),
        if (!enabled)
        Positioned(
          child: Container(
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget discWidget(BuildContext context, {bool disabled = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: Container(
            height: 84,
            width: 92,
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: data?.thumbnail ?? '',
                fit: BoxFit.cover,
                memCacheHeight: 320.cacheSize(context),
                memCacheWidth: 240.cacheSize(context),
                placeholder: (context, url) {
                  return Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 84,
                      width: 92,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Image.asset('${AssetPath.pngPath}content-error.png');
                },
              ),
            ),
          ),
        ),
        CustomPaint(
            size: const Size(1, double.infinity),
            painter: DashedLineVerticalPainter()),
        Flexible(child: dataWidget(context)),
        if (!context.read<DiscNotifier>().isView)
          GestureDetector(
            onTap: context.read<DiscNotifier>().isView
                ? null
                : disabled
                    ? null
                    : () => context.read<DiscNotifier>().selectedDisc(data),
            child: data?.checked ?? false
                ? const Icon(
                    Icons.radio_button_checked,
                    color: kHyppePrimary,
                  )
                : const Icon(
                    Icons.radio_button_off,
                    color: kHyppeBurem,
                  ),
          )
      ],
    );
  }

  Widget dataWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: data?.productName ?? 'Unknown',
            textStyle: const TextStyle(fontSize: 12.0),
          ),
          CustomTextWidget(
            textToDisplay:
                '${lang?.discount} ${System().currencyFormat(amount: data?.nominal_discount)}',
            textStyle:
                const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          tenPx,
          InkWell(
            onTap: () {
              // print('klick');
              context.read<DiscNotifier>().showButtomSheetInfo(context, lang!, data);
            },
            child: Row(
              children: [
                CustomTextWidget(
                  textToDisplay:
                      '${lang?.mintransaction} ${System().currencyFormat(amount: data?.min_use_disc ?? 0)}',
                  textStyle: const TextStyle(fontSize: 12.0),
                ),
                const Icon(
                  Icons.info_outline,
                  size: 18,
                )
              ],
            ),
          ),
          tenPx,
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 18,
              ),
              RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 11),
                      children: [
                    TextSpan(
                      text: lang?.validuntilcoupon ?? 'Berlaku hingga ',
                    ),
                    TextSpan(
                      text: DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(data!.endCouponDate ?? '')),
                    ),
                  ]))
            ],
          )
        ],
      ),
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = kHyppeBurem
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
