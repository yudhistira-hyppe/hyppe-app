import 'dart:io';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OldVersionDialog extends StatelessWidget {
  OldVersionDialog({Key? key}) : super(key: key);

  final _routing = Routing();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final _language = context.watch<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0)),
      height: 183,
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTextWidget(
            textToDisplay: '${_language.newUpdate}',
            textStyle: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          CustomTextWidget(
            // maxLines: 2,
            textOverflow: TextOverflow.visible,
            textToDisplay: '${_language.contentNewUpdate} ',
            textStyle: theme.textTheme.bodyLarge,
          ),
          _buildButton(
            caption: '${_language.updateNow} ',
            color: theme.colorScheme.primary,
            textColor: kHyppeLightButtonText,
            function: () => _routing.moveBack(),
            theme: theme,
          )
        ],
      ),
    );
  }

  Widget _buildButton(
      {required ThemeData theme,
      required String caption,
      required Function function,
      required Color color,
      Color? textColor}) {
    return CustomElevatedButton(
      child: CustomTextWidget(
          textToDisplay: caption,
          textStyle: theme.textTheme.labelLarge?.copyWith(color: textColor)),
      width: 220,
      height: 42,
      function: () async {
        if (Platform.isAndroid || Platform.isIOS) {
          final appId =
              Platform.isAndroid ? 'com.hyppe.hyppeapp' : 'id1545595684';
          final url = Uri.parse(
            // Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
            Platform.isAndroid
                ? "https://play.google.com/store/apps/details?id=$appId"
                : "https://apps.apple.com/app/id$appId",
          );
          print(url);

          launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      buttonStyle: theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }
}
