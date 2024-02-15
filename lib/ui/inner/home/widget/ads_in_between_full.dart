import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/arguments/ads_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/services/system.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../../ux/routing.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsInBetweenFull extends StatefulWidget {
  final AdsArgument arguments;
  const AdsInBetweenFull({Key? key, required this.arguments}) : super(key: key);

  @override
  State<AdsInBetweenFull> createState() => _AdsInBetweenFullState();
}

class _AdsInBetweenFullState extends State<AdsInBetweenFull> {
  bool loadLaunch = false;
  bool isSeeing = false;
  bool isZoom = false;
  bool isShowMore = true;
  ValueNotifier<int> networklHasErrorNotifier = ValueNotifier(0);

  @override
  void initState() {
    // if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
    //   print('Landscape VidPlayerPage');
    AdsData picData = widget.arguments.data;
    if (widget.arguments.orientation == Orientation.landscape && picData.mediaLandscapeUri != null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.arguments.data;
    print("response --- $data ${data.mediaPortraitUri ?? data.mediaUri}");
    return Scaffold(
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(child: image(data)),
            ),
            _buildBody(context, SizeConfig.screenWidth, data),
            // _buttomBodyRight(picData: picData, notifier: notifier, index: index),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.only(top: kTextTabBarHeight - 12, left: 12.0),
                padding: widget.arguments.orientation == Orientation.landscape ? const EdgeInsets.symmetric(horizontal: 18.0) : const EdgeInsets.symmetric(vertical: 18.0),
                width: double.infinity,
                height: kToolbarHeight * 1.6,
                child: VisibilityDetector(
                    key: Key(data.adsId.toString()),
                    onVisibilityChanged: (info) {
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
                    child: appBar(data)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget image(AdsData picData, {int index = 0}) {
    final lang = context.read<TranslateNotifierV2>().translate;
    return ValueListenableBuilder(
      valueListenable: networklHasErrorNotifier,
      builder: (BuildContext context, int count, _) {
        return ZoomableImage(
          enable: true,
          onScaleStart: () {
            setState(() {
              isZoom = true;
            });
          }, // optional
          onScaleStop: () {
            setState(() {
              isZoom = false;
            });
          },
          child: CustomBaseCacheImage(
            memCacheWidth: 100,
            memCacheHeight: 100,
            widthPlaceHolder: 80,
            heightPlaceHolder: 80,
            imageUrl: getImage(picData),
            imageBuilder: (context, imageProvider) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {},
                child: ImageSize(
                  onChange: (Size size) {},
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: SizeConfig.screenWidth,
                    // height: picData?.imageHeightTemp == 0 || (picData?.imageHeightTemp ?? 0) <= 100 ? null : picData?.imageHeightTemp,
                  ),
                ),
              );
            },
            emptyWidget: Container(
                decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                width: SizeConfig.screenWidth,
                height: 250,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: CustomTextWidget(
                  textToDisplay: lang.couldntLoadImage ?? 'Error',
                  maxLines: 3,
                )),
            errorWidget: (context, url, error) {
              return Container(
                  decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                  width: SizeConfig.screenWidth,
                  height: 250,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: CustomTextWidget(
                    textToDisplay: lang.couldntLoadImage ?? 'Error',
                    maxLines: 3,
                  ));
            },
          ),
        );
      },
    );
  }

  String? getImage(AdsData picData) {
    switch ((widget.arguments.isVideo??false)) {
      case true:
        if (widget.arguments.orientation == Orientation.landscape && picData.mediaLandscapeUri != null){
          return picData.mediaLandscapeUri ?? picData.mediaUri;
        }else{
          if (widget.arguments.isScroll??false){
            return picData.mediaPortraitUri ?? picData.mediaUri;
          }
          return picData.mediaUri ?? picData.mediaPortraitUri;
        }
      default:
        return picData.mediaPortraitUri ?? picData.mediaUri;
    }
  }
  Widget appBar(AdsData data) {
    final lang = context.read<TranslateNotifierV2>().translate;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  Routing().moveBack();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  shadows: <Shadow>[Shadow(color: Colors.black54, blurRadius: 8.0)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProfileComponent(
                isFullscreen: true,
                show: true,
                following: true,
                onFollow: () {},
                username: data.username ?? 'No Name',
                textColor: kHyppeLightBackground,
                spaceProfileAndId: eightPx,
                haveStory: false,
                isCelebrity: false,
                isUserVerified: false,
                onTapOnProfileImage: () {
                  System().navigateToProfile(context, data.email ?? '');
                },
                featureType: FeatureType.pic,
                imageUrl: '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                createdAt: lang.sponsored ?? 'Sponsored',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, width, AdsData data) {
    final lang = context.read<TranslateNotifierV2>().translate;
    return Positioned(
      bottom: widget.arguments.orientation == Orientation.landscape ? 12 : kToolbarHeight,
      left: 0,
      right: 0,
      child: Padding(
        padding: widget.arguments.orientation == Orientation.landscape ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0) : const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: SizeConfig.screenWidth ?? 0,
                    maxHeight: (data.adsDescription?.length??0) > 24
                        ? isShowMore
                            ? 42
                            : SizeConfig.screenHeight! * .4
                        : 100),
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                padding: const EdgeInsets.only(left: 8.0, top: 20),
                child: SingleChildScrollView(
                  child: CustomDescContent(
                    desc: "${data.adsDescription}",
                    // desc:
                    //     "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
                    trimLines: 2,
                    textAlign: TextAlign.start,
                    callbackIsMore: (val) {
                      setState(() {
                        isShowMore = val;
                      });
                    },
                    seeLess: ' ${lang.less}',
                    seeMore: ' ${lang.more}',
                    normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                    hrefStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppePrimary),
                    expandStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (data.adsUrlLink?.isEmail() ?? false) {
                    final email = data.adsUrlLink!.replaceAll('email:', '');
                    setState(() {
                      loadLaunch = true;
                    });
                    System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() {
                      if (widget.arguments.afterReport != null) {
                        widget.arguments.afterReport!();
                      }
      
                      Future.delayed(const Duration(milliseconds: 800), () {
                        Routing().moveBack(); 
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
                          System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() async {
                            if (widget.arguments.afterReport != null) {
                              widget.arguments.afterReport!();
                            }
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            Routing().moveBack();
                          });
                        } else {
                          throw "Could not launch $uri";
                        }
                      } catch (e) {
                        setState(() {
                          loadLaunch = true;
                        });
                        System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() {
                          if (widget.arguments.afterReport != null) {
                            widget.arguments.afterReport!();
                          }
                          System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                        });
                      }
                    }
                  }
                },
                child: Container(
                  width: SizeConfig.screenWidth,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                  child: loadLaunch
                      ? const SizedBox(width: 40, height: 20, child: CustomLoading())
                      : Text(
                          data.ctaButton ?? 'Learn More',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
