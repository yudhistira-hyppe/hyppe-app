import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class EventBannerWidget extends StatefulWidget {
  const EventBannerWidget({super.key});

  @override
  State<EventBannerWidget> createState() => _EventBannerWidgetState();
}

class _EventBannerWidgetState extends State<EventBannerWidget> {
  final CarouselController _controller = CarouselController();
  int _current = 0;
  final List<String> imgList = [
    'https://images.unsplash.com/photo-1603486002664-a7319421e133?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1842&q=80',
    'https://images.unsplash.com/photo-1580757468214-c73f7062a5cb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1932&q=80',
    'https://images.unsplash.com/photo-1626593261859-4fe4865d8cb1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2940&q=80'
  ];
  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Padding(
      padding: EdgeInsets.all(8),
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
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: CarouselSlider(
                options: CarouselOptions(
                    // height: 300
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    aspectRatio: 16 / 7,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
                items: imgList
                    .map((item) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                              child: Image.network(
                            item,
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
                          )),
                        ))
                    .toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: _current == entry.key ? 12 : 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.only(top: 12, left: 4, right: 4),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: (_current == entry.key ? kHyppePrimary : Color(0xffcecece))),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
