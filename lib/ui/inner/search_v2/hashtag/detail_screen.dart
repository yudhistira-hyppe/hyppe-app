import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_image_assets.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/bottom_detail.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/models/collection/search/hashtag.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/icon_button_widget.dart';

class DetailHashtagScreen extends StatefulWidget {
  bool isTitle;
  Hashtag hashtag;
  DetailHashtagScreen({Key? key, required this.isTitle, required this.hashtag}) : super(key: key);

  @override
  State<DetailHashtagScreen> createState() => _DetailHashtagScreenState();
}

class _DetailHashtagScreenState extends State<DetailHashtagScreen> {
  @override
  Widget build(BuildContext context) {
    final count = (widget.hashtag.count ?? 0);
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      return Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            onPressed: () => notifier.backFromSearchMore(),
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: CustomTextWidget(
            textToDisplay: widget.isTitle ? (notifier.language.popularHashtag ?? 'Popular Hashtag') : (widget.hashtag.name ?? ''),
            textStyle: context
                .getTextTheme()
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomImageAssets(
                            width: 56,
                            height: 56,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(28)),
                            assetPath: '${AssetPath.pngPath}thumb_hashtag.png'),
                        twelvePx,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: widget.hashtag.name ?? '',
                              textStyle: context.getTextTheme().bodyText1?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.getColorScheme().onBackground),
                              textAlign: TextAlign.start,
                            ),
                            fourPx,
                            Text(
                              count > 500
                                  ? "500+ ${notifier.language.posts}"
                                  : "$count ${notifier.language.posts}",
                              style:
                                  const TextStyle(fontSize: 12, color: kHyppeGrey),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: context.getColorScheme().surface,
              ),
              Expanded(child: BottomDetail())

            ],
          ),
        ),
      );
    });
  }
}
