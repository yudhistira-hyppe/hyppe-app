import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

class AutoCompleteSearch extends StatelessWidget {
  const AutoCompleteSearch({Key? key}) : super(key: key);
  static final _system = System();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            notifier.searchPeolpleData != null
                ? notifier.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(child: SizedBox(height: 50, child: CustomLoading())),
                        ],
                      )
                    : notifier.searchPeolpleData?.isEmpty ?? false
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Expanded(child: Center(child: Text('User tidak ditemukan'))),
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: (notifier.searchPeolpleData?.length ?? 0) >= 5 ? 5 : notifier.searchPeolpleData?.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 60,
                                child: ListTile(
                                  onTap: () {
                                    _system.navigateToProfile(context, notifier.searchPeolpleData?[index].email ?? '');
                                  },
                                  title: CustomTextWidget(
                                    textToDisplay: notifier.searchPeolpleData?[index].fullName ?? '',
                                    textStyle: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                  subtitle: Text(
                                    notifier.searchPeolpleData?[index].username ?? '',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  leading: StoryColorValidator(
                                    haveStory: false,
                                    featureType: FeatureType.pic,
                                    child: CustomProfileImage(
                                      width: 40,
                                      height: 40,
                                      onTap: () {},
                                      imageUrl: System().showUserPicture(notifier.searchPeolpleData?[index].avatar?.mediaEndpoint ?? ''),
                                      following: true,
                                      onFollow: () {},
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                : Container(),
            notifier.searchPeolpleData != null
                ? notifier.searchPeolpleData?.isNotEmpty ?? false || notifier.searchController.text != ''
                    ? ListTile(
                        onTap: () => notifier.onSearchPost(context),
                        title: CustomTextWidget(
                          textToDisplay: 'See More',
                          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kHyppePrimary),
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
