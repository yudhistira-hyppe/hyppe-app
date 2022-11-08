import 'dart:async';

import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
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
                      return PageView.builder(
                          controller: _mainPageController,
                          itemCount: 2,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, indexPage) => indexPage == 0
                              ? Stack(
                                  children: [
                                    // Background
                                    CustomBackgroundLayer(
                                      sigmaX: 30,
                                      sigmaY: 30,
                                      // thumbnail: picData!.content[arguments].contentUrl,
                                      thumbnail: (_notifier.listData![indexRoot].isApsara ?? false) ? _notifier.listData![indexRoot].mediaThumbUri : _notifier.listData![indexRoot].fullThumbPath,
                                    ),
                                    // Content
                                    _notifier.listData![indexRoot].isReport!
                                        ? Container()
                                        : PicPlaylishScreen(data: value.adsData, url: value.adsUrl, contentData: _notifier.listData![indexRoot], transformationController: transformationController),
                                    // Top action
                                    SafeArea(
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
                                                  _notifier.listData![indexRoot].isReport!
                                                      ? Container()
                                                      : ProfileComponent(
                                                          isDetail: true,
                                                          show: true,
                                                          following: true,
                                                          onFollow: () {},
                                                          haveStory: false,
                                                          onTapOnProfileImage: () => System().navigateToProfile(context, _notifier.listData![indexRoot].email!),
                                                          spaceProfileAndId: eightPx,
                                                          featureType: FeatureType.pic,
                                                          username: _notifier.listData![indexRoot].username,
                                                          isCelebrity: _notifier.listData![indexRoot].privacy?.isCelebrity,
                                                          imageUrl: '${System().showUserPicture(_notifier.listData![indexRoot].avatar?.mediaEndpoint)}',
                                                          createdAt: '${System().readTimestamp(
                                                            DateTime.parse(_notifier.listData![indexRoot].createdAt!).millisecondsSinceEpoch,
                                                            context,
                                                            fullCaption: true,
                                                          )}',
                                                        ),
                                                ],
                                              ),
                                            ),
                                            _notifier.listData![indexRoot].saleAmount! > 0
                                                ? const Padding(
                                                    padding: EdgeInsets.only(top: 10.0),
                                                    child: CustomIconWidget(
                                                      iconData: "${AssetPath.vectorPath}sale.svg",
                                                      defaultColor: false,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            _notifier.listData![indexRoot].email == SharedPreference().readStorage(SpKeys.email)
                                                ? _buildButtonV2(
                                                    context: context,
                                                    iconData: '${AssetPath.vectorPath}more.svg',
                                                    function: () => ShowBottomSheet.onShowOptionContent(
                                                      context,
                                                      contentData: _notifier.listData![indexRoot],
                                                      captionTitle: hyppePic,
                                                      // storyController: widget.storyController,
                                                      onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            _notifier.listData![indexRoot].isReport!
                                                ? Container()
                                                : _notifier.listData![indexRoot].email != SharedPreference().readStorage(SpKeys.email)
                                                    ? _buildButtonV2(
                                                        context: context,
                                                        iconData: '${AssetPath.vectorPath}more.svg',
                                                        function: () => ShowBottomSheet.onReportContent(context, _notifier.listData![indexRoot], hyppePic,
                                                            onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate()),
                                                      )
                                                    : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),

                                    _notifier.listData![indexRoot].isReport!
                                        ? SafeArea(
                                            child: SizedBox(
                                            width: SizeConfig.screenWidth,
                                            child: Consumer<TranslateNotifierV2>(
                                              builder: (context, transnot, child) => Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Spacer(),
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
                                                  Spacer(),
                                                  Container(
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
                                                  thirtyTwoPx,
                                                ],
                                              ),
                                            ),
                                          ))
                                        : Container(),

                                    // Bottom action
                                    _notifier.listData![indexRoot].isReport!
                                        ? Container()
                                        : Align(
                                            alignment: const Alignment(-1.0, 0.9),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Consumer<LikeNotifier>(
                                                      builder: (context, notifier, child) => _buildButtonV2(
                                                        context: context,
                                                        colorIcon: (_notifier.listData![indexRoot].insight?.isPostLiked ?? false) ? kHyppePrimary : kHyppeLightButtonText,
                                                        iconData: '${AssetPath.vectorPath}${(_notifier.listData![indexRoot].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                        function: () => notifier.likePost(context, _notifier.listData![indexRoot]),
                                                      ),
                                                    ),
                                                    _buildButtonV2(
                                                      context: context,
                                                      iconData: '${AssetPath.vectorPath}comment.svg',
                                                      function: _notifier.listData?[indexRoot] != null
                                                          ? () {
                                                              ShowBottomSheet.onShowCommentV2(context, postID: _notifier.listData![indexRoot].postID);
                                                            }
                                                          : () {},
                                                    ),
                                                    _buildButtonV2(
                                                      context: context,
                                                      iconData: '${AssetPath.vectorPath}share.svg',
                                                      function: _notifier.listData?[indexRoot] != null
                                                          ? () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: _notifier.listData![indexRoot])
                                                          : () {},
                                                    ),
                                                    if (_notifier.listData![indexRoot].saleAmount! > 0 && SharedPreference().readStorage(SpKeys.email) != _notifier.listData![indexRoot].email)
                                                      _buildButtonV2(
                                                        context: context,
                                                        iconData: '${AssetPath.vectorPath}cart.svg',
                                                        function: () => ShowBottomSheet.onBuyContent(context, data: _notifier.listData![indexRoot]),
                                                      ),
                                                  ],
                                                ),
                                                _notifier.listData![indexRoot].tagPeople!.isNotEmpty || _notifier.listData![indexRoot].location != ''
                                                    ? Padding(
                                                        padding: const EdgeInsets.only(left: 16, bottom: 26, top: 16),
                                                        child: Row(
                                                          children: [
                                                            _notifier.listData![indexRoot].tagPeople!.isNotEmpty
                                                                ? PicTagLabel(
                                                                    icon: 'user',
                                                                    label: '${_notifier.listData![indexRoot].tagPeople!.length} people',
                                                                    function: () {
                                                                      context
                                                                          .read<PicDetailNotifier>()
                                                                          .showUserTag(context, _notifier.listData![indexRoot].tagPeople, _notifier.listData![indexRoot].postID);
                                                                    },
                                                                    width: 18,
                                                                  )
                                                                : const SizedBox(),
                                                            _notifier.listData![indexRoot].location == '' || _notifier.listData![indexRoot].location == null
                                                                ? const SizedBox()
                                                                : PicTagLabel(
                                                                    icon: 'maptag-white',
                                                                    label: "${_notifier.listData![indexRoot].location}",
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
                                                          "${_notifier.listData![indexRoot].description}",
                                                          // "${_notifier.listData![indexRoot]?.description} ${_notifier.listData![indexRoot]?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                                                          trimLines: 5,
                                                          trimMode: TrimMode.Line,
                                                          textAlign: TextAlign.left,
                                                          trimExpandedText: 'Show less',
                                                          trimCollapsedText: 'Show more',
                                                          colorClickableText: Theme.of(context).colorScheme.primaryContainer,
                                                          style: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                                                          moreStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                                          lessStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                                        ),
                                                      ],
                                                    )),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                )
                                              ],
                                            ),
                                          ),
                                  ],
                                )
                              : PicDetailScreen(arguments: PicDetailScreenArgument(picData: _notifier.listData![indexRoot])));
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
