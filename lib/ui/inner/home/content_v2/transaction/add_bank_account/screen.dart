import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class AddBankAccount extends StatelessWidget {
  const AddBankAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AddBankAccount');
    final theme = Theme.of(context);
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => WillPopScope(
        onWillPop: () async {
          notifier.nameAccount.clear();
          notifier.noBankAccount.clear();
          notifier.accountOwnerName.clear();
          notifier.messageAddBankError = '';
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${notifier2.translate.addBankAccount}',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomTextFormField(
                  // focusNode: notifier.emailFocus,
                  inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                  inputAreaWidth: SizeConfig.screenWidth!,
                  textEditingController: notifier.nameAccount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  textInputType: TextInputType.text,
                  onChanged: (v) {
                    // notifier.email = v;
                  },
                  inputDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      labelText: notifier2.translate.bankName,
                      labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary, fontSize: 13),
                      prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth())),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                      suffixIcon: Transform.rotate(
                        angle: 90 * pi / 180,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        ),
                      )),
                  readOnly: true,
                  onTap: () => notifier.showButtomSheetAllBankList(context, notifier2.translate, true),
                ),
                sixteenPx,
                CustomTextFormField(
                  // focusNode: notifier.emailFocus,
                  inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                  inputAreaWidth: SizeConfig.screenWidth!,
                  textEditingController: notifier.noBankAccount,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  textInputType: TextInputType.number,
                  onChanged: (v) {
                    notifier.noBank = v;
                  },
                  maxLength: 20,
                  inputDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    labelText: notifier2.translate.noRek,
                    labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary, fontSize: 13),
                    prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth())),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                    counter: Offstage(),
                  ),
                ),
                sixteenPx,
                CustomTextFormField(
                  inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                  inputAreaWidth: SizeConfig.screenWidth!,
                  textEditingController: notifier.accountOwnerName,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  textInputType: TextInputType.text,
                  onChanged: (v) {
                    notifier.accountOwner = v;
                  },
                  inputDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    labelText: notifier2.translate.accountRekName,
                    labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: notifier.messageAddBankError != '' ? kHyppeDanger : Theme.of(context).colorScheme.secondary, fontSize: 13),
                    prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth())),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                  ),
                ),
                sixPx,
                CustomTextWidget(
                  textToDisplay: notifier.messageAddBankError != '' ? notifier.messageAddBankError : notifier2.translate.makeSureTheName ?? '',
                  textStyle: Theme.of(context).textTheme.caption?.copyWith(color: notifier.messageAddBankError != '' ? kHyppeDanger : kHyppeDisabled),
                  textAlign: TextAlign.start,
                  maxLines: 10,
                )
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: kToolbarHeight * 2.5,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline),
                      fourteenPx,
                      SizedBox(
                          width: MediaQuery.of(context).size.width * .85,
                          child: const Text('Dengan melakukan klik tombol dibawah, kamu telah menyetujui Syarat & Ketentuan serta Kebijakan Privasi untuk menambahkan rekening.'))
                    ],
                  ),
                  twentyPx,
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: CustomTextButton(
                      onPressed: notifier.checkSave()
                          ? () {
                              notifier.confirmAddBankAccount(context);
                            }
                          : null,
                      style: ButtonStyle(backgroundColor: notifier.checkSave() ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
                      child: CustomTextWidget(
                        textToDisplay: notifier2.translate.save ?? '',
                        textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
