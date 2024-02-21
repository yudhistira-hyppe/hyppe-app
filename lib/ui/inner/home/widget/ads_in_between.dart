import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/ads_argument.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/arguments/other_profile_argument.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/constants/utils.dart';
import '../../../../core/services/system.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../../ux/path.dart';
import '../../../../ux/routing.dart';
import '../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsInBetween extends StatefulWidget {
  final List<ContentData>? contentData;
  final int index;
  final AdsData data;
  final bool isVideo;
  final Function() afterReport;
  const AdsInBetween({Key? key, required this.data, required this.contentData, required this.index, required this.afterReport, required this.isVideo}) : super(key: key);

  @override
  State<AdsInBetween> createState() => _AdsInBetweenState();
}

class _AdsInBetweenState extends State<AdsInBetween> {
  bool loadLaunch = false;
  bool isSeeing = false;

  @override
  void initState() {
    super.initState();
  }

  void cta() async {
    final data = widget.data;
    if (data.adsUrlLink?.isEmail() ?? false) {
      final email = data.adsUrlLink!.replaceAll('email:', '');
      setState(() {
        loadLaunch = true;
      });
      System().adsView(widget.data, widget.data.duration?.round() ?? 10, isClick: true).whenComplete(() {
        widget.afterReport();
        Future.delayed(const Duration(milliseconds: 800), () {
          Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
        });
      });
    } else {
      if ((data.adsUrlLink ?? '').withHttp()) {
        print("=====mauk uooooyyy");
        try {
          final uri = Uri.parse(data.adsUrlLink ?? '');
          print('bottomAdsLayout ${data.adsUrlLink}');
          if (await canLaunchUrl(uri)) {
            setState(() {
              loadLaunch = true;
            });
            System().adsView(widget.data, widget.data.duration?.round() ?? 10, isClick: true).whenComplete(() async {
              widget.afterReport();
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            });
          } else {
            throw "Could not launch $uri";
          }
        } catch (e) {
          setState(() {
            loadLaunch = true;
          });
          System().adsView(widget.data, widget.data.duration?.round() ?? 10, isClick: true).whenComplete(() {
            widget.afterReport();
            System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
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
                    VisibilityDetector(
                      key: Key(widget.data.adsId ?? ''),
                      onVisibilityChanged: (VisibilityInfo info) {
                        if (info.visibleFraction >= 0.9) {
                          setState(() {
                            isSeeing = true;
                          });
                          // Future.delayed(const Duration(seconds: 1), (){
                          //   if(isSeeing){
                          //     System().adsView(widget.data, widget.data.duration?.round() ?? 10);
                          //   }
                          // });
                        }
                        if (info.visibleFraction < 0.3) {
                          try {
                            if (mounted) {
                              setState(() {
                                isSeeing = false;
                              });
                            } else {
                              isSeeing = false;
                            }
                          } catch (e) {
                            isSeeing = false;
                          }
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: widget.data.email));
                        },
                        child: CustomBaseCacheImage(
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
                          errorWidget: (_, url, ___) {
                            if (url.isNotEmpty && url.withHttp()) {
                              return ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(url, width: 36, height: 36, fit: BoxFit.cover, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                        ),
                                      ),
                                    );
                                  }, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(18)),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                                        ),
                                      ),
                                    );
                                  }));
                            }
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(18)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
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
                                image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    twelvePx,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            textToDisplay: widget.data.username ?? '',
                            textStyle: context.getTextTheme().caption?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          CustomTextWidget(
                            textToDisplay: language.sponsored ?? 'Sponsored',
                            textStyle: context.getTextTheme().caption?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                          )
                        ],
                      ),
                    ),
                    twelvePx,
                    GestureDetector(
                      onTap: () {
                        ShowBottomSheet().onReportContent(context, adsData: widget.data, type: adsPopUp, postData: null, onUpdate: () {
                          setState(() {
                            widget.data.isReport = true;
                          });
                        }, onCompleted: widget.afterReport);
                      },
                      child: const CustomIconWidget(
                        defaultColor: false,
                        iconData: '${AssetPath.vectorPath}more.svg',
                        color: kHyppeTextLightPrimary,
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
                      CustomBaseCacheImage(
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        widthPlaceHolder: 80,
                        heightPlaceHolder: 80,
                        imageUrl: widget.data.mediaUri,
                        imageBuilder: (context, imageProvider) => ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Image border
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                            width: context.getWidth(),
                          ),
                        ),
                        emptyWidget: Container(
                            decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                            width: context.getWidth(),
                            height: 250,
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: CustomTextWidget(
                              textToDisplay: language.couldntLoadImage ?? 'Error',
                              maxLines: 3,
                            )),
                        errorWidget: (context, url, error) {
                          return Container(
                              decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                              width: context.getWidth(),
                              height: 250,
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: CustomTextWidget(
                                textToDisplay: language.couldntLoadImage ?? 'Error',
                                maxLines: 3,
                              ));
                        },
                      ),
                      twelvePx,
                      InkWell(
                        onTap: () async {
                          cta();
                        },
                        child: Builder(builder: (context) {
                          final learnMore = (widget.data.ctaButton ?? 'Learn More');
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                            child: loadLaunch
                                ? const SizedBox(width: 40, height: 20, child: CustomLoading())
                                : Text(
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
                      if (widget.data.adsDescription != null)
                        Builder(builder: (context) {
                          final notifier = context.read<TranslateNotifierV2>();
                          return CustomDescContent(
                              desc: widget.data.adsDescription!,
                              trimLines: 2,
                              textAlign: TextAlign.justify,
                              seeLess: ' ${notifier.translate.seeLess}',
                              seeMore: ' ${notifier.translate.seeMoreContent}',
                              textOverflow: TextOverflow.visible,
                              normStyle: Theme.of(context).textTheme.bodyText2,
                              hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                              expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary));
                        })
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
