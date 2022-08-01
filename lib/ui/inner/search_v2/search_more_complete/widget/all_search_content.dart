import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/all_search_shimmer.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/vid_search_content.dart';
import 'package:provider/provider.dart';

class AllSearchContent extends StatefulWidget {
  final SearchContentModel? content;
  final FeatureType? featureType;
  const AllSearchContent({Key? key, this.content, this.featureType}) : super(key: key);

  @override
  State<AllSearchContent> createState() => _AllSearchContentState();
}

class _AllSearchContentState extends State<AllSearchContent> {
  final ScrollController _scrollController = ScrollController();
  TranslateNotifierV2? _translate;

  @override
  void initState() {
    _translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _themes = Theme.of(context);
    return widget.content != null
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.content!.users!.data!.isNotEmpty ? widgetUserList(_themes) : const SizedBox(),

                  sixteenPx,
                  // CustomTextWidget(
                  //   maxLines: 1,
                  //   textAlign: TextAlign.left,
                  //   textToDisplay: _translate!.translate.tag!,
                  //   textStyle: _themes.textTheme.button!.apply(
                  //     color: _themes.bottomNavigationBarTheme.unselectedItemColor,
                  //   ),
                  // ),
                  // twelvePx,
                  // ListTile(
                  //   // onTap: () => notifier.inserTagPeople(index),
                  //   contentPadding: EdgeInsets.zero,
                  //   title: Text("#Wisataindonesia"),
                  //   subtitle: Text("500+ posts"),
                  //   leading: Container(
                  //     width: 50,
                  //     height: 50,
                  //     // padding: EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: kHyppeLightIcon),
                  //       borderRadius: BorderRadius.circular(50),
                  //     ),
                  //     child: CustomIconWidget(
                  //       iconData: '${AssetPath.vectorPath}hashtag.svg',
                  //       defaultColor: false,
                  //       width: 20,
                  //     ),
                  //   ),
                  // ),
                  // sixteenPx,
                  CustomTextWidget(
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    textToDisplay: 'HyppeVid',
                    textStyle: _themes.textTheme.button!.apply(
                      color: _themes.bottomNavigationBarTheme.unselectedItemColor,
                    ),
                  ),
                  sixPx,
                  //------video content search
                  VidSearchContent(content: widget.content!.vid!.data, featureType: FeatureType.vid),
                  sixteenPx,
                  CustomTextWidget(
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    textToDisplay: 'HyppeDiary',
                    textStyle: _themes.textTheme.button!.apply(
                      color: _themes.bottomNavigationBarTheme.unselectedItemColor,
                    ),
                  ),
                  sixPx,
                  //------diaries content search
                  VidSearchContent(content: widget.content!.diary!.data, featureType: FeatureType.diary),
                  sixteenPx,
                  CustomTextWidget(
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    textToDisplay: 'HyppePic',
                    textStyle: _themes.textTheme.button!.apply(
                      color: _themes.bottomNavigationBarTheme.unselectedItemColor,
                    ),
                  ),
                  sixPx,
                  //------pic  content search
                  VidSearchContent(content: widget.content!.pict!.data, featureType: FeatureType.pic),
                ],
              ),
            ),
          )
        : const AllSearchShimmer();
  }

  Widget widgetUserList(_themes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        CustomTextWidget(
          maxLines: 1,
          textAlign: TextAlign.left,
          textToDisplay: _translate!.translate.account!,
          textStyle: _themes.textTheme.button!.apply(
            color: _themes.bottomNavigationBarTheme.unselectedItemColor,
          ),
        ),
        twelvePx,
        Column(
          children: [
            ...List.generate(
              widget.content!.users!.data!.length >= 4 ? 4 : widget.content!.users!.data!.length,
              (index) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  // onTap: () => notifier.inserTagPeople(index),
                  contentPadding: EdgeInsets.zero,
                  title: Text("${widget.content!.users!.data![index].fullName}"),
                  subtitle: Text("${widget.content!.users!.data![index].username}"),
                  leading: StoryColorValidator(
                    haveStory: false,
                    featureType: FeatureType.pic,
                    child: CustomProfileImage(
                      width: 50,
                      height: 50,
                      onTap: () {},
                      imageUrl: System().showUserPicture(widget.content!.users!.data![index].avatar?.mediaEndpoint),
                      following: true,
                      onFollow: () {},
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
