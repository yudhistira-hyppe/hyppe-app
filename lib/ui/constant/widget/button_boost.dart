import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ButtonBoost extends StatefulWidget {
  final ContentData? contentData;
  final bool marginBool;
  final bool onDetail;
  final Function? startState;
  final Function? afterState;
  const ButtonBoost({Key? key, this.contentData, this.marginBool = false, this.startState, this.afterState, this.onDetail = true}) : super(key: key);
  @override
  State<ButtonBoost> createState() => _ButtonBoostState();
}

class _ButtonBoostState extends State<ButtonBoost> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    final language = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Container(
      margin: EdgeInsets.all(widget.marginBool ? 0.0 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isKyc == VERIFIED
            ? (widget.contentData?.boosted.isEmpty ?? [].isEmpty)
                ? kHyppePrimary
                : kHyppeDisabled
            : kHyppeDisabled,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isKyc == VERIFIED
                ? () async {
                    bool isPanding = false;
                    setState(() {
                      isLoading = true;
                    });
                    await Provider.of<TransactionNotifier>(context, listen: false).checkTransPanding(context).then((value) {
                      isPanding = value;

                      setState(() {
                        isLoading = false;
                      });
                    });
                    if (isPanding) {
                      globalAliPlayer?.pause();
                      await ShowBottomSheet().onShowColouredSheet(
                        context,
                        language.otherPostsInProcessOfPayment ?? '',
                        subCaption: language.thePostisintheProcessofPayment,
                        subCaptionButton: language.viewPaymentStatus,
                        color: kHyppeRed,
                        iconSvg: '${AssetPath.vectorPath}remove.svg',
                        maxLines: 10,
                        functionSubCaption: () {
                          Routing().moveAndPop(Routes.transaction);
                        },
                      );
                      globalAliPlayer?.play();
                      return;
                    }

                    final notifier = Provider.of<PreUploadContentNotifier>(context, listen: false);
                    notifier.editData = widget.contentData;
                    notifier.isEdit = true;
                    notifier.isUpdate = true;
                    notifier.captionController.text = widget.contentData?.description ?? "";
                    notifier.tagsController.text = widget.contentData?.tags?.join(",") ?? '';
                    notifier.featureType = System().getFeatureTypeV2(widget.contentData?.postType ?? '');

                    notifier.thumbNail = widget.contentData?.fullThumbPath;
                    notifier.allowComment = widget.contentData?.allowComments ?? false;
                    notifier.certified = widget.contentData?.certified ?? false;
                    notifier.ownershipEULA = widget.contentData?.certified ?? false;

                    if (widget.contentData?.location != '') {
                      notifier.locationName = widget.contentData?.location ?? '';
                    } else {
                      notifier.locationName = notifier.language.addLocation ?? '';
                    }
                    notifier.privacyTitle = widget.contentData?.visibility ?? '';

                    notifier.privacyValue = widget.contentData?.visibility ?? '';
                    final _isoCodeCache = SharedPreference().readStorage(SpKeys.isoCode);

                    if (_isoCodeCache == 'id') {
                      switch (widget.contentData?.visibility ?? '') {
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
                      notifier.privacyValue = widget.contentData?.visibility ?? '';
                    }

                    notifier.interestData = [];
                    if (widget.contentData?.cats != null) {
                      widget.contentData?.cats!.map((val) {
                        notifier.interestData.add(val.id ?? '');
                      }).toList();
                    }
                    notifier.userTagData = [];
                    if (widget.contentData?.tagPeople != null) {
                      widget.contentData?.tagPeople!.map((val) {
                        notifier.userTagData.add(val.username ?? '');
                      }).toList();
                    }
                    notifier.userTagDataReal = [];
                    notifier.userTagDataReal.addAll(widget.contentData?.tagPeople ?? []);

                    notifier.toSell = widget.contentData?.saleAmount != null && (widget.contentData?.saleAmount ?? 0) > 0 ? true : false;
                    notifier.includeTotalViews = widget.contentData?.saleView ?? false;
                    notifier.includeTotalLikes = widget.contentData?.saleLike ?? false;
                    notifier.certified = widget.contentData?.certified ?? false;
                    notifier.priceController.text = widget.contentData?.saleAmount?.toInt().toString() ?? '';

                    if (widget.startState != null) {
                      widget.startState!();
                    }

                    globalAliPlayer?.pause();
                    await Routing()
                        .move(
                      Routes.preUploadContent,
                      argument: UpdateContentsArgument(onEdit: true, contentData: widget.contentData, content: ''),
                    )
                        .whenComplete(() {
                      if (widget.afterState != null) {
                        widget.afterState!();
                      }
                      if (widget.onDetail) Routing().moveBack();
                    });

                    globalAliPlayer?.play();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isKyc == VERIFIED && (widget.contentData?.boosted.isEmpty ?? [].isEmpty) ? kHyppePrimary : kHyppeLightInactive1,
                borderRadius: BorderRadius.circular(8),
              ),
              width: SizeConfig.screenWidth,
              child: isLoading
                  ? const CustomLoading(
                      size: 3,
                    )
                  : Center(
                    child: Text(
                        language.postBoost ?? 'Boost Post',
                        style: Theme.of(context).primaryTextTheme.subtitle2?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
