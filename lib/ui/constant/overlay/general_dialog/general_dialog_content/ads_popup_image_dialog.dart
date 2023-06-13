import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../widget/custom_icon_widget.dart';
import '../../../widget/custom_loading.dart';

class AdsPopupImageDialog extends StatefulWidget {
  const AdsPopupImageDialog({Key? key}) : super(key: key);

  @override
  State<AdsPopupImageDialog> createState() => _AdsPopupImageDialogState();
}

class _AdsPopupImageDialogState extends State<AdsPopupImageDialog> {
  var seconds = 4;
  var loadLaunch = false;
  Timer? countdownTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_){
      if(seconds == 0){
        countdownTimer?.cancel();
      }else{
        setState(() {
          seconds -= 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 23),
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
                              tenPx,
                              seconds > 0 ? Container(
                                height: 30,
                                width: 30,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.grey),
                                child: Text(
                                  '$seconds',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ) : InkWell(
                                onTap: (){
                                  Routing().moveBack();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: CustomIconWidget(
                                    defaultColor: false,
                                    iconData: "${AssetPath.vectorPath}close_ads.svg",
                                  ),
                                ),
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
                                // Container(
                                //   width: double.infinity,
                                //   decoration: BoxDecoration(
                                //     image: const DecorationImage(
                                //       image: AssetImage('${AssetPath.pngPath}avatar_ads_exp.png'),
                                //       fit: BoxFit.fitWidth,
                                //     ),
                                //     borderRadius: BorderRadius.circular(12.0),
                                //   ),
                                // ),
                                sixteenPx,
                                CustomTextWidget(
                                  maxLines: 10,
                                  textAlign: TextAlign.justify,
                                  textToDisplay: 'Embrace the iconic Swoosh logo and make a statement wherever you go. Choose Nike, choose excellence. Shop now and step up your shoe game with Nike.',
                                  textStyle: context.getTextTheme().bodyText1,),
                                sixteenPx,
                                InkWell(
                                  onTap: () async {

                                  },
                                  child: Builder(builder: (context) {
                                    final notifier = context.read<TranslateNotifierV2>();
                                    final learnMore = seconds < 1 ? (notifier.translate.learnMore ?? 'Learn More') : "${notifier.translate.learnMore ?? 'Learn More'}($seconds)";
                                    return Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: seconds < 1 ? KHyppeButtonAds : context.getColorScheme().secondary),
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
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
