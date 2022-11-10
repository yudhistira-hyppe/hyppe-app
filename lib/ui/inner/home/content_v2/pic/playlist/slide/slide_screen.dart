import 'dart:async';

import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/pic_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:readmore/readmore.dart';

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
          child: Scaffold(body: Consumer<SlidedPicDetailNotifier>(builder: (context, value, child) {
            return _notifier.listData != null
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _notifier.listData?.length ?? 0,
                    onPageChanged: (value) async {
                      await _notifier.initAdsVideo(context);
                    },
                    itemBuilder: (context, indexRoot) {
                      final data = _notifier.listData;
                      if (data != null) {}
                      return PageView.builder(
                          controller: _mainPageController,
                          itemCount: 2,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, indexPage) {
                            final data = _notifier.listData?[indexRoot];
                            if (data != null) {
                              return indexPage == 0
                                  ? Stack(
                                      children: [
                                        // Background
                                        CustomBackgroundLayer(
                                          sigmaX: 30,
                                          sigmaY: 30,
                                          // thumbnail: picData.content[arguments].contentUrl,
                                          thumbnail: (data.isApsara ?? false) ? data.mediaThumbUri : data.fullThumbPath,
                                        ),
                                        // Content
                                        data.isReport ?? false
                                            ? Container()
                                            : PicPlaylishScreen(data: value.adsData, url: value.adsUrl, contentData: data, transformationController: transformationController),
                                        // Top action
                                        data.isReport ?? false
                                            ? Container()
                                            : SafeArea(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            CustomTextButton(
                                                              onPressed: () {
                                                                resetZooming();
                                                                Routing().moveBack();
                                                              },
                                                              style: ButtonStyle(
                                                                alignment: Alignment.topCenter,
                                                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                                              ),
                                                              child: const DecoratedIconWidget(
                                                                Icons.arrow_back_ios,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            ProfileComponent(
                                                              isDetail: true,
                                                              show: true,
                                                              following: true,
                                                              onFollow: () {},
                                                              haveStory: false,
                                                              onTapOnProfileImage: () => System().navigateToProfile(context, data.email ?? ''),
                                                              spaceProfileAndId: eightPx,
                                                              featureType: FeatureType.pic,
                                                              username: data.username,
                                                              isCelebrity: data.privacy?.isCelebrity,
                                                              imageUrl: '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                                                              createdAt: '${System().readTimestamp(
                                                                DateTime.parse(data.createdAt ?? '').millisecondsSinceEpoch,
                                                                context,
                                                                fullCaption: true,
                                                              )}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      (data.saleAmount ?? 0) > 0
                                                          ? const Padding(
                                                              padding: EdgeInsets.only(top: 10.0),
                                                              child: CustomIconWidget(
                                                                iconData: "${AssetPath.vectorPath}sale.svg",
                                                                defaultColor: false,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      data.email == SharedPreference().readStorage(SpKeys.email)
                                                          ? _buildButtonV2(
                                                              context: context,
                                                              iconData: '${AssetPath.vectorPath}more.svg',
                                                              function: () => ShowBottomSheet.onShowOptionContent(
                                                                context,
                                                                contentData: data,
                                                                captionTitle: hyppePic,
                                                                // storyController: widget.storyController,
                                                                onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate(),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      data.email != SharedPreference().readStorage(SpKeys.email)
                                                          ? _buildButtonV2(
                                                              context: context,
                                                              iconData: '${AssetPath.vectorPath}more.svg',
                                                              function: () => ShowBottomSheet.onReportContent(
                                                                context,
                                                                postData: data,
                                                                adsData: null,
                                                                type: hyppePic,
                                                                onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate(),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        data.isReport ?? false
                                            ? SafeArea(
                                                child: SizedBox(
                                                width: SizeConfig.screenWidth,
                                                child: Consumer<TranslateNotifierV2>(
                                                  builder: (context, transnot, child) => Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      const Spacer(),
                                                      const CustomIconWidget(
                                                        iconData: "${AssetPath.vectorPath}valid-invert.svg",
                                                        defaultColor: false,
                                                        height: 30,
                                                      ),
                                                      Text(transnot.translate.reportReceived!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                      Text(transnot.translate.yourReportWillbeHandledImmediately!,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                          )),
                                                      const Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          context.read<ReportNotifier>().seeContent(context, data, hyppePic);
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
                                                            "${transnot.translate.see} HyppePic",
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
                                        // Bottom action
                                        data.isReport ?? false
                                            ? Container()
                                            : Align(
                                                alignment: Alignment.bottomCenter,
                                                // alignment: const Alignment(0.0, 0.9),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Consumer<LikeNotifier>(
                                                          builder: (context, notifier, child) => _buildButtonV2(
                                                            context: context,
                                                            colorIcon: (data.insight?.isPostLiked ?? false) ? kHyppePrimary : kHyppeLightButtonText,
                                                            iconData: '${AssetPath.vectorPath}${(data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                            function: () => notifier.likePost(context, data),
                                                          ),
                                                        ),
                                                        _buildButtonV2(
                                                          context: context,
                                                          iconData: '${AssetPath.vectorPath}comment.svg',
                                                          function: _notifier.listData?[indexRoot] != null
                                                              ? () {
                                                                  ShowBottomSheet.onShowCommentV2(context, postID: data.postID);
                                                                }
                                                              : () {},
                                                        ),
                                                        _buildButtonV2(
                                                          context: context,
                                                          iconData: '${AssetPath.vectorPath}share.svg',
                                                          function: _notifier.listData?[indexRoot] != null ? () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: data) : () {},
                                                        ),
                                                        if ((data.saleAmount ?? 0) > 0 && SharedPreference().readStorage(SpKeys.email) != data.email)
                                                          _buildButtonV2(
                                                            context: context,
                                                            iconData: '${AssetPath.vectorPath}cart.svg',
                                                            function: () => ShowBottomSheet.onBuyContent(context, data: data),
                                                          ),
                                                      ],
                                                    ),
                                                    data.tagPeople?.isNotEmpty ?? false || data.location != ''
                                                        ? Padding(
                                                            padding: const EdgeInsets.only(left: 16, bottom: 26, top: 16),
                                                            child: Row(
                                                              children: [
                                                                data.tagPeople?.isNotEmpty ?? false
                                                                    ? PicTagLabel(
                                                                        icon: 'user',
                                                                        label: '${data.tagPeople?.length} people',
                                                                        function: () {
                                                                          context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID);
                                                                        },
                                                                        width: 18,
                                                                      )
                                                                    : const SizedBox(),
                                                                data.location == '' || data.location == null
                                                                    ? const SizedBox()
                                                                    : PicTagLabel(
                                                                        icon: 'maptag-white',
                                                                        label: "${data.location}",
                                                                        function: () {},
                                                                        width: 13,
                                                                      ),
                                                              ],
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    Padding(
                                                      child: Container(
                                                        padding: const EdgeInsets.all(2),
                                                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                                                        // color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),

                                                        child: SingleChildScrollView(
                                                            child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            ReadMoreText(
                                                              "${data.description}",
                                                              // "${data?.description} ${data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                                                              trimLines: 5,
                                                              trimMode: TrimMode.Line,
                                                              textAlign: TextAlign.left,
                                                              trimExpandedText: 'Show less',
                                                              trimCollapsedText: 'Show more',
                                                              colorClickableText: Theme.of(context).colorScheme.primaryContainer,
                                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppeLightButtonText),
                                                              moreStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                                              lessStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                                            ),
                                                          ],
                                                        )),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                    ),
                                                    twentyPx,
                                                    ContentViolationWidget(data: data)
                                                  ],
                                                ),
                                              ),
                                      ],
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

  Widget _buildButtonV2({
    Color? colorIcon,
    required String iconData,
    required Function function,
    required BuildContext context,
  }) {
    return CustomTextButton(
      onPressed: function,
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      child: CustomIconWidget(
        defaultColor: false,
        iconData: iconData,
        color: colorIcon ?? kHyppeLightButtonText,
      ),
    );
  }
}
