import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/supporting_document/camera_verification.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep5 extends StatefulWidget {
  const VerificationIDStep5({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep5> createState() => _VerificationIDStep5State();
}

class _VerificationIDStep5State extends State<VerificationIDStep5> with AfterFirstLayoutMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStep5');
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final ntfr = context.read<VerificationIDNotifier>();
    // ntfr.initStep5(context);
  }

//ShowBottomSheet.onShowIDVerificationFailed(context);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    // bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retryTakeIdCard();
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.retryTakeIdCard(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.idVerification ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: kHyppeRank4,
                          border: Border.all(color: kHyppeRank2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}info-icon.svg",
                              color: kHyppeTextLightPrimary,
                              defaultColor: false,
                            ),
                            twelvePx,
                            Expanded(
                                child: Text(
                              'Proses verifikasi ini hanya dapat dilakukan satu kali, pastikan data sudah sesuai dengan E-KTP Kamu.',
                              style: TextStyle(fontSize: 10, fontFamily: 'Lato', color: kHyppeTextLightPrimary),
                            )),
                          ],
                        ),
                      ),
                      twentyFourPx,
                      _disabledInputText(title: notifier.language.fullName ?? '', value: notifier.idCardName.toUpperCase()),
                      if (notifier.errorName != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorName,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      _disabledInputText(title: notifier.language.eKtpNumber ?? '', value: notifier.idCardNumber),
                      if (notifier.errorKtp != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorKtp,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      CustomTextWidget(
                        textToDisplay: notifier.language.gender ?? 'gender',
                        textStyle: textTheme.bodySmall?.copyWith(color: kHyppeTextLightPrimary),
                      ),
                      tenPx,
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
                                child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                              ),
                            ),
                            TextFormField(
                              maxLines: 1,
                              validator: (String? input) {
                                if (input?.isEmpty ?? true) {
                                  return notifier.language.selectGenderInfo ?? '';
                                } else {
                                  return null;
                                }
                              },
                              enabled: false,
                              keyboardAppearance: Brightness.dark,
                              cursorColor: const Color(0xff8A3181),
                              textInputAction: TextInputAction.newline,
                              style: textTheme.bodyLarge,
                              controller: notifier.genderController,
                              decoration: InputDecoration(
                                errorBorder: InputBorder.none,
                                hintStyle: textTheme.bodyText2,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(vertical: 5),
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
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      CustomTextWidget(
                        textToDisplay: notifier.language.dateOfBirth ?? '',
                        textStyle: textTheme.bodySmall?.copyWith(color: kHyppeTextLightPrimary),
                      ),
                      tenPx,
                      TextFormField(
                        onTap: () async {
                          ShowBottomSheet.onVerificationDate(context);

                          // final DateTime? pickedDate = await showDatePicker(
                          //     context: context,
                          //     initialDate: notifier.selectedBirthDate,
                          //     firstDate: DateTime(1900),
                          //     lastDate: DateTime.now().add(const Duration(days: 1)),
                          //     builder: (context, child) {
                          //       return Theme(
                          //         data: Theme.of(context).copyWith(
                          //           colorScheme: const ColorScheme.light(
                          //             primary: kHyppePrimary, // header background color
                          //             onPrimary: Colors.white, // header text color
                          //             onSurface: kHyppeTextLightPrimary, // body text color
                          //           ),
                          //           textButtonTheme: TextButtonThemeData(
                          //             style: TextButton.styleFrom(
                          //               primary: kHyppePrimary, // button text color
                          //             ),
                          //           ),
                          //         ),
                          //         child: child ?? Container(),
                          //       );
                          //     });

                          // if (pickedDate != null && pickedDate != notifier.selectedBirthDate) {
                          //   notifier.selectedBirthDate = pickedDate;
                          //   FocusScope.of(context).unfocus();
                          // }
                        },
                        readOnly: true,
                        maxLines: 1,
                        keyboardAppearance: Brightness.dark,
                        cursorColor: const Color(0xff8A3181),
                        textInputAction: TextInputAction.newline,
                        style: textTheme.bodyLarge,
                        controller: notifier.birtDateController,
                        decoration: InputDecoration(
                          errorBorder: InputBorder.none,
                          hintStyle: textTheme.bodyText2,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: "",
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                      _buildDivider(context),
                      if (notifier.errorDateBirth != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorDateBirth,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      CustomTextWidget(
                        textToDisplay: notifier.language.placeBirth ?? '',
                        textStyle: textTheme.bodySmall?.copyWith(color: kHyppeTextLightPrimary),
                      ),
                      tenPx,
                      TextFormField(
                        maxLines: 1,
                        validator: (String? input) {
                          if (input?.isEmpty ?? true) {
                            return notifier.language.placeBirthNote;
                          } else {
                            return null;
                          }
                        },
                        keyboardAppearance: Brightness.dark,
                        cursorColor: const Color(0xff8A3181),
                        textInputAction: TextInputAction.newline,
                        style: textTheme.bodyLarge,
                        controller: notifier.birtPlaceController,
                        decoration: InputDecoration(
                          errorBorder: InputBorder.none,
                          hintStyle: textTheme.bodyText2,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: "",
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                      _buildDivider(context),
                      if (notifier.errorPlaceBirth != '')
                        CustomTextWidget(
                          textToDisplay: notifier.errorPlaceBirth,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                    ],
                  ),
                ),
          bottomSheet: Container(
            // height: 120 * SizeConfig.scaleDiagonal,
            // padding: const EdgeInsets.only(left: 16, right: 16),
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                sixteenPx,
                Container(
                  padding: const EdgeInsets.only(left: 6, right: 16, bottom: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: notifier.acceptTos,
                        activeColor: kHyppePrimary,
                        onChanged: (e) => notifier.checked(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      sixPx,
                      Expanded(
                          child: Text(
                        notifier.language.confirmIdGenuine ?? '',
                        style: const TextStyle(fontSize: 12),
                      ))
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: CustomElevatedButton(
                    width: SizeConfig.screenWidth,
                    height: 44.0 * SizeConfig.scaleDiagonal,
                    // function: () => notifier.step5CanNext ? notifier.continueSelfie(context) : null,
                    function: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraVerification(),
                          ));
                    },
                    buttonStyle: notifier.step5CanNext
                        ? ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                            shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                            overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          )
                        : ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                            shadowColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                            overlayColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                            backgroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                          ),
                    child: CustomTextWidget(
                      textToDisplay: notifier.language.agreeAndContinue ?? '',
                      textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // GestureDetector(
                //   onTap: () => Routing().moveBack(),
                //   child: Text(
                //     notifier.language.cancel ?? 'cancel',
                //     style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // thirtyTwoPx,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _disabledInputText({required String title, required String value, bool? infoIcon}) {
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
                child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}info-icon.svg"),
              )
          ],
        ),
        const SizedBox(height: 10),
        _buildDivider(context),
      ],
    );
  }

  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1));
}
