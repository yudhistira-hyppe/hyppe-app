import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/jangakauan_status.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';
import 'package:readmore/readmore.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../constant/widget/music_status_page_widget.dart';

class LeftItems extends StatefulWidget {
  final String? userName;
  final String? description;
  final String? tags;
  final Music? music;
  final String? authorName;
  final StoryController? storyController;
  final String? postID;
  final String? location;
  final List<TagPeople>? tagPeople;
  final ContentData? data;

  const LeftItems({
    Key? key,
    this.userName,
    this.description,
    this.tags,
    this.music,
    this.authorName,
    this.storyController,
    this.postID,
    this.location,
    this.tagPeople,
    this.data,
  }) : super(key: key);

  @override
  _LeftItemsState createState() => _LeftItemsState();
}

class _LeftItemsState extends State<LeftItems> with SingleTickerProviderStateMixin {
  // AnimationController? _controller;
  // Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    print('lokasi is ${widget.location}');
    return Container(
      width: widget.music != null ? double.infinity : SizeConfig.screenWidth! / 1.3,
      // alignment: Alignment(widget.music != null ? 0 : -1.0, 0.75),
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(left: 15.0, right: 20, bottom: 80.0),
      child: Column(
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
                              icon: 'user',
                              label: '${widget.tagPeople?.length} people',
                              function: () {
                                widget.storyController?.pause();
                                context.read<PicDetailNotifier>().showUserTag(context, widget.tagPeople, widget.postID, storyController: widget.storyController);
                              },
                            )
                          : const SizedBox(),
                      widget.location == '' || widget.location == null
                          ? const SizedBox()
                          : PicTagLabel(
                              icon: 'maptag',
                              label: "${widget.location}",
                              function: () {},
                            ),
                    ],
                  ),
                )
              : const SizedBox(),
          Container(
            padding: const EdgeInsets.all(2),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            // color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadMoreText(
                    "${widget.description}",
                    trimLines: 5,
                    trimMode: TrimMode.Line,
                    textAlign: TextAlign.left,
                    trimExpandedText: 'Show less',
                    trimCollapsedText: 'Show more',
                    colorClickableText: Theme.of(context).colorScheme.primaryVariant,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppeLightButtonText),
                    moreStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                    lessStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                  ),
                ],
              ),
            ),
          ),

          twelvePx,
          (widget.data?.reportedStatus != 'OWNED' && widget.data?.reportedStatus != 'BLURRED') && widget.data?.isBoost == null && widget.data?.email == SharedPreference().readStorage(SpKeys.email)
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ButtonBoost(
                    marginBool: true,
                    contentData: widget.data,
                  ),
                )
              : Container(),
          widget.data?.isBoost != null && widget.data?.email == SharedPreference().readStorage(SpKeys.email)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: JangkaunStatus(
                    jangkauan: widget.data?.boostJangkauan ?? 0,
                    isDiary: true,
                  ),
                )
              : Container(),

          // SizedBox(height: 40.0 * SizeConfig.scaleDiagonal),
          // _musicInfo(),
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
  //     ],
  //   );
  // }
}
