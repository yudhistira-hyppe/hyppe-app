import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:provider/provider.dart';

class AutoCompleteUserTagComment extends StatefulWidget {
  const AutoCompleteUserTagComment({Key? key}) : super(key: key);

  @override
  State<AutoCompleteUserTagComment> createState() => _AutoCompleteUserTagCommentState();
}

class _AutoCompleteUserTagCommentState extends State<AutoCompleteUserTagComment> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentNotifierV2>(
      builder: (context, notifier, child) => Visibility(
        visible: notifier.isShowAutoComplete,
        child: Padding(
          padding: const EdgeInsets.only(),
          child: Container(
            height: 200,
            color: Theme.of(context).colorScheme.background,
            child: notifier.searchPeolpleData != null
                ? notifier.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(child: SizedBox(height: 50, child: CustomLoading())),
                        ],
                      )
                    : notifier.searchPeolpleData.isEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Center(child: Text('${notifier.language.userIsNotFound}'))),
                            ],
                          )
                        : NotificationListener<ScrollUpdateNotification>(
                            // disable load more because interfere swipe to refresh feature
                            // onNotification: (notification) {
                            //   notifier.scrollListPeopleListener(
                            //     context,
                            //     _scrollController,
                            //     notifier.inputCaption,
                            //   );
                            //   return true;
                            // },
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: notifier.searchPeolpleData.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          notifier.insertAutoComplete(index);
                                        },
                                        title: CustomTextWidget(
                                          textToDisplay: '@ ${notifier.searchPeolpleData[index].username}',
                                          textStyle: Theme.of(context).textTheme.bodyMedium,
                                          textAlign: TextAlign.start,
                                        ),
                                        // subtitle: Text("${notifier.searchPeolpleData[index].fullName}"),
                                        leading: StoryColorValidator(
                                          haveStory: false,
                                          featureType: FeatureType.pic,
                                          child: CustomProfileImage(
                                            width: 30,
                                            height: 30,
                                            onTap: () {},
                                            imageUrl: System().showUserPicture(notifier.searchPeolpleData[index].avatar?.mediaEndpoint),
                                            badge: notifier.searchPeolpleData[index].urluserBadge,
                                            following: true,
                                            onFollow: () {},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: notifier.isLoadingLoadMore,
                                  child: const CustomLoading(),
                                )
                              ],
                            ),
                          )
                : Container(),
          ),
        ),
      ),
    );
  }
}
