import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PermanentlyDeniedPermissionContent extends StatelessWidget {
  final String permissions;
  const PermanentlyDeniedPermissionContent(
      {Key? key, required this.permissions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => CupertinoAlertDialog(
        content: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.bodyLarge,
            textToDisplay:
                notifier.translate.hyppeDoesNotHaveAccessToYourPermission ??
                    '' + ' ' + permissions,
            textOverflow: TextOverflow.visible),
        actions: [
          CustomTextButton(
            onPressed: () => Routing().moveBack(),
            child: CustomTextWidget(
              textStyle: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.apply(color: Theme.of(context).colorScheme.primary),
              textToDisplay: notifier.translate.cancel ?? 'Cancel',
            ),
          ),
          CustomTextButton(
            onPressed: () async {
              await System()
                  .openSetting()
                  .whenComplete(() => Routing().moveBack());
            },
            child: CustomTextWidget(
              textStyle: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.apply(color: Theme.of(context).colorScheme.primary),
              textToDisplay: notifier.translate.settings ?? 'Settings',
            ),
          )
        ],
      ),
    );
  }
}
