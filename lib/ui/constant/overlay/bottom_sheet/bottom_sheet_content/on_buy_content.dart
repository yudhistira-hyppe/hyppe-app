import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class OnBuyContentBottomSheet extends StatelessWidget {
//   final ContentData? data;
//   const OnBuyContentBottomSheet({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     print(data?.saleAmount);
//     // var f = NumberFormat.decimalPattern('id');

//     return Consumer<TranslateNotifierV2>(
//       builder: (_, notifier, __) => Padding(
//         padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal, horizontal: 16 * SizeConfig.scaleDiagonal),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomTextWidget(
//                   textToDisplay: notifier.translate.purchaseTerms ?? '',
//                   textStyle: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomTextWidget(
//                       textToDisplay: notifier.translate.originalContent ?? "Original Content",
//                       textStyle: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     CustomTextWidget(
//                       textToDisplay: System().currencyFormat(amount: data?.saleAmount?.toInt()),
//                       textStyle: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomTextWidget(
//                       textToDisplay: notifier.translate.totalViews ?? "Total Views",
//                       textStyle: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     CustomTextWidget(
//                       textToDisplay: (data?.saleView ?? false) ? notifier.translate.yes ?? '' : notifier.translate.no ?? '',
//                       textStyle: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomTextWidget(
//                       textToDisplay: notifier.translate.totalLikes ?? "Total Likes",
//                       textStyle: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     CustomTextWidget(
//                       // textToDisplay: f.format(data?.saleLike),
//                       textToDisplay: (data?.saleLike ?? false) ? notifier.translate.yes ?? 'yes' : notifier.translate.no ?? 'no',
//                       textStyle: Theme.of(context).textTheme.titleMedium,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             CustomElevatedButton(
//               child: CustomTextWidget(
//                 textToDisplay: notifier.translate.buy ?? 'buy',
//                 textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: kHyppeLightButtonText),
//               ),
//               width: double.infinity,
//               height: 50 * SizeConfig.scaleDiagonal,
//               function: () => Routing().move(Routes.reviewBuyContent, argument: data),
//               buttonStyle: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary), overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class OnBuyContentBottomSheet extends StatelessWidget {
  final ContentData? data;
  const OnBuyContentBottomSheet({Key? key, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(data?.saleAmount);
    // var f = NumberFormat.decimalPattern('id');

    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.symmetric(
            vertical: 8 * SizeConfig.scaleDiagonal,
            horizontal: 16 * SizeConfig.scaleDiagonal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}handler.svg"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: notifier.translate.purchaseTerms ?? '',
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.translate.originalContent ??
                          "Original Content",
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}ic-coin.svg",
                            height: 18,
                            defaultColor: false,
                          ),
                        ),
                        //Convert Rp to Coin
                        CustomTextWidget(
                          textToDisplay: System()
                              .numberFormat(amount: data?.saleAmount?.toInt()),
                          // textToDisplay: System().numberFormat(amount: (data!.saleAmount! ~/ 1000).toInt()),
                          textStyle: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay:
                          notifier.translate.totalViews ?? "Total Views",
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    CustomTextWidget(
                      textToDisplay: (data?.saleView ?? false)
                          ? notifier.translate.yes ?? ''
                          : notifier.translate.no ?? '',
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay:
                          notifier.translate.totalLikes ?? "Total Likes",
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    CustomTextWidget(
                      // textToDisplay: f.format(data?.saleLike),
                      textToDisplay: (data?.saleLike ?? false)
                          ? notifier.translate.yes ?? 'yes'
                          : notifier.translate.no ?? 'no',
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.translate.buy ?? 'buy',
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () =>
                  Routing().move(Routes.reviewBuyContent, argument: data),
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
