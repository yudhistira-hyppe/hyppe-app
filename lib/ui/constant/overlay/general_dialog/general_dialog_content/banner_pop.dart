import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class BannerPop extends StatefulWidget {
  final bool uploadProses;
  const BannerPop({Key? key, this.uploadProses = false}) : super(key: key);

  @override
  State<BannerPop> createState() => _BannerPopState();
}

class _BannerPopState extends State<BannerPop> {
  final CarouselController _controller = CarouselController();
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Consumer<ChallangeNotifier>(
      builder: (_, notifier, __) => Stack(
        fit: StackFit.loose,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: size.width + 16,
                width: size.width,
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  // return Container(
                  //   width: size.width,
                  //   margin: EdgeInsets.all(12),
                  //   height: constraints.maxHeight,
                  //   decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       image: DecorationImage(
                  //         image: NetworkImage('https://cache.teia.rocks/ipfs/QmPfuBWAmkaqxdkJZL4d2eCgkfAxrpnwKTLtSvo2t5Grjg'),
                  //         fit: BoxFit.cover,
                  //       )),
                  // );
                  return Container(
                    width: size.width,
                    height: constraints.maxHeight,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: CarouselSlider(
                      options: CarouselOptions(
                          // height: 300
                          enlargeCenterPage: false,
                          viewportFraction: 1.0,
                          aspectRatio: 1 / 1,
                          autoPlayInterval: Duration(seconds: 3),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                      items: notifier.bannerData
                          .map((item) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Center(
                                    child: Image.network(
                                  item.bannerLandingpage ?? '',
                                  height: constraints.maxHeight,
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
                  );
                }),
              ),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: ClipOval(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    color: kHyppeTextLightPrimary,
                    child: const CustomIconWidget(
                      width: 20,
                      height: 20,
                      iconData: "${AssetPath.vectorPath}close.svg",
                      defaultColor: false,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: notifier.bannerData.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: _current == entry.key ? 12 : 6.0,
                      height: 6.0,
                      margin: const EdgeInsets.only(top: 20, left: 4, right: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: (_current == entry.key ? kHyppePrimary : Color(0xffcecece))),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: imgList.asMap().entries.map((entry) {
          //         return GestureDetector(
          //           onTap: () => _controller.animateToPage(entry.key),
          //           child: Container(
          //             width: 12.0,
          //             height: 12.0,
          //             margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          //             decoration:
          //                 BoxDecoration(shape: BoxShape.circle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == entry.key ? 0.9 : 0.4)),
          //           ),
          //         );
          //       }).toList(),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
