import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';
import 'dart:math' as math;

class LeftItems extends StatefulWidget {
  final String? userName;
  final String? description;
  final String? tags;
  final Music? music;
  final String? authorName;
  // final StoryController? storyController;
  final String? postID;
  final String? location;
  final List<TagPeople>? tagPeople;
  final ContentData? data;
  final FlutterAliplayer? aliPlayer;
  final AnimationController? animatedController;

  const LeftItems(
      {Key? key,
      this.userName,
      this.description,
      this.tags,
      this.music,
      this.authorName,
      // this.storyController,
      this.postID,
      this.location,
      this.tagPeople,
      this.data,
      this.aliPlayer,
      this.animatedController})
      : super(key: key);

  @override
  _LeftItemsState createState() => _LeftItemsState();
}

class _LeftItemsState extends State<LeftItems> with SingleTickerProviderStateMixin {
  // late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  // AnimationController? _controller;
  // Animation<Offset>? _offsetAnimation;
  bool isShowMore = false;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LeftItems');
    super.initState();
    // widget.animatedController!.repeat();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 3),
    //   vsync: this,
    // )..repeat();
    // _offsetAnimation = Tween<Offset>(
    //   begin: Offset.zero,
    //   end: const Offset(-2.0, 0.0),
    // ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    // _controller.dispose();
    // animatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // print('lokasi is ${widget.location}');

