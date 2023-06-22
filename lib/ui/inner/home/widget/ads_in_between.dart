import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsInBetween extends StatefulWidget {
  const AdsInBetween({Key? key}) : super(key: key);

  @override
  State<AdsInBetween> createState() => _AdsInBetweenState();
}

class _AdsInBetweenState extends State<AdsInBetween> {
  bool loadLaunch = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('${AssetPath.pngPath}image_ads_exp.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    twelvePx,
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(textToDisplay: 'nike.offical', textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700, ),),
                        CustomTextWidget(textToDisplay: 'Bersponsor', textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, ),)
                      ],
                    ),),
                    twelvePx,
                    const CustomIconWidget(
                      defaultColor: false,
                      iconData: '${AssetPath.vectorPath}more.svg',
                      color: kHyppeTextLightPrimary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('${AssetPath.pngPath}avatar_ads_exp.png', width: double.infinity, fit: BoxFit.cover,),
                      twelvePx,
                      InkWell(
                        onTap: () async {

                        },
                        child: Builder(builder: (context) {
                          final notifier = context.read<TranslateNotifierV2>();
                          final learnMore = (notifier.translate.learnMore ?? 'Learn More');
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                            child: loadLaunch ? const SizedBox(width: 40, height: 20, child: CustomLoading()) : Text(
                              learnMore,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }),
                      ),
                      twelvePx,
                      Builder(
                        builder: (context) {
                          final notifier = context.read<TranslateNotifierV2>();
                          return CustomDescContent(
                              desc: 'Embrace the iconic Swoosh logo and make a statement wherever you go. Choose Nike, choose excellence. Shop now and step up your shoe game with Nike.',
                              trimLines: 2,
                              textAlign: TextAlign.justify,
                              seeLess: ' ${notifier.translate.seeLess}',
                              seeMore: ' ${notifier.translate.seeMoreContent}',
                              textOverflow: TextOverflow.visible,
                              normStyle: Theme.of(context).textTheme.bodyText2,
                              hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                              expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary));
                        }
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}
