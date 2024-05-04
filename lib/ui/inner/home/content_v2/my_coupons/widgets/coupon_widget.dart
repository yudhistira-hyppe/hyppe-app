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
  const CouponWidget({Key? key, required this.data, this.lang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.read<MyCouponsNotifier>().isView ? null : () => context.read<MyCouponsNotifier>().selectedCoupon(data),
      child: Row(
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
          Expanded(child: dataWidget(context)),
          if (!context.read<MyCouponsNotifier>().isView)
          IconButton(
              onPressed: context.read<MyCouponsNotifier>().isView ? null : () => 
                  context.read<MyCouponsNotifier>().selectedCoupon(data),
              icon: data?.checked ?? false
                  ? const Icon(
                      Icons.radio_button_checked,
                      color: kHyppePrimary,
                    )
                  : const Icon(
                      Icons.radio_button_off,
                      color: kHyppeBurem,
                    ))
        ],
      ),
    );
  }

  Widget dataWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(textToDisplay: data?.productName ?? 'Unknown', textStyle: const TextStyle(fontSize: 12.0),),
          CustomTextWidget(
            textToDisplay: data?.name ?? 'Unknown',
            textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          tenPx,
          Row(
            children: [
              CustomTextWidget(textToDisplay: lang?.mintransaction??'Min transaksi ${System().currencyFormat(amount: data?.min_use_disc)}', textStyle: const TextStyle(fontSize: 12.0),),
              GestureDetector(onTap:  () {
                context.read<MyCouponsNotifier>().showButtomSheetInfo(context, lang!);
              }, child: const Icon(Icons.info_outline, size: 18,))
            ],
          ),
          tenPx,
          Row(
            children: [
              const Icon(Icons.access_time, size: 18,),
              RichText(text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11
                ),
                children: [
                  TextSpan(
                    text: lang?.validuntilcoupon ?? 'Berlaku hingga ',
                  ),
                  TextSpan(
                    text: DateFormat('dd MMM yyyy').format(DateTime.parse(data!.endCouponDate??'')),
                  ),
                ]
              ))
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
