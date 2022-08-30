import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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
        body: Column(
          children: [
            CustomTextFormField(
              // focusNode: notifier.emailFocus,
              inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
              inputAreaWidth: SizeConfig.screenWidth!,
              textEditingController: notifier.noBankAccount,
              style: Theme.of(context).textTheme.bodyText1,
              textInputType: TextInputType.emailAddress,
              onChanged: (v) {
                // notifier.email = v;
              },
              inputDecoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                labelText: notifier.language.noBankAccount,
                labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: notifier.emailValidator(notifier.emailController.text) != ''
                        ? Theme.of(context).colorScheme.error
                        : notifier.emailFocus.hasFocus
                            ? Theme.of(context).colorScheme.primaryVariant
                            : null),
                prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)),
                prefixIcon: Transform.translate(
                  offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0.0),
                  child: Transform.scale(
                    scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                    child: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                  ),
                ),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: notifier.emailFocus.hasFocus ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).colorScheme.secondary)),
                errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
              ),
              readOnly: notifier.isLoading
                  ? true
                  : notifier.loadingForObject(LoginNotifier.loadingForgotPasswordKey)
                      ? true
                      : false,
              // validator: (v) {
              //   if (notifier.emailValidator(v!) == '') {
              //     return 'asdasd';
              //   } else {
              //     return null;
              //   }
              // },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: () {},
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
            child: CustomTextWidget(
              textToDisplay: notifier.language.addBankAccount!,
              textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
