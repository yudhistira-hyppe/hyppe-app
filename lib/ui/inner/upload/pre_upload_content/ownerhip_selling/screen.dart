import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_check_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../constant/widget/custom_currency_input_formatter.dart';

class OwnershipSellingScreen extends StatefulWidget {
  const OwnershipSellingScreen({Key? key}) : super(key: key);

  @override
  State<OwnershipSellingScreen> createState() => _OwnershipSellingScreenState();
}

class _OwnershipSellingScreenState extends State<OwnershipSellingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var nn = Provider.of<PreUploadContentNotifier>(context, listen: false);
      nn.getSettingApps(context);
    });
  }

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
              notifier.submitOwnership(context);
            },
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: CustomTextWidget(
            textToDisplay: notifier.language.ownershipSelling ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: notifier.isloadingSetting
            ? const Center(child: const CustomLoading())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.language.registerContentOwnership ?? '',
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
                      notifier.certified && notifier.canSale
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  textToDisplay: notifier.language.sellContent ?? '',
                                  textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                                ),
                                CustomSwitchButton(
                                  value: notifier.toSell,
                                  onChanged: (value) {
                                    final enable = !notifier.checkChallenge;
                                    if (enable) {
                                      notifier.toSell = value;
                                      notifier.includeTotalViews = false;
                                      notifier.includeTotalLikes = false;
                                      notifier.priceController.clear();
                                    } else {
                                      // ShowGeneralDialog.showToastAlert(
                                      //   context,
                                      //   'asdasdasdasd',
                                      //   () async {},
                                      // );
                                      ShowBottomSheet().onShowColouredSheet(
                                        context,
                                        'Tidak dapat menjual konten ini',
                                        subCaption: 'Kamu tidak dapat menjual konten ini karena konten ini sedang terdaftar di challenge',
                                        maxLines: 3,
                                        borderRadius: 8,
                                        color: kHyppeBorderDanger,
                                        iconSvg: "${AssetPath.vectorPath}info-moderate.svg",
                                        iconColor: Colors.white,
                                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
                                        margin: EdgeInsets.only(left: 10, right: 10, bottom: SizeConfig.scaleDiagonal * 60),
                                        closeWidget: GestureDetector(
                                          onTap: () => Routing().moveBack(),
                                          child: const CustomIconWidget(
                                            iconData: "${AssetPath.vectorPath}close_ads.svg",
                                            defaultColor: false,
                                            color: Colors.white,
                                          ),
                                        ),
                                        sizeIcon: 20,
                                        barrierColor: Colors.transparent,
                                      );
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
                              textToDisplay: notifier.language.marketContent1 ?? '',
                              textStyle: Theme.of(context).textTheme.caption ?? const TextStyle(),
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
                                          notifier.language.includeTotalViews ?? '',
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                        CustomCheckButton(
                                          value: notifier.includeTotalViews,
                                          onChanged: (value) => notifier.includeTotalViews = value ?? false,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notifier.language.includeTotalLikes ?? '',
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                      CustomCheckButton(
                                          value: notifier.includeTotalLikes,
                                          onChanged: (value) {
                                            //print("Like" + value.toString());
                                            notifier.includeTotalLikes = value ?? false;
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
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.all(Radius.circular(8))
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
                                        notifier.checkValidasi();
                                      },
                                      keyboardAppearance: Brightness.dark,
                                      cursorColor: const Color(0xff8A3181),
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()], // Only numbers can be entered
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
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 18, left: 10),
                                    child: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                                      height: 18,
                                      defaultColor: false,
                                    ),
                                    // Text(
                                    //   notifier.language.rp ?? 'Rp',
                                    //   style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                                    // ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () => FocusScope.of(context).unfocus(),
                                      child: Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: notifier.priceController.text != '' ? kHyppePrimary : kHyppeDisabled),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        child: Text(
                                          notifier.language.setPrice ?? '',
                                          style: Theme.of(context).textTheme.caption?.copyWith(color: notifier.priceController.text != '' ? kHyppeLightButtonText : kHyppeSecondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        notifier.toSell && notifier.isWarning && notifier.priceController.text != ''
                            ? CustomTextWidget(
                                textAlign: TextAlign.start,
                                textToDisplay:
                                    notifier.language.localeDatetime == 'id' ? 'Wajib diisi dengan harga kelipatan = 10 (contoh 10, 20,...dst)' : 'Price must be a multiple of 10 (e.g., 10, 20, etc.)',
                                textStyle: const TextStyle(color: kHyppeDanger),
                              )
                            : Container()
                      ]
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: notifier.certified
                ? () {
                    if (!notifier.toSell && (notifier.priceController.text == '' || notifier.priceController.text == '0')) {
                      Routing().moveBack();
                    } else {
                      notifier.submitOwnership(context, withAlert: true);
                    }
                  }
                : null,
            style: ButtonStyle(backgroundColor: notifier.certified ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
            child: CustomTextWidget(
              textToDisplay: notifier.language.confirm ?? 'confirm',
              textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
