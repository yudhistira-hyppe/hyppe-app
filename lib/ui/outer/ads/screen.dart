import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/ads_argument.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/bloc/ads_video/bloc.dart';
import '../../../core/constants/asset_path.dart';
import '../../../core/constants/enum.dart';
import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/constants/size_config.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/constants/utils.dart';
import '../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../core/models/collection/advertising/view_ads_request.dart';
import '../../../core/services/shared_preference.dart';
import '../../../initial/hyppe/translate_v2.dart';
import '../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../constant/widget/custom_background_layer.dart';
import '../../constant/widget/custom_base_cache_image.dart';
import '../../constant/widget/custom_cache_image.dart';
import '../../constant/widget/custom_icon_widget.dart';
import '../../constant/widget/custom_spacer.dart';

class AdsScreen extends StatefulWidget {
  final AdsArgument argument;
  const AdsScreen({Key? key, required this.argument}) : super(key: key);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final List<StoryItem> _storyItems = [];
  final StoryController _storyController = StoryController();

  final _sharedPrefs = SharedPreference();
  var secondsSkip = 0;
  var secondsVideo = 0;
  // List<ContentData>? _vidData;

  @override
  void initState() {
    _storyItems.add(StoryItem.pageVideo(widget.argument.adsUrl,
        controller: _storyController,
        id: widget.argument.data.adsId ?? '',
        requestHeaders: {
          'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
          'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
        },
        duration: Duration(milliseconds: ((widget.argument.data.duration ?? 15) * 1000).toInt())));
    print('isShowPopAds true');
    SharedPreference().writeStorage(SpKeys.isShowPopAds, true);

    secondsSkip = widget.argument.data.adsSkip ?? 0;
    super.initState();
  }

