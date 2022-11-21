import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class CardBoost extends StatelessWidget {
  final ContentData? data;
  final LocalizationModelV2? language;

  const CardBoost({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String title = '';
    // String titleContent = '';
    // String keterangan = '';
    // String fullname = '';
    // String email = '';
    // switch (data?.postType) {
    //   case FeatureType.pic:
    //     titleContent = 'HyppePict';
    //     break;
    //   case FeatureType.vid:
    //     titleContent = 'HyppeVid';
    //     break;
    //   case FeatureType.diary:
    //     titleContent = 'HyppeDiary';
    //     break;
    //   case FeatureType.story:
    //     titleContent = 'HyppeStory';
    //     break;
    //   default:
    // }

    // Color? titleColor;
    // Color? blockColor;

    // switch (data?.type) {
    //   case TransactionType.buy:
    //     keterangan = language?.from ?? 'from';
    //     titleColor = kHyppeRed;
    //     blockColor = kHyppeRedLight;
    //     title = language?.buy ?? 'buy';
    //     fullname = data?.penjual ?? '';
    //     email = data?.emailpenjual ?? '';
    //     if (data?.jenis == 'BOOST_CONTENT') {
    //       keterangan = language?.by ?? 'by';
    //       titleColor = kHyppeJingga;
    //       blockColor = kHyppeJinggaLight;
    //       title = language?.postBoost ?? 'Post Boost';
    //       fullname = data?.fullName ?? '';
    //       email = data?.email ?? '';
    //     }
    //     break;

    //   default:
    //     keterangan = language?.forr ?? '';
    //     titleColor = kHyppeGreen;
    //     blockColor = kHyppeGreenLight;
    //     title = language?.sell ?? '';
    //     fullname = data?.pembeli ?? '';
    //     email = data?.emailpembeli ?? '';
    // }
    // final desc = '$titleContent $keterangan $fullname ( $email )';
    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16, top: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // context.read<TransactionNotifier>().getDetailTransactionHistory(context, id: data?.id ?? '', type: System().convertTransactionTypeToString(data?.type), jenis: data?.jenis);
            // context.read<TransactionNotifier>().navigateToDetailTransaction();
          },
          child: Container(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: System().convertTypeContent(data?.postType ?? ''),
                        textStyle: Theme.of(context).primaryTextTheme.button,
                      ),
                      Row(
                        children: [
                          CustomTextWidget(
                            textToDisplay: '${data?.statusBoost}',
                            // textToDisplay: data?.status ?? '',
                            textStyle: Theme.of(context).textTheme.caption,
                          ),
                          sixPx,
                          const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}unread.svg",
                            defaultColor: false,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
                twelvePx,
                // SelectableText("${data.apsara ? data.media.imageInfo.isEmpty ? data.media.videoList[0].coverURL : data.media.imageInfo[0].url : data?.fullThumbPath}"),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomCacheImage(
                        imageUrl: data?.mediaThumbEndPoint, // imageUrl: data?.apsara ?? false
                        //     ? data?.media?.imageInfo?.isEmpty ?? false
                        //         ? (data?.media?.videoList?[0].coverURL ?? '')
                        //         : (data?.media?.imageInfo?[0].url ?? '')
                        //     : data?.fullThumbPath ?? '',
                        imageBuilder: (_, imageProvider) {
                          return Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
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
                      ),
                    ),
                    sixPx,
                    Expanded(
                      flex: 10,
                      child: CustomTextWidget(
                        maxLines: 5,
                        textToDisplay: '${data?.description}',
                        textStyle: Theme.of(context).primaryTextTheme.caption,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                twentyPx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kHyppeGreyLight,
                      ),
                      child: Row(
                        children: [
                          const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}calendar2.svg",
                            defaultColor: false,
                          ),
                          sixPx,
                          CustomTextWidget(
                            textToDisplay: "${System().dateFormatter(data?.boosted?.boostDate ?? '', 5)}",
                            textStyle: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kHyppeGreyLight,
                      ),
                      child: Row(
                        children: [
                          const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}reach.svg",
                            defaultColor: false,
                          ),
                          sixPx,
                          CustomTextWidget(
                            textToDisplay: "${data?.boostJangkauan ?? '0'} ${language?.reach}",
                            textStyle: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kHyppePrimary,
                      ),
                      child: Row(
                        children: [
                          sixPx,
                          CustomTextWidget(
                            textToDisplay: "Lihat Detail",
                            textStyle: Theme.of(context).textTheme.overline?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
