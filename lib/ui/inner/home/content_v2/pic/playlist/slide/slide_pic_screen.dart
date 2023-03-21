import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/pic_screen.dart';
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

class _SlidePicScreenState extends State<SlidePicScreen> with AfterFirstLayoutMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SlidePicScreen');
    print('pindah screen ${widget.data.certified ?? false}');
    if (widget.data.certified ?? false) {
      print('pindah screen2 ${widget.data.certified ?? false}');
      System().block(context);
    } else {
      System().disposeBlock();
    }
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SlidedPicDetailNotifier>();
    notifier.initDetailPost(context, widget.data.postID ?? '');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<SlidedPicDetailNotifier>(context);
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    final data = notifier.savedData ?? widget.data;
    return Stack(
      children: [
        // Background
        CustomBackgroundLayer(
          sigmaX: 30,
          sigmaY: 30,
          // thumbnail: picData.content[arguments].contentUrl,
          thumbnail: (data.isApsara ?? false) ? (data.mediaThumbUri ?? (data.media?.imageInfo?[0].url ?? '')) : data.fullThumbPath,
        ),
        // Content
        (data.reportedStatus == "BLURRED")
            ? Container()
            : PicPlaylishScreen(
                data: notifier.adsData,
                url: notifier.adsUrl,
                contentData: data,
                transformationController: widget.transformationController,
              ),
        // Top action
        (data.reportedStatus == "BLURRED")
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomTextButton(
                      onPressed: () {
                        widget.resetZooming();
                        System().disposeBlock();
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
                                System().disposeBlock();
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
                            // Text("${data.isShared}"),
                            ProfileComponent(
                              isDetail: true,
                              show: true,
                              following: true,
                              onFollow: () {},
                              haveStory: false,
                              onTapOnProfileImage: () => System().navigateToProfile(context, data.email ?? ''),
                              spaceProfileAndId: eightPx,
                              featureType: FeatureType.pic,
                              username: (data.username?.isNotEmpty ?? false) ? data.username : notifier.savedData?.username,
                              isCelebrity: data.privacy?.isCelebrity,
                              imageUrl:
                                  '${System().showUserPicture((data.avatar?.mediaEndpoint?.isNotEmpty ?? false) ? data.avatar?.mediaEndpoint : (notifier.savedData?.avatar?.mediaEndpoint ?? ''))}',
                              createdAt: '${System().readTimestamp(
                                DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? '')).millisecondsSinceEpoch,
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
                                height: 22,
                                defaultColor: false,
                              ),
                            )
                          : const SizedBox(),
                      data.email == SharedPreference().readStorage(SpKeys.email)
                          ? _buildButtonV2(
                              context: context,
                              iconData: '${AssetPath.vectorPath}more.svg',
                              function: () async {
                                notifier.preventMusic = true;
                                SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                await ShowBottomSheet().onShowOptionContent(
                                  context,
                                  contentData: data,
                                  captionTitle: hyppePic, isShare: data.isShared,
                                  // storyController: widget.storyController,
                                  onUpdate: () => context.read<SlidedPicDetailNotifier>().onUpdate(),
                                );
                                notifier.preventMusic = false;
                                SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                              },
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
                      Visibility(
                        visible: (data.saleAmount == 0 && (data.certified ?? false)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: IconOwnership(correct: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        data.reportedStatus == "BLURRED"
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
                      data.email == SharedPreference().readStorage(SpKeys.email)
                          ? GestureDetector(
                              onTap: () => Routing().move(Routes.appeal, argument: data),
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
                          setState(() {
                            data.reportedStatus = '';
                          });
                          context.read<ReportNotifier>().seeContent(context, data, hyppePic);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          margin: const EdgeInsets.all(8),
                          width: SizeConfig.screenWidth,
                          decoration: const BoxDecoration(
                            color: Colors.red,
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
        (data.reportedStatus == "BLURRED")
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
                          builder: (context, notifier, child) => data.insight?.isloading ?? false
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
                                  colorIcon: (data.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeLightButtonText,
                                  iconData: '${AssetPath.vectorPath}${(data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                  function: () {
                                    print('ini l0000ike');
                                    notifier.likePost(context, data);
                                  },
                                ),
                        ),
                        eightPx,
                        if ((data.allowComments ?? true))
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}comment.svg',
                            function: () {
                              ShowBottomSheet.onShowCommentV2(context, postID: data.postID);
                            },
                          ),
                        eightPx,
                        if ((data.isShared ?? true) && data.visibility == 'PUBLIC')
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}share.svg',
                            function: () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: data),
                          ),
                        eightPx,
                        if ((data.saleAmount ?? 0) > 0 && SharedPreference().readStorage(SpKeys.email) != data.email)
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}cart.svg',
                            function: () async {
                              notifier.preventMusic = true;
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                              await ShowBottomSheet.onBuyContent(context, data: data);
                              notifier.preventMusic = false;
                              SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                            },
                          ),
                      ],
                    ),
                    (data.tagPeople?.isNotEmpty ?? false) || data.location != ''
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 0, top: 16),
                            child: Row(
                              children: [
                                data.tagPeople?.isNotEmpty ?? false
                                    ? PicTagLabel(
                                        icon: 'tag_people',
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
                            CustomDescContent(
                              callback: (value) {
                                globalAudioPlayer?.pause();
                              },
                              desc: "${data.description}",
                              trimLines: 5,
                              textAlign: TextAlign.start,
                              seeLess: ' ${translate.seeLess}',
                              seeMore: ' ${translate.seeMoreContent}',
                              normStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppeLightButtonText),
                              hrefStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppePrimary),
                              expandStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            if (data.music?.musicTitle != null && (data.apsaraId ?? '').isNotEmpty)
                              notifier.preventMusic
                                  ? const SizedBox.shrink()
                                  : notifier.isLoadMusic
                                      ? LoadingMusicScreen(
                                          music: data.music!,
                                          index: widget.rootIndex,
                                        )
                                      : Builder(builder: (context) {
                                          final musicPost = notifier.urlMusic;
                                          if (musicPost.isNotEmpty) {
                                            return MusicStatusPage(
                                              music: data.music!,
                                              urlMusic: notifier.urlMusic,
                                            );
                                          } else {
                                            return LoadingMusicScreen(
                                              music: data.music!,
                                              index: widget.rootIndex,
                                            );
                                          }
                                        })
                          ],
                        )),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    twentyPx,
                    (data.reportedStatus != 'OWNED' && data.reportedStatus != 'BLURRED' && data.reportedStatus2 != 'BLURRED') &&
                            (data.boosted.isEmpty) &&
                            data.email == SharedPreference().readStorage(SpKeys.email)
                        ? ButtonBoost(
                            contentData: data,
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
                    (data.boosted.isNotEmpty) && data.email == SharedPreference().readStorage(SpKeys.email)
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: JangkaunStatus(
                              jangkauan: data.boostJangkauan ?? 0,
                              isDiary: true,
                            ),
                          )
                        : Container(),
                    data.email == SharedPreference().readStorage(SpKeys.email) && (data.reportedStatus == 'OWNED')
                        ? ContentViolationWidget(
                            data: data,
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
}
