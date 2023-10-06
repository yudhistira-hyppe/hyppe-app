import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
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
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: size.width + 20,
                width: size.width - 20,
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
                    padding: EdgeInsets.only(bottom: 12),
                    width: size.width,
                    height: constraints.maxHeight,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        child: CarouselSlider(
                          options: CarouselOptions(
                              // height: size.width,
                              enlargeCenterPage: false,
                              viewportFraction: 1.2,
                              aspectRatio: 1 / 1,
                              padEnds: true,
                              enableInfiniteScroll: false,
                              autoPlayInterval: Duration(seconds: 3),
                              disableCenter: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                          items: notifier.bannerData
                              .map((item) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: GestureDetector(
                                      onTap: () {
                                        Routing().moveBack();
                                        Routing().move(Routes.chalengeDetail, argument: GeneralArgument()..id = item.sId);
                                      },
                                      child: Center(
                                          child: Image.network(
                                        item.bannerLandingpage ?? '',
                                        height: constraints.maxHeight,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: Container(
                                              height: size.width - 20,
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
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
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
                    padding: EdgeInsets.only(
                      right: 2,
                    ),
                    // color: kHyppeTextLightPrimary,
                    child: const CustomIconWidget(
                      width: 32,
                      height: 32,
                      iconData: "${AssetPath.vectorPath}close-solid.svg",
                      defaultColor: false,
                      // color: Colors.white,
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
                      margin: const EdgeInsets.only(top: 30, left: 4, right: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: (_current == entry.key ? Color(0xffAB23B0) : Color(0xffcecece))),
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
