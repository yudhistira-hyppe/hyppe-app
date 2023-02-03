import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/forgot_password/widget/forgot_password_title.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  void initState() {
    final notifier = Provider.of<ForgotPasswordNotifier>(context, listen: false);
    notifier.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    SizeConfig().init(context);
    return Consumer<ForgotPasswordNotifier>(
      builder: (context, notifier, child) => KeyboardDisposal(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: () async {
            if (context.read<ForgotPasswordNotifier>().isLoading) {
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: CustomIconButtonWidget(
                color: Theme.of(context).iconTheme.color,
                onPressed: () => Navigator.pop(context),
                iconData: '${AssetPath.vectorPath}back-arrow.svg',
              ),
              title: CustomTextWidget(
                textToDisplay: notifier.language.reset ?? '',
                textStyle: style.bodyText1?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  ForgotPasswordTitle(
                    title: notifier.language.forgotPassword ?? '',
                    subtitle: notifier.language.wellEmailYourCodeToResetYourPassword ?? '',
                  ),
                  Align(
                    alignment: const Alignment(0, -0.3),
                    child: CustomTextFormField(
                      focusNode: notifier.focusNode,
                      inputAreaHeight: (notifier.invalidEmail != null ? 70 : 55) * SizeConfig.scaleDiagonal,
                      inputAreaWidth: SizeConfig.screenWidth!,
                      textEditingController: notifier.emailController,
                      style: Theme.of(context).textTheme.bodyText1,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (v){
                        notifier.text = v;
                        if(System().validateEmail(v)){
                          notifier.invalidEmail = null;
                        }else{
                          if(v.isNotEmpty){
                            notifier.invalidEmail = notifier.language.messageInvalidEmail;
                          }else{
                            notifier.invalidEmail = null;
                          }
                        }
                      },
                      inputDecoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, bottom: (notifier.invalidEmail != null) ? 0 : 16, right: 16),
                        labelText: notifier.language.email ?? '',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(color: notifier.focusNode.hasFocus || notifier.emailController.text.isNotEmpty ? Theme.of(context).colorScheme.primaryVariant : null),
                        prefixIconConstraints: BoxConstraints(minWidth: SizeWidget().calculateSize(30.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth())),
                        prefixIcon: Transform.translate(
                          offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()), 0.0),
                          child: Transform.scale(
                            scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                            child: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: notifier.focusNode.hasFocus || notifier.emailController.text.isNotEmpty
                                    ? Theme.of(context).colorScheme.primaryVariant
                                    : Theme.of(context).colorScheme.secondaryVariant)),
                        suffixIcon: notifier.emailSuffixIcon(),
                        errorText: notifier.invalidEmail,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.95),
                    child: SafeArea(
                      child: CustomElevatedButton(
                        height: 50,
                        width: SizeConfig.screenWidth,
                        buttonStyle: ButtonStyle(
                          shadowColor: MaterialStateProperty.all<Color>(notifier.emailNextButtonColor(context)),
                          overlayColor: MaterialStateProperty.all<Color>(notifier.emailNextButtonColor(context)),
                          foregroundColor: MaterialStateProperty.all<Color>(notifier.emailNextButtonColor(context)),
                          backgroundColor: MaterialStateProperty.all<Color>(notifier.emailNextButtonColor(context)),
                        ),
                        function: () => notifier.onClickForgotPassword(context),
                        child: notifier.isLoading
                            ? const CustomLoading()
                            : CustomTextWidget(
                                textToDisplay: notifier.language.reset ?? '',
                                textStyle: notifier.emailNextTextColor(context),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
