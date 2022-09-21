import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep5 extends StatefulWidget {
  const VerificationIDStep5({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep5> createState() => _VerificationIDStep5State();
}

class _VerificationIDStep5State extends State<VerificationIDStep5> {
  @override
  void initState() {
    final ntfr = Provider.of<VerificationIDNotifier>(context, listen: false);
    ntfr.isLoading = true;
    Future.delayed(const Duration(seconds: 2), () {
      print("CARDNAME => " + ntfr.idCardName);
      print("CARDNUM => " + ntfr.idCardNumber);
      if (ntfr.idCardName == "" || ntfr.idCardNumber == "") {
        ShowBottomSheet.onShowIDVerificationFailed(context);
      }
      ntfr.isLoading = false;
    });

    super.initState();
  }

//ShowBottomSheet.onShowIDVerificationFailed(context);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retryTakeIdCard();
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.retryTakeIdCard(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.idVerification!,
              textStyle:
                  Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
            ),
            centerTitle: false,
          ),
          body: notifier.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: kHyppePrimary,
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _disabledInputText(
                          title: notifier.language.realName!,
                          value: notifier.idCardName.toUpperCase()),
                      if (notifier.errorName != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      _disabledInputText(
                          title: notifier.language.eKtpNumber!,
                          value: notifier.idCardNumber,
                          infoIcon: true),
                      if (notifier.errorKtp != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorKtp,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      CustomTextWidget(
                        textToDisplay: notifier.language.gender!,
                        textStyle:
                            textTheme.bodySmall!.copyWith(color: kHyppePrimary),
                      ),
                      // TextFormField(
                      //   maxLines: 1,
                      //   validator: (String? input) {
                      //     if (input?.isEmpty ?? true) {
                      //       return notifier.language.selectGenderInfo!;
                      //     } else {
                      //       return null;
                      //     }
                      //   },
                      //   enabled: false,
                      //   keyboardAppearance: Brightness.dark,
                      //   cursorColor: const Color(0xff8A3181),
                      //   textInputAction: TextInputAction.newline,
                      //   style: textTheme.bodyText2,
                      //   controller: notifier.genderController,
                      //   decoration: InputDecoration(
                      //     errorBorder: InputBorder.none,
                      //     hintStyle: textTheme.bodyText2,
                      //     enabledBorder: InputBorder.none,
                      //     focusedBorder: InputBorder.none,
                      //     disabledBorder: InputBorder.none,
                      //     focusedErrorBorder: InputBorder.none,
                      //     counterText: "",
                      //     contentPadding:
                      //         const EdgeInsets.symmetric(vertical: 5),
                      //     isDense: true,
                      //     border: InputBorder.none,
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          notifier.genderOnTap(context);
                        },
                        child: Stack(
                          children: [
                            const Align(
                              alignment: Alignment(0.975, 1),
                              heightFactor: 1,
                              child: RotatedBox(
                                quarterTurns: -45,
                                child: CustomIconWidget(
                                    iconData:
                                        "${AssetPath.vectorPath}back-arrow.svg"),
                              ),
                            ),
                            TextFormField(
                              maxLines: 1,
                              validator: (String? input) {
                                if (input?.isEmpty ?? true) {
                                  return notifier.language.selectGenderInfo!;
                                } else {
                                  return null;
                                }
                              },
                              enabled: false,
                              keyboardAppearance: Brightness.dark,
                              cursorColor: const Color(0xff8A3181),
                              textInputAction: TextInputAction.newline,
                              style: textTheme.bodyText2,
                              controller: notifier.genderController,
                              decoration: InputDecoration(
                                errorBorder: InputBorder.none,
                                hintStyle: textTheme.bodyText2,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                counterText: "",
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDivider(context),
                      if (notifier.errorGender != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorGender,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      CustomTextWidget(
                        textToDisplay: notifier.language.placeBirth!,
                        textStyle:
                            textTheme.bodySmall!.copyWith(color: kHyppePrimary),
                      ),
                      TextFormField(
                        maxLines: 1,
                        validator: (String? input) {
                          if (input?.isEmpty ?? true) {
                            return notifier.language.placeBirthNote!;
                          } else {
                            return null;
                          }
                        },
                        keyboardAppearance: Brightness.dark,
                        cursorColor: const Color(0xff8A3181),
                        textInputAction: TextInputAction.newline,
                        style: textTheme.bodyText2,
                        controller: notifier.birtPlaceController,
                        decoration: InputDecoration(
                          errorBorder: InputBorder.none,
                          hintStyle: textTheme.bodyText2,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: "",
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                      _buildDivider(context),
                      CustomTextWidget(
                        textToDisplay: notifier.language.placeBirthNote!,
                        textStyle: textTheme.bodySmall,
                      ),
                      if (notifier.errorPlaceBirth != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorPlaceBirth,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      CustomTextWidget(
                        textToDisplay: notifier.language.dateOfBirth!,
                        textStyle:
                            textTheme.bodySmall!.copyWith(color: kHyppePrimary),
                      ),
                      TextFormField(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: notifier.selectedBirthDate,
                              firstDate: DateTime(1900),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary:
                                          kHyppePrimary, // header background color
                                      onPrimary:
                                          Colors.white, // header text color
                                      onSurface:
                                          kHyppeTextLightPrimary, // body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        primary:
                                            kHyppePrimary, // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              });

                          if (pickedDate != null &&
                              pickedDate != notifier.selectedBirthDate) {
                            notifier.selectedBirthDate = pickedDate;
                          }
                        },
                        readOnly: true,
                        maxLines: 1,
                        keyboardAppearance: Brightness.dark,
                        cursorColor: const Color(0xff8A3181),
                        textInputAction: TextInputAction.newline,
                        style: textTheme.bodyText2,
                        controller: notifier.birtDateController,
                        decoration: InputDecoration(
                          errorBorder: InputBorder.none,
                          hintStyle: textTheme.bodyText2,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: "",
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                      _buildDivider(context),
                      CustomTextWidget(
                        textToDisplay: notifier.language.selectDateBirthInfo!,
                        textStyle: textTheme.bodySmall,
                      ),
                      if (notifier.errorDateBirth != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorDateBirth,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: CustomRichTextWidget(
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              textSpan: TextSpan(
                                  style: textTheme.bodyText2!
                                      .copyWith(color: kHyppeLightSecondary),
                                  text: notifier.language.confirmIdGenuine!),
                            ),
                          ),
                          Checkbox(
                            checkColor: Colors.white,
                            value: notifier.acceptTos,
                            onChanged: (e) =>
                                notifier.acceptTos = !notifier.acceptTos,
                          )
                        ],
                      ),
                      const SizedBox(height: 70),
                      CustomRichTextWidget(
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        textSpan: TextSpan(
                            style: textTheme.bodyText2!
                                .copyWith(color: kHyppeLightSecondary),
                            text: notifier.language.confirmIdNotice!),
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.retakeIdPicture!,
                          textStyle: Theme.of(context)
                              .textTheme
                              .button!
                              .copyWith(color: kHyppePrimary),
                        ),
                        width: double.infinity,
                        height: 50 * SizeConfig.scaleDiagonal,
                        function: () => notifier.retryTakeIdCard(),
                        buttonStyle: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                      ),
                      const SizedBox(height: 5),
                      CustomElevatedButton(
                        width: SizeConfig.screenWidth,
                        height: 44.0 * SizeConfig.scaleDiagonal,
                        function: () => notifier.continueSelfie(context),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.continueSelfie!,
                          textStyle: textTheme.button
                              ?.copyWith(color: kHyppeLightButtonText),
                        ),
                        buttonStyle: notifier.step5CanNext
                            ? ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryVariant),
                                shadowColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryVariant),
                                overlayColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryVariant),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryVariant),
                              )
                            : ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.secondary),
                                shadowColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.secondary),
                                overlayColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.secondary),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.secondary),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.dataDidntShow!,
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => Routing().moveAndRemoveUntil(
                              Routes.verificationIDStepSupportDocsEula,
                              Routes.verificationIDStepSupportDocsEula),
                          child: RichText(
                            text: TextSpan(
                              text: notifier.language.tapHere!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: kHyppePrimary),
                              children: <TextSpan>[
                                TextSpan(
                                  text: notifier.language.toAppeal!,
                                  style: const TextStyle(
                                      color: kHyppeTextLightPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _disabledInputText(
      {required String title, required String value, bool? infoIcon}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: title,
          textStyle: textTheme.bodySmall,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              textToDisplay: value,
              textStyle: textTheme.bodyLarge,
            ),
            if (infoIcon != null && infoIcon)
              GestureDetector(
                onTap: () => ShowBottomSheet.onShowInfoIDCard(context),
                child: const CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}info-icon.svg"),
              )
          ],
        ),
        const SizedBox(height: 10),
        _buildDivider(context),
      ],
    );
  }

  Widget _buildDivider(context) => Divider(
      thickness: 1.0,
      color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));
}
