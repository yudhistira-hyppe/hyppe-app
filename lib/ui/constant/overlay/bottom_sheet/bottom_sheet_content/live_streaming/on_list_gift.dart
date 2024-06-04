import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/list_user_gift_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/icon_button_widget.dart';

class OnListGift extends StatefulWidget {
  const OnListGift({super.key});

  @override
  State<OnListGift> createState() => _OnListGiftState();
}

class _OnListGiftState extends State<OnListGift> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro.getListGift(context, mounted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: CustomIconButtonWidget(
                        height: 30,
                        width: 30,
                        onPressed: () {
                          Routing().moveBack();
                        },
                        color: Colors.black,
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}back-arrow.svg",
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CustomTextWidget(
                      textToDisplay: language.giftList ?? 'List Gift',
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: notifier.dataUserGift.length,
                  itemBuilder: (context, index) {
                    final watcher = notifier.dataUserGift[index];
                    return watcherItem(watcher, index, language);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget watcherItem(ListGiftModel data, int index, LocalizationModelV2 language) {
    final mimeType = System().extensionFiles(data.thumbnail ?? '')?.split('/')[0] ?? '';
    String type = '';
    if (mimeType != '') {
      var a = mimeType.split('/');
      type = a[0];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: InkWell(
              onTap: () => System().navigateToProfile(context, data.email ?? ''),
              // onTap: () => ShowBottomSheet.onWatcherStatus(context, data.email ?? '', data.sId ?? ''),
              child: Row(
                children: [
                  type == '.svg'
                      ? SvgPicture.network(
                          data.thumbnail ?? '',
                          height: 50 * SizeConfig.scaleDiagonal,
                          width: 50 * SizeConfig.scaleDiagonal,
                          semanticsLabel: 'A shark?!',
                          placeholderBuilder: (BuildContext context) => Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                        )
                      : SizedBox(
                          // width: MediaQuery.of(context2).size.width,
                          width: 50 * SizeConfig.scaleDiagonal,
                          height: 50 * SizeConfig.scaleDiagonal,
                          child: CustomCacheImage(
                            imageUrl: data.thumbnail ?? '',
                            imageBuilder: (_, imageProvider) {
                              return Container(
                                alignment: Alignment.topRight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                ),
                              );
                            },
                            errorWidget: (_, __, ___) {
                              return Container(
                                alignment: Alignment.topRight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  image: const DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  ),
                                ),
                              );
                            },
                            emptyWidget: Container(
                              alignment: Alignment.topRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(
                              text: "${data.count} ",
                              style: context.getTextTheme().bodyText2?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: kHyppeTextLightPrimary,
                                  ),
                              children: [
                                TextSpan(
                                  text: "${data.name}",
                                  style: const TextStyle(color: kHyppeBurem),
                                ),
                              ],
                            )),
                            sixPx,
                            RichText(
                                text: TextSpan(
                              text: "${language.from} ",
                              style: context.getTextTheme().bodyText2?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: kHyppeBurem,
                                  ),
                              children: [
                                TextSpan(
                                  text: "@${data.username}",
                                  style: const TextStyle(color: kHyppePrimary),
                                ),
                              ],
                            )),
                          ],
                        ),
                        // Button Follow
                      ],
                    ),
                  ),
                  tenPx
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
