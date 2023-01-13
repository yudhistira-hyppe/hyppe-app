import 'dart:async';

import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
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

class _SlidedPicDetailState extends State<SlidedPicDetail> with AfterFirstLayoutMixin {
  final _notifier = SlidedPicDetailNotifier();
  late PageController _pageController;
  late PageController _mainPageController;
  final TransformationController transformationController = TransformationController();

  void resetZooming() {
    if (transformationController.value != Matrix4.identity()) {
      transformationController.value = Matrix4.identity();
      setState(() {});
    }
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.arguments.index.toInt());
    _pageController.addListener(() => _notifier.currentPage = _pageController.page);
    _mainPageController = PageController(initialPage: 0);
    super.initState();

  }

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
    final notif = context.read<SlidedPicDetailNotifier>();
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
          resetZooming();
          return Future.value(true);
        },
        child: GestureDetector(
          onDoubleTap: () => resetZooming(),
          child: Scaffold(body: Consumer<SlidedPicDetailNotifier>(builder: (context, notifier, child) {
            return notifier.listData != null
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: notifier.listData?.length ?? 0,
                    onPageChanged: (value) async {
                      notifier.nextPlaylistPic(context, value);
                      notifier.initAdsVideo(context);
                      print('onPageChanged Image : $value : ${notifier.listData?.length}');
                      print('check index hit : my index $value');
                      notifier.currentIndex = value;
                      notifier.urlMusic = '';
                      notifier.isLoadMusic = true;
                      final detailNotifier = context.read<PicDetailNotifier>();
                      detailNotifier.isLoadMusic = true;
                      detailNotifier.urlMusic = '';
                    },
                    itemBuilder: (context, indexRoot) {
                      return PageView.builder(
                          controller: _mainPageController,
                          itemCount: 2,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (verticalIndex) {
                            // notifier.urlMusic = '';
                            notifier.mainIndex = verticalIndex;

                            if(verticalIndex == 0){
                              notifier.isLoadMusic = true;
                            }else{
                              final detailNotifier = context.read<PicDetailNotifier>();
                              detailNotifier.isLoadMusic = true;
                              detailNotifier.urlMusic = '';
                            }

                          },
                          itemBuilder: (context, indexPage) {
                            final data = notifier.listData?[indexRoot];
                            if (data != null) {
                              print('apsaraMusic Slides : ${data.music?.apsaraMusic}');
                              return indexPage == 0
                                  ? SlidePicScreen(
                                      data: data,
                                      transformationController: transformationController,
                                      resetZooming: resetZooming,
                                      rootIndex: indexRoot,
                                      mainIndex: indexPage,
                                    )
                                  : PicDetailScreen(arguments: PicDetailScreenArgument(picData: data));
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
