import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/hashtag_item.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/enum.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_profile_image.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../../constant/widget/story_color_validator.dart';
import '../../notifier.dart';

class NewAutoCompleteSearch extends StatefulWidget {
  const NewAutoCompleteSearch({Key? key}) : super(key: key);

  @override
  State<NewAutoCompleteSearch> createState() => _NewAutoCompleteSearchState();
}

class _NewAutoCompleteSearchState extends State<NewAutoCompleteSearch> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'NewAutoCompleteSearch');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) {
        final isHashTag = notifier.searchController.text.isHashtag();
        final isEmpty = isHashTag ? notifier.searchHashtag?.isEmpty ?? false : (notifier.searchUsers?.isEmpty ?? false);
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              notifier.isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: CustomLoading(),
                          ),
                        ),
                      ],
                    )
                  : isEmpty && notifier.searchController.text != ''
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Center(child: Text('${notifier.language.noResultsFor} "${notifier.searchController.text}"'))),
                          ],
                        )
                      : Builder(builder: (context) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: isHashTag
                                ? ((notifier.searchHashtag?.length ?? 0) >= 5 ? 5 : notifier.searchHashtag?.length)
                                : ((notifier.searchUsers?.length ?? 0) >= 5 ? 5 : notifier.searchUsers?.length),
                            itemBuilder: (context, index) {
                              if (isHashTag) {
                                final hashTag = notifier.searchHashtag?[index];
                                return HashtagItem(
                                    onTap: () {
                                      notifier.selectedHashtag = notifier.searchHashtag?[index];
                                      if(notifier.layout == SearchLayout.searchMore){
                                        notifier.isFromComplete = true;
                                      }
                                      notifier.layout = SearchLayout.hashtagDetail;
                                    },
                                    title: hashTag?.tag ?? 'No Tag',
                                    count: hashTag?.total ?? 0,
                                    countContainer: notifier.language.posts ?? 'Posts');
                              } else {
                                return SizedBox(
                                  height: 60,
                                  child: ListTile(
                                    onTap: () {
                                      System().navigateToProfile(context, notifier.searchUsers?[index].email ?? '');
                                    },
                                    title: CustomTextWidget(
                                      textToDisplay: notifier.searchUsers?[index].fullName ?? '',
                                      textStyle: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.start,
                                    ),
                                    subtitle: Text(
                                      notifier.searchUsers?[index].username ?? '',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    leading: StoryColorValidator(
                                      haveStory: false,
                                      featureType: FeatureType.pic,
                                      child: CustomProfileImage(
                                        width: 40,
                                        height: 40,
                                        onTap: () {},
                                        imageUrl: System().showUserPicture(notifier.searchUsers?[index].avatar?[0].mediaEndpoint?.split('_')[0] ?? ''),
                                        badge: notifier.searchUsers?[index].urluserBadge,
                                        following: true,
                                        onFollow: () {},
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }),
              notifier.searchController.text != ''
                  ? ListTile(
                      onTap: () {
                        notifier.insertHistory(context, notifier.searchController.text);
                        notifier.limit = 5;
                        notifier.tabIndex = 0;
                        notifier.setEmptyLastKey();
                        notifier.layout = SearchLayout.searchMore;
                        // notifier.getDataSearch(context, isMove: true);
                      },
                      title: CustomTextWidget(
                        textToDisplay: notifier.language.seeMoreContent ?? 'See More',
                        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kHyppePrimary),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
