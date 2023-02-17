import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class MiddleBuySellDetailWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const MiddleBuySellDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: data?.type == TransactionType.reward ? 'Ads Detail' : language?.contentDetail ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: CustomCacheImage(
                imageUrl: data?.apsara ?? false
                    ? data?.media?.imageInfo?.isEmpty ?? false
                        ? (data?.media?.videoList != null
                            ? data!.media!.videoList!.isNotEmpty
                                ? "${data?.media?.videoList?[0].coverURL}"
                                : ""
                            : '')
                        : (data?.media?.imageInfo?[0].url ?? '')
                    : data?.fullThumbPath ?? '',
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
                    textToDisplay: data?.type == TransactionType.reward ? data?.description ?? '' : data?.descriptionContent ?? '',
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                    maxLines: 3,
                    textAlign: TextAlign.start,
                  ),
                  data?.type == TransactionType.reward
                      ? CustomTextWidget(
                          textToDisplay: "${data?.duration.toString()}s",
                          textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontSize: 10),
                          maxLines: 3,
                          textAlign: TextAlign.start,
                        )
                      : Container(),
                  sixPx,
                  CustomTextWidget(
                    textToDisplay:
                        '${(data?.like ?? false) ? data?.totallike ?? '' : ''}${(data?.like ?? false) ? ' ${language?.like}' : ''} ${(data?.like ?? false) && (data?.view ?? false) ? ' | ' : ''}${(data?.view ?? false) ? data?.totalview : ''}${(data?.view ?? false) ? ' ${language?.views}' : ''}',
                    textStyle: Theme.of(context).textTheme.caption ?? const TextStyle(),
                  ),
                  twelvePx,
                  Row(
                    children: [
                      data?.like ?? false
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                              ),
                              child: CustomTextWidget(
                                textToDisplay: '${language?.like}',
                                textStyle: Theme.of(context).textTheme.caption ?? const TextStyle(),
                                textAlign: TextAlign.start,
                              ),
                            )
                          : Container(),
                      (data?.like ?? false) ? twelvePx : Container(),
                      (data?.view ?? false)
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                              ),
                              child: CustomTextWidget(
                                textToDisplay: '${language?.views}',
                                textStyle: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.start,
                              ),
                            )
                          : Container(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
