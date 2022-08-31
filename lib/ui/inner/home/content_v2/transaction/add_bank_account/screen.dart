import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:provider/provider.dart';

class AddBankAccount extends StatelessWidget {
  const AddBankAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TransactionNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: theme.textTheme.subtitle1,
            textToDisplay: '${notifier.language.addBankAccount}',
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
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.onBackground),
                textInputType: TextInputType.text,
                onChanged: (v) {
                  // notifier.email = v;
                },
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  labelText: notifier.language.bankName,
                  labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 13),
                  prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryVariant)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                ),
                readOnly: true,
              ),
              sixteenPx,
              CustomTextFormField(
                // focusNode: notifier.emailFocus,
                inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                inputAreaWidth: SizeConfig.screenWidth!,
                textEditingController: notifier.noBankAccount,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.onBackground),
                textInputType: TextInputType.number,
                onChanged: (v) {
                  // notifier.email = v;
                },
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  labelText: notifier.language.noBankAccount,
                  labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 13),
                  prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryVariant)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                ),
              ),
              sixteenPx,
              CustomTextFormField(
                inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
                inputAreaWidth: SizeConfig.screenWidth!,
                textEditingController: notifier.accountOwnerName,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.onBackground),
                textInputType: TextInputType.text,
                onChanged: (v) {
                  // notifier.email = v;
                },
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  labelText: notifier.language.accountOwnerName,
                  labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 13),
                  prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryVariant)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
                ),
              ),
              sixPx,
              CustomTextWidget(
                textToDisplay: notifier.language.makeSureTheName!,
                textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeDisabled),
                textAlign: TextAlign.start,
                maxLines: 10,
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: () {
              ShowGeneralDialog.generalDialog(
                context,
                titleText: notifier.language.keepSignIn,
                bodyText:
                    "${notifier.language.youWillAdd} ${notifier.nameAccount.text} ${notifier.language.accountWithAccountNumber} ${notifier.noBankAccount.text} ${notifier.language.ownedBy} ${notifier.accountOwnerName.text}",
                maxLineTitle: 1,
                maxLineBody: 10,
                functionPrimary: () {},
                functionSecondary: () {},
                titleButtonPrimary: "${notifier.language.yes}, ${notifier.language.save}",
                titleButtonSecondary: "${notifier.language.cancel}",
              );
            },
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
            child: CustomTextWidget(
              textToDisplay: notifier.language.save!,
              textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
