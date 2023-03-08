// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/diary_player.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/test.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_dynamic_link_error.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/diary_page/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items_shimmer.dart';

class HyppePlaylistDiaries extends StatefulWidget {
  final DiaryDetailScreenArgument argument;

  const HyppePlaylistDiaries({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  _HyppePlaylistDiariesState createState() => _HyppePlaylistDiariesState();
}

class _HyppePlaylistDiariesState extends State<HyppePlaylistDiaries> with AfterFirstLayoutMixin {
  late PageController _pageController;
  final notifier = DiariesPlaylistNotifier();

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.argument.index.toInt());
    _pageController.addListener(() => notifier.currentPage = _pageController.page);
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    notifier.initState(context, widget.argument);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DiariesPlaylistNotifier>(
      create: (context) => notifier,
      child: WillPopScope(
        onWillPop: () async {
          notifier.onWillPop(mounted);
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Consumer<DiariesPlaylistNotifier>(
              builder: (context, value, child) => notifier.listData != null
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: notifier.listData?.length ?? 0,
                      onPageChanged: (index) async {
                        notifier.nextPlaylistDiary(context, index);
                      },
                      itemBuilder: (context, rootIndex) {
                        if (notifier.listData?.isNotEmpty ?? false) {
                          if (notifier.currentPage?.floor() == rootIndex) {
                            double value = (notifier.currentPage ?? 0) - rootIndex;
                            double degValue = notifier.degreeToRadian(value * 90);
                            // return DiaryPlayerPage(
                            //   data: notifier.listData?[rootIndex],
                            // );
                            return DiaryPage(
                              // function: () => notifier.onNextPage(context, _pageController, widget.arguments),
                              // arguments: widget.argument,
                              data: notifier.listData?[rootIndex],
                              controller: _pageController,
                              total: notifier.listData?.length,
                              function: () {
                                notifier.onNextPage(
                                  context: context,
                                  data: notifier.listData?[rootIndex] ?? ContentData(),
                                  mounted: mounted,
                                );
                              },
                              isScrolling: _pageController.position.activity?.isScrolling,
                            );
                          } else if ((notifier.currentPage?.floor() ?? 0) + 1 == rootIndex) {
                            double value = (notifier.currentPage ?? 0) - rootIndex;
                            double degValue = notifier.degreeToRadian(value * 90);

                            // return DiaryPlayerPage(data: notifier.listData?[rootIndex]);
                            // return DiaryPage(
                            //   // function: () => notifier.onNextPage(context, _pageController, widget.arguments),
                            //   // arguments: widget.argument,
                            //   data: notifier.listData?[rootIndex],
                            //   controller: _pageController,
                            //   function: () => notifier.onNextPage(
                            //     context: context,
                            //     data: notifier.listData?[rootIndex] ?? ContentData(),
                            //     mounted: mounted,
                            //   ),
                            //   isScrolling: _pageController.position.activity?.isScrolling,
                            // );
                          }
                          // return DiaryPlayerPage(data: notifier.listData?[rootIndex]);
                          // return DiaryPage(
                          //   // function: () => notifier.onNextPage(context, _pageController, widget.arguments),
                          //   // arguments: widget.argument,
                          //   data: notifier.listData?[rootIndex],
                          //   controller: _pageController,
                          //   function: () => notifier.onNextPage(
                          //     context: context,
                          //     data: notifier.listData?[rootIndex] ?? ContentData(),
                          //     mounted: mounted,
                          //   ),
                          //   isScrolling: _pageController.position.activity?.isScrolling,
                          // );
                        }
                        return Center(
                          child: GestureDetector(
                            // onTap: () => notifier.onWillPop(context, widget.arguments),
                            onTap: () => notifier.onWillPop(mounted),
                            child: const CustomDynamicLinkErrorWidget(),
                          ),
                        );
                      },
                    )
                  : Stack(
                      children: [
                        const CustomShimmer(),
                        RightItemsShimmer(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
