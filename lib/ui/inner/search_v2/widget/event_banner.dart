import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class EventBannerWidget extends StatefulWidget {
  const EventBannerWidget({super.key});

  @override
  State<EventBannerWidget> createState() => _EventBannerWidgetState();
}

class _EventBannerWidgetState extends State<EventBannerWidget> {
  int _current = 0;
  final List<String> imgList = [
    'https://cache.teia.rocks/ipfs/QmPfuBWAmkaqxdkJZL4d2eCgkfAxrpnwKTLtSvo2t5Grjg',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
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
              CustomTextWidget(
                textToDisplay: tn.translate.otherCompetitions ?? '',
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kHyppePrimary),
              ),
            ],
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.purple,
              child: CarouselSlider(
                options: CarouselOptions(
                    // height: 300
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: Duration(seconds: 3),
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
          )
        ],
      ),
    );
  }
}