  Future adsView(BuildContext context, AdsData data, int time, {bool isClick = false}) async {
    try {
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(
        watchingTime: time,
        adsId: data.adsId,
        useradsId: data.useradsId,
      );
      await notifier.viewAdsBloc(context, request, isClick: isClick);
      final fetch = notifier.adsDataFetch;
      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print("ini hasil ${fetch.data['rewards']}");
        if (fetch.data['rewards'] == true) {
          print("ini hasil ${mounted}");
          if (mounted) {
            ShowGeneralDialog.adsRewardPop(context);
            Timer(const Duration(milliseconds: 800), () {
              Routing().moveBack();
              Timer(const Duration(milliseconds: 800), () {
                Routing().moveBack();
              });
            });
          }
        }
      } else {
        Routing().moveBack();
      }

      return true;
      // final fetch = notifier.adsVideoFetch;

    } catch (e) {
      'Failed hit view ads $e'.logger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              (widget.argument.data.mediaType ?? '').translateType() == ContentType.image
                  ? Stack(
                      children: [
                        // Background
                        CustomBackgroundLayer(
                          sigmaX: 30,
                          sigmaY: 30,
                          thumbnail: widget.argument.adsUrl,
                        ),
                        // Content
                        InteractiveViewer(
                          child: InkWell(
                            child: CustomCacheImage(
                              imageUrl: widget.argument.adsUrl,
                              imageBuilder: (ctx, imageProvider) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                  ),
                                );
                              },
                              errorWidget: (_, __, ___) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                    ),
                                  ),
                                );
                              },
                              emptyWidget: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        StoryView(
                          inline: false,
                          repeat: false,
                          progressColor: kHyppeLightButtonText,
                          durationColor: kHyppeLightButtonText,
                          storyItems: _storyItems,
                          controller: _storyController,
                          progressPosition: ProgressPosition.top,
                          isAds: true,
                          onStoryShow: (storyItem) {},
                          onEverySecond: (dur) {
                            'second of video $dur'.logger();
                            setState(() {
                              secondsSkip -= 1;
                              secondsVideo += 1;
                            });
                          },
                          nextDebouncer: false,
                          onComplete: () async {
                            _storyController.pause();
                            await adsView(context, widget.argument.data, secondsVideo);
                          },
                        ),
                        widget.argument.data.isReport ?? false
                            ? BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                child: Container(
                                  color: Colors.black.withOpacity(0),
                                ),
                              )
                            : Container()
                      ],
                    ),
              widget.argument.data.isReport!
                  ? SafeArea(
                      child: SizedBox(
                      width: SizeConfig.screenWidth,
                      child: Consumer<TranslateNotifierV2>(
                        builder: (context, transnot, child) => Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Spacer(),
                            const CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}valid-invert.svg",
                              defaultColor: false,
                              height: 30,
                            ),
                            Text(transnot.translate.reportReceived ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(transnot.translate.yourReportWillbeHandledImmediately ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                )),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.argument.data.isReport = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(top: 8),
                                margin: const EdgeInsets.all(8),
                                width: SizeConfig.screenWidth,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "See Ads",
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            thirtyTwoPx,
                          ],
                        ),
                      ),
                    ))
                  : Container(),
              Positioned(left: 0, top: 50, right: 0, child: topAdsLayout(widget.argument.data)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: (widget.argument.data.isReport ?? false) ? Container() : bottomAdsLayout(widget.argument.data),
              )
            ],
          )),
    );
  }

  Widget topAdsLayout(AdsData data) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 18, right: 18, top: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                data.isReport ?? false
                    ? Container()
                    : Row(
                        children: [
                          CustomBaseCacheImage(
                            imageUrl: data.avatar?.fullLinkURL,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CustomIconWidget(
                                    defaultColor: false,
                                    iconData: "${AssetPath.vectorPath}ad_yellow_icon.svg",
                                  ),
                                  fourPx,
                                  Text(
                                    data.adsDescription ?? 'Nike',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              sixPx,
                              Text(
                                widget.argument.isSponsored ? 'Sponsored' : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // _storyController.pause();
                        ShowBottomSheet.onReportContent(
                          context,
                          adsData: widget.argument.data,
                          type: adsPopUp,
                          postData: null,
                          onUpdate: () {
                            setState(() {
                              data.isReport = true;
                            });
                          },
                        );
                      },
                      child: const CustomIconWidget(
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}more.svg",
                        color: kHyppeLightButtonText,
                      ),
                    ),
                    secondsSkip < 1 || widget.argument.data.isReport == true
                        ? InkWell(
                            onTap: () {
                              adsView(context, widget.argument.data, secondsVideo);
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: CustomIconWidget(
                                defaultColor: false,
                                iconData: "${AssetPath.vectorPath}close_ads.svg",
                              ),
                            ),
                          )
                        : Container()
                  ],
                )
              ],
            ),
            secondsSkip > 0 && widget.argument.data.isReport != true
                ? Container(
                    height: 30,
                    width: 30,
                    margin: EdgeInsets.only(top: 0),
                    child: Text(
                      '$secondsSkip',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.grey),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget bottomAdsLayout(AdsData data) {
    return Material(
      color: Colors.transparent,
      child: Consumer<TranslateNotifierV2>(
        builder: (context, notifier, _){
          return Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
            child: InkWell(
              onTap: () async {
                if(secondsSkip < 1){
                  final uri = Uri.parse(data.adsUrlLink ?? '');
                  if (await canLaunchUrl(uri)) {
                    adsView(context, widget.argument.data, secondsVideo, isClick: true);
                    Navigator.pop(context);
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw "Could not launch $uri";
                  }
                  // can't launch url, there is some error
                }

              },
              child: Builder(
                builder: (context) {
                  final learnMore = secondsSkip < 1 ? (notifier.translate.learnMore ?? 'Learn More') : "${notifier.translate.learnMore ?? 'Learn More'}($secondsSkip)";
                  return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: secondsSkip < 1 ? KHyppeButtonAds : context.getColorScheme().secondary),
                      child: CustomTextWidget(
                        textToDisplay: learnMore,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )

                    //  Text(
                    //   'Learn more',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    // ),
                  );
                }
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    print('isShowPopAds false');
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
    _storyController.dispose();
    super.dispose();
  }
}
