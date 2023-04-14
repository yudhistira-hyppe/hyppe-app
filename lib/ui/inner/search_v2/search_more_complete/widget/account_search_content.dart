import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../widget/search_no_result.dart';
import 'all_search_shimmer.dart';

class AccountSearchContent extends StatefulWidget {
  final List<DataUser>? users;
  const AccountSearchContent({Key? key, this.users}) : super(key: key);

  @override
  State<AccountSearchContent> createState() => _AccountSearchContentState();
}

class _AccountSearchContentState extends State<AccountSearchContent> {
  final ScrollController _scrollController = ScrollController();
  TranslateNotifierV2? _translate;
  static final _system = System();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AccountSearchContent');
    _translate = Provider.of<TranslateNotifierV2>(context, listen: false);

    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        final notifier = context.read<SearchNotifier>();
        final lenght = notifier.searchUsers?.length;
        if (lenght != null) {
          if (lenght % 12 == 0) {
            notifier.getDataSearch(context, typeSearch: SearchLoadData.user, reload: false);
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _themes = Theme.of(context);
    return widget.users != null
        ? Consumer<SearchNotifier>(builder: (context, notifier, _) {
            final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';
            return !notifier.isLoading
                ? RefreshIndicator(
                    strokeWidth: 2.0,
                    color: context.getColorScheme().primary,
                    onRefresh: () => notifier.getDataSearch(context),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 16, top: 16),
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: CustomTextWidget(
                                textToDisplay: notifier.language.account ?? 'Contents',
                                textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            twelvePx,
                            if (widget.users.isNotNullAndEmpty())
                              ...List.generate(
                                widget.users?.length ?? 0,
                                (index) => Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ListTile(
                                    onTap: () => _system.navigateToProfile(context, widget.users?[index].email ?? ''),
                                    contentPadding: EdgeInsets.zero,
                                    title: Text("${widget.users?[index].fullName}"),
                                    subtitle: Text(
                                      isIndo ? (widget.users?[index].statusID ?? '') : (widget.users?[index].statusEN ?? ''),
                                      style: context.getTextTheme().overline,
                                    ),
                                    leading: StoryColorValidator(
                                      haveStory: false,
                                      featureType: FeatureType.pic,
                                      child: CustomProfileImage(
                                        width: 50,
                                        height: 50,
                                        onTap: () {},
                                        imageUrl: widget.users?[index].avatar == null ? '' : System().showUserPicture(widget.users?[index].avatar?[0].mediaEndpoint?.split('_')[0]),
                                        following: true,
                                        onFollow: () {},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!widget.users.isNotNullAndEmpty()) SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text),
                            if ((widget.users?.length ?? 0) % limitSearch == 0 && (widget.users?.isNotEmpty ?? false))
                              Container(
                                width: double.infinity,
                                height: 50,
                                alignment: Alignment.center,
                                child: const CustomLoading(),
                              )
                          ],
                        ),
                      ),
                    ),
                  )
                : const AllSearchShimmer();
          })
        : Container();
  }
}
