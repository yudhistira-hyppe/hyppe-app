import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:provider/provider.dart';

class OnShowUserViewContentBottomSheet extends StatefulWidget {
  final String postId;
  final String eventType;
  final String title;

  const OnShowUserViewContentBottomSheet({
    Key? key,
    required this.postId,
    required this.eventType,
    required this.title,
  }) : super(key: key);

  @override
  State<OnShowUserViewContentBottomSheet> createState() => _OnShowUserViewContentBottomSheetState();
}

class _OnShowUserViewContentBottomSheetState extends State<OnShowUserViewContentBottomSheet> with GeneralMixin {
  // final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? lastInputValue;

  @override
  void initState() {
    super.initState();
    var likeNotifier = Provider.of<LikeNotifier>(context, listen: false);
    likeNotifier.skip = 0;
    likeNotifier.listLikeView = [];
    likeNotifier.getLikeView(context, widget.postId, widget.eventType, 20);
    _scrollController.addListener(() => likeNotifier.scrollListLikeView(context, _scrollController, widget.postId, widget.eventType, 20));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Consumer<LikeNotifier>(
        builder: (context, notifier, child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  const Center(child: CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CustomTextWidget(
                        textToDisplay: widget.title,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
              notifier.isLoading
                  ? const Center(child: CustomLoading())
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        // scrollDirection: Axis.vertical,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifier.listLikeView?.length,
                        itemBuilder: (context, index) {
                          final data = notifier.listLikeView?[index];
                          // print(System().showUserPicture(value[index].avatar));
                          if (data != null) {
                            return ListTile(
                              onTap: () => System().navigateToProfile(context, data.email ?? ''),
                              contentPadding: EdgeInsets.zero,
                              title: CustomTextWidget(
                                textToDisplay: data.username ?? '',
                                textStyle: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.start,
                              ),
                              leading: StoryColorValidator(
                                haveStory: false,
                                featureType: FeatureType.pic,
                                child: CustomProfileImage(
                                  width: 40,
                                  height: 40,
                                  onTap: () => System().navigateToProfile(context, data.email ?? ''),
                                  imageUrl: System().showUserPicture(data.avatar == null ? '' : data.avatar?.mediaEndpoint),
                                  badge: data.urluserBadge,
                                  following: true,
                                  onFollow: () {},
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    )
            ],
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }
}
