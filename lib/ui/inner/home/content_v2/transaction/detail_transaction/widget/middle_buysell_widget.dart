import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class MiddleBuySellDetailWidget extends StatelessWidget {
  TransactionHistoryModel? data;
  LocalizationModelV2? language;

  MiddleBuySellDetailWidget({Key? key, this.data, this.language}) : super(key: key);

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
            textToDisplay: language!.contentDetail!,
            textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
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
                imageUrl: data!.apsara!
                    ? data!.media!.imageInfo!.isEmpty
                        ? data!.media!.videoList![0].coverURL
                        : data!.media!.imageInfo![0].url
                    : data?.fullThumbPath,
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
              ),
            ),
            twelvePx,
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    textToDisplay: data!.descriptionContent!,
                    textStyle: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.onBackground),
                    maxLines: 3,
                    textAlign: TextAlign.start,
                  ),
                  sixPx,
                  CustomTextWidget(
                    textToDisplay:
                        '${data!.totallike! > 0 ? data!.totallike! : ''}${data!.totallike! > 0 ? ' ${language!.like}' : ''}${data!.totallike! > 0 && data!.totalview! > 0 ? ' | ' : ''}${data!.totalview! > 0 ? data!.totalview! : ''}${data!.totalview! > 0 ? ' ${language!.views}' : ''}',
                    textStyle: Theme.of(context).textTheme.caption!,
                  ),
                  twelvePx,
                  Row(
                    children: [
                      data!.like!
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                              ),
                              child: CustomTextWidget(
                                textToDisplay: 'Like',
                                textStyle: Theme.of(context).textTheme.caption!,
                                textAlign: TextAlign.start,
                              ),
                            )
                          : Container(),
                      data!.like! ? twelvePx : Container(),
                      data!.view!
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                              ),
                              child: CustomTextWidget(
                                textToDisplay: 'View',
                                textStyle: Theme.of(context).textTheme.caption!,
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
