import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/view_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:provider/provider.dart';

class OnShowUserViewContentBottomSheet extends StatefulWidget {
  final String postId;
  final String eventType;
  final String title;

  OnShowUserViewContentBottomSheet({
    Key? key,
    required this.postId,
    required this.eventType,
    required this.title,
  }) : super(key: key);

  @override
  State<OnShowUserViewContentBottomSheet> createState() => _OnShowUserViewContentBottomSheetState();
}

class _OnShowUserViewContentBottomSheetState extends State<OnShowUserViewContentBottomSheet> with GeneralMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? lastInputValue;

  @override
  void initState() {
    super.initState();
    var likeNotifier = Provider.of<LikeNotifier>(context, listen: false);
    likeNotifier.skip = 0;
    likeNotifier.listLikeView = [];
    likeNotifier.getLikeView(context, widget.postId, widget.eventType, 10);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<LikeNotifier>(
      builder: (context, notifier, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
              notifier.isLoading
                  ? const Center(child: CustomLoading())
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifier.listLikeView?.length,
                      itemBuilder: (context, index) {
                        final data = notifier.listLikeView?[index];
                        // print(System().showUserPicture(value[index].avatar));
                        if(data != null){
                          return Column(
                            children: [
                              ListTile(
                                onTap: () => System().navigateToProfile(context, data.email ?? ''),
                                contentPadding: EdgeInsets.zero,
                                title: CustomTextWidget(
                                  textToDisplay: data.username ?? '',
                                  textStyle: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.start,
                                ),
                                // subtitle: Text("${notifier.searchPeolpleData[index].fullName!}"),
                                // trailing: Consumer<PreUploadContentNotifier>(
                                //   builder: (_, notifier, __) {
                                //     notifier.statusFollow = notifier.label(widget.value[index].status!);
                                //     return SizedBox(
                                //       width: 100,
                                //       child: CustomTextButton(
                                //         child: Text(
                                //           notifier.statusFollow!,
                                //           style: TextStyle(color: widget.value[index].status == 'TOFOLLOW' ? kHyppeTextPrimary : kHyppeLightSecondary),
                                //         ),
                                //         onPressed: widget.value[index].status != 'TOFOLLOW'
                                //             ? null
                                //             : () {
                                //                 notifier.followUser(context, email: widget.value[index].email, index: index).then((value) {
                                //                   if (value) {
                                //                     widget.value[index].status = 'requested';
                                //                     setState(() {});
                                //                   }
                                //                 });
                                //               },
                                //         style: widget.value[index].status == 'TOFOLLOW'
                                //             ? ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary))
                                //             : ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppeLightInactive1)),
                                //       ),
                                //     );
                                //   },
                                // ),

                                leading: StoryColorValidator(
                                  haveStory: false,
                                  featureType: FeatureType.pic,
                                  child: CustomProfileImage(
                                    width: 40,
                                    height: 40,
                                    onTap: () => System().navigateToProfile(context, data.email ?? ''),
                                    imageUrl: System().showUserPicture(data.avatar == null ? '' : data.avatar?.mediaEndpoint),
                                    following: true,
                                    onFollow: () {},
                                  ),
                                ),
                              ),
                            ],
                          );
                        }else{
                          return Container();
                        }

                      },
                    )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }
}
