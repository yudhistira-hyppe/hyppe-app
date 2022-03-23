import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextInputChangePassword extends StatefulWidget {
  @override
  _TextInputChangePasswordState createState() => _TextInputChangePasswordState();
}

class _TextInputChangePasswordState extends State<TextInputChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChangePasswordNotifier>(
      builder: (_, notifier, __) => Container(
        height: SizeConfig.screenHeight! * 0.35,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomTextFormField(
              style: notifier.text(context),
              readOnly: false,
              onChanged: (v) {},
              obscuringCharacter: '*',
              textAlign: TextAlign.left,
              textInputType: TextInputType.text,
              textEditingController: notifier.currentPasswordController,
              inputDecoration: InputDecoration(
                hintText: notifier.language.currentPassword,
                labelText: notifier.language.typeYourCurrentPassword,
                hintStyle: notifier.hint(context),
                labelStyle: notifier.label(context),
                suffixIcon: CustomTextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      overlayColor: MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () => setState(() => notifier.obscureCurrentPassword = !notifier.obscureCurrentPassword),
                  child: CustomIconWidget(iconData: "${AssetPath.vectorPath}${notifier.obscureCurrentPassword ? "eye-off" : "eye"}.svg"),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: notifier.currentPasswordController.text.isEmpty ? Theme.of(context).iconTheme.color! : kHyppePrimary, width: 1)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kHyppePrimary, width: 1)),
                contentPadding: const EdgeInsets.only(bottom: 2),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              inputAreaWidth: SizeConfig.screenWidth!,
              obscureText: notifier.obscureCurrentPassword,
              inputAreaHeight: 75.0 * SizeConfig.scaleDiagonal,
            ),
            CustomTextFormField(
              style: notifier.text(context),
              readOnly: false,
              onChanged: (v) {},
              obscuringCharacter: '*',
              textAlign: TextAlign.left,
              textInputType: TextInputType.text,
              textEditingController: notifier.newPasswordController,
              inputDecoration: InputDecoration(
                hintText: notifier.language.password,
                labelText: notifier.language.typeYourNewPassword,
                hintStyle: notifier.hint(context),
                labelStyle: notifier.label(context),
                suffixIcon: CustomTextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      overlayColor: MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () => setState(() => notifier.obscureNewPassword = !notifier.obscureNewPassword),
                  child: CustomIconWidget(iconData: "${AssetPath.vectorPath}${notifier.obscureNewPassword ? "eye-off" : "eye"}.svg"),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: notifier.newPasswordController.text.isEmpty ? Theme.of(context).iconTheme.color! : kHyppePrimary, width: 1)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kHyppePrimary, width: 1)),
                contentPadding: const EdgeInsets.only(bottom: 2),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              inputAreaWidth: SizeConfig.screenWidth!,
              obscureText: notifier.obscureNewPassword,
              inputAreaHeight: 75.0 * SizeConfig.scaleDiagonal,
            ),
            CustomTextFormField(
              style: notifier.text(context),
              readOnly: false,
              onChanged: (v) {},
              obscuringCharacter: '*',
              textAlign: TextAlign.left,
              textInputType: TextInputType.text,
              textEditingController: notifier.reTypePasswordController,
              inputDecoration: InputDecoration(
                hintText: notifier.language.password,
                labelText: notifier.language.retypeYourNewPassword,
                hintStyle: notifier.hint(context),
                labelStyle: notifier.label(context),
                suffixIcon: CustomTextButton(
                  style: ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      overlayColor: MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () => setState(() => notifier.obscureReTypePassword = !notifier.obscureReTypePassword),
                  child: CustomIconWidget(iconData: "${AssetPath.vectorPath}${notifier.obscureReTypePassword ? "eye-off" : "eye"}.svg"),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: notifier.reTypePasswordController.text.isEmpty ? Theme.of(context).iconTheme.color! : kHyppePrimary, width: 1)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kHyppePrimary, width: 1)),
                contentPadding: const EdgeInsets.only(bottom: 2),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              inputAreaWidth: SizeConfig.screenWidth!,
              obscureText: notifier.obscureReTypePassword,
              inputAreaHeight: 75.0 * SizeConfig.scaleDiagonal,
            )
          ],
        ),
      ),
    );
  }
}
