import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../constant/widget/custom_text_widget.dart';

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
    // final _themes = Theme.of(context);
    return widget.users != null
        ? Consumer<SearchNotifier>(
          builder: (context, notifier, _) {
            return SingleChildScrollView(
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
                      ...List.generate(
                        widget.users?.length ?? 0,
                        (index) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ListTile(
                            onTap: () => _system.navigateToProfile(context, widget.users?[index].email ?? ''),
                            contentPadding: EdgeInsets.zero,
                            title: Text("${widget.users?[index].fullName}"),
                            subtitle: Text("${widget.users?[index].username}"),
                            leading: StoryColorValidator(
                              haveStory: false,
                              featureType: FeatureType.pic,
                              child: CustomProfileImage(
                                width: 50,
                                height: 50,
                                onTap: () {},
                                imageUrl: widget.users?[index].avatar == null ? '' : System().showUserPicture(widget.users?[index].avatar?[0].mediaEndpoint?.replaceAll("_860.jpeg", "")),
                                following: true,
                                onFollow: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        )
        : Container();
  }
}
