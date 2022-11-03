import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';
import 'package:readmore/readmore.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:provider/provider.dart';

class LeftItems extends StatefulWidget {
  final String? userName;
  final String? description;
  final String? tags;
  final String? musicName;
  final String? authorName;
  final StoryController? storyController;
  final String? postID;
  final String? location;
  final List<TagPeople>? tagPeople;

  const LeftItems({
    Key? key,
    this.userName,
    this.description,
    this.tags,
    this.musicName,
    this.authorName,
    this.storyController,
    this.postID,
    this.location,
    this.tagPeople,
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
    return Container(
      width: SizeConfig.screenWidth ?? context.getWidth() / 1.3,
      alignment: const Alignment(-1.0, 0.75),
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.tagPeople?.isNotEmpty ?? false || widget.location != ''
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      widget.tagPeople?.isNotEmpty ?? false
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
              child: ReadMoreText(
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
            ),
          ),
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
