import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
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
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import '../../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';

class PicDetail extends StatefulWidget {
  final ContentData? arguments;

  const PicDetail({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<PicDetail> createState() => _PicDetailState();
}

class _PicDetailState extends State<PicDetail> {
  final TransformationController transformationController = TransformationController();

  void resetZooming() {
    if (transformationController.value != Matrix4.identity()) {
      transformationController.value = Matrix4.identity();
      setState(() {});
    }
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicDetail');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>().translate;
    return WillPopScope(
      onWillPop: () {
        resetZooming();
        return Future.value(true);
      },
      child: GestureDetector(
        onDoubleTap: () => resetZooming(),
        child: Scaffold(
          body: Stack(
            children: [
              // Background
              CustomBackgroundLayer(
                sigmaX: 30,
                sigmaY: 30,
                // thumbnail: picData.content[arguments].contentUrl,
                thumbnail: (widget.arguments?.isApsara ?? false) ? widget.arguments?.mediaThumbUri : widget.arguments?.fullThumbPath,
              ),
              // Content
              InteractiveViewer(
                transformationController: transformationController,
                child: InkWell(
                  onDoubleTap: () {
                    context.read<LikeNotifier>().likePost(context, widget.arguments ?? ContentData());
                  },
                  child: CustomCacheImage(
                    // imageUrl: picData.content[arguments].contentUrl,
                    imageUrl: (widget.arguments?.isApsara ?? false) ? widget.arguments?.mediaThumbUri : widget.arguments?.fullThumbPath,
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                        ),
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage('${AssetPath.pngPath}content-error.png'),
                          ),
                        ),
                      );
                    },
                    emptyWidget: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Top action
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                            onTapOnProfileImage: () => System().navigateToProfile(context, widget.arguments?.email ?? ''),
                            spaceProfileAndId: eightPx,
                            featureType: FeatureType.pic,
                            username: widget.arguments?.username,
                            isCelebrity: widget.arguments?.privacy?.isCelebrity,
                            isUserVerified: widget.arguments?.isIdVerified ?? false,
                            imageUrl: '${System().showUserPicture(widget.arguments?.avatar?.mediaEndpoint)}',
                            createdAt: '${System().readTimestamp(
                              DateTime.parse(System().dateTimeRemoveT(widget.arguments?.createdAt ?? '')).millisecondsSinceEpoch,
                              context,
                              fullCaption: true,
                            )}',
                          ),
                        ],
                      ),
                      widget.arguments?.email == SharedPreference().readStorage(SpKeys.email)
                          ? _buildButtonV2(
                              context: context,
                              iconData: '${AssetPath.vectorPath}more.svg',
                              function: () async {
                                await ShowBottomSheet().onShowOptionContent(
                                  context,
                                  contentData: widget.arguments ?? ContentData(),
                                  captionTitle: hyppePic,
                                  isShare: widget.arguments?.isShared ?? true,
                                  // storyController: widget.storyController,
                                  onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                                );
                              },
                            )
                          : SizedBox(),
                      widget.arguments?.email != SharedPreference().readStorage(SpKeys.email)
                          ? _buildButtonV2(
                              context: context,
                              iconData: '${AssetPath.vectorPath}more.svg',
                              function: () => ShowBottomSheet.onReportContent(
                                context,
                                postData: widget.arguments,
                                type: hyppePic,
                                adsData: null,
                                onUpdate: () => context.read<PicDetailNotifier>().onUpdate(),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),

              // _buildButton(
              //   context,
              //   iconData: '${AssetPath.vectorPath}bookmark.svg',
              //   function: () => context
              //       .read<PlaylistNotifier>()
              //       .showMyPlaylistBottomSheet(context, index: arguments, data: picData, featureType: FeatureType.pic),
              //   alignment: const Alignment(0.8, -0.98),
              // ),

              // Bottom action
              Align(
                alignment: const Alignment(-1.0, 0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        sixteenPx,
                        Consumer<LikeNotifier>(
                          builder: (context, notifier, child) => widget.arguments?.insight?.isloading ?? false
                              ? Container(
                                  height: 21,
                                  width: 21,
                                  margin: const EdgeInsets.only(left: 20),
                                  child: const CircularProgressIndicator(
                                    color: kHyppePrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : _buildButtonV2(
                                  context: context,
                                  colorIcon: (widget.arguments?.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeLightButtonText,
                                  iconData: '${AssetPath.vectorPath}${(widget.arguments?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                  function: () => notifier.likePost(context, widget.arguments ?? ContentData()),
                                ),
                        ),
                        eightPx,
                        if ((widget.arguments?.allowComments ?? true))
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}comment.svg',
                            function: () {
                              ShowBottomSheet.onShowCommentV2(context, postID: widget.arguments?.postID);
                            },
                          ),
                        eightPx,
                        if ((widget.arguments?.isShared ?? true) && widget.arguments?.visibility == 'PUBLIC')
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}share.svg',
                            function: widget.arguments != null ? () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: widget.arguments) : () {},
                          ),
                        eightPx,
                        if ((widget.arguments?.saleAmount ?? 0) > 0 && SharedPreference().readStorage(SpKeys.email) != widget.arguments?.email)
                          _buildButtonV2(
                            context: context,
                            iconData: '${AssetPath.vectorPath}cart.svg',
                            function: () async {
                              // notifier.preventMusic = true;
                              ShowBottomSheet.onBuyContent(context, data: widget.arguments);
                              // notifier.preventMusic = true;
                            },
                          ),
                        // _buildButtonV2(
                        //   context: context,
                        //   iconData: '${AssetPath.vectorPath}bookmark.svg',
                        //   function: () {},
                        //   function: () => context.read<PlaylistNotifier>().showMyPlaylistBottomSheet(
                        //         context,
                        //         data: picData,
                        //         featureType: FeatureType.pic,
                        //         index: context.read<SeeAllNotifier>().contentIndex,
                        //       ),
                        // )
                      ],
                    ),
                    (widget.arguments?.tagPeople?.isNotEmpty ?? false) || widget.arguments?.location != ''
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 26, top: 16),
                            child: Row(
                              children: [
                                widget.arguments?.tagPeople?.isNotEmpty ?? false
                                    ? PicTagLabel(
                                        icon: 'tag_people',
                                        label: '${widget.arguments?.tagPeople?.length} people',
                                        function: () {
                                          context.read<PicDetailNotifier>().showUserTag(context, widget.arguments?.tagPeople ?? [], widget.arguments?.postID);
                                        },
                                        width: 18,
                                      )
                                    : const SizedBox(),
                                widget.arguments?.location == '' || widget.arguments?.location == null
                                    ? const SizedBox()
                                    : PicTagLabel(
                                        icon: 'maptag-white',
                                        label: "${widget.arguments?.location}",
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
                              desc: "${widget.arguments?.description}",
                              trimLines: 5,
                              textAlign: TextAlign.start,
                              seeLess: ' ${translate.seeLess}',
                              seeMore: ' ${translate.seeMoreContent}',
                              normStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppeLightButtonText),
                              hrefStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppePrimary),
                              expandStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        )),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    )
                  ],
                ),
              ),

              // Description
              // Align(
              //   alignment: const Alignment(-1.0, 0.9),
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: CustomTextWidget(
              //       textAlign: TextAlign.left,
              //       textOverflow: TextOverflow.visible,
              //       textToDisplay: "${picData.description}",
              //       textStyle: Theme.of(context).textTheme.bodyText1,
              //     ),
              //   ),
              // ),
            ],
          ),
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
