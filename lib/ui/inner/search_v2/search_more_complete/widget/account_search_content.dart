import 'package:dynamic_widget/dynamic_widget/basic/icon_widget_parser.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/vid_search_content.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_shimmer.dart';
import 'package:provider/provider.dart';

class AccountSearchContent extends StatefulWidget {
  final SearchContentModel? content;
  final FeatureType? featureType;
  const AccountSearchContent({Key? key, this.content, this.featureType}) : super(key: key);

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
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  twelvePx,
                  ...List.generate(
                    widget.content!.users!.data!.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        onTap: () => _system.navigateToProfile(context, widget.content!.users!.data![index].email!),
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
            ),
          )
        : Container();
  }
}
