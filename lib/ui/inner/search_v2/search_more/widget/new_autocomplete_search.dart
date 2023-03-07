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
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            notifier.searchUsers != null
                ? notifier.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(
                              child:
                                  SizedBox(height: 50, child: CustomLoading())),
                        ],
                      )
                    : (notifier.searchUsers?.isEmpty ?? false) &&
                            notifier.searchController.text != ''
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Center(
                                      child: Text(
                                          '${notifier.language.noResultsFor} "${notifier.searchController.text}"'))),
                            ],
                          )
                        : Builder(builder: (context) {
                            final isHashTag = notifier.searchController.text.isHashtag();
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: isHashTag
                                  ? ((notifier.searchHashtag?.length ?? 0) >= 5
                                      ? 5
                                      : notifier.searchHashtag?.length)
                                  : ((notifier.searchUsers?.length ?? 0) >= 5
                                      ? 5
                                      : notifier.searchUsers?.length),
                              itemBuilder: (context, index) {
                                if (isHashTag) {
                                  final hashTag =
                                      notifier.searchHashtag?[index];
                                  return HashtagItem(
                                    onTap: (){
                                      notifier.selectedHashtag = notifier.searchHashtag?[index];
                                      notifier.layout = SearchLayout.mainHashtagDetail;
                                    },
                                      title: hashTag?.tag ?? 'No Tag',
                                      count: hashTag?.total ?? 0,
                                      countContainer:
                                          notifier.language.posts ?? 'Posts');
                                } else {
                                  return SizedBox(
                                    height: 60,
                                    child: ListTile(
                                      onTap: () {
                                        System().navigateToProfile(
                                            context,
                                            notifier.searchUsers?[index]
                                                    .email ??
                                                '', isReplaced: false);
                                      },
                                      title: CustomTextWidget(
                                        textToDisplay: notifier
                                                .searchUsers?[index].fullName ??
                                            '',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        textAlign: TextAlign.start,
                                      ),
                                      subtitle: Text(
                                        notifier.searchUsers?[index].username ??
                                            '',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      leading: StoryColorValidator(
                                        haveStory: false,
                                        featureType: FeatureType.pic,
                                        child: CustomProfileImage(
                                          width: 40,
                                          height: 40,
                                          onTap: () {},
                                          imageUrl: System().showUserPicture(
                                              notifier
                                                      .searchUsers?[index]
                                                      .avatar?[0]
                                                      .mediaEndpoint ??
                                                  ''),
                                          following: true,
                                          onFollow: () {},
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          })
                : Container(),
            notifier.searchUsers != null
                ? notifier.searchController.text != ''
                    ? ListTile(
                        onTap: () {
                          notifier.limit = 5;
                          notifier.tabIndex = 0;
                          notifier.layout = SearchLayout.searchMore;
                          // notifier.getDataSearch(context, isMove: true);
                        },
                        title: CustomTextWidget(
                          textToDisplay: 'See More',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: kHyppePrimary),
                        ),
                      )
                    : const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
