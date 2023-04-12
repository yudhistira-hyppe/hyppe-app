import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/slide_pic_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../constant/widget/custom_shimmer.dart';
import '../../../diary/playlist/widget/right_items_shimmer.dart';
import '../screen.dart';
import 'notifier.dart';

class SlidedPicDetail extends StatefulWidget {
  final SlidedPicDetailScreenArgument arguments;

  const SlidedPicDetail({Key? key, required this.arguments}) : super(key: key);

  @override
  State<SlidedPicDetail> createState() => _SlidedPicDetailState();
}

class _SlidedPicDetailState extends State<SlidedPicDetail>
    with AfterFirstLayoutMixin, WidgetsBindingObserver {
  final _notifier = SlidedPicDetailNotifier();
  late PageController _pageController;
  late PageController _mainPageController;
  bool isOnPageTurning = false;
  // final TransformationController transformationController = TransformationController();

  // void resetZooming() {
  //   if (transformationController.value != Matrix4.identity()) {
  //     transformationController.value = Matrix4.identity();
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SlidedPicDetail');
    WidgetsBinding.instance.addObserver(this);

    _notifier.setMainIndex(0);
    _pageController =
        PageController(initialPage: widget.arguments.index.toInt(), viewportFraction: 1);
    _pageController.addListener(() {
      if (isOnPageTurning &&
          _pageController.page == _pageController.page?.roundToDouble()) {
        _notifier.currentPage = _pageController.page?.toInt();
        setState(() {
          // current = _controller.page.toInt();
          isOnPageTurning = false;
        });
      } else if (!isOnPageTurning &&
          _notifier.currentPage?.toDouble() != _pageController.page) {
        if (((_notifier.currentPage?.toDouble() ?? 0) -
                    (_pageController.page ?? 0))
                .abs() >
            0.1) {
          setState(() {
            isOnPageTurning = true;
          });
        }
      }
    });
    _mainPageController = PageController(initialPage: 0);
    _mainPageController.addListener(() {
      if (isOnPageTurning &&
          _mainPageController.page ==
              _mainPageController.page?.roundToDouble()) {
        _notifier.currentPage = _mainPageController.page?.toInt();
        setState(() {
          // current = _controller.page.toInt();
          isOnPageTurning = false;
        });
      } else if (!isOnPageTurning &&
          _notifier.currentPage?.toDouble() != _mainPageController.page) {
        if (((_notifier.currentPage?.toDouble() ?? 0) -
                    (_mainPageController.page ?? 0))
                .abs() >
            0.1) {
          setState(() {
            isOnPageTurning = true;
          });
        }
      }
    });


    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Show custom alert message when the app is resumed
      print("capture ter capture");
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
    final notif = context.read<SlidedPicDetailNotifier>();
    notif.isZooming = true;
    notif.currentIndex = -1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SlidedPicDetailNotifier>(
      create: (context) => _notifier,
      child: WillPopScope(
        onWillPop: () {
          System().disposeBlock();
          // resetZooming();
          return Future.value(true);
        },
        child: GestureDetector(
          // onDoubleTap: () => resetZooming(),
          onScaleStart: (details) {
            print('onScaleStart Detail: $details');
            final notifier = context.read<SlidedPicDetailNotifier>();
            notifier.isZooming = true;
          },
          onScaleUpdate: (details) {
            print('onScaleUpdate Detail: $details');
            final notifier = context.read<SlidedPicDetailNotifier>();
            notifier.isZooming = true;
          },
          onScaleEnd: (details) {
            print('onScaleEnd Detail: $details');
            final notifier = context.read<SlidedPicDetailNotifier>();
            notifier.isZooming = false;
          },
          // onPanUpdate: (detail){
          //   final notifier = context.read<SlidedPicDetailNotifier>();
          //   notifier.isZooming = false;
          // },
          child: Scaffold(body: Consumer<SlidedPicDetailNotifier>(
              builder: (context, notifier, child) {
            return notifier.listData != null
                ? PageView.builder(
                    physics: notifier.isZooming
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    controller: _pageController,
                    itemCount: notifier.listData?.length ?? 0,
                    onPageChanged: (value) async {
                      notifier.nextPlaylistPic(context, value);
                      // notifier.initAdsVideo(context);
                      final detailNotifier = context.read<PicDetailNotifier>();
                      print(
                          'onPageChanged Image : $value : ${notifier.listData?.length}');
                      print(
                          'check index hit : my index  ${notifier.currentIndex}: $value');
                      notifier.currentIndex = value;
                      // notifier.isLoadMusic = true;
                      notifier.mainIndex = 0;
                      // detailNotifier.isLoadMusic = true;
                    },
                    itemBuilder: (context, indexRoot) {
                      return PageView.builder(
                          physics: notifier.isZooming
                              ? const NeverScrollableScrollPhysics()
                              : const ClampingScrollPhysics(),
                          controller: _mainPageController,
                          itemCount: 2,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (verticalIndex) {
                            // notifier.urlMusic = '';
                            final detailNotifier =
                                context.read<PicDetailNotifier>();
                            notifier.mainIndex = verticalIndex;
                            notifier.isLoadMusic = true;
                            detailNotifier.isLoadMusic = true;
                            if (verticalIndex != 0) {
                              notifier.isLoadMusic = true;
                            } else {
                              final detailNotifier =
                                  context.read<PicDetailNotifier>();
                              detailNotifier.isLoadMusic = true;
                            }
                          },
                          itemBuilder: (context, indexPage) {
                            final data = notifier.listData?[indexRoot];
                            if (data != null) {
                              print(
                                  'apsaraMusic Slides : ${data.music?.apsaraMusic}');
                              return indexPage == 0
                                  ? SlidePicScreen(
                                      data: notifier.listData?[indexRoot] ??
                                          ContentData(),
                                      // transformationController: transformationController,
                                      // resetZooming: resetZooming,
                                      rootIndex: indexRoot,
                                      isOnPageTurning: isOnPageTurning,
                                    )
                                  : PicDetailScreen(
                                      arguments: PicDetailScreenArgument(
                                        picData: data,
                                      ),
                                      isOnPageTurning: isOnPageTurning,
                                    );
                            } else {
                              return Stack(
                                children: [
                                  const CustomShimmer(),
                                  RightItemsShimmer(),
                                ],
                              );
                            }
                          });
                    })
                : Stack(
                    children: [
                      const CustomShimmer(),
                      RightItemsShimmer(),
                    ],
                  );
          })),
        ),
      ),
    );
  }
}
