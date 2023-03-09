import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
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
import 'package:hyppe/ui/inner/search_v2/widget/search_no_result.dart';
import 'package:provider/provider.dart';

import '../../hashtag/widget/hashtag_item.dart';

class AllSearchContent extends StatefulWidget {
  const AllSearchContent({Key? key}) : super(key: key);

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
    // _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
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

    return Consumer<SearchNotifier>(builder: (context, notifier, _){
      final vids = notifier.searchVid;
      final diaries = notifier.searchDiary;
      final pics = notifier.searchPic;
      return !notifier.isLoading
          ? RefreshIndicator(
        strokeWidth: 2.0,
        color: context.getColorScheme().primary,
        onRefresh: () => notifier.getDataSearch(context),
            child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetUserList(_themes, notifier),
                sixteenPx,
                // ------video content search
                VidSearchContent(content: vids, featureType: FeatureType.vid, title: 'HyppeVid', selecIndex: 2),
                sixteenPx,
                //------diaries content search
                VidSearchContent(content: diaries, featureType: FeatureType.diary, title: 'HyppeDiary', selecIndex: 3),
                sixteenPx,
                //------pic  content search
                VidSearchContent(content: pics, featureType: FeatureType.pic, title: 'HyppePic', selecIndex: 4),
              ],
            ),
        ),
      ),
          )
          : const AllSearchShimmer();
    });

  }

  Widget widgetUserList(_themes, SearchNotifier notifier) {
    final users = notifier.searchUsers;
    final tags = notifier.searchHashtag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        Container(
          padding: const EdgeInsets.only(left: 0, top: 16),
          width: double.infinity,
          child: CustomTextWidget(
            textToDisplay: notifier.language.account ?? 'Contents',
            textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
        ),
        twelvePx,
        users.isNotNullAndEmpty() ? Column(
          children: [
            ...List.generate(
              (users?.length ?? 0) >= 5 ? 5 : users?.length ?? 0,
              (index) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  onTap: () => _system.navigateToProfile(context, users?[index].email ?? '',isReplaced: false),
                  contentPadding: EdgeInsets.zero,
                  title: Text("${users?[index].fullName}"),
                  subtitle: Text("${users?[index].username}"),
                  leading: StoryColorValidator(
                    haveStory: false,
                    featureType: FeatureType.pic,
                    child: CustomProfileImage(
                      width: 50,
                      height: 50,
                      onTap: () {},
                      imageUrl: System().showUserPicture(users?[index].avatar?[0].mediaEndpoint?.replaceAll("_860.jpeg", "")),
                      following: true,
                      onFollow: () {},
                    ),
                  ),
                ),
              ),
            ),
          ],
        ) : SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text),
        sixteenPx,
        Container(
          padding: const EdgeInsets.only(left: 0, top: 16),
          width: double.infinity,
          child: CustomTextWidget(
            textToDisplay: notifier.language.hashtags ?? 'Hashtags',
            textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
        ),
        twelvePx,
        tags.isNotNullAndEmpty() ? Column(
          children: [
            ...List.generate(
              (tags?.length ?? 0) >= 5 ? 5 : tags?.length ?? 0,
                  (index) => Builder(
                    builder: (context){
                      final data = tags?[index];
                      if (data != null) {
                        return HashtagItem(
                            onTap: () {
                              notifier.selectedHashtag = data;
                              notifier.layout = SearchLayout.mainHashtagDetail;
                            },
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            title: '#${data.tag}',
                            count: data.total ?? 0,
                            countContainer:
                            notifier.language.posts ?? 'Posts');
                      }else{
                        return Container();
                      }
                    }
                  ),
            ),
          ],
        ) : SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text),
      ],
    );
  }
}
