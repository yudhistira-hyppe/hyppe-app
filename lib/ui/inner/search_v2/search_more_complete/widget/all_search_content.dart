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
  static final _system = System();

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
                  (widget.content?.users?.data?.isNotEmpty ?? false) ? widgetUserList(_themes) : const SizedBox(),
                  sixteenPx,
                  //------video content search
                  (widget.content?.vid?.data?.isNotEmpty ?? false) ? VidSearchContent(content: widget.content?.vid?.data, featureType: FeatureType.vid, title: 'HyppeVid') : const SizedBox(),
                  sixteenPx,
                  //------diaries content search
                  (widget.content?.diary?.data?.isNotEmpty ?? false) ? VidSearchContent(content: widget.content?.diary?.data, featureType: FeatureType.diary, title: 'HyppeDiary') : const SizedBox(),
                  sixteenPx,
                  //------pic  content search
                  (widget.content?.pict?.data?.isNotEmpty ?? false) ? VidSearchContent(content: widget.content?.pict?.data, featureType: FeatureType.pic, title: 'HyppePic') : const SizedBox(),
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
          textToDisplay: _translate?.translate.account ?? '',
          textStyle: _themes.textTheme.button?.apply(
            color: _themes.bottomNavigationBarTheme.unselectedItemColor,
          ),
        ),
        twelvePx,
        Column(
          children: [
            ...List.generate(
              (widget.content?.users?.data?.length ?? 0) >= 4 ? 4 : widget.content?.users?.data?.length ?? 0,
              (index) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  onTap: () => _system.navigateToProfile(context, widget.content?.users?.data?[index].email ?? ''),
                  contentPadding: EdgeInsets.zero,
                  title: Text("${widget.content?.users?.data?[index].fullName}"),
                  subtitle: Text("${widget.content?.users?.data?[index].username}"),
                  leading: StoryColorValidator(
                    haveStory: false,
                    featureType: FeatureType.pic,
                    child: CustomProfileImage(
                      width: 50,
                      height: 50,
                      onTap: () {},
                      imageUrl: System().showUserPicture(widget.content?.users?.data?[index].avatar?.mediaEndpoint),
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
