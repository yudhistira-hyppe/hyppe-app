import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../core/constants/utils.dart';
import '../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../core/services/system.dart';
import '../../../widget/custom_base_cache_image.dart';
import '../../../widget/custom_icon_widget.dart';
import '../../../widget/custom_loading.dart';
import '../../bottom_sheet/show_bottom_sheet.dart';

class AdsPopupImageDialog extends StatefulWidget {
  final AdsData data;
  const AdsPopupImageDialog({Key? key, required this.data}) : super(key: key);

  @override
  State<AdsPopupImageDialog> createState() => _AdsPopupImageDialogState();
}

class _AdsPopupImageDialogState extends State<AdsPopupImageDialog> {
  var secondsSkip = 0;
  var loadLaunch = false;
  var secondsImage = 0;
  Timer? countdownTimer;

  @override
  void initState() {
    // TODO: implement initState
    secondsSkip = widget.data.adsSkip ?? 4;
    secondsImage = 0;
    super.initState();
    startTimer();
  }

  void stopTime({bool isReset = false}) {
    setState(() => countdownTimer?.cancel());
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_){
      if(secondsSkip == 0){
        countdownTimer?.cancel();
      }else{
        setState(() {
          secondsSkip -= 1;
          secondsImage += 1;
          if(((widget.data.adsSkip ?? 4) + 2) == secondsImage){
            stopTime();
          }
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
              child: Builder(
                builder: (context) {
                  final language = context.read<TranslateNotifierV2>().translate;
                  return Container(
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
                                  // Container(
                                  //   height: 36,
                                  //   width: 36,
                                  //   decoration: BoxDecoration(
                                  //     image: const DecorationImage(
                                  //       image: AssetImage('${AssetPath.pngPath}image_ads_exp.png'),
                                  //       fit: BoxFit.cover,
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(18.0),
                                  //   ),
                                  // ),
                                  CustomBaseCacheImage(
                                    imageUrl: widget.data.avatar?.fullLinkURL,
                                    memCacheWidth: 200,
                                    memCacheHeight: 200,
                                    imageBuilder: (_, imageProvider) {
                                      return Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: imageProvider,
                                          ),
                                        ),
                                      );
                                    },
                                    errorWidget: (_, __, ___) {
                                      return Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(18)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                          ),
                                        ),
                                      );
                                    },
                                    emptyWidget: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(18)),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  twelvePx,
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextWidget(textToDisplay: widget.data.fullName ?? '', textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700, ),),
                                      CustomTextWidget(textToDisplay: language.sponsored ?? 'Bersponsor', textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, ),)
                                    ],
                                  ),),
                                  twelvePx,
                                  GestureDetector(
                                    onTap: () {
                                      ShowBottomSheet().onReportContent(
                                        context,
                                        adsData: widget.data,
                                        type: adsPopUp,
                                        postData: null,
                                        onUpdate: () {
                                          setState(() {
                                            widget.data.isReport = true;
                                          });
                                        },
                                      );
                                    },
                                    child: const CustomIconWidget(
                                      defaultColor: false,
                                      iconData: '${AssetPath.vectorPath}more.svg',
                                      color: kHyppeTextLightPrimary,
                                    ),
                                  ),
                                  tenPx,
                                  secondsSkip > 0 ? Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.grey),
                                    child: Text(
                                      '$secondsSkip',
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
                                    if(widget.data.adsDescription != null)
                                    CustomTextWidget(
                                      maxLines: 10,
                                      textAlign: TextAlign.justify,
                                      textToDisplay: widget.data.adsDescription ?? '',
                                      textStyle: context.getTextTheme().bodyText1,),
                                    sixteenPx,
                                    InkWell(
                                      onTap: () async {
                                        if (secondsSkip < 1) {
                                          final data = widget.data;
                                          if (data.adsUrlLink?.isEmail() ?? false) {
                                            final email = data.adsUrlLink!.replaceAll('email:', '');
                                            setState(() {
                                              loadLaunch = true;
                                            });
                                            // Navigator.pop(context);
                                            // Future.delayed(const Duration(milliseconds: 800), () {
                                            //   Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                            // });
                                            // adsView(widget.data, secondsImage, isClick: true).whenComplete(() {
                                            //   Navigator.pop(context);
                                            //   Future.delayed(const Duration(milliseconds: 800), () {
                                            //     Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                            //   });
                                            // });
                                          } else {
                                            try {
                                              final uri = Uri.parse(data.adsUrlLink ?? '');
                                              print('bottomAdsLayout ${data.adsUrlLink}');
                                              if (await canLaunchUrl(uri)) {
                                                setState(() {
                                                  loadLaunch = true;
                                                });
                                                // Navigator.pop(context);
                                                // await launchUrl(
                                                //   uri,
                                                //   mode: LaunchMode.externalApplication,
                                                // );
                                                // adsView(widget.data, secondsImage, isClick: true).whenComplete(() async {
                                                //   Navigator.pop(context);
                                                //   await launchUrl(
                                                //     uri,
                                                //     mode: LaunchMode.externalApplication,
                                                //   );
                                                // });
                                              } else {
                                                throw "Could not launch $uri";
                                              }
                                              // can't launch url, there is some error
                                            } catch (e) {
                                              setState(() {
                                                loadLaunch = true;
                                              });
                                              System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                              // adsView(widget.data, secondsImage, isClick: true).whenComplete(() {
                                              //   System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                              // });
                                            }
                                          }
                                        }
                                      },
                                      child: Builder(builder: (context) {
                                        final notifier = context.read<TranslateNotifierV2>();
                                        final learnMore = secondsSkip < 1 ? (notifier.translate.learnMore ?? 'Learn More') : "${notifier.translate.learnMore ?? 'Learn More'}($secondsSkip)";
                                        return Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: secondsSkip < 1 ? KHyppeButtonAds : context.getColorScheme().secondary),
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
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
