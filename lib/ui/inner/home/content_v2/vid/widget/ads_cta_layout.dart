import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/arguments/other_profile_argument.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../ux/path.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/custom_base_cache_image.dart';
import '../../../../../constant/widget/custom_spacer.dart';
import '../../../../../constant/widget/custom_text_widget.dart';

class AdsCTALayout extends StatefulWidget {
  final AdsData adsData;
  final Function() onClose;
  final String postId;
  const AdsCTALayout({
    super.key,
    required this.adsData,
    required this.onClose,
    required this.postId});

  @override
  State<AdsCTALayout> createState() => _AdsCTALayoutState();
}

class _AdsCTALayoutState extends State<AdsCTALayout> {
  var loadLaunch = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoNotifier>(
      builder: (context, notifier, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(color: kHyppeLightSurface),
          child: Row(
            children: [
              CustomBaseCacheImage(
                imageUrl: widget.adsData.avatar?.fullLinkURL,
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
              tenPx,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextWidget(
                      textToDisplay: widget.adsData.fullName ?? '',
                      textStyle: context
                          .getTextTheme()
                          .caption
                          ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    fourPx,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomTextWidget(textToDisplay: 'Ad ·', textStyle: context
                            .getTextTheme()
                            .caption
                            ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),),
                        Expanded(child: CustomTextWidget(textAlign: TextAlign.start,textToDisplay: ' ${widget.adsData.adsUrlLink}', textStyle: context.getTextTheme().caption, maxLines: 1, textOverflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Ink(
                  width: 120,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: notifier.secondsSkip <= 0 ? KHyppeButtonAds : context.getColorScheme().secondary),
                  child: InkWell(
                    splashColor: context.getColorScheme().secondary,
                    onTap: () async {
                      if(notifier.secondsSkip <= 0){
                        final data = widget.adsData;
                        final secondsVideo = widget.adsData.duration?.round() ?? 10;
                        if(!loadLaunch){
                          if(data != null){
                            if (data.adsUrlLink?.isEmail() ?? false) {
                              final email = data.adsUrlLink!.replaceAll('email:', '');
                              setState(() {
                                loadLaunch = true;
                              });
                              print('second close ads: $secondsVideo');
                              System().adsView(data, secondsVideo, isClick: true).whenComplete(() {
                                notifier.adsAliplayer?.stop();
                                notifier.adsCurrentPosition = 0;
                                notifier.adsCurrentPositionText = 0;
                                notifier.hasShowedAds = true;
                                notifier.tempAdsData = null;
                                notifier.isShowingAds = false;
                                notifier.setMapAdsContent(widget.postId, null);
                                widget.onClose();
                                Future.delayed(const Duration(milliseconds: 800), () {
                                  Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                });
                                setState(() {
                                  loadLaunch = false;
                                });
                              });
                            } else {
                              if((data.adsUrlLink ?? '').withHttp()){
                                try {
                                  final uri = Uri.parse(data.adsUrlLink ?? '');
                                  print('bottomAdsLayout ${data.adsUrlLink}');
                                  if (await canLaunchUrl(uri)) {
                                    setState(() {
                                      loadLaunch = true;
                                    });
                                    print('second close ads: $secondsVideo');
                                    System().adsView(data, secondsVideo, isClick: true).whenComplete(() async {
                                      notifier.adsAliplayer?.stop();
                                      notifier.adsCurrentPosition = 0;
                                      notifier.adsCurrentPositionText = 0;
                                      notifier.hasShowedAds = true;
                                      notifier.tempAdsData = null;
                                      notifier.isShowingAds = false;
                                      notifier.setMapAdsContent(widget.postId, null);
                                      widget.onClose();
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    });
                                  } else {
                                    throw "Could not launch $uri";
                                  }
                                  // can't launch url, there is some error
                                } catch (e) {
                                  setState(() {
                                    loadLaunch = true;
                                  });
                                  print('second close ads: $secondsVideo');
                                  // System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                  System().adsView(data, secondsVideo, isClick: true).whenComplete(() {
                                    notifier.adsAliplayer?.stop();
                                    notifier.adsCurrentPosition = 0;
                                    notifier.adsCurrentPositionText = 0;
                                    notifier.hasShowedAds = true;
                                    notifier.tempAdsData = null;
                                    notifier.isShowingAds = false;
                                    notifier.setMapAdsContent(widget.postId, null);
                                    notifier.isPlay = true;
                                    widget.onClose();
                                    System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                  });
                                }finally{
                                  setState(() {
                                    loadLaunch = false;
                                  });
                                }
                              }

                            }
                          }else{
                            setState(() {
                              loadLaunch = false;
                            });
                          }
                        }
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: Text(
                            widget.adsData.ctaButton ?? 'Learn More',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
