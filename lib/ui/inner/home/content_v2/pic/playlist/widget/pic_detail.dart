import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
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
import 'package:readmore/readmore.dart';

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
  Widget build(BuildContext context) {
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
                // thumbnail: picData!.content[arguments].contentUrl,
                thumbnail: widget.arguments?.fullThumbPath,
              ),
              // Content
              InteractiveViewer(
                transformationController: transformationController,
                child: CustomCacheImage(
                  // imageUrl: picData.content[arguments].contentUrl,
                  imageUrl: widget.arguments?.fullThumbPath,
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
                ),
              ),
              // Top action
              SafeArea(
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
                        shadows: [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    ProfileComponent(
                      isDetail: true,
                      show: true,
                      following: true,
                      onFollow: () {},
                      haveStory: false,
                      onTapOnProfileImage: () => System().navigateToProfile(context, widget.arguments!.email!),
                      spaceProfileAndId: eightPx,
                      featureType: FeatureType.pic,
                      username: widget.arguments?.username,
                      isCelebrity: widget.arguments?.privacy?.isCelebrity,
                      imageUrl: '${System().showUserPicture(widget.arguments?.avatar?.mediaEndpoint)}',
                      createdAt: '${System().readTimestamp(
                        DateTime.parse(widget.arguments!.createdAt!).millisecondsSinceEpoch,
                        context,
                        fullCaption: true,
                      )}',
                      // username: picData.username,
                      // spaceProfileAndId: eightPx,
                      // isCelebrity: picData.isCelebrity,
                      // haveStory: picData.isHaveStory ?? false,
                      // imageUrl: '${picData.profilePic}$VERYBIG',
                      // featureType: context.read<SeeAllNotifier>().featureType!,
                      // onTapOnProfileImage: () => System().navigateToProfileScreen(context, picData),
                      // createdAt: '${System().readTimestamp(int.parse(picData.createdAt!), context, fullCaption: true)}',
                    ),
                  ],
                ),
              ),
              // _buildButton(
              //   context,
              //   iconData: '${AssetPath.vectorPath}more.svg',
              //   function: () => ShowBottomSheet.onShowReport(context, data: picData, reportType: ReportType.post),
              //   alignment: const Alignment(1.0, -0.98),
              // ),
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
                      children: [
                        Consumer<LikeNotifier>(
                          builder: (context, notifier, child) => _buildButtonV2(
                            context: context,
                            colorIcon: (widget.arguments?.insight?.isPostLiked ?? false) ? kHyppePrimary : kHyppeLightButtonText,
                            iconData: '${AssetPath.vectorPath}${(widget.arguments?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                            function: () => notifier.likePost(context, widget.arguments!),
                          ),
                        ),
                        _buildButtonV2(
                          context: context,
                          iconData: '${AssetPath.vectorPath}share.svg',
                          function: widget.arguments != null
                              ? () => context.read<PicDetailNotifier>().createdDynamicLink(context, data: widget.arguments)
                              : () {},
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
                    Padding(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                        child: SingleChildScrollView(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             ReadMoreText(
                            "${widget.arguments?.description}",
                            trimLines: 5,
                            trimMode: TrimMode.Line,
                            textAlign: TextAlign.left,
                            trimExpandedText: 'Show less',
                            trimCollapsedText: 'Show more',
                            colorClickableText: Theme.of(context).colorScheme.primaryVariant,
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                            moreStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                            lessStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                          ),
                         for (var i = 0; i < widget.arguments!.tags!.length; i++) 
                           ReadMoreText(
                            "#${widget.arguments?.tags?[i].replaceAll('#', '')}",
                            trimLines: 5,
                            trimMode: TrimMode.Line,
                            textAlign: TextAlign.left,
                            trimExpandedText: 'Show less',
                            trimCollapsedText: 'Show more',
                            colorClickableText: Theme.of(context).colorScheme.primaryVariant,
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                            moreStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                            lessStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                          ),
                          ],
                          )
                        ),
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
