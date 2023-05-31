import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
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
import 'package:hyppe/ui/inner/search_v2/widget/search_no_result_image.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../hashtag/widget/hashtag_item.dart';
import '../../widget/grid_content_view.dart';

class AllSearchContent extends StatefulWidget {
  String keyword;
  TabController tabController;
  AllSearchContent({Key? key, required this.tabController, required this.keyword}) : super(key: key);

  @override
  State<AllSearchContent> createState() => _AllSearchContentState();
}

class _AllSearchContentState extends State<AllSearchContent> {
  final ScrollController _scrollController = ScrollController();
  TranslateNotifierV2? _translate;
  static final _system = System();

  final listTab = [
    HyppeType.HyppePic,
    HyppeType.HyppeDiary,
    HyppeType.HyppeVid
  ];

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AllSearchContent');
    // _translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    // final notifier = Provider.of<SearchNotifier>(context, listen: false);
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
      final tags = notifier.searchHashtag;
      final users = notifier.searchUsers;
      final isAllEmpty = !vids.isNotNullAndEmpty() && !diaries.isNotNullAndEmpty() && !pics.isNotNullAndEmpty() && !tags.isNotNullAndEmpty() && !users.isNotNullAndEmpty();
      return !notifier.isLoading
          ? RefreshIndicator(
        strokeWidth: 2.0,
        color: context.getColorScheme().primary,
        onRefresh: () => notifier.getDataSearch(context),
            child: SingleChildScrollView(
        child: isAllEmpty ? SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text,) :Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widgetUserList(_themes, notifier),
            sixteenPx,
            widgetContents(notifier)
            // ------video content search
            // VidSearchContent(content: vids, featureType: FeatureType.vid, title: 'HyppeVid', selecIndex: 2),
            // sixteenPx,
            // //------diaries content search
            // VidSearchContent(content: diaries, featureType: FeatureType.diary, title: 'HyppeDiary', selecIndex: 3),
            // sixteenPx,
            // //------pic  content search
            // VidSearchContent(content: pics, featureType: FeatureType.pic, title: 'HyppePic', selecIndex: 4),
          ],
        ),
      ),
          )
          : const AllSearchShimmer();
    });

  }
  
  Widget widgetContents(SearchNotifier notifier){
    final vids = notifier.searchVid;
    final diaries = notifier.searchDiary;
    final pics = notifier.searchPic;
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: notifier.language.content ?? 'Contents',
            textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: listTab.map((e) {
                  final isActive = e == notifier.mainContentTab;
                  return Expanded(
                    child: Container(
                      margin:
                      const EdgeInsets.only(right: 12, top: 10, bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive
                                ? context.getColorScheme().primary
                                : context.getColorScheme().background,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                          ),
                          child: InkWell(
                            onTap: () {
                              notifier.mainContentTab = e;
                            },
                            borderRadius: const BorderRadius.all(Radius.circular(18)),
                            splashColor: context.getColorScheme().primary,
                            child: Container(
                              alignment: Alignment.center,
                              height: 36,
                              padding: const EdgeInsets.symmetric( horizontal: 16),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(18)),
                                  border: !isActive
                                      ? Border.all(
                                      color:
                                      context.getColorScheme().secondary,
                                      width: 1)
                                      : null),
                              child: CustomTextWidget(
                                textToDisplay:
                                System().getTitleHyppe(e),
                                textStyle: context.getTextTheme().bodyText2?.copyWith(color: isActive ? context.getColorScheme().background : context.getColorScheme().secondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()),
          ),
          Builder(
              builder: (context) {
                final fixVid = vids?.where((element){
                  final index = vids.indexOf(element);
                  return index < 6;
                }).toList();
                final fixPic = pics?.where((element){
                  final index = pics.indexOf(element);
                  return index < 6;
                }).toList();
                final fixDiary = diaries?.where((element){
                  final index = diaries.indexOf(element);
                  return index < 6;
                }).toList();
                final type = notifier.mainContentTab;
                switch(type){
                  case HyppeType.HyppePic:
                    return fixPic.isNotNullAndEmpty() ? GridContentView(type: type, data: fixPic ?? [],
                      isLoading: false,
                      keyword: widget.keyword ?? '',
                      api: TypeApiSearch.normal,) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text,);
                  case HyppeType.HyppeDiary:
                    return fixDiary.isNotNullAndEmpty() ? GridContentView(type: type, data: fixDiary ?? [],
                      isLoading: false,
                      keyword: widget.keyword ?? '',
                      api: TypeApiSearch.normal,) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
                  case HyppeType.HyppeVid:
                    return fixVid.isNotNullAndEmpty() ? GridContentView(type: type, data: fixVid ?? [],
                      isLoading: false,
                      keyword: widget.keyword ?? '',
                      api: TypeApiSearch.normal,) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
                }
              }
          )
        ],
      ),
    );
  }

  Widget widgetUserList(_themes, SearchNotifier notifier) {
    final users = notifier.searchUsers;
    final tags = notifier.searchHashtag;
    final search = notifier.searchController.text;
    final isHashtag = search.isHashtag();
    final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 0, top: 16),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.account ?? 'Account',
                        textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        widget.tabController.animateTo(1, duration: const Duration(seconds: 1));
                      },
                      child: Row(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.language.other ?? 'Other',
                            textStyle: context.getTextTheme().bodyText2?.copyWith(color: kHyppeBurem, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                          const CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}arrow_right.svg', height: 14, width: 14,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              twelvePx,
              !isHashtag ? users.isNotNullAndEmpty() ? Column(
                children: [
                  ...List.generate(
                    (users?.length ?? 0) >= 3 ? 3 : users?.length ?? 0,
                        (index) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        onTap: () => _system.navigateToProfile(context, users?[index].email ?? ''),
                        contentPadding: EdgeInsets.zero,
                        title: Text("${users?[index].fullName}"),
                        subtitle: Text(isIndo ? (users?[index].statusID ?? '') : (users?[index].statusEN ?? ''), style: context.getTextTheme().overline,),
                        leading: StoryColorValidator(
                          haveStory: false,
                          featureType: FeatureType.pic,
                          child: CustomProfileImage(
                            width: 50,
                            height: 50,
                            onTap: () {},
                            imageUrl: System().showUserPicture(users?[index].avatar?[0].mediaEndpoint?.split('_')[0]),
                            following: true,
                            onFollow: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ) : SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text): SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 12,
          color: context.getColorScheme().surface,
        ),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 0, top: 16),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.hashtags ?? 'Hashtags',
                        textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        widget.tabController.animateTo(3, duration: const Duration(seconds: 1));
                      },
                      child: Row(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.language.other ?? 'Other',
                            textStyle: context.getTextTheme().bodyText2?.copyWith(color: kHyppeBurem, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                          const CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}arrow_right.svg', height: 14, width: 14,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              twelvePx,
              tags.isNotNullAndEmpty() ? Column(
                children: [
                  ...List.generate(
                    (tags?.length ?? 0) >= 2 ? 2 : tags?.length ?? 0,
                        (index) => Builder(
                        builder: (context){
                          final data = tags?[index];
                          if (data != null) {
                            return HashtagItem(
                                onTap: () {
                                  notifier.selectedHashtag = data;
                                  if(notifier.layout == SearchLayout.searchMore){
                                    notifier.isFromComplete = true;
                                  }
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
          ),
        ),
        Container(
          width: double.infinity,
          height: 12,
          color: context.getColorScheme().surface,
        ),

      ],
    );
  }
}
