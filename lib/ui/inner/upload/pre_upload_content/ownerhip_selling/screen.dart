import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_check_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:provider/provider.dart';

class OwnershipSellingScreen extends StatelessWidget {
  const OwnershipSellingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<PreUploadContentNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: CustomIconButtonWidget(
            onPressed: () {
              notifier.submitOwnership();
            },
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: CustomTextWidget(
            textToDisplay: notifier.language.ownershipSelling!,
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.registerContentOwnership!,
                    textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                  ),
                  CustomCheckButton(
                    value: notifier.certified,
                    onChanged: (value) {
                      if (notifier.isEdit && notifier.certified && notifier.ownershipEULA) {
                      } else {
                        notifier.onOwnershipEULA(context);
                      }
                    },
                    disable: notifier.isEdit && notifier.certified && notifier.ownershipEULA,
                  ),
                ],
              ),
              notifier.certified
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextWidget(
                          textToDisplay: notifier.language.sellContent!,
                          textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        CustomSwitchButton(
                          value: notifier.toSell,
                          onChanged: (value) {
                            notifier.toSell = value;
                            if (!notifier.toSell) {
                              notifier.includeTotalViews = false;
                              notifier.toSell = false;
                              notifier.includeTotalLikes = false;
                              notifier.priceController.clear();
                            }
                          },
                        ),
                      ],
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  fivePx,
                  Expanded(
                    child: CustomTextWidget(
                      textToDisplay: notifier.language.marketContent1!,
                      textStyle: Theme.of(context).textTheme.caption!,
                      maxLines: 3,
                      textAlign: TextAlign.start,
                    ),
                  )
                ],
              ),
              if (notifier.certified) ...[
                SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                notifier.toSell
                    ? Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notifier.language.includeTotalViews!,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                CustomCheckButton(
                                  value: notifier.includeTotalViews,
                                  onChanged: (value) => notifier.includeTotalViews = value!,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notifier.language.includeTotalLikes!,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              CustomCheckButton(
                                  value: notifier.includeTotalLikes,
                                  onChanged: (value) {
                                    //print("Like" + value.toString());
                                    notifier.includeTotalLikes = value!;
                                  }),
                            ],
                          ),
                          SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                        ],
                      )
                    : Container(),
                notifier.toSell
                    ? Stack(
                        alignment: AlignmentDirectional.bottomStart,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 35, right: 10),
                            decoration: const BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1), borderRadius: BorderRadius.all(Radius.circular(8))
                                // border: Border(
                                //   bottom: BorderSide(
                                //     color:
                                //         Color.fromRGBO(171, 34, 175, 1),
                                //     width: 0.5,
                                //   ),
                                // ),
                                ),
                            child: TextFormField(
                              maxLines: 1,
                              validator: (String? input) {
                                if (input?.isEmpty ?? true) {
                                  return notifier.language.pleaseSetPrice;
                                } else {
                                  return null;
                                }
                              },
                              enabled: notifier.isSavedPrice ? false : true,
                              controller: notifier.priceController,
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  notifier.priceIsFilled = true;
                                } else {
                                  notifier.priceIsFilled = false;
                                }
                              },
                              keyboardAppearance: Brightness.dark,
                              cursorColor: const Color(0xff8A3181),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()], // Only numbers can be entered
                              style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                errorBorder: InputBorder.none,
                                hintStyle: textTheme.bodyText2,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18, left: 10),
                            child: Text(
                              notifier.language.rp!,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 8,
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: notifier.priceController.text != '' ? kHyppePrimary : kHyppeDisabled),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                notifier.language.setPrice!,
                                style: Theme.of(context).textTheme.caption!.copyWith(color: notifier.priceController.text != '' ? kHyppeLightButtonText : kHyppeSecondary),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                notifier.toSell && notifier.priceController.text == ''
                    ? CustomTextWidget(
                        textAlign: TextAlign.start,
                        textToDisplay: notifier.language.mustFilledFirst!,
                        textStyle: const TextStyle(color: kHyppeDanger),
                      )
                    : Container()
              ]
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: notifier.certified
                ? () {
                    if (notifier.toSell && notifier.priceController.text == '') {
                      return null;
                    } else {
                      notifier.submitOwnership();
                    }
                  }
                : null,
            style: ButtonStyle(backgroundColor: notifier.certified ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
            child: CustomTextWidget(
              textToDisplay: notifier.language.confirm!,
              textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
