import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/pic_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/tag_label.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/enum.dart';
import '../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/constants/utils.dart';
import '../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../../ux/routing.dart';
import '../../../../../../constant/entities/like/notifier.dart';
import '../../../../../../constant/entities/report/notifier.dart';
import '../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../constant/widget/button_boost.dart';
import '../../../../../../constant/widget/custom_background_layer.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../../../../../../constant/widget/decorated_icon_widget.dart';
import '../../../../../../constant/widget/icon_ownership.dart';
import '../../../../../../constant/widget/jangakauan_status.dart';
import '../../../../../../constant/widget/music_status_page_widget.dart';
import '../../../../../../constant/widget/profile_component.dart';
import '../../../diary/playlist/widget/content_violation.dart';
import '../notifier.dart';
import '../widget/pic_tag_label.dart';
import 'loading_music_screen.dart';
import 'notifier.dart';

class SlidePicScreen extends StatefulWidget {
  ContentData data;
  TransformationController transformationController;
  Function resetZooming;
  int rootIndex;
  SlidePicScreen({Key? key, required this.data, required this.transformationController, required this.resetZooming, required this.rootIndex}) : super(key: key);

  @override
  State<SlidePicScreen> createState() => _SlidePicScreenState();
}

class _SlidePicScreenState extends State<SlidePicScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<SlidedPicDetailNotifier>(context);
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Stack(
      children: [
        // Background
        CustomBackgroundLayer(
          sigmaX: 30,
          sigmaY: 30,
          // thumbnail: picData.content[arguments].contentUrl,
          thumbnail: (widget.data.isApsara ?? false) ? widget.data.mediaThumbUri : widget.data.fullThumbPath,
        ),
        // Content
        (widget.data.reportedStatus == "BLURRED")
            ? Container()
            : PicPlaylishScreen(
                data: notifier.adsData,
                url: notifier.adsUrl,
                contentData: widget.data,
                transformationController: widget.transformationController,
              ),
        // Top action
        (widget.data.reportedStatus == "BLURRED")
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomTextButton(
                      onPressed: () {
                        widget.resetZooming();
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
                  ),
                ),
              )
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
                                widget.resetZooming();
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
                              onTapOnProfileImage: () => System().navigateToProfile(context, widget.data.email ?? ''),
                              spaceProfileAndId: eightPx,
                              featureType: FeatureType.pic,
                              username: widget.data.username,
                              isCelebrity: widget.data.privacy?.isCelebrity,
                              imageUrl: '${System().showUserPicture(widget.data.avatar?.mediaEndpoint)}',
                              createdAt: '${System().readTimestamp(
                                DateTime.parse(System().dateTimeRemoveT(widget.data.createdAt ?? '')).millisecondsSinceEpoch,
                                context,
                                fullCaption: true,
                              )}',
                            ),
                          ],
                        ),
                      ),
                      (widget.data.saleAmount ?? 0) > 0
                          ? const Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}sale.svg",
                                defaultColor: false,
                              ),
                            )
                          : const SizedBox(),
                      widget.data.email == SharedPreference().readStorage(SpKeys.email)
                          ? _buildButtonV2(
                              context: context,
                              iconData: '${AssetPath.vectorPath}more.svg',
                              function: () async {
                                notifier.preventMusic = true;
                                SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                await ShowBottomSheet().onShowOptionContent(
                                  context,
                                  contentData: widget.data,
                                  captionTitle: hyppePic,
                                  // storyController: widget.storyController,
                                  onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate(),
                                );

                                notifier.preventMusic = false;
                                SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                              },
                            )
                          : const SizedBox(),
                      widget.data.email != SharedPreference().readStorage(SpKeys.email)
                          ? _buildButtonV2(
                              context: context,
                              iconData: '${AssetPath.vectorPath}more.svg',
                              function: () => ShowBottomSheet.onReportContent(
                                context,
                                postData: widget.data,
                                adsData: null,
                                type: hyppePic,
                                onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate(),
                              ),
                            )
                          : const SizedBox(),
                      Visibility(
                        visible: (widget.data.saleAmount == 0 && (widget.data.certified ?? false)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: IconOwnership(correct: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        widget.data.reportedStatus == "BLURRED"
            ? SafeArea(
                child: SizedBox(
                width: SizeConfig.screenWidth,
                child: Consumer<TranslateNotifierV2>(
                  builder: (context, transnot, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppePic ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      widget.data.email == SharedPreference().readStorage(SpKeys.email)
                          ? GestureDetector(
                              onTap: () => Routing().move(Routes.appeal, argument: widget.data),
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                                  child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.read<ReportNotifier>().seeContent(context, widget.data, hyppePic);
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
        (widget.data.reportedStatus == "BLURRED")
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
                        sixteenPx,
                        Consumer<LikeNotifier>(
                          builder: (context, notifier, child) => widget.data.insight?.isloading ?? false
                              ? const SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: CircularProgressIndicator(
                                    color: kHyppePrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : _buildButtonV2(
                                  context: context,
                                  colorIcon: (widget.data.insight?.isPostLiked ?? false) ? kHyppePrimary : kHyppeLightButtonText,
                                  iconData: '${AssetPath.vectorPath}${(widget.data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                  function: () {
                                    print('ini l0000ike');
                                    notifier.likePost(context, widget.data);
                                  },
                                ),
                        ),
                        eightPx,
                        _buildButtonV2(
                          context: context,
                          iconData: '${AssetPath.vectorPath}comment.svg',
                          function: () {
                            ShowBottomSheet.onShowCommentV2(context, postID: widget.data.postID);
                          },
                        ),
                        eightPx,
                        _buildButtonV2(
                          context: context,
                          iconData: '${AssetPath.vectorPath}share.svg',
                          function: () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: widget.data),
                        ),
                        eightPx,
                        if ((widget.data.saleAmount ?? 0) > 0 && SharedPreference().readStorage(SpKeys.email) != widget.data.email)
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}cart.svg',
                            function: () async {
                              notifier.preventMusic = true;
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                              await ShowBottomSheet.onBuyContent(context, data: widget.data);
                              notifier.preventMusic = false;
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                            },
                          ),
                      ],
                    ),
                    (widget.data.tagPeople?.isNotEmpty ?? false) || widget.data.location != ''
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 0, top: 16),
                            child: Row(
                              children: [
                                widget.data.tagPeople?.isNotEmpty ?? false
                                    ? PicTagLabel(
                                        icon: 'user',
                                        label: '${widget.data.tagPeople?.length} people',
                                        function: () {
                                          context.read<PicDetailNotifier>().showUserTag(context, widget.data.tagPeople, widget.data.postID);
                                        },
                                        width: 18,
                                      )
                                    : const SizedBox(),
                                widget.data.location == '' || widget.data.location == null
                                    ? const SizedBox()
                                    : PicTagLabel(
                                        icon: 'maptag-white',
                                        label: "${widget.data.location}",
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
                            CustomDescContent(
                              desc: "${widget.data.description}",
                              trimLines: 5,
                              textAlign: TextAlign.start,
                              seeLess: translate.seeLess,
                              seeMore: translate.seeMoreContent,
                              normStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppeLightButtonText),
                              hrefStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppePrimary),
                              expandStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                            ),
                            if (widget.data.music?.musicTitle != null && (widget.data.apsaraId ?? '').isNotEmpty)
                              notifier.preventMusic
                                  ? const SizedBox.shrink()
                                  : notifier.isLoadMusic
                                      ? LoadingMusicScreen(
                                          music: widget.data.music!,
                                          index: widget.rootIndex,
                                        )
                                      : MusicStatusPage(
                                          music: widget.data.music!,
                                          urlMusic: notifier.urlMusic,
                                        )
                          ],
                        )),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    twentyPx,
                    (widget.data.reportedStatus != 'OWNED' && widget.data.reportedStatus != 'BLURRED' && widget.data.reportedStatus2 != 'BLURRED') &&
                            (widget.data.boosted.isEmpty) &&
                            widget.data.email == SharedPreference().readStorage(SpKeys.email)
                        ? ButtonBoost(
                            contentData: widget.data,
                            startState: () {
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                              notifier.preventMusic = true;
                            },
                            afterState: () {
                              notifier.preventMusic = false;
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                            },
                          )
                        : Container(),
                    (widget.data.boosted.isNotEmpty) && widget.data.email == SharedPreference().readStorage(SpKeys.email)
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: JangkaunStatus(
                              jangkauan: widget.data.boostJangkauan ?? 0,
                              isDiary: true,
                            ),
                          )
                        : Container(),
                    widget.data.email == SharedPreference().readStorage(SpKeys.email) && (widget.data.reportedStatus == 'OWNED')
                        ? ContentViolationWidget(
                            data: widget.data,
                            text: translate.thisHyppePicisSubjectToModeration ?? '',
                          )
                        : Container(),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildButtonV2({
    Color? colorIcon,
    required String iconData,
    required Function function,
    required BuildContext context,
  }) {
    return SizedBox(
      width: 30,
      child: CustomTextButton(
        onPressed: function,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        child: CustomIconWidget(
          defaultColor: false,
          iconData: iconData,
          color: colorIcon ?? kHyppeLightButtonText,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