    final notifier = context.read<TranslateNotifierV2>();
    return Container(
      width: widget.music != null ? double.infinity : SizeConfig.screenWidth! / 1.3,
      // alignment: Alignment(widget.music != null ? 0 : -1.0, 0.75),
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(left: 15.0, right: 20, bottom: 50.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              (widget.tagPeople?.isNotEmpty ?? false) || widget.location != ''
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          (widget.tagPeople?.isNotEmpty ?? false)
                              ? PicTagLabel(
                                  width: 20,
                                  icon: 'tag-people-light',
                                  label: '${widget.tagPeople?.length} ${notifier.translate.people}',
                                  function: () {
                                    // widget.storyController?.pause();
                                    context.read<PicDetailNotifier>().showUserTag(context, widget.tagPeople, widget.postID, title: notifier.translate.inThisDiary);
                                  },
                                )
                              : const SizedBox(),
                          widget.location == '' || widget.location == null
                              ? const SizedBox()
                              : PicTagLabel(
                                  width: 17,
                                  icon: 'maptag',
                                  label: "${widget.location}",
                                  function: () {},
                                ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              Container(
                constraints: BoxConstraints(
                    maxWidth: SizeConfig.screenWidth! * .7,
                    maxHeight: widget.description!.length > 24
                        ? isShowMore
                            ? 42
                            : SizeConfig.screenHeight! * .1
                        : 42),
                // color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDescContent(
                        beforeGone: () {
                          widget.aliPlayer?.pause();
                        },
                        afterGone: () {
                          widget.aliPlayer?.play();
                        },
                        callbackIsMore: (val) {
                          setState(() {
                            isShowMore = val;
                          });
                        },
                        desc: "${widget.description}",
                        trimLines: 2,
                        textAlign: TextAlign.start,
                        seeLess: ' ${notifier.translate.seeLess}', // ${notifier2.translate.seeLess}',
                        seeMore: '  ${notifier.translate.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                        normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                        hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                        expandStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      widget.data?.statusBoost != 'BERLANGSUNG' &&
                      (widget.data?.reportedStatus != 'OWNED' && widget.data?.reportedStatus != 'BLURRED' && widget.data?.reportedStatus2 != 'BLURRED') &&
                      widget.data?.email == SharedPreference().readStorage(SpKeys.email)
                  ? Container(
                      width: SizeConfig.screenWidth,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.only(left: 0.0, right: 80, top: 10),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: widget.data,
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              if (widget.data?.email == SharedPreference().readStorage(SpKeys.email) &&
                  (widget.data?.boostCount ?? 0) >= 0 &&
                  widget.data?.statusBoost == 'BERLANGSUNG' &&
                  (widget.data?.boosted.isNotEmpty ?? [].isEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10, bottom: 10, left: 0.0),
                  width: MediaQuery.of(context).size.width * .75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kHyppeGreyLight.withOpacity(.9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}reach.svg",
                        defaultColor: false,
                        height: 24,
                        color: kHyppeTextLightPrimary,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: CustomTextWidget(
                          textToDisplay: "${widget.data?.boostJangkauan ?? '0'} ${notifier.translate.reach}",
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                        ),
                      )
                    ],
                  ),
                ),
              // twelvePx,
              Container(),
              if (widget.data?.music != null)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: SizeConfig.screenWidth! * .75,
                      margin: const EdgeInsets.only(left: 0.0, top: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: kHyppeSurface.withOpacity(.9),
                            child: AnimatedBuilder(
                              animation: widget.animatedController!,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: widget.animatedController!.value * 2 * -math.pi,
                                  child: child,
                                );
                              },
                              child: CustomBaseCacheImage(
                                imageUrl: widget.data?.music?.apsaraThumnailUrl ?? '',
                                imageBuilder: (_, imageProvider) {
                                  return AnimatedBuilder(
                                    animation: widget.animatedController!,
                                    builder: (_, child) {
                                      return Transform.rotate(
                                        angle: widget.animatedController!.value * 2 * -math.pi,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: kDefaultIconDarkColor,
                                        borderRadius: const BorderRadius.all(Radius.circular(24)),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (_, __, ___) {
                                  return const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                    defaultColor: false,
                                    color: kHyppeLightIcon,
                                    height: 18,
                                  );
                                },
                                emptyWidget: AnimatedBuilder(
                                  animation: widget.animatedController!,
                                  builder: (_, child) {
                                    return Transform.rotate(
                                      angle: widget.animatedController!.value * 2 * -math.pi,
                                      child: child,
                                    );
                                  },
                                  child: const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                    defaultColor: false,
                                    color: kHyppeTextPrimary,
                                    height: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                            width: 5,
                          ),
                          SizedBox(
                            width: SizeConfig.screenWidth! * .56,
                            height: 40,
                            child: _textSize(widget.data?.music?.musicTitle ?? '', const TextStyle(fontWeight: FontWeight.normal)).width > SizeConfig.screenWidth! * .56
                                ? Marquee(
                                    text: '  ${widget.data?.music?.musicTitle ?? ''}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                  )
                                : CustomTextWidget(
                                    textToDisplay: " ${widget.data?.music?.musicTitle ?? ''}",
                                    maxLines: 1,
                                    textStyle: const TextStyle(color: kHyppeTextPrimary, fontSize: 12),
                                    textAlign: TextAlign.left,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
              //         (widget.data?.reportedStatus != 'OWNED' && widget.data?.reportedStatus != 'BLURRED' && widget.data?.reportedStatus2 != 'BLURRED') &&
              //         (widget.data?.boosted.isEmpty ?? [].isEmpty) &&
              //         widget.data?.email == SharedPreference().readStorage(SpKeys.email)
              //     ? Container(
              //         width: MediaQuery.of(context).size.width * 0.8,
              //         margin: const EdgeInsets.only(bottom: 16),
              //         child: ButtonBoost(
              //           marginBool: true,
              //           contentData: widget.data,
              //           startState: () {
              //             SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
              //           },
              //           afterState: () {
              //             SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
              //           },
              //         ),
              //       )
              //     : Container(),
              // (widget.data?.boosted.isNotEmpty ?? [].isNotEmpty) && widget.data?.email == SharedPreference().readStorage(SpKeys.email)
              //     ? SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.8,
              //         child: JangkaunStatus(
              //           jangkauan: widget.data?.boostJangkauan ?? 0,
              //           isDiary: true,
              //         ),
              //       )
              //     : Container(),

              // SizedBox(height: 40.0 * SizeConfig.scaleDiagonal),
              // _musicInfo(),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _musicInfo() {
  //   return Row(
  //     children: <Widget>[
  //       CustomIconWidget(
  //         defaultColor: false,
  //         iconData: "${AssetPath.vectorPath}music.svg",
  //       ),
  //       SizedBox(width: 5.0 * SizeConfig.scaleDiagonal),
  //       Flexible(
  //         /// Xulu Code => [Wrap SlideTransition Widget with Flexible Widget & add overflow property into Text Widget]
  //         child: SlideTransition(
  //           position: _offsetAnimation,
  //           child: Center(
  //             child: Text(
  //               "${widget.musicName} - ${widget.authorName}",
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontFamily: "Roboto",
  //                   fontSize: 18 * SizeConfig.scaleDiagonal,
  //                   fontWeight: FontWeight.w400),
  //             ),
  //           ),
  //         ),
  //       )
  //     ],`
  //   );
  // }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
