import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:provider/provider.dart';

class BoostUploadScreen extends StatelessWidget {
  const BoostUploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.exitBoostPage();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leading: CustomIconButtonWidget(
              onPressed: () => notifier.exitBoostPage(),
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: CustomTextWidget(
              textToDisplay: notifier.language.postBoost ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: notifier.isLoading
              ? const Center(child: CustomLoading())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              notifier.isEdit
                                  ? Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CustomBaseCacheImage(
                                        widthPlaceHolder: 80,
                                        heightPlaceHolder: 80,
                                        imageUrl: notifier.editData?.isApsara ?? false ? (notifier.editData?.mediaThumbEndPoint ?? '') : '${notifier.editData?.fullThumbPath}',
                                        imageBuilder: (context, imageProvider) => Container(
                                          // margin: margin,
                                          // // const EdgeInsets.symmetric(horizontal: 4.5),
                                          // width: _scaling,
                                          height: 168,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          print('errorWidget :  $error');
                                          return Container(
                                            // margin: margin,
                                            // // const EdgeInsets.symmetric(horizontal: 4.5),
                                            // width: _scaling,
                                            height: 186,
                                            // child: _buildBody(context),
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
                                                image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          );
                                        },
                                        emptyWidget: Container(
                                          // margin: margin,
                                          // // const EdgeInsets.symmetric(horizontal: 4.5),
                                          // width: _scaling,
                                          height: 186,
                                          // child: _buildBody(context),
                                          decoration: BoxDecoration(
                                            image: const DecorationImage(
                                              image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const ValidateType(editContent: false),
                                    ),
                              sixPx,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 6,
                                    ),
                                    child: CustomTextWidget(
                                      textToDisplay: System().convertTypeContent(
                                        System().validatePostTypeV2(notifier.featureType),
                                      ),
                                      textStyle: Theme.of(context).textTheme.caption?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.screenWidth! * 0.55,
                                    child: Text(
                                      notifier.captionController.text,
                                      style: Theme.of(context).textTheme.caption?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 4,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        fifteenPx,
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        fifteenPx,
                        Text(notifier.language.startDate ?? 'Start Date'),
                        tenPx,
                        GestureDetector(
                          onTap: () async {
                            final date = DateTime.now();
                            final startDate = DateTime(date.year, date.month, date.day + 1);
                            final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: notifier.tmpstartDate == DateTime(1000) ? startDate : notifier.tmpstartDate,
                                firstDate: startDate,
                                lastDate: DateTime(3000),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: kHyppePrimary, // header background color
                                        onPrimary: Colors.white, // header text color
                                        onSurface: kHyppeTextLightPrimary, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          primary: kHyppePrimary, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child ?? Container(),
                                  );
                                });
                            if (pickedDate != null && pickedDate != notifier.tmpstartDate) {
                              notifier.tmpstartDate = pickedDate;
                              notifier.tmpfinsihDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day + 30);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notifier.tmpstartDate == DateTime(1000)
                                    ? '00/00/0000'
                                    : "${System().dateFormatter(notifier.tmpstartDate.toString(), 5)} - ${System().dateFormatter(notifier.tmpfinsihDate.toString(), 5)}",
                                style: Theme.of(context).primaryTextTheme.bodyLarge,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: CustomIconWidget(iconData: "${AssetPath.vectorPath}calendar.svg"),
                              )
                            ],
                          ),
                        ),
                        tenPx,
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          groupValue: notifier.tmpBoost,
                          value: 'automatic',
                          onChanged: (val) {
                            notifier.tmpBoost = val ?? '';
                            notifier.tmpBoostTime = '';
                            notifier.tmpBoostInterval = '';
                            notifier.tmpBoostIntervalId = '';
                            notifier.tmpBoostTimeId = '';
                          },
                          title: CustomTextWidget(
                            textAlign: TextAlign.left,
                            textToDisplay: notifier.language.autoSelect ?? 'automatic',
                            textStyle: Theme.of(context).primaryTextTheme.bodyText2?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          activeColor: Theme.of(context).colorScheme.primaryVariant,
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          groupValue: notifier.tmpBoost,
                          value: 'manual',
                          onChanged: (val) {
                            notifier.tmpBoost = val ?? '';
                          },
                          title: CustomTextWidget(
                            textAlign: TextAlign.left,
                            textToDisplay: notifier.language.selectManual ?? 'manual',
                            textStyle: Theme.of(context).primaryTextTheme.bodyText2?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          activeColor: Theme.of(context).colorScheme.primaryVariant,
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        sixteenPx,
                        notifier.tmpBoostTime == ''
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(notifier.language.boostTime ?? 'Boost Time'),
                              ),
                        GestureDetector(
                          onTap: notifier.tmpBoost == 'manual'
                              ? () async {
                                  ShowBottomSheet.onShowBoostTime(context);
                                }
                              : null,
                          child: Material(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  textAlign: TextAlign.left,
                                  textToDisplay: notifier.tmpBoostTime == '' ? notifier.language.boostTime ?? 'Boost Time' : notifier.tmpBoostTime,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                                        color: notifier.tmpBoost == 'manual' ? kHyppeLightSecondary : kHyppeDisabled,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 15,
                                    color: kHyppeDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        sixteenPx,
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        tenPx,
                        notifier.tmpBoostInterval == ''
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(notifier.language.interval ?? 'Interval'),
                              ),
                        GestureDetector(
                          onTap: notifier.tmpBoost == 'manual'
                              ? () async {
                                  ShowBottomSheet.onShowBoostInterval(context);
                                }
                              : null,
                          child: Material(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  textAlign: TextAlign.left,
                                  textToDisplay: notifier.tmpBoostInterval == '' ? notifier.language.interval ?? 'Interval' : notifier.tmpBoostInterval,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                                        color: notifier.tmpBoost == 'manual' ? kHyppeLightSecondary : kHyppeDisabled,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 15,
                                    color: kHyppeDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        sixteenPx,
                        Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                        twentyFourPx,
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: kHyppeLightInactive1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Text(
                            notifier.language.contentWillbeBoostedfor30days ?? '',
                            style: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextButton(
              onPressed: notifier.isLoading
                  ? null
                  : notifier.enableBoostConfirm()
                      ? () {
                          notifier.boostButton(context);
                        }
                      : null,
              style: ButtonStyle(backgroundColor: notifier.enableBoostConfirm() ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
              child: notifier.isLoading
                  ? const SizedBox(height: 20, child: CustomLoading())
                  : CustomTextWidget(
                      textToDisplay: notifier.language.confirm ?? 'confirm',
                      textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
