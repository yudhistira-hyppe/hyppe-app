import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class BuySellWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const BuySellWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuySellWidget');
    String title = '';
    String titleContent = '';
    String keterangan = '';
    String fullname = '';
    String email = '';
    switch (data?.postType) {
      case FeatureType.pic:
        titleContent = 'HyppePict';
        break;
      case FeatureType.vid:
        titleContent = 'HyppeVid';
        break;
      case FeatureType.diary:
        titleContent = 'HyppeDiary';
        break;
      case FeatureType.story:
        titleContent = 'HyppeStory';
        break;
      default:
    }

    Color? titleColor;
    Color? blockColor;

    switch (data?.type) {
      case TransactionType.buy:
        keterangan = language?.from ?? 'from';
        titleColor = kHyppeRed;
        blockColor = kHyppeRedLight;
        title = language?.purchased ?? 'Purchased';
        fullname = data?.penjual ?? '';
        email = data?.emailpenjual ?? '';
        if (data?.jenis == 'BOOST_CONTENT') {
          keterangan = language?.by ?? 'by';
          titleColor = kHyppeJingga;
          blockColor = kHyppeJinggaLight;
          title = language?.postBoost ?? 'Post Boost';
          fullname = data?.fullName ?? '';
          email = data?.email ?? '';
        }
        break;
      default:
        keterangan = language?.forr ?? '';
        titleColor = kHyppeGreen;
        blockColor = kHyppeGreenLight;
        title = language?.soldOut ?? 'Sold out';
        fullname = data?.pembeli ?? '';
        email = data?.emailpembeli ?? '';
    }
    final desc = '$titleContent $keterangan $fullname ( $email )';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kHyppeBurem.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kHyppeBurem.withOpacity(.3))
        // boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (data?.description != 'FAILED TRANSACTION') {
              context.read<TransactionNotifier>().getDetailTransactionHistory(context, id: data?.id ?? '', type: System().convertTransactionTypeToString(data?.type), jenis: data?.jenis);
              context.read<TransactionNotifier>().navigateToDetailTransaction();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                      ),
                      child: CustomTextWidget(
                        textToDisplay: title,
                        textStyle: Theme.of(context).textTheme.button?.copyWith(color: titleColor),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomTextWidget(
                              textToDisplay: data?.status ?? '',
                              textStyle: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          sixPx,
                          CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}unread.svg",
                            defaultColor: false,
                            color: (data?.status ?? '') == 'Cancel' ? Colors.red : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 0.2, thickness: 1, color: kHyppeBurem.withOpacity(.3)),
                twelvePx,
                // SelectableText("${data.apsara ? data.media.imageInfo.isEmpty ? data.media.videoList[0].coverURL : data.media.imageInfo[0].url : data?.fullThumbPath}"),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomCacheImage(
                        imageUrl: data?.apsara ?? false
                            ? data?.media?.imageInfo?.isEmpty ?? false
                                ? (data?.media?.videoList != null
                                    ? data!.media!.videoList!.isNotEmpty
                                        ? "${data?.media?.videoList?[0].coverURL ?? ''}"
                                        : ""
                                    : '')
                                : (data?.media?.imageInfo?[0].url ?? '')
                            : data?.fullThumbPath ?? '',
                        imageBuilder: (_, imageProvider) {
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          );
                        },
                        errorWidget: (_, __, ___) {
                          return Container(
                            height: 50,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage('${AssetPath.pngPath}content-error.png'),
                              ),
                            ),
                          );
                        },
                        emptyWidget: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage('${AssetPath.pngPath}content-error.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    sixPx,
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            textToDisplay: data?.descriptionContent ?? '',
                            textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                          ),
                          CustomTextWidget(
                            textToDisplay: desc,
                            textStyle: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                twelvePx,
                CustomTextWidget(
                  textToDisplay: data?.type != TransactionType.buy ? language?.totalIncome ?? '' : language?.totalExpenditure ?? '',
                  textStyle: Theme.of(context).textTheme.caption,
                ),
                fourPx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: "${data?.debetKredit} ${System().currencyFormat(amount: data?.totalamount)}",
                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                    CustomTextWidget(
                      textToDisplay: System().dateFormatter(data?.timestamp ?? '', 3),
                      textStyle: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                fourPointFivePx
              ],
            ),
          ),
        ),
      ),
    );
  }
}
