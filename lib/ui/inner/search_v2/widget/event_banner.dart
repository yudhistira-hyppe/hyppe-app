import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class EventBannerWidget extends StatefulWidget {
  final CarouselController? controller;
  final Function(int)? callback;

  const EventBannerWidget({super.key, this.controller, this.callback});

  @override
  State<EventBannerWidget> createState() => _EventBannerWidgetState();
}

class _EventBannerWidgetState extends State<EventBannerWidget> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 0), () {
      var cn = context.read<ChallangeNotifier>();
      cn.getBannerLanding(context, isSearch: true);
    });

    print("===-=-=-=-=-= init banner challange");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("asdasdasdasdasdasdasdasd");
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<ChallangeNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tn.translate.comeOnJoinTheInterestingCompetition ?? '',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () {
                    Routing().move(Routes.chalenge);
                  },
                  child: CustomTextWidget(
                    textToDisplay: tn.translate.otherCompetitions ?? '',
                    textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kHyppePrimary),
                  ),
                ),
              ],
            ),
            sixteenPx,
            CarouselSlider(
              carouselController: widget.controller,
              options: CarouselOptions(
                  // height: 300
                  padEnds: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  // aspectRatio: 343 / 103,
                  height: SizeConfig.screenWidth! * 0.3,
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                      widget.callback!(index);
                    });
                  }),
              items: notifier.isLoadingBanner
                  ? notifier.bannerSearchData
                      .map((e) => AspectRatio(
                            aspectRatio: 16 / 7,
                            child: CustomLoading(),
                          ))
                      .toList()
                  : notifier.bannerSearchData
                      .map((item) => GestureDetector(
                            onTap: () => Routing().move(Routes.chalenge),
                            // onTap: () => Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: item.sId)),
                            child: Center(
                                child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.bannerLandingpage ?? '',
                                width: SizeConfig.screenWidth,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Container(
                                      height: SizeConfig.screenHeight,
                                      width: SizeConfig.screenWidth,
                                      color: Colors.black,
                                      child: UnconstrainedBox(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator(
                                              // value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )),
                          ))
                      .toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: notifier.bannerSearchData.asMap().entries.map((entry) {
                return GestureDetector(
                  // onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _current == entry.key ? 12 : 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.only(top: 12, left: 4, right: 4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: (_current == entry.key ? kHyppePrimary : Color(0xffcecece))),
                  ),
                );
              }).toList(),
            ),
            sixteenPx,
          ],
        ),
      ),
    );
  }
}
