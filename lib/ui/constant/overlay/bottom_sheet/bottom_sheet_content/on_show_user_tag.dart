import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnShowUserTagBottomSheet extends StatefulWidget {
  final List<TagPeople> value;
  final Function() function;
  final String postId;
  OnShowUserTagBottomSheet({
    Key? key,
    required this.value,
    required this.function,
    required this.postId,
  }) : super(key: key);

  @override
  State<OnShowUserTagBottomSheet> createState() => _OnShowUserTagBottomSheetState();
}

class _OnShowUserTagBottomSheetState extends State<OnShowUserTagBottomSheet> with GeneralMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _notifier = PreUploadContentNotifier();
  String? lastInputValue;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<PreviewVidNotifier>(
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
                    textToDisplay: hyppeVid,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.value.length,
                itemBuilder: (context, index) {
                  // print(System().showUserPicture(value[index].avatar));
                  return Column(
                    children: [
                      ListTile(
                        // onTap: () => notifier.inserTagPeople(index),
                        contentPadding: EdgeInsets.zero,
                        title: CustomTextWidget(
                          textToDisplay: widget.value[index].username!,
                          textStyle: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.start,
                        ),
                        // subtitle: Text("${notifier.searchPeolpleData[index].fullName!}"),
                        trailing: Consumer<PreUploadContentNotifier>(
                          builder: (_, notifier, __) {
                            return notifier.emailcheck(widget.value[index].email)
                                ? SizedBox(
                                    width: 100,
                                    child: CustomTextButton(
                                      onPressed: () {
                                        // notifier.showDeleteMyTag(context, postId);
                                        // ShowGeneralDialog.deleteContentDialog(context, widget.captionTitle.replaceAll('Hyppe', ''), () async {
                                        //   await deletePostByID(context, postID: widget.contentData.postID!, postType: widget.contentData.postType!).then((value) {
                                        //     if (value) _handleDelete(context);
                                        //   });
                                        // });
                                        // deleteMyTag(context, widget.postId);
                                        print(widget.postId);

                                        Routing().moveBack();
                                        ShowGeneralDialog.deleteTagUserContentDialog(context, '', () {
                                          // await deleteMyTag(context, widget.postId).then((value) {
                                          //   // if (value) _handleDelete(context);
                                          // });
                                          // await notifier.deleteMyTag(context, postId);
                                        }, widget.postId);
                                      },
                                      child: Text(
                                        notifier.language.delete!,
                                        style: const TextStyle(color: kHyppePrimary),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 100,
                                    child: CustomTextButton(
                                      child: Text(
                                        notifier.label(widget.value[index].status!),
                                        style: TextStyle(color: widget.value[index].status != 'TOFOLLOW' ? kHyppeTextPrimary : kHyppeLightSecondary),
                                      ),
                                      onPressed: widget.value[index].status != 'TOFOLLOW' ? null : () {},
                                      style: widget.value[index].status != 'TOFOLLOW'
                                          ? ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary))
                                          : ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppeLightInactive1)),
                                    ),
                                  );
                          },
                        ),
                        leading: StoryColorValidator(
                          haveStory: false,
                          featureType: FeatureType.pic,
                          child: CustomProfileImage(
                            width: 40,
                            height: 40,
                            onTap: () {},
                            imageUrl: System().showUserPicture(widget.value[index].avatar == null ? '' : widget.value[index].avatar!.mediaEndpoint),
                            following: true,
                            onFollow: () {},
                          ),
                        ),
                      ),
                    ],
                  );
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
