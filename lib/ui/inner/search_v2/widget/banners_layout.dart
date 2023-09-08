import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/system.dart';

class BannersLayout extends StatefulWidget {
  final Widget layout;
  const BannersLayout({Key? key, required this.layout}) : super(key: key);

  @override
  State<BannersLayout> createState() => _BannersLayoutState();
}

class _BannersLayoutState extends State<BannersLayout>
    with AfterFirstLayoutMixin {
  int currIndex = 0;
  late CarouselController controller;
  // late Timer _timer;

  @override
  void initState() {
    controller = CarouselController();
    super.initState();
    // _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
    //   final values = (Routing.navigatorKey.currentContext ?? context)
    //       .read<ChallangeNotifier>()
    //       .banners;
    //   if (values?.isNotEmpty ?? false) {
    //     print('timer banner $currIndex');
    //     final total = (values?.length ?? 1) - 1;
    //     if (currIndex < total) {
    //       currIndex++;
    //     } else {
    //       currIndex = 0;
    //     }
    //     print('timer banner 1 $currIndex');
    //     controller.animateToPage(
    //       currIndex,
    //       duration: Duration(milliseconds: 350),
    //       curve: Curves.easeIn,
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    // _timer.cancel();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<ChallangeNotifier>();
    notifier.getBanners(context);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 375 / 250,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AspectRatio(
              aspectRatio: 375 / 211,
              child: Consumer<ChallangeNotifier>(builder: (context, notifier, _) {
                  return Stack(
              children: [
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      if (notifier.isLoading || notifier.banners == null) {
                        return Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const CustomLoading(),
                        );
                      }
                      return CarouselSlider(
                        carouselController: controller,
                        options: CarouselOptions(
                          // height: 300
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            // autoPlay: true,
                            viewportFraction: 1.0,
                            aspectRatio: 375 / 211,
                            // aspectRatio: 343 / 103,
                            // autoPlayInterval: const Duration(seconds: 3),
                            onPageChanged: (index, reason) {
                              setState(() {
                                currIndex = index;
                              });
                            }),
                        items: List.generate(notifier.banners?.length ?? 0, (index){
                          final data = notifier.banners?[index];
                          return GestureDetector(
                            onTap: () async {
                              try {
                                final uri = Uri.parse(data?.url ?? '');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  throw "Could not launch $uri";
                                }
                                // can't launch url, there is some error
                              } catch (e) {
                                System().goToWebScreen(data?.url ?? '', isPop: true);
                              }
                            },
                            child: Image.network(
                              data?.image ?? '',
                              fit: BoxFit.fill,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Container(
                                      height: context.getHeight(),
                                      width: context.getWidth(),
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
                                }
                            ),
                          );
                        }),
                      );
                      // return PageView.builder(
                      //   controller: controller,
                      //   onPageChanged: (index) {
                      //     setState(() {
                      //       currIndex = index;
                      //     });
                      //   },
                      //   itemCount: notifier.banners?.length,
                      //   itemBuilder: (context, index) {
                      //     final data = notifier.banners?[index];
                      //     return GestureDetector(
                      //       onTap: () async {
                      //         try {
                      //           final uri = Uri.parse(data?.url ?? '');
                      //           if (await canLaunchUrl(uri)) {
                      //             await launchUrl(
                      //               uri,
                      //               mode: LaunchMode.externalApplication,
                      //             );
                      //           } else {
                      //             throw "Could not launch $uri";
                      //           }
                      //           // can't launch url, there is some error
                      //         } catch (e) {
                      //           System().goToWebScreen(data?.url ?? '', isPop: true);
                      //         }
                      //       },
                      //       child: Image.network(
                      //         data?.image ?? '',
                      //         fit: BoxFit.fill,
                      //       ),
                      //     );
                      //     return Image.network(
                      //       data?.image ?? '',
                      //       fit: BoxFit.fill,
                      //     );
                      //   },
                      // );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Builder(builder: (context) {
                    if (notifier.banners == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            notifier.banners?.length ?? 0,
                            (index) => dotWidget(index == currIndex)),
                      ),
                    );
                  }),
                )
              ],
                  );
                }),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: widget.layout)
        ],
      ),
    );
  }
}

Widget dotWidget(bool active) {
  if (active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 17,
      height: 10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.white),
    );
  } else {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white.withOpacity(0.5)),
    );
  }
}
