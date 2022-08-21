import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnShowOptionContent extends StatefulWidget {
  final String captionTitle;
  final bool onDetail;
  final ContentData contentData;

  const OnShowOptionContent({
    Key? key,
    required this.contentData,
    required this.captionTitle,
    this.onDetail = true,
  }) : super(key: key);

  @override
  State<OnShowOptionContent> createState() => _OnShowOptionContentState();
}

class _OnShowOptionContentState extends State<OnShowOptionContent> with GeneralMixin {
  final _routing = Routing();
  final _system = System();
  final _language = TranslateNotifierV2();

  void _handleDelete(BuildContext context) {
    _routing.moveBack();
    _routing.moveBack();
    if (widget.onDetail) _routing.moveBack();
    context.read<SelfProfileNotifier>().onDeleteSelfPostContent(
          context,
          postID: widget.contentData.postID!,
          content: widget.captionTitle,
        );
    context.read<HomeNotifier>().onDeleteSelfPostContent(
          context,
          postID: widget.contentData.postID!,
          content: widget.captionTitle,
        );
    _showMessage('${_language.translate.yourContentHadSuccessfullyDeleted}');
  }

  void _handleLink(BuildContext context, {required bool copiedToClipboard, required String description, required ContentData data}) async {
    late String _routes;

    if (description == hyppeVid) {
      _routes = Routes.vidDetail;
    } else if (description == hyppeDiary) {
      _routes = Routes.diaryDetail;
    } else if (description == hyppePic) {
      _routes = Routes.picDetail;
    } else if (description == hyppeStory) {
      _routes = Routes.storyDetail;
    }

    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: _routes,
        postID: data.postID,
        fullName: data.username,
        description: data.description ?? "",
        thumb: '${data.fullThumbPath}',
      ),
      copiedToClipboard: copiedToClipboard,
    ).then((value) {
      if (value) {
        if (copiedToClipboard) _showMessage('Link Copied');
      }
    });
  }

  void _showMessage(String message) {
    // show message
    _routing.showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              fromSnackBar: true,
              textOverflow: TextOverflow.visible,
            ),
          ),
        ),
        backgroundColor: kHyppeTextSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              sixteenPx,
              CustomTextWidget(
                textToDisplay: widget.captionTitle,
                // '$captionTitle ${contentData?.content.length == 1 ? contentData?.content.length : contentIndex} of ${contentData?.content.length}',
                textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _tileComponent(
                moveBack: true,
                caption: '${TranslateNotifierV2().translate.copyLink}',
                icon: 'copy-link.svg',
                onTap: () => _handleLink(context, copiedToClipboard: true, description: widget.captionTitle, data: widget.contentData),
              ),
              _tileComponent(
                moveBack: false,
                caption: '${TranslateNotifierV2().translate.share}',
                icon: 'share.svg',
                onTap: () => _handleLink(context, copiedToClipboard: false, description: widget.captionTitle, data: widget.contentData),
              ),
              if (_system.getFeatureTypeV2(widget.contentData.postType!) != FeatureType.story) ...[
                _tileComponent(
                  moveBack: false,
                  caption: '${TranslateNotifierV2().translate.edit}',
                  icon: 'edit-content.svg',
                  onTap: () {
<<<<<<< HEAD
                    final notifier = Provider.of<PreUploadContentNotifier>(context, listen: false);
                    notifier.isEdit = true;
                    notifier.captionController.text = widget.contentData.description ?? "";
                    notifier.tagsController.text = widget.contentData.tags!.join(",");
                    notifier.featureType = _system.getFeatureTypeV2(widget.contentData.postType!);
=======
                    final notifier = Provider.of<PreUploadContentNotifier>(
                        context,
                        listen: false);
                    notifier.isUpdate = true;
                    notifier.captionController.text =
                        widget.contentData.description ?? "";
                    notifier.tagsController.text =
                        widget.contentData.tags!.join(",");
                    notifier.featureType =
                        _system.getFeatureTypeV2(widget.contentData.postType!);
>>>>>>> 572f1c3d4fcecad21e7558364b5396c0bbfee4c1
                    notifier.thumbNail = widget.contentData.fullThumbPath;
                    notifier.allowComment = widget.contentData.allowComments ?? false;
                    notifier.certified = widget.contentData.certified ?? false;
<<<<<<< HEAD
                    if (widget.contentData.location != null) {
                      notifier.locationName = widget.contentData.location!;
                    }

                    notifier.privacyTitle = widget.contentData.visibility!;

                    notifier.privacyValue = widget.contentData.visibility!;
                    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);
                    print('widget.contentData.visibility');
                    print(widget.contentData.visibility);
                    if (_isoCodeCache == 'id') {
                      switch (widget.contentData.visibility!) {
                        case 'PUBLIC':
                          notifier.privacyTitle = 'Umum';
                          break;
                        case 'FRIEND':
                          notifier.privacyTitle = 'Teman';
                          break;
                        case 'PRIVATE':
                          notifier.privacyTitle = 'Hanya saya';
                          break;
                        default:
                      }
                    } else {
                      notifier.privacyValue = widget.contentData.visibility!;
                    }

                    notifier.interestData = [];
                    if (widget.contentData.cats != null) {
                      widget.contentData.cats!.map((val) {
                        notifier.interestData.add(val.interestName!);
                      }).toList();
                    }
                    notifier.userTagData = [];
                    if (widget.contentData.tagPeople != null) {
                      widget.contentData.tagPeople!.map((val) {
                        notifier.userTagData.add(val.username!);
                      }).toList();
                    }
                    notifier.userTagDataReal = [];
                    notifier.userTagDataReal.addAll(widget.contentData.tagPeople!);

=======
                    notifier.toSell = widget.contentData.saleAmount != null &&
                            widget.contentData.saleAmount! > 0
                        ? true
                        : false;
                    notifier.includeTotalViews =
                        widget.contentData.saleView ?? false;
                    notifier.includeTotalLikes =
                        widget.contentData.saleLike ?? false;
                    notifier.certified = widget.contentData.certified ?? false;
                    notifier.priceController.text =
                        widget.contentData.saleAmount!.toInt().toString();
>>>>>>> 572f1c3d4fcecad21e7558364b5396c0bbfee4c1
                    _routing
                        .move(Routes.preUploadContent,
                            argument: UpdateContentsArgument(
                              onEdit: true,
                              contentData: widget.contentData,
                              content: widget.captionTitle,
                            ))
                        .whenComplete(() => _routing.moveBack());
                  },
                ),
              ],
              _tileComponent(
                moveBack: false,
                caption: '${TranslateNotifierV2().translate.delete}',
                icon: 'delete.svg',
                onTap: () async {
                  ShowGeneralDialog.deleteContentDialog(context, widget.captionTitle.replaceAll('Hyppe', ''), () async {
                    await deletePostByID(context, postID: widget.contentData.postID!, postType: widget.contentData.postType!).then((value) {
                      if (value) _handleDelete(context);
                    });
                  });
                },
              ),
              // _tileComponent(
              //   moveBack: false,
              //   caption: 'Turn off commenting',
              //   icon: 'comment.svg',
              //   onTap: () {},
              // ),
            ],
          ),
        )
      ],
    );
  }

  Widget _tileComponent({
    required String caption,
    required String icon,
    required bool moveBack,
    required Function onTap,
  }) {
    return ListTile(
      onTap: () async {
        await onTap();
        if (moveBack) _routing.moveBack();
      },
      title: CustomTextWidget(
        textAlign: TextAlign.start,
        textToDisplay: caption,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: CustomIconWidget(
        defaultColor: false,
        iconData: "${AssetPath.vectorPath}$icon",
      ),
      minLeadingWidth: 20,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class _interestData {}
